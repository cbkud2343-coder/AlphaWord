import SwiftUI

struct MainMenuView: View {
    @StateObject private var core = GameCore()
    @State private var showLB = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("AlphaWord")
                    .font(.system(size: 42, weight: .heavy, design: .rounded))
                    .foregroundStyle(Pastel.text)

                Text("5×5 pastel word grids — A → Z")
                    .foregroundStyle(.secondary)

                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Pastel.tile)
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Pastel.tileStroke, lineWidth: 1)
                    
                    VStack(spacing: 10) {
                        Text("Current Letter")
                            .font(.headline)
                        Text(core.currentLetter)
                            .font(.system(size: 80, weight: .black, design: .rounded))
                        if let best = core.progress.bestTimes[core.progress.currentIndex] {
                            Text("Best time: \(format(best))")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(16)
                }
                .frame(height: 200)

                NavigationLink("Play") {
                    GameView()
                        .environmentObject(core)
                }
                .buttonStyle(.borderedProminent)

                Button("Reset progress", role: .destructive) { 
                    core.resetProgress() 
                }

                Spacer()
            }
            .padding()
            .background(Pastel.bg.ignoresSafeArea())
            .navigationTitle("Menu")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if let top = UIApplication.shared.topMostViewController() {
                            GCManager.shared.presentLeaderboard(
                                from: top, 
                                letterIndex: core.progress.currentIndex
                            )
                        }
                    } label: { 
                        Image(systemName: "trophy") 
                    }
                }
            }
        }
    }

    private func format(_ t: TimeInterval) -> String {
        let s = Int(t) % 60
        let m = Int(t) / 60
        let ms = Int((t - floor(t)) * 100)
        return String(format: "%02d:%02d.%02d", m, s, ms)
    }
}
