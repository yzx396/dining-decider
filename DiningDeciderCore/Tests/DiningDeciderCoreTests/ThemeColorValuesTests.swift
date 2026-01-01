import XCTest
@testable import DiningDeciderCore

final class ThemeColorValuesTests: XCTestCase {

    // MARK: - Valid Hex Format Tests

    func test_allColorValues_areValidHexStrings() {
        let allColors = [
            // Backgrounds
            ThemeColorValues.Background.light,
            ThemeColorValues.Background.dark,
            ThemeColorValues.CardBackground.light,
            ThemeColorValues.CardBackground.dark,
            // Text
            ThemeColorValues.Title.light,
            ThemeColorValues.Title.dark,
            ThemeColorValues.Label.light,
            ThemeColorValues.Label.dark,
            ThemeColorValues.TextPrimary.light,
            ThemeColorValues.TextPrimary.dark,
            ThemeColorValues.TextSecondary.light,
            ThemeColorValues.TextSecondary.dark,
            // Interactive
            ThemeColorValues.PrimaryButton.light,
            ThemeColorValues.PrimaryButton.dark,
            ThemeColorValues.PrimaryButtonText.light,
            ThemeColorValues.PrimaryButtonText.dark,
            ThemeColorValues.DisabledButton.light,
            ThemeColorValues.DisabledButton.dark,
            ThemeColorValues.Border.light,
            ThemeColorValues.Border.dark,
            // Wheel
            ThemeColorValues.WheelBorder.light,
            ThemeColorValues.WheelBorder.dark,
            ThemeColorValues.WheelCenter.light,
            ThemeColorValues.WheelCenter.dark,
            // Vibes
            ThemeColorValues.VibeAesthetic.color,
            ThemeColorValues.VibeSplurge.color,
            ThemeColorValues.VibeStandard.color,
        ]

        for hex in allColors {
            XCTAssertEqual(hex.count, 6, "Hex string '\(hex)' should be 6 characters")
            XCTAssertTrue(
                hex.allSatisfy { $0.isHexDigit },
                "Hex string '\(hex)' should contain only hex digits"
            )
        }
    }

    func test_wheelColorArrays_areValidHexStrings() {
        let allWheelColors = ThemeColorValues.aestheticWheelColors +
                            ThemeColorValues.splurgeWheelColors +
                            ThemeColorValues.standardWheelColors

        for hex in allWheelColors {
            XCTAssertEqual(hex.count, 6, "Wheel color '\(hex)' should be 6 characters")
            XCTAssertTrue(
                hex.allSatisfy { $0.isHexDigit },
                "Wheel color '\(hex)' should contain only hex digits"
            )
        }
    }

    // MARK: - Array Length Tests

    func test_aestheticWheelColors_has8Colors() {
        XCTAssertEqual(ThemeColorValues.aestheticWheelColors.count, 8)
    }

    func test_splurgeWheelColors_has6Colors() {
        XCTAssertEqual(ThemeColorValues.splurgeWheelColors.count, 6)
    }

    func test_standardWheelColors_has8Colors() {
        XCTAssertEqual(ThemeColorValues.standardWheelColors.count, 8)
    }

    // MARK: - Light Mode Color Value Tests

    func test_background_light_isWarmCream() {
        XCTAssertEqual(ThemeColorValues.Background.light, "F0EFE9")
    }

    func test_cardBackground_light_isWhite() {
        XCTAssertEqual(ThemeColorValues.CardBackground.light, "FFFFFF")
    }

    func test_title_light_isMutedCharcoal() {
        XCTAssertEqual(ThemeColorValues.Title.light, "5E5B52")
    }

    func test_primaryButton_isDustyRose() {
        XCTAssertEqual(ThemeColorValues.PrimaryButton.light, "C8A299")
    }

    // MARK: - Dark Mode Color Value Tests

    func test_background_dark_isSystemDark() {
        XCTAssertEqual(ThemeColorValues.Background.dark, "1C1C1E")
    }

    func test_cardBackground_dark_isElevatedSurface() {
        XCTAssertEqual(ThemeColorValues.CardBackground.dark, "2C2C2E")
    }

    func test_title_dark_isLightGray() {
        XCTAssertEqual(ThemeColorValues.Title.dark, "E5E5E5")
    }

    func test_border_dark_isDarkSeparator() {
        XCTAssertEqual(ThemeColorValues.Border.dark, "3A3A3C")
    }

    // MARK: - Brand Colors Consistency Tests

    func test_vibeAesthetic_isRoseCoral() {
        XCTAssertEqual(ThemeColorValues.VibeAesthetic.color, "D98880")
    }

    func test_vibeSplurge_isDeepPurple() {
        XCTAssertEqual(ThemeColorValues.VibeSplurge.color, "884EA0")
    }

    func test_vibeStandard_isMutedGray() {
        XCTAssertEqual(ThemeColorValues.VibeStandard.color, "7F8C8D")
    }

    func test_primaryButton_sameInBothModes() {
        XCTAssertEqual(
            ThemeColorValues.PrimaryButton.light,
            ThemeColorValues.PrimaryButton.dark,
            "Primary button color should be same in both modes (brand color)"
        )
    }

    // MARK: - Contrast Tests

    func test_darkModeBackground_isDarkerThanCardBackground() {
        // Background should be darker than cards for elevation
        let bgLuminance = LuminanceCalculator.relativeLuminance(hex: ThemeColorValues.Background.dark)
        let cardLuminance = LuminanceCalculator.relativeLuminance(hex: ThemeColorValues.CardBackground.dark)

        XCTAssertLessThan(
            bgLuminance,
            cardLuminance,
            "Background should be darker than card for visual elevation"
        )
    }

    func test_lightModeBackground_isLighterThanCardBackground() {
        // In light mode, background is slightly off-white, cards are pure white
        let bgLuminance = LuminanceCalculator.relativeLuminance(hex: ThemeColorValues.Background.light)
        let cardLuminance = LuminanceCalculator.relativeLuminance(hex: ThemeColorValues.CardBackground.light)

        XCTAssertLessThan(
            bgLuminance,
            cardLuminance,
            "Light mode background should be slightly darker than white cards"
        )
    }

    func test_textPrimary_hasGoodContrastWithBackground() {
        // Light mode: dark text on light background
        let lightBgLuminance = LuminanceCalculator.relativeLuminance(hex: ThemeColorValues.Background.light)
        let lightTextLuminance = LuminanceCalculator.relativeLuminance(hex: ThemeColorValues.TextPrimary.light)
        let lightContrast = abs(lightBgLuminance - lightTextLuminance)

        XCTAssertGreaterThan(lightContrast, 0.4, "Light mode text should have good contrast")

        // Dark mode: light text on dark background
        let darkBgLuminance = LuminanceCalculator.relativeLuminance(hex: ThemeColorValues.Background.dark)
        let darkTextLuminance = LuminanceCalculator.relativeLuminance(hex: ThemeColorValues.TextPrimary.dark)
        let darkContrast = abs(darkBgLuminance - darkTextLuminance)

        XCTAssertGreaterThan(darkContrast, 0.7, "Dark mode text should have good contrast")
    }
}
