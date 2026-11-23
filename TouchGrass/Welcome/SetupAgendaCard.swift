import SwiftUI

struct SetupAgendaCard: View {
    private let steps = [
        "Learn about the obstacles",
        "Create obstacle rules"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Setup agenda")
                .font(.system(size: 18, weight: .semibold))   // Outfit in the prototype
                .accessibilityAddTraits(.isHeader)

            VStack(alignment: .leading, spacing: 10) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, title in
                    HStack(spacing: 12) {
                        Text("\(index + 1)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 28, height: 28)
                            .background(Color.tgForest, in: Circle())
                            .accessibilityHidden(true)

                        Text(title)
                            .font(.system(size: 16, weight: .medium))
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Step \(index + 1): \(title)")
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.tgCard.opacity(0.7))
        )
        .foregroundStyle(Color.tgInk)
    }
}

#Preview {
    ZStack {
        Color.tgMint.ignoresSafeArea()
        SetupAgendaCard().padding(28)
    }
}
