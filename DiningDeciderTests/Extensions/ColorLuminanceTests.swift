import XCTest
import SwiftUI
@testable import DiningDecider

final class ColorLuminanceTests: XCTestCase {

    // MARK: - Relative Luminance Tests

    func test_relativeLuminance_whiteColor_returnsOne() {
        // Given
        let whiteColor = Color.white

        // When
        let luminance = whiteColor.relativeLuminance

        // Then
        XCTAssertEqual(luminance, 1.0, accuracy: 0.01, "White color should have luminance close to 1.0")
    }

    func test_relativeLuminance_blackColor_returnsZero() {
        // Given
        let blackColor = Color.black

        // When
        let luminance = blackColor.relativeLuminance

        // Then
        XCTAssertEqual(luminance, 0.0, accuracy: 0.01, "Black color should have luminance close to 0.0")
    }

    func test_relativeLuminance_lightGrayColor_returnsHighValue() {
        // Given
        let lightGray = Color(hex: "F0F0F0")

        // When
        let luminance = lightGray.relativeLuminance

        // Then
        XCTAssertGreaterThan(luminance, 0.7, "Light gray should have high luminance (>0.7)")
    }

    func test_relativeLuminance_darkGrayColor_returnsLowValue() {
        // Given
        let darkGray = Color(hex: "333333")

        // When
        let luminance = darkGray.relativeLuminance

        // Then
        XCTAssertLessThan(luminance, 0.3, "Dark gray should have low luminance (<0.3)")
    }

    func test_relativeLuminance_mediumGrayColor_returnsMidRange() {
        // Given
        let mediumGray = Color(hex: "808080")

        // When
        let luminance = mediumGray.relativeLuminance

        // Then
        XCTAssertGreaterThan(luminance, 0.2, "Medium gray luminance should be > 0.2")
        XCTAssertLessThan(luminance, 0.6, "Medium gray luminance should be < 0.6")
    }

    // MARK: - Text Color Selection Tests

    func test_contrastTextColor_withWhiteBackground_returnsCharcoalText() {
        // Given
        let whiteBackground = Color.white

        // When
        let textColor = whiteBackground.contrastTextColor

        // Then
        // Compare UIColor representations since Color doesn't have direct equality
        let expectedColor = Color.theme.textPrimary
        XCTAssertEqual(
            UIColor(textColor).cgColor.components,
            UIColor(expectedColor).cgColor.components,
            "White background should get charcoal text (textPrimary)"
        )
    }

    func test_contrastTextColor_withBlackBackground_returnsOffWhiteText() {
        // Given
        let blackBackground = Color.black

        // When
        let textColor = blackBackground.contrastTextColor

        // Then
        let expectedColor = Color.theme.textSecondary
        XCTAssertEqual(
            UIColor(textColor).cgColor.components,
            UIColor(expectedColor).cgColor.components,
            "Black background should get off-white text (textSecondary)"
        )
    }

    func test_contrastTextColor_lightPinkFromAestheticPalette_returnsCharcoalText() {
        // Given - Light pink from Aesthetic wheel (#F5B7B1)
        let lightPink = Color(hex: "F5B7B1")

        // When
        let textColor = lightPink.contrastTextColor

        // Then
        let expectedColor = Color.theme.textPrimary
        XCTAssertEqual(
            UIColor(textColor).cgColor.components,
            UIColor(expectedColor).cgColor.components,
            "Light pink should get charcoal text for readability"
        )
    }

    func test_contrastTextColor_deepPurpleFromSplurgePalette_returnsOffWhiteText() {
        // Given - Deep purple from Splurge wheel (#884EA0)
        let deepPurple = Color(hex: "884EA0")

        // When
        let textColor = deepPurple.contrastTextColor

        // Then
        let expectedColor = Color.theme.textSecondary
        XCTAssertEqual(
            UIColor(textColor).cgColor.components,
            UIColor(expectedColor).cgColor.components,
            "Deep purple should get off-white text for readability"
        )
    }

