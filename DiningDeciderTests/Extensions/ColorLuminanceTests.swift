import XCTest
import SwiftUI
import DiningDeciderCore
@testable import DiningDecider

/// Integration tests for Color luminance extensions that require UIColor (iOS Simulator).
/// Pure luminance math tests are in LuminanceCalculatorTests.
final class ColorLuminanceTests: XCTestCase {

    // MARK: - Color Extension Integration Tests

    func test_swiftUIColor_relativeLuminance_matchesCalculator() {
        // Verify SwiftUI Color extension produces same results as pure calculator
        let testCases: [(hex: String, description: String)] = [
            ("FFFFFF", "White"),
            ("000000", "Black"),
            ("F0EFE9", "App background"),
            ("D98880", "Aesthetic rose"),
            ("884EA0", "Splurge purple"),
        ]

        for testCase in testCases {
            let color = Color(hex: testCase.hex)
            let colorLuminance = color.relativeLuminance
            let calculatorLuminance = LuminanceCalculator.relativeLuminance(hex: testCase.hex)

            XCTAssertEqual(
                colorLuminance,
                calculatorLuminance,
                accuracy: 0.01,
                "\(testCase.description): Color extension should match calculator"
            )
        }
    }

    // MARK: - Text Color Selection Tests

    func test_contrastTextColor_lightBackgrounds_returnCharcoalText() {
        let lightColors: [(color: Color, description: String)] = [
            (Color.white, "White"),
            (Color(hex: "F5B7B1"), "Light pink (Aesthetic)"),
            (Color(hex: "FAD7A0"), "Peach (Aesthetic)"),
            (Color.theme.background, "App background"),
        ]

        for testCase in lightColors {
            let textColor = testCase.color.contrastTextColor

            XCTAssertEqual(
                textColor,
                Color.theme.textPrimary,
                "\(testCase.description) should get charcoal text"
            )
        }
    }

    func test_contrastTextColor_darkBackgrounds_returnOffWhiteText() {
        let darkColors: [(color: Color, description: String)] = [
            (Color.black, "Black"),
            (Color(hex: "884EA0"), "Deep purple (Splurge)"),
            (Color(hex: "5B2C6F"), "Darker purple (Splurge)"),
        ]

        for testCase in darkColors {
            let textColor = testCase.color.contrastTextColor

            XCTAssertEqual(
                textColor,
                Color.theme.textSecondary,
                "\(testCase.description) should get off-white text"
            )
        }
    }

    // MARK: - Theme Palette Validation

    func test_allWheelColors_haveValidLuminance() {
        let allColors = Color.theme.aestheticWheelColors +
                       Color.theme.splurgeWheelColors +
                       Color.theme.standardWheelColors

        for color in allColors {
            let luminance = color.relativeLuminance
            XCTAssertGreaterThanOrEqual(luminance, 0.0, "Luminance should be >= 0.0")
            XCTAssertLessThanOrEqual(luminance, 1.0, "Luminance should be <= 1.0")
        }
    }

    func test_allWheelColors_selectValidTextColor() {
        let allColors = Color.theme.aestheticWheelColors +
                       Color.theme.splurgeWheelColors +
                       Color.theme.standardWheelColors

        for color in allColors {
            let textColor = color.contrastTextColor
            let isExpectedColor = textColor == Color.theme.textPrimary ||
                                  textColor == Color.theme.textSecondary

            XCTAssertTrue(isExpectedColor, "Should select either charcoal or off-white text")
        }
    }
}
