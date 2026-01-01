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
    // MARK: - Adaptive Colors (Light/Dark Mode)

    /// Background color - warm cream in light mode, dark gray in dark mode
    let background = Color("ThemeBackground")

    /// Card background - white in light mode, elevated surface in dark mode
    let cardBackground = Color("ThemeCardBackground")

    /// Title text color - muted charcoal in light mode, light gray in dark mode
    let title = Color("ThemeTitle")

    /// Label text color - gray in light mode, medium gray in dark mode
    let label = Color("ThemeLabel")

    /// Primary text color - dark gray in light mode, near white in dark mode
    let textPrimary = Color("ThemeTextPrimary")

    /// Secondary text color - off-white for dark backgrounds (same in both modes)
    let textSecondary = Color(hex: ThemeColorValues.TextSecondary.light)

    /// Border color - light gray in light mode, dark separator in dark mode
    let borderColor = Color("ThemeBorder")

    /// Wheel border - beige in light mode, dark border in dark mode
    let wheelBorder = Color("ThemeWheelBorder")

    /// Wheel center - white in light mode, dark gray in dark mode
    let wheelCenter = Color("ThemeWheelCenter")

    /// Disabled button color - adapts to mode
    let disabledButton = Color("ThemeDisabledButton")

    // MARK: - Brand Colors (Same in Both Modes)

    /// Primary button color - dusty rose
    let primaryButton = Color(hex: ThemeColorValues.PrimaryButton.light)

    /// Primary button text - white
    let primaryButtonText = Color(hex: ThemeColorValues.PrimaryButtonText.light)

    // MARK: - Vibe Colors (Same in Both Modes - Brand Identity)

    /// Aesthetic vibe color - rose/coral
    let vibeAesthetic = Color(hex: ThemeColorValues.VibeAesthetic.color)

    /// Aesthetic wheel colors - 8 pastel colors
    let aestheticWheelColors: [Color] = ThemeColorValues.aestheticWheelColors.map { Color(hex: $0) }

    /// Splurge vibe color - deep purple
    let vibeSplurge = Color(hex: ThemeColorValues.VibeSplurge.color)

    /// Splurge wheel colors - 6 purple colors
    let splurgeWheelColors: [Color] = ThemeColorValues.splurgeWheelColors.map { Color(hex: $0) }

    /// Standard vibe color - muted gray
    let vibeStandard = Color(hex: ThemeColorValues.VibeStandard.color)

    /// Standard wheel colors - 8 neutral/sage colors
    let standardWheelColors: [Color] = ThemeColorValues.standardWheelColors.map { Color(hex: $0) }
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
