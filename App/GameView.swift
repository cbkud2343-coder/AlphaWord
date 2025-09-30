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
            HStack {
                Label("\(secondsLeft)s", systemImage: "timer").font(.headline)
                Spacer()
                Label("\(score)", systemImage: "star.fill").font(.headline)
            }

            Spacer(minLength: 8)

            Text("Round \(round) / \(maxRounds)")
                .font(.headline)

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
        .padding(20)
        .onAppear { resetRound(word: currentWord) }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .inactive || newPhase == .background { isRunning = false }
        }
        .task { await tickTimer() }
        .navigationBarBackButtonHidden(true)
        // ✅ iOS 15–safe: no toolbar; use navigationBarItems
        .navigationBarItems(leading:
            Button("Quit") { endGame() }
        )
        .sheet(isPresented: $showSummary) {
            SummaryView(score: score) { dismiss() }
        }
    }

    private func resetRound(word: String) {
        currentWord = word
        shuffled = Array(word.uppercased()).shuffled()
        guess = []
        usedIndices.removeAll()
    }
    private func shuffleTiles() { shuffled.shuffle(); usedIndices
