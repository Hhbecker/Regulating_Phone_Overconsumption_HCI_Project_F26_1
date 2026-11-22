//  iOS doesn't let apps change system colours, so grayscale is set up once by the
//  person in Shortcuts. This screen explains how; see README for details.

import SwiftUI

struct GrayscaleObstacle: View {
    var onComplete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("iOS doesn’t let other apps change your screen’s colours, so this one takes a one-time setup in the Shortcuts app:")
                .foregroundStyle(Color.tgMuted)
            step(1, "Open Shortcuts › Automation › New Automation › App.")
            step(2, "Pick the apps you want in black and white, choose “Is Opened”, and run immediately.")
            step(3, "Add the action “Set Color Filters” and turn it on. Make a second automation with “Is Closed” to turn it off.")
            step(4, "Check that Settings › Accessibility › Display & Text Size › Color Filters is set to Grayscale.")
            Button("Got it", action: onComplete)
                .buttonStyle(TGPrimaryButtonStyle())
                .padding(.top, 8)
        }
    }

    private func step(_ n: Int, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(n)")
                .font(.subheadline.bold())
                .frame(width: 28, height: 28)
                .background(Circle().fill(Color.tgChip))
            Text(text).foregroundStyle(Color.tgInk)
        }
    }
}