    func test_contrastTextColor_sageGreenFromStandardPalette_returnsOffWhiteText() {
        // Given - Sage green from Standard wheel (#A4B494)
        // Note: Sage green has luminance ~0.44, which is < 0.5 threshold
        let sageGreen = Color(hex: "A4B494")

        // When
        let textColor = sageGreen.contrastTextColor

        // Then
        let expectedColor = Color.theme.textSecondary
        XCTAssertEqual(
            UIColor(textColor).cgColor.components,
            UIColor(expectedColor).cgColor.components,
            "Sage green (low luminance) should get off-white text for readability"
        )
    }

    func test_contrastTextColor_peachFromAestheticPalette_returnsCharcoalText() {
        // Given - Peach from Aesthetic wheel (#FAD7A0)
        let peach = Color(hex: "FAD7A0")

        // When
        let textColor = peach.contrastTextColor

        // Then
        let expectedColor = Color.theme.textPrimary
        XCTAssertEqual(
            UIColor(textColor).cgColor.components,
            UIColor(expectedColor).cgColor.components,
            "Peach should get charcoal text for readability"
        )
    }

    func test_contrastTextColor_darkPurpleFromSplurgePalette_returnsOffWhiteText() {
        // Given - Darker purple from Splurge wheel (#5B2C6F)
        let darkPurple = Color(hex: "5B2C6F")

        // When
        let textColor = darkPurple.contrastTextColor

        // Then
        let expectedColor = Color.theme.textSecondary
        XCTAssertEqual(
            UIColor(textColor).cgColor.components,
            UIColor(expectedColor).cgColor.components,
            "Dark purple should get off-white text for readability"
        )
    }

    // MARK: - Edge Cases & Validation Tests

    func test_relativeLuminance_allWheelPaletteColors_areWithinValidRange() {
        // Given - All colors from all three palettes
        let allColors = Color.theme.aestheticWheelColors +
                       Color.theme.splurgeWheelColors +
                       Color.theme.standardWheelColors

        // When & Then
        for color in allColors {
            let luminance = color.relativeLuminance
            XCTAssertGreaterThanOrEqual(luminance, 0.0, "Luminance should be >= 0.0")
            XCTAssertLessThanOrEqual(luminance, 1.0, "Luminance should be <= 1.0")
        }
    }

    func test_contrastTextColor_isAlwaysEitherCharcoalOrOffWhite() {
        // Given - Sample colors across the luminance spectrum
        let testColors = [
            Color.white,
            Color(hex: "F0F0F0"),
            Color(hex: "CCCCCC"),
            Color(hex: "808080"),
            Color(hex: "555555"),
            Color(hex: "333333"),
            Color.black
        ]

        let charcoal = UIColor(Color.theme.textPrimary)
        let offWhite = UIColor(Color.theme.textSecondary)

        // When & Then
        for color in testColors {
            let textColor = UIColor(color.contrastTextColor)
            let isCharcoal = textColor.cgColor.components == charcoal.cgColor.components
            let isOffWhite = textColor.cgColor.components == offWhite.cgColor.components

            XCTAssertTrue(
                isCharcoal || isOffWhite,
                "Text color should always be either charcoal or off-white, got \(textColor)"
            )
        }
    }

    func test_contrastTextColor_atThresholdBoundary_selectsCorrectColor() {
        // Given - A color near the 0.5 luminance threshold
        // RGB(186, 186, 186) has luminance very close to 0.5
        let nearThreshold = Color(hex: "BABABA")

        // When
        let textColor = nearThreshold.contrastTextColor
        let luminance = nearThreshold.relativeLuminance

        // Then
        if luminance > 0.5 {
            XCTAssertEqual(
                UIColor(textColor).cgColor.components,
                UIColor(Color.theme.textPrimary).cgColor.components,
                "Luminance slightly above 0.5 should get charcoal text"
            )
        } else {
            XCTAssertEqual(
                UIColor(textColor).cgColor.components,
                UIColor(Color.theme.textSecondary).cgColor.components,
                "Luminance at or below 0.5 should get off-white text"
            )
        }
    }

    func test_relativeLuminance_withThemeBackground_returnsExpectedValue() {
        // Given - The app's main background color
        let background = Color.theme.background

        // When
        let luminance = background.relativeLuminance

        // Then - Should be a light color (high luminance)
        XCTAssertGreaterThan(luminance, 0.7, "Theme background should have high luminance")
    }
}
