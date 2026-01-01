import XCTest
import SwiftUI
@testable import DiningDecider

/// Tests for dark mode color adaptation.
/// TDD: These tests are written BEFORE implementing dark mode support.
final class ColorDarkModeTests: XCTestCase {

    // MARK: - Color Scheme Adaptation Tests

    func test_background_lightMode_isWarmCream() {
        let lightTraits = UITraitCollection(userInterfaceStyle: .light)
        let color = Color.theme.background
        let uiColor = UIColor(color)
        let resolved = uiColor.resolvedColor(with: lightTraits)

        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        resolved.getRed(&r, green: &g, blue: &b, alpha: &a)

        // Warm cream: #F0EFE9 = RGB(240, 239, 233)
        XCTAssertEqual(r, 240/255, accuracy: 0.02, "Red component should be ~240")
        XCTAssertEqual(g, 239/255, accuracy: 0.02, "Green component should be ~239")
        XCTAssertEqual(b, 233/255, accuracy: 0.02, "Blue component should be ~233")
    }

    func test_background_darkMode_isDarkGray() {
        let darkTraits = UITraitCollection(userInterfaceStyle: .dark)
        let color = Color.theme.background
        let uiColor = UIColor(color)
        let resolved = uiColor.resolvedColor(with: darkTraits)

        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        resolved.getRed(&r, green: &g, blue: &b, alpha: &a)

        // Dark background: #1C1C1E = RGB(28, 28, 30)
        XCTAssertEqual(r, 28/255, accuracy: 0.02, "Red component should be ~28")
        XCTAssertEqual(g, 28/255, accuracy: 0.02, "Green component should be ~28")
        XCTAssertEqual(b, 30/255, accuracy: 0.02, "Blue component should be ~30")
    }

    func test_cardBackground_lightMode_isWhite() {
        let lightTraits = UITraitCollection(userInterfaceStyle: .light)
        let color = Color.theme.cardBackground
        let uiColor = UIColor(color)
        let resolved = uiColor.resolvedColor(with: lightTraits)

        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        resolved.getRed(&r, green: &g, blue: &b, alpha: &a)

        // White: RGB(255, 255, 255)
        XCTAssertEqual(r, 1.0, accuracy: 0.01, "Should be white in light mode")
        XCTAssertEqual(g, 1.0, accuracy: 0.01, "Should be white in light mode")
        XCTAssertEqual(b, 1.0, accuracy: 0.01, "Should be white in light mode")
    }

    func test_cardBackground_darkMode_isElevatedSurface() {
        let darkTraits = UITraitCollection(userInterfaceStyle: .dark)
        let color = Color.theme.cardBackground
        let uiColor = UIColor(color)
        let resolved = uiColor.resolvedColor(with: darkTraits)

        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        resolved.getRed(&r, green: &g, blue: &b, alpha: &a)

        // Elevated surface: #2C2C2E = RGB(44, 44, 46)
        XCTAssertEqual(r, 44/255, accuracy: 0.02, "Red component should be ~44")
        XCTAssertEqual(g, 44/255, accuracy: 0.02, "Green component should be ~44")
        XCTAssertEqual(b, 46/255, accuracy: 0.02, "Blue component should be ~46")
    }

    func test_titleColor_lightMode_isMutedCharcoal() {
        let lightTraits = UITraitCollection(userInterfaceStyle: .light)
        let color = Color.theme.title
        let uiColor = UIColor(color)
        let resolved = uiColor.resolvedColor(with: lightTraits)

        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        resolved.getRed(&r, green: &g, blue: &b, alpha: &a)

        // Muted charcoal: #5E5B52 = RGB(94, 91, 82)
        XCTAssertEqual(r, 94/255, accuracy: 0.02, "Red component should be ~94")
        XCTAssertEqual(g, 91/255, accuracy: 0.02, "Green component should be ~91")
        XCTAssertEqual(b, 82/255, accuracy: 0.02, "Blue component should be ~82")
    }

    func test_titleColor_darkMode_isLightGray() {
        let darkTraits = UITraitCollection(userInterfaceStyle: .dark)
        let color = Color.theme.title
        let uiColor = UIColor(color)
        let resolved = uiColor.resolvedColor(with: darkTraits)

        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        resolved.getRed(&r, green: &g, blue: &b, alpha: &a)

        // Light gray for dark mode: #E5E5E5 = RGB(229, 229, 229)
        XCTAssertEqual(r, 229/255, accuracy: 0.02, "Red component should be ~229")
        XCTAssertEqual(g, 229/255, accuracy: 0.02, "Green component should be ~229")
        XCTAssertEqual(b, 229/255, accuracy: 0.02, "Blue component should be ~229")
    }

    func test_textPrimary_lightMode_isDarkGray() {
        let lightTraits = UITraitCollection(userInterfaceStyle: .light)
        let color = Color.theme.textPrimary
        let uiColor = UIColor(color)
        let resolved = uiColor.resolvedColor(with: lightTraits)

        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        resolved.getRed(&r, green: &g, blue: &b, alpha: &a)

        // Dark gray: #333333 = RGB(51, 51, 51)
        XCTAssertEqual(r, 51/255, accuracy: 0.02)
        XCTAssertEqual(g, 51/255, accuracy: 0.02)
        XCTAssertEqual(b, 51/255, accuracy: 0.02)
    }

