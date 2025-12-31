import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Theme Colors

extension Color {
    static let theme = ThemeColors()
}

struct ThemeColors {
    // Background & Surfaces
    let background = Color(hex: "F0EFE9")
    let cardBackground = Color.white

    // Text
    let title = Color(hex: "5E5B52")
    let label = Color(hex: "999999")
    let textPrimary = Color(hex: "333333")

    // Interactive
    let primaryButton = Color(hex: "C8A299")
    let primaryButtonText = Color.white
    let disabledButton = Color(hex: "DDDDDD")

    // Wheel
    let wheelBorder = Color(hex: "EAE8E1")
    let wheelCenter = Color.white

    // Vibe: Aesthetic
    let vibeAesthetic = Color(hex: "D98880")
    let aestheticWheelColors: [Color] = [
        Color(hex: "E6B0AA"),
        Color(hex: "D98880"),
        Color(hex: "F1948A"),
        Color(hex: "C39BD3")
    ]

    // Vibe: Splurge
    let vibeSplurge = Color(hex: "884EA0")
    let splurgeWheelColors: [Color] = [
        Color(hex: "884EA0"),
        Color(hex: "AF7AC5"),
        Color(hex: "7D3C98"),
        Color(hex: "5B2C6F")
    ]

    // Vibe: Standard
    let vibeStandard = Color(hex: "7F8C8D")
    let standardWheelColors: [Color] = [
        Color(hex: "A4B494"),
        Color(hex: "DCC7AA"),
        Color(hex: "B5C0D0"),
        Color(hex: "E4B7B2")
    ]
}
