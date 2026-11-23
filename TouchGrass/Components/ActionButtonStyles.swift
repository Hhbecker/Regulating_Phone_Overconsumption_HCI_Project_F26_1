import SwiftUI

/// Large filled button ("See the obstacles", "Next: create rules", "Save rule").
/// Dims automatically when the button is disabled.
struct PrimaryActionStyle: ButtonStyle {
    var height: CGFloat = 60

    func makeBody(configuration: Configuration) -> some View {
        PrimaryActionLabel(configuration: configuration, height: height)
    }
}

private struct PrimaryActionLabel: View {
    @Environment(\.isEnabled) private var isEnabled
    let configuration: ButtonStyleConfiguration
    let height: CGFloat

    var body: some View {
        configuration.label
            .font(.system(size: 18, weight: .bold))
            .foregroundStyle(isEnabled ? Color.white : Color.tgMuted)
            .frame(maxWidth: .infinity, minHeight: height)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(isEnabled ? Color.tgForest : Color.tgForest.opacity(0.25))
            )
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

/// Smaller outlined button ("Skip to my rules", "Edit rules").
struct SecondaryActionStyle: ButtonStyle {
    var height: CGFloat = 44
    var fontSize: CGFloat = 15
    var cornerRadius: CGFloat = 14

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: fontSize, weight: .medium))
            .foregroundStyle(Color.tgForest)
            .frame(maxWidth: .infinity, minHeight: height)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.tgForest.opacity(0.35), lineWidth: 1.5)
            )
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .opacity(configuration.isPressed ? 0.6 : 1)
    }
}
