import Foundation
import SwiftUI
import GameKit

// MARK: - Game Center (simple helper)
final class GCManager: NSObject, ObservableObject, GKGameCenterControllerDelegate {
    static let shared = GCManager()
    @Published var isAuthenticated = false

    func authenticate() {
        GKLocalPlayer.local.authenticateHandler = { vc, error in
            DispatchQueue.main.async {
                if let vc = vc {
                    UIApplication.shared.topMostViewController()?.present(vc, animated: true)
                }
                self.isAuthenticated = GKLocalPlayer.local.isAuthenticated
                if let error = error {
                    print("GC auth error:", error.localizedDescription)
                }
            }
        }
    }

    func submit(seconds: TimeInterval, for letterIndex: Int) {
        guard GKLocalPlayer.local.isAuthenticated else { return }
        let leaderboardID = "alphaword.letter.\(letterIndex).time" // Create these in App Store Connect
        let score = GKScore(leaderboardIdentifier: leaderboardID)
        // Lower is better: Game Center sorts DESC by default; invert by submitting milliseconds negative.
        let ms = Int(seconds * 1000)
        score.value = Int64(-ms)
        GKScore.report([score]) { err in
            if let err = err {
                print("Submit error:", err.localizedDescription)
            }
        }
    }

    func presentLeaderboard(from vc: UIViewController, letterIndex: Int) {
        let gcVC = GKGameCenterViewController(leaderboardID: "alphaword.letter.\(letterIndex).time", playerScope: .global, timeScope: .allTime)
        gcVC.gameCenterDelegate = self
        vc.present(gcVC, animated: true)
    }

    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }
}

// MARK: - Core game state
final class GameCore: ObservableObject {
    @AppStorage("progress") private var progressData: Data = Data()
    @Published var progress: GameProgress = .init()

    @Published var currentRows: [RowSpec] = []
    @Published var inputs: [String] = Array(repeating: "", count: 5)
    @Published var checks:  [Bool]   = Array(repeating: false, count: 5)
    @Published var levelLocked: Bool = false
    @Published var showCongrats: Bool = false

    // timer
    @Published var elapsed: TimeInterval = 0
    private var startTime: Date?
    private var timer: Timer?

    var currentLetter: String { 
        guard progress.currentIndex >= 0 && progress.currentIndex < Alpha.letters.count else { return "A" }
        return Alpha.letters[progress.currentIndex]
    }

    init() {
        if let decoded = try? JSONDecoder().decode(GameProgress.self, from: progressData), 
           decoded.currentIndex >= 0 && decoded.currentIndex < 26 {
            progress = decoded
        }
        loadLevel()
        GCManager.shared.authenticate()
    }

    func loadLevel() {
        inputs = .init(repeating: "", count: 5)
        checks = .init(repeating: false, count: 5)
        levelLocked = false

        guard progress.currentIndex >= 0 && progress.currentIndex < 26,
              let letter = Alpha.letters[safe: progress.currentIndex]
        else { 
            levelLocked = true 
            currentRows = []
            return 
        }

        var rows = WordBank.rows(for: progress.currentIndex) ?? []
        
        // Dynamic word fixes for problematic letters
        if letter == "Q" {
            rows = [
                .init(lockedLetter: "Q", lockedPosition: 1, answer: "QUILL", hint: "Feather pen."),
                .init(lockedLetter: "Q", lockedPosition: 2, answer: "EQUAL", hint: "Same as."),
                .init(lockedLetter: "Q", lockedPosition: 3, answer: "SQUID", hint: "Ocean creature."),
                .init(lockedLetter: "Q", lockedPosition: 4, answer: "QUART", hint: "Liquid measure."),
                .init(lockedLetter: "Q", lockedPosition: 4, answer: "SQUAD", hint: "Small team.")
            ]
        }
        if letter == "U" {
            rows = [
                .init(lockedLetter: "U", lockedPosition: 1, answer: "ULTRA", hint: "Beyond normal."),
                .init(lockedLetter: "U", lockedPosition: 2, answer: "AUDIO", hint: "Sound."),
                .init(lockedLetter: "U", lockedPosition: 3, answer: "SAUCE", hint: "Gravy."),
                .init(lockedLetter: "U", lockedPosition: 4, answer: "THUMB", hint: "Digit."),
                .init(lockedLetter: "U", lockedPosition: 5, answer: "DATUM", hint: "Data point.")
            ]
        }
        if letter == "W" {
            rows = [
                .init(lockedLetter: "W", lockedPosition: 1, answer: "WATER", hint: "H2O."),
                .init(lockedLetter: "W", lockedPosition: 2, answer: "AWAKE", hint: "Not asleep."),
                .init(lockedLetter: "W", lockedPosition: 3, answer: "BOWER", hint: "Garden shelter."),
                .init(lockedLetter: "W", lockedPosition: 4, answer: "STRAW", hint: "Sipper."),
                .init(lockedLetter: "W", lockedPosition: 5, answer: "SCREW", hint: "Fastener.")
            ]
        }

        currentRows = rows
        startTimer()
    }

