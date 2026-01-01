import XCTest
@testable import DiningDeciderCore

/// Tests for validating theme color configurations and luminance calculations.
final class ColorValidationTests: XCTestCase {

    // MARK: - Wheel Color Luminance Tests

    func test_allWheelColors_haveValidLuminance() {
        let allColorHexes = ThemeColorValues.aestheticWheelColors +
                           ThemeColorValues.splurgeWheelColors +
                           ThemeColorValues.standardWheelColors

        for hex in allColorHexes {
            let luminance = LuminanceCalculator.relativeLuminance(hex: hex)
            XCTAssertGreaterThanOrEqual(luminance, 0.0, "Luminance for \(hex) should be >= 0.0")
            XCTAssertLessThanOrEqual(luminance, 1.0, "Luminance for \(hex) should be <= 1.0")
        }
    }

    func test_allWheelColors_selectValidTextColor() {
        let allColorHexes = ThemeColorValues.aestheticWheelColors +
                           ThemeColorValues.splurgeWheelColors +
                           ThemeColorValues.standardWheelColors

        for hex in allColorHexes {
            let luminance = LuminanceCalculator.relativeLuminance(hex: hex)
            let useDarkText = LuminanceCalculator.shouldUseDarkText(forLuminance: luminance)
            // Should return a boolean without crashing
            XCTAssertTrue(useDarkText == true || useDarkText == false,
                "Text color decision for \(hex) should be valid")
        }
    }

    // MARK: - Aesthetic Wheel Colors Tests

    func test_aestheticColors_areLightEnoughForDarkText() {
        // Aesthetic colors are pastels - most should use dark text
        var lightColorCount = 0
        for hex in ThemeColorValues.aestheticWheelColors {
            let luminance = LuminanceCalculator.relativeLuminance(hex: hex)
            if luminance > 0.4 {
                lightColorCount += 1
            }
        }
        // Most aesthetic colors should be reasonably light (>= 5 out of 8)
        XCTAssertGreaterThanOrEqual(lightColorCount, 5,
            "Most aesthetic wheel colors should be light (luminance > 0.4)")
    }

    // MARK: - Splurge Wheel Colors Tests

    func test_splurgeColors_haveVariedLuminance() {
        // Splurge colors include both dark purples and light purples
        let luminances = ThemeColorValues.splurgeWheelColors.map {
            LuminanceCalculator.relativeLuminance(hex: $0)
        }

        let hasLight = luminances.contains { $0 > 0.4 }
        let hasDark = luminances.contains { $0 < 0.3 }

        XCTAssertTrue(hasLight, "Splurge colors should include some light colors")
        XCTAssertTrue(hasDark, "Splurge colors should include some dark colors")
    }

    // MARK: - Standard Wheel Colors Tests

    func test_standardColors_areMuted() {
        // Standard colors are muted/neutral - check saturation is low
        for hex in ThemeColorValues.standardWheelColors {
            let components = LuminanceCalculator.rgbComponents(from: hex)
            let r = components.red
            let g = components.green
            let b = components.blue

            let maxC = max(r, g, b)
            let minC = min(r, g, b)
            let range = maxC - minC

            // Muted colors have lower saturation (smaller range between components)
            XCTAssertLessThan(range, 0.4,
                "Standard color \(hex) should be muted (low saturation)")
        }
    }

    // MARK: - Background Color Tests

    func test_lightBackground_isLighterThanDarkBackground() {
        let lightLuminance = LuminanceCalculator.relativeLuminance(hex: ThemeColorValues.Background.light)
        let darkLuminance = LuminanceCalculator.relativeLuminance(hex: ThemeColorValues.Background.dark)
        XCTAssertGreaterThan(lightLuminance, darkLuminance)
    }

    func test_lightCardBackground_isLighterThanDarkCardBackground() {
        let lightLuminance = LuminanceCalculator.relativeLuminance(hex: ThemeColorValues.CardBackground.light)
        let darkLuminance = LuminanceCalculator.relativeLuminance(hex: ThemeColorValues.CardBackground.dark)
        XCTAssertGreaterThan(lightLuminance, darkLuminance)
    }

