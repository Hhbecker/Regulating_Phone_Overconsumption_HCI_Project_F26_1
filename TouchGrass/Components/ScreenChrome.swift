import SwiftUI
import UIKit

/// Square back button used at the top of pushed screens.
struct BackButton: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Button { dismiss() } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.tgForest)
                .frame(width: 44, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.tgForest.opacity(0.12))
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Back")
    }
}

extension View {
    /// Mint background, system navigation bar hidden (screens draw their own header).
    func tgScreen() -> some View {
        self
            .foregroundStyle(Color.tgInk)
            .background(Color.tgMint.ignoresSafeArea())
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .navigationBar)
    }
}

// Hiding the navigation bar also disables the edge-swipe-back gesture.
// This common workaround turns it back on for pushed screens.
extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        viewControllers.count > 1
    }
}
