import XCTest
import SwiftUI
@testable import DiningDecider

final class ColorLuminanceTests: XCTestCase {
    // Cache UIColor conversions to avoid expensive repeated conversions
    private let charcoalUIColor = UIColor(Color.theme.textPrimary)
    private let offWhiteUIColor = UIColor(Color.theme.textSecondary)

    private lazy var charcoalComponents = charcoalUIColor.cgColor.components
    private lazy var offWhiteComponents = offWhiteUIColor.cgColor.components

    // MARK: - Relative Luminance Tests

    func test_relativeLuminance_extremeAndMidRangeValues() {
        // Test white, black, and grays in single test to reduce setup overhead
        let testCases: [(color: Color, minLuminance: Double?, maxLuminance: Double?, description: String)] = [
            (Color.white, 0.99, 1.0, "White"),
            (Color.black, 0.0, 0.01, "Black"),
            (Color(hex: "F0F0F0"), 0.7, 1.0, "Light gray"),
            (Color(hex: "333333"), 0.0, 0.3, "Dark gray"),
            (Color(hex: "808080"), 0.2, 0.6, "Medium gray"),
        ]

        for testCase in testCases {
            let luminance = testCase.color.relativeLuminance

            if let min = testCase.minLuminance {
                XCTAssertGreaterThanOrEqual(luminance, min, "\(testCase.description): luminance should be >= \(min)")
            }
            if let max = testCase.maxLuminance {
                XCTAssertLessThanOrEqual(luminance, max, "\(testCase.description): luminance should be <= \(max)")
            }
        }
    }

    // MARK: - Text Color Selection Tests

    func test_contrastTextColor_lightBackgrounds_returnCharcoalText() {
        // Combine multiple light color tests to reduce setup overhead
        let lightColors: [(color: Color, description: String)] = [
            (Color.white, "White"),
            (Color(hex: "F5B7B1"), "Light pink (Aesthetic)"),
            (Color(hex: "FAD7A0"), "Peach (Aesthetic)"),
        ]

        for testCase in lightColors {
            let textColor = testCase.color.contrastTextColor
            let textUIColor = UIColor(textColor)

            XCTAssertEqual(
                textUIColor.cgColor.components,
                charcoalComponents,
                "\(testCase.description) should get charcoal text"
            )
        }
    }

    func test_contrastTextColor_darkBackgrounds_returnOffWhiteText() {
        // Combine multiple dark color tests to reduce setup overhead
        let darkColors: [(color: Color, description: String)] = [
            (Color.black, "Black"),
            (Color(hex: "884EA0"), "Deep purple (Splurge)"),
            (Color(hex: "5B2C6F"), "Darker purple (Splurge)"),
            (Color(hex: "A4B494"), "Sage green (Standard, luminance ~0.44)"),
        ]

        for testCase in darkColors {
            let textColor = testCase.color.contrastTextColor
            let textUIColor = UIColor(textColor)

            XCTAssertEqual(
                textUIColor.cgColor.components,
                offWhiteComponents,
                "\(testCase.description) should get off-white text"
            )
        }
    }

    // MARK: - Edge Cases & Validation Tests

    func test_relativeLuminance_andTextColor_comprehensiveValidation() {
        // Single comprehensive test combining multiple edge cases
        let allColors = Color.theme.aestheticWheelColors +
                       Color.theme.splurgeWheelColors +
                       Color.theme.standardWheelColors

        // Validate luminance ranges for all palette colors
        for color in allColors {
            let luminance = color.relativeLuminance
            XCTAssertGreaterThanOrEqual(luminance, 0.0, "Luminance should be >= 0.0")
            XCTAssertLessThanOrEqual(luminance, 1.0, "Luminance should be <= 1.0")
        }

        // Validate text color selection across spectrum in single test
        let testColors = [
            Color.white, Color(hex: "F0F0F0"), Color(hex: "CCCCCC"),
            Color(hex: "808080"), Color(hex: "555555"), Color(hex: "333333"), Color.black
        ]

        for color in testColors {
            let textColor = UIColor(color.contrastTextColor)
            let isCharcoal = textColor.cgColor.components == charcoalComponents
            let isOffWhite = textColor.cgColor.components == offWhiteComponents

            XCTAssertTrue(
                isCharcoal || isOffWhite,
                "Color should select either charcoal or off-white"
            )
        }

        // Validate theme background has expected brightness
        let bgLuminance = Color.theme.background.relativeLuminance
        XCTAssertGreaterThan(bgLuminance, 0.7, "Theme background should be light")

        // Validate threshold boundary behavior
        let nearThreshold = Color(hex: "BABABA")
        let thresholdLuminance = nearThreshold.relativeLuminance
        let thresholdTextColor = UIColor(nearThreshold.contrastTextColor)

        if thresholdLuminance > 0.5 {
            XCTAssertEqual(
                thresholdTextColor.cgColor.components,
                charcoalComponents,
                "Luminance above 0.5 should get charcoal"
            )
        } else {
            XCTAssertEqual(
                thresholdTextColor.cgColor.components,
                offWhiteComponents,
                "Luminance at/below 0.5 should get off-white"
            )
        }
    }
}