    func test_textPrimary_darkMode_isLightText() {
        let darkTraits = UITraitCollection(userInterfaceStyle: .dark)
        let color = Color.theme.textPrimary
        let uiColor = UIColor(color)
        let resolved = uiColor.resolvedColor(with: darkTraits)

        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        resolved.getRed(&r, green: &g, blue: &b, alpha: &a)

        // Light text for dark mode: #F5F5F5 = RGB(245, 245, 245)
        XCTAssertEqual(r, 245/255, accuracy: 0.02)
        XCTAssertEqual(g, 245/255, accuracy: 0.02)
        XCTAssertEqual(b, 245/255, accuracy: 0.02)
    }

    func test_labelColor_lightMode_isGray() {
        let lightTraits = UITraitCollection(userInterfaceStyle: .light)
        let color = Color.theme.label
        let uiColor = UIColor(color)
        let resolved = uiColor.resolvedColor(with: lightTraits)

        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        resolved.getRed(&r, green: &g, blue: &b, alpha: &a)

        // Gray: #999999 = RGB(153, 153, 153)
        XCTAssertEqual(r, 153/255, accuracy: 0.02)
        XCTAssertEqual(g, 153/255, accuracy: 0.02)
        XCTAssertEqual(b, 153/255, accuracy: 0.02)
    }

    func test_labelColor_darkMode_isMediumGray() {
        let darkTraits = UITraitCollection(userInterfaceStyle: .dark)
        let color = Color.theme.label
        let uiColor = UIColor(color)
        let resolved = uiColor.resolvedColor(with: darkTraits)

        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        resolved.getRed(&r, green: &g, blue: &b, alpha: &a)

        // Medium gray for dark mode: #8E8E93 = RGB(142, 142, 147)
        XCTAssertEqual(r, 142/255, accuracy: 0.02)
        XCTAssertEqual(g, 142/255, accuracy: 0.02)
        XCTAssertEqual(b, 147/255, accuracy: 0.02)
    }

    // MARK: - Border & Surface Colors

    func test_borderColor_lightMode_isLightGray() {
        let lightTraits = UITraitCollection(userInterfaceStyle: .light)
        let color = Color.theme.borderColor
        let uiColor = UIColor(color)
        let resolved = uiColor.resolvedColor(with: lightTraits)

        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        resolved.getRed(&r, green: &g, blue: &b, alpha: &a)

        // Light gray: #E0E0E0 = RGB(224, 224, 224)
        XCTAssertEqual(r, 224/255, accuracy: 0.02)
        XCTAssertEqual(g, 224/255, accuracy: 0.02)
        XCTAssertEqual(b, 224/255, accuracy: 0.02)
    }

    func test_borderColor_darkMode_isDarkerGray() {
        let darkTraits = UITraitCollection(userInterfaceStyle: .dark)
        let color = Color.theme.borderColor
        let uiColor = UIColor(color)
        let resolved = uiColor.resolvedColor(with: darkTraits)

        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        resolved.getRed(&r, green: &g, blue: &b, alpha: &a)

        // Dark mode border: #3A3A3C = RGB(58, 58, 60)
        XCTAssertEqual(r, 58/255, accuracy: 0.02)
        XCTAssertEqual(g, 58/255, accuracy: 0.02)
        XCTAssertEqual(b, 60/255, accuracy: 0.02)
    }

    func test_wheelBorder_lightMode_isBeige() {
        let lightTraits = UITraitCollection(userInterfaceStyle: .light)
        let color = Color.theme.wheelBorder
        let uiColor = UIColor(color)
        let resolved = uiColor.resolvedColor(with: lightTraits)

        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        resolved.getRed(&r, green: &g, blue: &b, alpha: &a)

        // Beige: #EAE8E1 = RGB(234, 232, 225)
        XCTAssertEqual(r, 234/255, accuracy: 0.02)
        XCTAssertEqual(g, 232/255, accuracy: 0.02)
        XCTAssertEqual(b, 225/255, accuracy: 0.02)
    }

    func test_wheelBorder_darkMode_isDarkBeige() {
        let darkTraits = UITraitCollection(userInterfaceStyle: .dark)
        let color = Color.theme.wheelBorder
        let uiColor = UIColor(color)
        let resolved = uiColor.resolvedColor(with: darkTraits)

        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        resolved.getRed(&r, green: &g, blue: &b, alpha: &a)

        // Dark mode wheel border: #3A3A3C = RGB(58, 58, 60)
        XCTAssertEqual(r, 58/255, accuracy: 0.02)
        XCTAssertEqual(g, 58/255, accuracy: 0.02)
        XCTAssertEqual(b, 60/255, accuracy: 0.02)
    }

