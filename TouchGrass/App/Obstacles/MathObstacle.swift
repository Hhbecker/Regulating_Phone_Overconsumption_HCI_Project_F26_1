import SwiftUI

struct MathObstacle: View {
    var onComplete: () -> Void
    @State private var a = Int.random(in: 12...29)
    @State private var b = Int.random(in: 3...9)
    @State private var c = Int.random(in: 10...99)
    @State private var answer = ""
    @State private var wrong = false
    @FocusState private var focused: Bool

    var body: some View {
        VStack(spacing: 16) {
            Text("\(a) × \(b) + \(c) = ?")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(Color.tgInk)
            TextField("Your answer", text: $answer)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .font(.title)
                .padding()
                .background(Color.tgCard, in: RoundedRectangle(cornerRadius: 16))
                .focused($focused)
            if wrong {
                Text("Not quite. Here’s a new one.")
                    .foregroundStyle(.red)
            }
            Button("Check", action: check)
                .buttonStyle(TGPrimaryButtonStyle())
                .disabled(answer.isEmpty)
        }
        .onAppear { focused = true }
    }

    private func check() {
        if Int(answer) == a * b + c {
            onComplete()
        } else {
            wrong = true
            answer = ""
            a = Int.random(in: 12...29)
            b = Int.random(in: 3...9)
            c = Int.random(in: 10...99)
        }
    }
}
