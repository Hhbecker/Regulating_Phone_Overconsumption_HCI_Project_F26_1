//  Theme.swift — colours taken from the TouchGrass prototype screens.

import SwiftUI

extension Color {
    static let tgMint   = Color(red: 0.69, green: 0.88, blue: 0.79)   // screen background
    static let tgForest = Color(red: 0.13, green: 0.29, blue: 0.21)   // buttons, selected chips
    static let tgInk    = Color(red: 0.09, green: 0.16, blue: 0.12)   // headings
    static let tgMuted  = Color(red: 0.29, green: 0.37, blue: 0.33)   // body text
    static let tgCard   = Color(red: 0.96, green: 0.98, blue: 0.96)   // cards
    static let tgChip   = Color(red: 0.86, green: 0.93, blue: 0.89)   // icon tiles, presets
}

extension Font {
    static let tgTitle    = Font.system(size: 34, weight: .bold, design: .rounded)
    static let tgHeadline = Font.system(size: 24, weight: .bold, design: .rounded)
}

struct TGPrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 18, weight: .bold, design: .rounded))
            .foregroundStyle(isEnabled ? Color.white : Color.tgForest.opacity(0.6))
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(isEnabled ? Color.tgForest : Color.tgForest.opacity(0.2))
            )
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

struct Chip: View {
    let title: String
    let selected: Bool
    var badge: Int? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let badge { Text("\(badge)").font(.caption.bold()) }
                Text(title).font(.subheadline.bold())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .foregroundStyle(selected ? Color.white : Color.tgForest)
            .background(Capsule().fill(selected ? Color.tgForest : Color.clear))
            .overlay(Capsule().stroke(Color.tgForest, lineWidth: 2))
        }
        .buttonStyle(.plain)
    }
}
