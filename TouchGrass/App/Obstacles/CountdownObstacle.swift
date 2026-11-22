import SwiftUI

struct CountdownObstacle: View {
    let seconds: Int
    var onComplete: () -> Void
    @State private var remaining: Int

    init(seconds: Int, onComplete: @escaping () -> Void) {
        self.seconds = seconds
        self.onComplete = onComplete
        _remaining = State(initialValue: seconds)
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("\(remaining)")
                .font(.system(size: 96, weight: .bold, design: .rounded))
                .monospacedDigit()
                .contentTransition(.numericText())
                .foregroundStyle(Color.tgForest)
            Text(remaining > 0 ? "Take a breath. Do you really need this app right now?" : "Okay, you waited.")
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.tgMuted)
            if remaining == 0 {
                Button("Continue", action: onComplete)
                    .buttonStyle(TGPrimaryButtonStyle())
            }
        }
        .task {
            while remaining > 0 {
                try? await Task.sleep(for: .seconds(1))
                if Task.isCancelled { return }
                withAnimation { remaining -= 1 }
            }
        }
    }
}
