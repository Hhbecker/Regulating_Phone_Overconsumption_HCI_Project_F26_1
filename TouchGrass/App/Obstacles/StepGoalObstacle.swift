//  Needs "Privacy - Motion Usage Description" (NSMotionUsageDescription) in the app's Info tab.

import SwiftUI
import CoreMotion

struct StepGoalObstacle: View {
    var goal = 1_000
    var onComplete: () -> Void
    @State private var steps: Int?
    @State private var unavailable = false
    @State private var pedometer = CMPedometer()

    var body: some View {
        VStack(spacing: 16) {
            if unavailable {
                Text("Step counting isn’t available here (the simulator has no motion sensor).")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.tgMuted)
                #if DEBUG
                Button("Skip (debug only)", action: onComplete)
                    .buttonStyle(TGPrimaryButtonStyle())
                #endif
            } else if let steps {
                ProgressView(value: Double(min(steps, goal)), total: Double(goal))
                    .tint(Color.tgForest)
                Text("\(steps) of \(goal) steps today")
                    .font(.title3.bold())
                    .foregroundStyle(Color.tgInk)
                if steps >= goal {
                    Button("Continue", action: onComplete)
                        .buttonStyle(TGPrimaryButtonStyle())
                } else {
                    Text("Go touch some grass. This updates as you walk.")
                        .foregroundStyle(Color.tgMuted)
                }
            } else {
                ProgressView()
            }
        }
        .onAppear(perform: start)
        .onDisappear { pedometer.stopUpdates() }
    }

    private func start() {
        guard CMPedometer.isStepCountingAvailable() else {
            unavailable = true
            return
        }
        pedometer.startUpdates(from: Calendar.current.startOfDay(for: .now)) { data, _ in
            guard let count = data?.numberOfSteps.intValue else { return }
            DispatchQueue.main.async { steps = count }
        }
    }
}