    func test_wheelCenter_lightMode_isWhite() {
        let lightTraits = UITraitCollection(userInterfaceStyle: .light)
        let color = Color.theme.wheelCenter
        let uiColor = UIColor(color)
        let resolved = uiColor.resolvedColor(with: lightTraits)

        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        resolved.getRed(&r, green: &g, blue: &b, alpha: &a)

        XCTAssertEqual(r, 1.0, accuracy: 0.01)
        XCTAssertEqual(g, 1.0, accuracy: 0.01)
        XCTAssertEqual(b, 1.0, accuracy: 0.01)
    }

    func test_wheelCenter_darkMode_isDarkGray() {
        let darkTraits = UITraitCollection(userInterfaceStyle: .dark)
        let color = Color.theme.wheelCenter
        let uiColor = UIColor(color)
        let resolved = uiColor.resolvedColor(with: darkTraits)

        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        resolved.getRed(&r, green: &g, blue: &b, alpha: &a)

        // Dark mode center: #2C2C2E = RGB(44, 44, 46)
        XCTAssertEqual(r, 44/255, accuracy: 0.02)
        XCTAssertEqual(g, 44/255, accuracy: 0.02)
        XCTAssertEqual(b, 46/255, accuracy: 0.02)
    }

    // MARK: - Interactive Colors (Should Stay Vibrant)

    func test_primaryButton_maintainsColorInBothModes() {
        let lightTraits = UITraitCollection(userInterfaceStyle: .light)
        let darkTraits = UITraitCollection(userInterfaceStyle: .dark)

        let color = Color.theme.primaryButton
        let uiColor = UIColor(color)

        let lightResolved = uiColor.resolvedColor(with: lightTraits)
        let darkResolved = uiColor.resolvedColor(with: darkTraits)

        var lr: CGFloat = 0, lg: CGFloat = 0, lb: CGFloat = 0, la: CGFloat = 0
        var dr: CGFloat = 0, dg: CGFloat = 0, db: CGFloat = 0, da: CGFloat = 0

        lightResolved.getRed(&lr, green: &lg, blue: &lb, alpha: &la)
        darkResolved.getRed(&dr, green: &dg, blue: &db, alpha: &da)

        // Primary button color should be same or similar in both modes
        // Dusty rose: #C8A299 = RGB(200, 162, 153)
        XCTAssertEqual(lr, 200/255, accuracy: 0.02)
        XCTAssertEqual(dr, 200/255, accuracy: 0.02)
    }

    func test_vibeColors_maintainIdentityInBothModes() {
        let lightTraits = UITraitCollection(userInterfaceStyle: .light)
        let darkTraits = UITraitCollection(userInterfaceStyle: .dark)

        // Vibe colors should stay recognizable in both modes
        let vibeColors: [(color: Color, description: String)] = [
            (Color.theme.vibeAesthetic, "Aesthetic rose"),
            (Color.theme.vibeSplurge, "Splurge purple"),
            (Color.theme.vibeStandard, "Standard gray"),
        ]

        for vibeColor in vibeColors {
            let uiColor = UIColor(vibeColor.color)
            let lightResolved = uiColor.resolvedColor(with: lightTraits)
            let darkResolved = uiColor.resolvedColor(with: darkTraits)

            var lr: CGFloat = 0, lg: CGFloat = 0, lb: CGFloat = 0, la: CGFloat = 0
            var dr: CGFloat = 0, dg: CGFloat = 0, db: CGFloat = 0, da: CGFloat = 0

            lightResolved.getRed(&lr, green: &lg, blue: &lb, alpha: &la)
            darkResolved.getRed(&dr, green: &dg, blue: &db, alpha: &da)

            // Colors should be similar in both modes (within 10% tolerance)
            XCTAssertEqual(lr, dr, accuracy: 0.1, "\(vibeColor.description) should maintain hue in dark mode")
            XCTAssertEqual(lg, dg, accuracy: 0.1, "\(vibeColor.description) should maintain hue in dark mode")
            XCTAssertEqual(lb, db, accuracy: 0.1, "\(vibeColor.description) should maintain hue in dark mode")
        }
    }

    // MARK: - Wheel Colors Stay Vibrant

    func test_wheelColors_remainVibrantInDarkMode() {
        let darkTraits = UITraitCollection(userInterfaceStyle: .dark)

        let allWheelColors = Color.theme.aestheticWheelColors +
                            Color.theme.splurgeWheelColors +
                            Color.theme.standardWheelColors

        for color in allWheelColors {
            let uiColor = UIColor(color)
            let resolved = uiColor.resolvedColor(with: darkTraits)

            var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
            resolved.getRed(&r, green: &g, blue: &b, alpha: &a)

            // Wheel colors should have saturation (not all gray)
            let maxComponent = max(r, g, b)
            let minComponent = min(r, g, b)
            let range = maxComponent - minComponent

            // At least some colors should have color variation (saturation > 0.05)
            // This ensures they're not all washed out gray
            XCTAssertTrue(
                range > 0.02 || (r == g && g == b && r > 0.3),
                "Wheel color should maintain vibrancy or be intentionally neutral"
            )
        }
    }
}
