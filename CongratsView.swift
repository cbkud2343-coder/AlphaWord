import SwiftUI

struct CongratsView: View {
    let letter: String
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            Text("🎉 Congratulations!")
                .font(.largeTitle.bold())
            
            Text("You finished the letter "\(letter)".")
                .foregroundStyle(.secondary)
            
            Button("Continue to next letter") { 
                onContinue() 
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(Pastel.bg)
    }
}