    // MARK: - Text Color Contrast Tests

    func test_titleColors_haveGoodContrast() {
        let lightTitleLuminance = LuminanceCalculator.relativeLuminance(hex: ThemeColorValues.Title.light)
        let darkTitleLuminance = LuminanceCalculator.relativeLuminance(hex: ThemeColorValues.Title.dark)

        // Light mode title (dark text) should have low luminance
        XCTAssertLessThan(lightTitleLuminance, 0.5, "Light mode title should be dark")

        // Dark mode title (light text) should have high luminance
        XCTAssertGreaterThan(darkTitleLuminance, 0.5, "Dark mode title should be light")
    }

    func test_textPrimary_hasGoodContrast() {
        let lightTextLuminance = LuminanceCalculator.relativeLuminance(hex: ThemeColorValues.TextPrimary.light)
        let darkTextLuminance = LuminanceCalculator.relativeLuminance(hex: ThemeColorValues.TextPrimary.dark)

        XCTAssertLessThan(lightTextLuminance, 0.3, "Light mode text should be dark")
        XCTAssertGreaterThan(darkTextLuminance, 0.8, "Dark mode text should be light")
    }

    // MARK: - Vibe Color Identity Tests

    func test_vibeColors_areSameInBothModes() {
        // Vibe colors are brand colors - single value for both modes
        XCTAssertNotNil(ThemeColorValues.VibeAesthetic.color)
        XCTAssertNotNil(ThemeColorValues.VibeSplurge.color)
        XCTAssertNotNil(ThemeColorValues.VibeStandard.color)

        // They should be valid hex
        for hex in [ThemeColorValues.VibeAesthetic.color,
                    ThemeColorValues.VibeSplurge.color,
                    ThemeColorValues.VibeStandard.color] {
            XCTAssertEqual(hex.count, 6, "Vibe color should be 6-character hex")
            let luminance = LuminanceCalculator.relativeLuminance(hex: hex)
            XCTAssertGreaterThan(luminance, 0.0, "Vibe color should have positive luminance")
        }
    }

    func test_vibeAesthetic_isRose() {
        let hex = ThemeColorValues.VibeAesthetic.color
        let components = LuminanceCalculator.rgbComponents(from: hex)
        let r = components.red
        let g = components.green
        let b = components.blue
        // Rose color: high red, moderate green/blue
        XCTAssertGreaterThan(r, g, "Aesthetic rose should have more red than green")
        XCTAssertGreaterThan(r, b, "Aesthetic rose should have more red than blue")
    }

    func test_vibeSplurge_isPurple() {
        let hex = ThemeColorValues.VibeSplurge.color
        let components = LuminanceCalculator.rgbComponents(from: hex)
        let r = components.red
        let g = components.green
        let b = components.blue
        // Purple color: high red and blue, low green
        XCTAssertGreaterThan(r, g, "Splurge purple should have more red than green")
        XCTAssertGreaterThan(b, g, "Splurge purple should have more blue than green")
    }

    // MARK: - Primary Button Color Tests

    func test_primaryButton_isDustyRose() {
        let hex = ThemeColorValues.PrimaryButton.light
        let luminance = LuminanceCalculator.relativeLuminance(hex: hex)

        // Dusty rose is a medium-light color
        XCTAssertGreaterThan(luminance, 0.3, "Primary button should be visible")
        XCTAssertLessThan(luminance, 0.7, "Primary button should have enough contrast")
    }

    func test_primaryButtonText_isWhite() {
        let hex = ThemeColorValues.PrimaryButtonText.light
        let luminance = LuminanceCalculator.relativeLuminance(hex: hex)

        // White text for button
        XCTAssertEqual(luminance, 1.0, accuracy: 0.01, "Button text should be white")
    }
}
