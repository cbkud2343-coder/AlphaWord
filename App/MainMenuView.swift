import SwiftUI

struct MainMenuView: View {
    var body: some View {
        // iOS 15 compatible (use NavigationView, not NavigationStack)
        NavigationView {
            VStack(spacing: 24) {
                Text("AlphaWord")
                    .font(.largeTitle).bold()
                Text("Fast, simple word challenge")
                    .foregroundStyle(.secondary)

                NavigationLink {
                    GameView()
                } label: {
                    Label("Play", systemImage: "play.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                NavigationLink {
                    HowToPlayView()
                } label: {
                    Label("How to Play", systemImage: "questionmark.circle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                NavigationLink {
                    SettingsView()
                } label: {
                    Label("Settings", systemImage: "gearshape")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                if let best = HighScores.shared.bestScore {
                    Text("Best: \(best) pts")
                        .font(.subheadline)
                        .padding(.top, 8)
                }

                Spacer()
            }
            .padding(24)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    MainMenuView()
}