    // MARK: Timer
    private func startTimer() {
        timer?.invalidate()
        elapsed = 0
        startTime = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self, let start = self.startTime else { return }
            self.elapsed = Date().timeIntervalSince(start)
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func saveProgress() {
        if let data = try? JSONEncoder().encode(progress) {
            progressData = data
        }
    }

    // MARK: Input editing via custom keyboard
    func insert(letter: Character, row i: Int) {
        guard i >= 0 && i < 5, !levelLocked else { return }
        var text = inputs[i].uppercased()
        if text.count < 5 {
            text.append(letter)
            inputs[i] = text
        }
    }
    
    func backspace(row i: Int) {
        guard i >= 0 && i < 5 else { return }
        var text = inputs[i]
        if !text.isEmpty {
            text.removeLast()
            inputs[i] = text
        }
    }

    // Check one row
    func submit(row i: Int) {
        guard i >= 0 && i < 5, !levelLocked, i < currentRows.count else { return }
        let row = currentRows[i]
        let letter = currentLetter
        let guess = inputs[i].uppercased()
        let requiredCol = lockedColumn(for: letter, rowIndex: i)

        guard guess.count == 5 else { 
            checks[i] = false
            return 
        }
        
        guard requiredCol >= 1 && requiredCol <= 5 else {
            checks[i] = false
            return
        }
        
        let idx = guess.index(guess.startIndex, offsetBy: requiredCol - 1)
        guard guess[idx] == Character(row.lockedLetter.uppercased()) else { 
            checks[i] = false
            return 
        }

        checks[i] = (guess == row.answer.uppercased())
        
        if checks.allSatisfy({ $0 }) {
            stopTimer()
            // Save best time
            let t = elapsed
            if let best = progress.bestTimes[progress.currentIndex] {
                progress.bestTimes[progress.currentIndex] = min(best, t)
            } else {
                progress.bestTimes[progress.currentIndex] = t
            }
            saveProgress()
            // Submit to Game Center
            GCManager.shared.submit(seconds: t, for: progress.currentIndex)
            showCongrats = true
        }
    }

    func nextLetter() {
        if progress.currentIndex < 25 {
            progress.currentIndex += 1
        } else {
            progress.currentIndex = 0
        }
        saveProgress()
        loadLevel()
    }

    func resetProgress() {
        progress = .init()
        saveProgress()
        loadLevel()
    }
}

// Helpers
extension Array {
    subscript(safe i: Int) -> Element? { 
        return (indices ~= i) ? self[i] : nil 
    }
}

extension UIApplication {
    func topMostViewController(base: UIViewController? = nil) -> UIViewController? {
        let base = base ?? connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?.rootViewController
        
        if let nav = base as? UINavigationController {
            return topMostViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return topMostViewController(base: tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return topMostViewController(base: presented)
        }
        return base
    }
}
