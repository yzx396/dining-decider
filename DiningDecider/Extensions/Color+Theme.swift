import SwiftUI
import DiningDeciderCore

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
    let textSecondary = Color(hex: "FAFAFA")  // Off-white for dark backgrounds

    // Interactive
    let primaryButton = Color(hex: "C8A299")
    let primaryButtonText = Color.white
    let disabledButton = Color(hex: "DDDDDD")
    let borderColor = Color(hex: "E0E0E0")

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

// MARK: - Luminance & Contrast

extension Color {
    /// Calculates the relative luminance of a color using the WCAG formula.
    ///
    /// Relative luminance is the relative brightness of any point in a colorspace,
    /// normalized to 0 for darkest black and 1 for lightest white.
    ///
    /// - Returns: A value between 0.0 (black) and 1.0 (white)
    var relativeLuminance: Double {
        guard let components = extractRGBComponents() else {
            return 0.0  // Default to dark if extraction fails
        }

        return LuminanceCalculator.relativeLuminance(
            red: components.red,
            green: components.green,
            blue: components.blue
        )
    }

    /// Returns the optimal text color (charcoal or off-white) for this background color.
    ///
    /// Uses WCAG relative luminance to determine which text color provides better contrast:
    /// - Light backgrounds (luminance > 0.5) get charcoal text (#333333)
    /// - Dark backgrounds (luminance ≤ 0.5) get off-white text (#FAFAFA)
    ///
    /// - Returns: Either `Color.theme.textPrimary` or `Color.theme.textSecondary`
    var contrastTextColor: Color {
        return LuminanceCalculator.shouldUseDarkText(forLuminance: relativeLuminance)
            ? Color.theme.textPrimary
            : Color.theme.textSecondary
    }

    /// Extracts RGB components from a SwiftUI Color by converting to UIColor.
    ///
    /// - Returns: A tuple containing red, green, and blue components (0.0-1.0), or nil if extraction fails
    private func extractRGBComponents() -> (red: Double, green: Double, blue: Double)? {
        let uiColor = UIColor(self)

        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        // Extract RGB components using UIColor
        guard uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }

        return (red: Double(red), green: Double(green), blue: Double(blue))
    }
}
