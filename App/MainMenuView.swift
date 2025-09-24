import SwiftUI

struct MainMenuView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("AlphaWord").font(.system(size: 42, weight: .heavy, design: .rounded))
            Text("Hello from Codemagic build").foregroundStyle(.secondary)
        }.padding()
    }
}
