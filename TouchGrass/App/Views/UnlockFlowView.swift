//  UnlockFlowView.swift — runs a rule's obstacles in order, then unlocks.

import SwiftUI

struct UnlockFlowView: View {
    let rule: Rule
    @EnvironmentObject private var screenTime: ScreenTimeManager
    @ObservedObject private var router = Router.shared
    @State private var step = 0

    var body: some View {
        ZStack {
            Color.tgMint.ignoresSafeArea()
            if step < rule.obstacles.count {
                VStack(spacing: 0) {
                    HStack {
                        Button("Not now") {
                            Shared.defaults.removeObject(forKey: Shared.pendingUnlockKey)
                            router.unlockRule = nil
                        }
                        Spacer()
                        Text("Obstacle \(step + 1) of \(rule.obstacles.count)")
                            .font(.subheadline.bold())
                            .foregroundStyle(Color.tgMuted)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    ObstacleView(kind: rule.obstacles[step]) {
                        withAnimation { step += 1 }
                    }
                    .id(step)    // fresh state for each obstacle
                }
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(Color.tgForest)
                    Text("Unlocked for \(rule.unlockMinutes) minutes")
                        .font(.tgHeadline)
                        .foregroundStyle(Color.tgInk)
                    Text("Head back to your app. When the time’s up, the obstacle comes back.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.tgMuted)
                    Button("Done") { router.unlockRule = nil }
                        .buttonStyle(TGPrimaryButtonStyle())
                }
                .padding(24)
                .onAppear { screenTime.grantUnlock(for: rule) }
            }
        }
    }
}
