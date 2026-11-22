//  ObstacleView.swift — shows one obstacle; calls onComplete when it's cleared.

import SwiftUI

struct ObstacleView: View {
    let kind: ObstacleKind
    var onComplete: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: kind.symbol)
                .font(.system(size: 36))
                .frame(width: 72, height: 72)
                .background(Color.tgChip, in: RoundedRectangle(cornerRadius: 20))
                .foregroundStyle(Color.tgForest)
            Text(kind.title)
                .font(.tgHeadline)
                .foregroundStyle(Color.tgInk)

            switch kind {
            case .timer:     CountdownObstacle(seconds: 10, onComplete: onComplete)
            case .puzzle:    SlidingPuzzleObstacle(onComplete: onComplete)
            case .math:      MathObstacle(onComplete: onComplete)
            case .steps:     StepGoalObstacle(onComplete: onComplete)
            case .grayscale: GrayscaleObstacle(onComplete: onComplete)
            }
            Spacer(minLength: 0)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.tgMint.ignoresSafeArea())
    }
}
