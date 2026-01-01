import Foundation

/// Pure math functions for calculating color luminance and contrast.
/// These functions work with raw RGB values (0.0-1.0) and don't depend on UIKit.
public enum LuminanceCalculator {

    /// Calculates the relative luminance of an RGB color using the WCAG formula.
    ///
    /// Relative luminance is the relative brightness of any point in a colorspace,
    /// normalized to 0 for darkest black and 1 for lightest white.
    ///
    /// - Parameters:
    ///   - red: Red component (0.0-1.0)
    ///   - green: Green component (0.0-1.0)
    ///   - blue: Blue component (0.0-1.0)
    /// - Returns: A value between 0.0 (black) and 1.0 (white)
    public static func relativeLuminance(red: Double, green: Double, blue: Double) -> Double {
        // Linearize sRGB components (gamma correction)
        let r = linearize(red)
        let g = linearize(green)
        let b = linearize(blue)

        // Apply WCAG relative luminance formula
        return (0.2126 * r) + (0.7152 * g) + (0.0722 * b)
    }

    /// Calculates relative luminance from a hex color string.
    ///
    /// - Parameter hex: A hex color string (e.g., "FF0000" or "#FF0000")
    /// - Returns: A value between 0.0 (black) and 1.0 (white)
    public static func relativeLuminance(hex: String) -> Double {
        let components = rgbComponents(from: hex)
        return relativeLuminance(red: components.red, green: components.green, blue: components.blue)
    }

    /// Determines if a background color should use light or dark text for optimal contrast.
    ///
    /// Uses WCAG relative luminance with a 0.5 threshold:
    /// - Light backgrounds (luminance > 0.5) should use dark text
    /// - Dark backgrounds (luminance ≤ 0.5) should use light text
    ///
    /// - Parameter luminance: The relative luminance of the background color
    /// - Returns: `true` if dark text should be used, `false` for light text
    public static func shouldUseDarkText(forLuminance luminance: Double) -> Bool {
        return luminance > 0.5
    }

    /// Determines if a background color should use light or dark text.
    ///
    /// - Parameters:
    ///   - red: Red component (0.0-1.0)
    ///   - green: Green component (0.0-1.0)
    ///   - blue: Blue component (0.0-1.0)
    /// - Returns: `true` if dark text should be used, `false` for light text
    public static func shouldUseDarkText(red: Double, green: Double, blue: Double) -> Bool {
        let luminance = relativeLuminance(red: red, green: green, blue: blue)
        return shouldUseDarkText(forLuminance: luminance)
    }

    // MARK: - Private Helpers

    /// Linearizes an sRGB component for luminance calculation (gamma correction).
    private static func linearize(_ component: Double) -> Double {
        if component <= 0.03928 {
            return component / 12.92
        } else {
            return pow((component + 0.055) / 1.055, 2.4)
        }
    }

    /// Extracts RGB components from a hex string.
    public static func rgbComponents(from hex: String) -> (red: Double, green: Double, blue: Double) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r, g, b: UInt64
        switch hex.count {
        case 6:
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (r, g, b) = (int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }

        return (
            red: Double(r) / 255.0,
            green: Double(g) / 255.0,
            blue: Double(b) / 255.0
        )
    }
}
