import SwiftUI

struct GameView: View {
    @State private var currentWord: String = WordBank.randomWord()
    @State private var shuffled: [Character] = []
    @State private var guess: [Character] = []
    @State private var usedIndices: Set<Int> = []
    @State private var score: Int = 0
    @State private var secondsLeft: Int = 60
    @State private var round: Int = 1
    @State private var isRunning: Bool = true
    @State private var showSummary: Bool = false

    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dismiss) private var dismiss

    private let maxRounds = 5
    private let tileSize: CGFloat = 56

    var body: some View {
        VStack(spacing: 16) {
            header
            Spacer(minLength: 8)

            Text("Round \(round) / \(maxRounds)")
                .font(.headline)

            // Target slots
            HStack(spacing: 8) {
                ForEach(0..<currentWord.count, id: \.self) { i in
                    let letter: String = i < guess.count ? String(guess[i]) : ""
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(.secondary, lineWidth: 1)
                            .frame(width: tileSize, height: tileSize)
                        Text(letter.uppercased())
                            .font(.title2).bold()
                    }
                }
            }
            .padding(.vertical, 8)

            // Letter tiles
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 6), spacing: 8) {
                ForEach(Array(shuffled.enumerated()), id: \.offset) { idx, ch in
                    Button {
                        tapTile(index: idx, char: ch)
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(usedIndices.contains(idx) ? Color.gray.opacity(0.25) : Color.gray.opacity(0.12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(.secondary.opacity(0.6), lineWidth: 1)
                                )
                                .frame(height: tileSize)
                            Text(String(ch).uppercased())
                                .font(.title3).bold()
                        }
                    }
                    .disabled(usedIndices.contains(idx) || !isRunning)
                }
            }
            .padding(.top, 8)

            controls
        }
        .padding(20)
        .onAppear { resetRound(word: currentWord) }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .inactive || newPhase == .background {
                isRunning = false
            }
        }
        .task { await tickTimer() }
        .navigationBarBackButtonHidden(true)
        // iOS 15: make the toolbar overload explicit to avoid ambiguity
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Quit") { endGame() }
            }
        })
        // Plain .sheet (no .presentationDetents, which is iOS 16+)
        .sheet(isPresented: $showSummary) {
            SummaryView(score: score) {
                dismiss()
            }
        }
    }

    // MARK: - Subviews
    private var header: some View {
        HStack {
            Label("\(secondsLeft)s", systemImage: "timer").font(.headline)
            Spacer()
            Label("\(score)", systemImage: "star.fill").font(.headline)
        }
    }

    private var controls: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Button { backspace() } label: {
                    Label("Back", systemImage: "delete.left").frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button { shuffleTiles() } label: {
                    Label("Shuffle", systemImage: "arrow.triangle.2.circlepath").frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button { submitGuess() } label: {
                    Label("Submit", systemImage: "checkmark.circle.fill").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(guess.count != currentWord.count || !isRunning)
            }

            if !isRunning && secondsLeft > 0 {
                Button { isRunning = true } label: {
                    Label("Resume", systemImage: "play.fill").frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Logic
    private func resetRound(word: String) {
        currentWord = word
        shuffled = Array(word.uppercased()).shuffled()
        guess = []
        usedIndices.removeAll()
    }

    private func shuffleTiles() {
        shuffled.shuffle()
        usedIndices = []
        guess = []
    }

    private func tapTile(index: Int, char: Character) {
        guard isRunning, !usedIndices.contains(index) else { return }
        guess.append(char)
        usedIndices.insert(index)
    }

    private func backspace() {
        guard !guess.isEmpty else { return }
        _ = guess.removeLast()
        usedIndices = []
        var remaining = guess
        for (i, ch) in shuffled.enumerated() {
            if let pos = remaining.firstIndex(of: ch) {
                remaining.remove(at: pos)
                usedIndices.insert(i)
            }
        }
    }

    private func submitGuess() {
        guard guess.count == currentWord.count else { return }
        let made = String(guess).uppercased()
        if made == currentWord.uppercased() {
            score += 10 + max(0, secondsLeft / 5)
            nextRound()
        } else {
            score = max(0, score - 2)
        }
    }

    private func nextRound() {
        if round >= maxRounds {
            endGame()
            return
        }
        round += 1
        resetRound(word: WordBank.randomWord())
    }

    private func endGame() {
        isRunning = false
        HighScores.shared.register(score: score)
        showSummary = true
    }

    private func tickSleep() async {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
    }

    private func tickTimer() async {
        while secondsLeft > 0 {
            guard isRunning else { try? await Task.sleep(nanoseconds: 250_000_000); continue }
            await tickSleep()
            if !isRunning { continue }
            secondsLeft -= 1
            if secondsLeft == 0 { endGame() }
        }
    }
}

struct SummaryView: View {
    let score: Int
    let onDone: () -> Void
    var body: some View {
        VStack(spacing: 16) {
            Text("Round Over").font(.title).bold()
            Text("Score: \(score)").font(.title2)
            if let best = HighScores.shared.bestScore {
                Text("Best: \(best)").foregroundStyle(.secondary)
            }
            Button {
                onDone()
            } label: {
                Label("Back to Menu", systemImage: "chevron.left.circle.fill")
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 12)
        }
        .padding(24)
    }
}

struct HowToPlayView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("How to Play").font(.title).bold()
                Text("""
Unscramble the letters to form the hidden word.
- Tap tiles to build your guess.
- Use **Back** to delete a letter, **Shuffle** to reshuffle tiles.
- Hit **Submit** when your guess matches the word.
You have **60 seconds** to score as much as possible across 5 rounds. Good luck!
""")
            }
            .padding(20)
        }
        .navigationBarTitle("How to Play", displayMode: .inline)
    }
}

struct SettingsView: View {
    @AppStorage("AlphaWord.soundOn") private var soundOn: Bool = true
    var body: some View {
        Form {
            Toggle("Sound Effects", isOn: $soundOn)
            NavigationLink("Reset High Score") {
                ResetHighScoreView()
            }
        }
        .navigationBarTitle("Settings", displayMode: .inline)
    }
}

struct ResetHighScoreView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Reset High Score?").font(.headline)
            Text("This cannot be undone.")
                .foregroundStyle(.secondary)
            HStack {
                Button("Cancel") { }
                    .buttonStyle(.bordered)
                Button("Reset") { HighScores.shared.reset() }
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(20)
    }
}

enum WordBank {
    static let words: [String] = [
        "SWIFT","APPLE","CODE","DEBUG","MOBILE",
        "STACK","CLICK","BUILD","XCODE","ALPHA"
    ]
    static func randomWord() -> String { words.randomElement() ?? "SWIFT" }
}

final class HighScores {
    static let shared = HighScores()
    private let bestKey = "AlphaWord.bestScore"
    private init() {}
    var bestScore: Int? {
        let s = UserDefaults.standard.integer(forKey: bestKey)
        return s == 0 ? nil : s
    }
    func register(score: Int) {
        let prev = bestScore ?? 0
        if score > prev { UserDefaults.standard.set(score, forKey: bestKey) }
    }
    func reset() { UserDefaults.standard.removeObject(forKey: bestKey) }
}
