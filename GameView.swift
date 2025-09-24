import SwiftUI

struct GameView: View {
    @EnvironmentObject var core: GameCore
    @State private var activeRow: Int = 0
    @State private var shakeFlags: [Bool] = Array(repeating: false, count: 5)

    var body: some View {
        VStack(spacing: 12) {
            header

            gridHeader
            ForEach(0..<5, id: \.self) { i in
                RowView(
                    letter: core.currentLetter,
                    rowIndex: i,
                    spec: core.currentRows[safe: i],
                    text: core.inputs[safe: i] ?? "",
                    isActive: activeRow == i,
                    isCorrect: core.checks[safe: i] ?? false,
                    shake: shakeFlags[i]
                )
                .onTapGesture { activeRow = i }
            }

            HStack {
                Label("Timer", systemImage: "timer")
                Text(format(core.elapsed))
                    .font(.title3.monospacedDigit())
                Spacer()
                Text(nextHint)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .padding(.top, 6)

            Spacer(minLength: 6)

            KeyboardView(
                onKey: { ch in core.insert(letter: ch, row: activeRow) },
                onDel: { core.backspace(row: activeRow) },
                onSubmit: {
                    core.submit(row: activeRow)
                    if !(core.checks[safe: activeRow] ?? false) {
                        shakeFlags[activeRow] = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { 
                            shakeFlags[activeRow] = false 
                        }
                    } else {
                        activeRow = min(activeRow + 1, 4)
                    }
                }
            )
        }
        .padding()
        .background(Pastel.bg.ignoresSafeArea())
        .navigationTitle("Letter \(core.currentLetter)")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $core.showCongrats) {
            CongratsView(letter: core.currentLetter) {
                core.showCongrats = false
                core.nextLetter()
                activeRow = 0
            }
            .presentationDetents([.height(260)])
        }
    }

    private var header: some View {
        HStack {
            Text("Solve 5 words").font(.headline)
            Spacer()
            Button("Check All") {
                for i in 0..<5 { 
                    core.submit(row: i) 
                }
            }
            .buttonStyle(.bordered)
            .disabled(core.levelLocked)
        }
    }

    private var gridHeader: some View {
        HStack(spacing: 8) {
            ForEach(1...5, id: \.self) { col in
                Text("\(col)")
                    .font(.caption)
                    .frame(maxWidth: .infinity)
                    .padding(6)
                    .background(Pastel.accent.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }

    private var nextHint: String {
        guard let idx = (0..<5).first(where: { !(core.checks[safe: $0] ?? true) }),
              let spec = core.currentRows[safe: idx] else { 
            return "All solved! 🎉" 
        }
        return "Hint: \(spec.hint)"
    }

    private func format(_ t: TimeInterval) -> String {
        let s = Int(t) % 60
        let m = Int(t) / 60
        let ms = Int((t - floor(t)) * 100)
        return String(format: "%02d:%02d.%02d", m, s, ms)
    }
}

private struct RowView: View {
    let letter: String
    let rowIndex: Int
    let spec: RowSpec?
    let text: String
    let isActive: Bool
    let isCorrect: Bool
    let shake: Bool

    var lockedCol: Int { 
        lockedColumn(for: letter, rowIndex: rowIndex) 
    }

    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...5, id: \.self) { col in
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isCorrect ? Pastel.success.opacity(0.35) : Pastel.tile)
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Pastel.tileStroke, lineWidth: 1)

                    Text(char(at: col))
                        .font(.system(
                            size: 20, 
                            weight: (col == lockedCol) ? .heavy : .semibold, 
                            design: .rounded
                        ))
                        .foregroundStyle(Pastel.text)
                }
                .frame(height: 48)
                .modifier(Shake(animatableData: CGFloat(shake ? 1 : 0)))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isActive ? Pastel.accent : .clear, lineWidth: 2)
                )
            }
            Image(systemName: isCorrect ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isCorrect ? .green : .secondary.opacity(0.5))
                .imageScale(.large)
                .frame(width: 28)
        }
        .opacity(spec == nil ? 0.4 : 1)
    }

    private func char(at col: Int) -> String {
        guard let spec = spec else { return " " }
        if col == lockedCol { 
            return String(spec.lockedLetter).uppercased() 
        }
        let t = text.uppercased()
        guard t.count >= col else { return " " }
        let idx = t.index(t.startIndex, offsetBy: col - 1)
        return String(t[idx])
    }
}

private struct Shake: GeometryEffect {
    var amplitude: CGFloat = 8
    var shakesPerUnit: CGFloat = 3
    var animatableData: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        let tx = amplitude * sin(animatableData * .pi * shakesPerUnit)
        return ProjectionTransform(CGAffineTransform(translationX: tx, y: 0))
    }
}

// Bottom keyboard
struct KeyboardView: View {
    let onKey: (Character) -> Void
    let onDel: () -> Void
    let onSubmit: () -> Void

    private let rows: [String] = [
        "QWERTYUIOP",
        "ASDFGHJKL",
        "ZXCVBNM"
    ]

    var body: some View {
        VStack(spacing: 8) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: 6) {
                    ForEach(Array(row), id: \.self) { ch in
                        key(title: String(ch)) { onKey(ch) }
                    }
                }
            }
            HStack(spacing: 8) {
                Button(action: onDel) {
                    Label("Delete", systemImage: "delete.left")
                        .labelStyle(.titleAndIcon)
                        .font(.subheadline)
                }
                .buttonStyle(.bordered)

                Button(action: onSubmit) {
                    Label("Submit", systemImage: "checkmark")
                        .labelStyle(.titleAndIcon)
                        .font(.subheadline)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(10)
        .background(Pastel.tile.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func key(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(width: 32, height: 42)
                .background(Pastel.accent.opacity(0.55))
                .foregroundStyle(Pastel.text)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}
