import SwiftUI

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }

    // Prefixed with "tg" so they never collide with SwiftUI's built-in
    // Color.mint (and friends).
    static let tgMint   = Color(hex: 0xA3E4C9)   // screen background
    static let tgForest = Color(hex: 0x0E4A36)   // primary / accents
    static let tgInk    = Color(hex: 0x0B3B2C)   // main text
    static let tgMuted  = Color(hex: 0x24533F)   // secondary text
    static let tgSubtle = Color(hex: 0x3A5E50)   // tertiary text
    static let tgCard   = Color(hex: 0xF4FBF7)   // card surface
    static let tgTile   = Color(hex: 0xD3F1E3)   // icon tiles, pills
    static let tgDanger = Color(hex: 0x9A3412)   // destructive text
}
