//
//  MainMenuView.swift
//  AlphaWord
//
//  A minimal starter screen so the project builds cleanly.
//

import SwiftUI

struct MainMenuView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text("AlphaWord")
                    .font(.largeTitle).bold()
                Text("SwiftUI Starter")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                NavigationLink("Start Game") {
                    Text("Game Screen Placeholder")
                        .font(.title)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
    }
}

#Preview {
    MainMenuView()
}
