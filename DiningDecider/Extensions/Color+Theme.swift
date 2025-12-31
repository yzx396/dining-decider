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

    // Vibe: Aesthetic (8 colors for 8 sectors)
    let vibeAesthetic = Color(hex: "D98880")
    let aestheticWheelColors: [Color] = [
        Color(hex: "E6B0AA"),  // Soft pink
        Color(hex: "D98880"),  // Rose
        Color(hex: "F1948A"),  // Coral pink
        Color(hex: "C39BD3"),  // Lavender
        Color(hex: "F5B7B1"),  // Light pink
        Color(hex: "FAD7A0"),  // Peach
        Color(hex: "E8DAEF"),  // Light purple
        Color(hex: "D7BDE2")   // Soft purple
    ]

    // Vibe: Splurge (6 colors)
    let vibeSplurge = Color(hex: "884EA0")
    let splurgeWheelColors: [Color] = [
        Color(hex: "884EA0"),  // Deep purple
        Color(hex: "AF7AC5"),  // Medium purple
        Color(hex: "7D3C98"),  // Dark purple
        Color(hex: "5B2C6F"),  // Deeper purple
        Color(hex: "D2B4DE"),  // Light purple
        Color(hex: "A569BD")   // Purple
    ]

    // Vibe: Standard (8 colors)
    let vibeStandard = Color(hex: "7F8C8D")
    let standardWheelColors: [Color] = [
        Color(hex: "A4B494"),  // Sage green
        Color(hex: "DCC7AA"),  // Tan
        Color(hex: "B5C0D0"),  // Blue gray
        Color(hex: "E4B7B2"),  // Dusty rose
        Color(hex: "C4C3D0"),  // Soft gray
        Color(hex: "9FAEB5"),  // Steel blue
        Color(hex: "D8DCD6"),  // Light gray
        Color(hex: "C8A299")   // Warm gray
    ]
}
