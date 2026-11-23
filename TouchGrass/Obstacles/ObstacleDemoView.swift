import SwiftUI

/// Placeholder so the menu rows have somewhere to go.
/// Replace the body with one real view per obstacle
/// (timer, puzzle, math, steps, grayscale).
struct ObstacleDemoView: View {
    let obstacle: Obstacle

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                BackButton()
                Spacer()
            }

            Spacer()

            VStack(spacing: 12) {
                Image(systemName: obstacle.symbol)
                    .font(.system(size: 44))
                    .foregroundStyle(Color.tgForest)
                Text(obstacle.title)
                    .font(.system(size: 28, weight: .bold))
                Text(obstacle.detail)
                    .font(.system(size: 16))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.tgMuted)
                Text("Demo coming soon")
                    .font(.system(size: 14, weight: .semibold))
                    .padding(.top, 8)
            }
            .frame(maxWidth: .infinity)

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 24)
        .tgScreen()
    }
}

#Preview {
    NavigationStack { ObstacleDemoView(obstacle: .timer) }
}
