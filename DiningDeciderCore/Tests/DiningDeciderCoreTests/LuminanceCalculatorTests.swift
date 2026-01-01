import XCTest
@testable import DiningDeciderCore

/// Tests for LuminanceCalculator - pure math, no simulator required
final class LuminanceCalculatorTests: XCTestCase {

    // MARK: - Relative Luminance Tests

    func test_relativeLuminance_white_returnsOne() {
        let luminance = LuminanceCalculator.relativeLuminance(red: 1.0, green: 1.0, blue: 1.0)
        XCTAssertEqual(luminance, 1.0, accuracy: 0.01)
    }

    func test_relativeLuminance_black_returnsZero() {
        let luminance = LuminanceCalculator.relativeLuminance(red: 0.0, green: 0.0, blue: 0.0)
        XCTAssertEqual(luminance, 0.0, accuracy: 0.01)
    }

    func test_relativeLuminance_pureRed_returnsExpectedValue() {
        // Pure red has luminance of 0.2126 (the red coefficient)
        let luminance = LuminanceCalculator.relativeLuminance(red: 1.0, green: 0.0, blue: 0.0)
        XCTAssertEqual(luminance, 0.2126, accuracy: 0.01)
    }

    func test_relativeLuminance_pureGreen_returnsExpectedValue() {
        // Pure green has luminance of 0.7152 (the green coefficient)
        let luminance = LuminanceCalculator.relativeLuminance(red: 0.0, green: 1.0, blue: 0.0)
        XCTAssertEqual(luminance, 0.7152, accuracy: 0.01)
    }

    func test_relativeLuminance_pureBlue_returnsExpectedValue() {
        // Pure blue has luminance of 0.0722 (the blue coefficient)
        let luminance = LuminanceCalculator.relativeLuminance(red: 0.0, green: 0.0, blue: 1.0)
        XCTAssertEqual(luminance, 0.0722, accuracy: 0.01)
    }

    func test_relativeLuminance_midGray_returnsMidRange() {
        // 50% gray (0.5, 0.5, 0.5) should be around 0.21 due to gamma
        let luminance = LuminanceCalculator.relativeLuminance(red: 0.5, green: 0.5, blue: 0.5)
        XCTAssertGreaterThan(luminance, 0.1)
        XCTAssertLessThan(luminance, 0.3)
    }

    // MARK: - Hex Color Luminance Tests

    func test_relativeLuminance_hexWhite_returnsOne() {
        let luminance = LuminanceCalculator.relativeLuminance(hex: "FFFFFF")
        XCTAssertEqual(luminance, 1.0, accuracy: 0.01)
    }

    func test_relativeLuminance_hexBlack_returnsZero() {
        let luminance = LuminanceCalculator.relativeLuminance(hex: "000000")
        XCTAssertEqual(luminance, 0.0, accuracy: 0.01)
    }

    func test_relativeLuminance_hexWithHashPrefix_works() {
        let luminance = LuminanceCalculator.relativeLuminance(hex: "#FFFFFF")
        XCTAssertEqual(luminance, 1.0, accuracy: 0.01)
    }

    func test_relativeLuminance_lightGray_isHigh() {
        let luminance = LuminanceCalculator.relativeLuminance(hex: "F0F0F0")
        XCTAssertGreaterThan(luminance, 0.7)
    }

    func test_relativeLuminance_darkGray_isLow() {
        let luminance = LuminanceCalculator.relativeLuminance(hex: "333333")
        XCTAssertLessThan(luminance, 0.1)
    }

    // MARK: - Should Use Dark Text Tests

    func test_shouldUseDarkText_lightBackground_returnsTrue() {
        // Light backgrounds should use dark text
        XCTAssertTrue(LuminanceCalculator.shouldUseDarkText(forLuminance: 0.8))
        XCTAssertTrue(LuminanceCalculator.shouldUseDarkText(forLuminance: 0.6))
        XCTAssertTrue(LuminanceCalculator.shouldUseDarkText(forLuminance: 0.51))
    }

    func test_shouldUseDarkText_darkBackground_returnsFalse() {
        // Dark backgrounds should use light text
        XCTAssertFalse(LuminanceCalculator.shouldUseDarkText(forLuminance: 0.2))
        XCTAssertFalse(LuminanceCalculator.shouldUseDarkText(forLuminance: 0.4))
        XCTAssertFalse(LuminanceCalculator.shouldUseDarkText(forLuminance: 0.5))
    }

    func test_shouldUseDarkText_threshold_isFiftyPercent() {
        // Exactly 0.5 should use light text (not dark)
        XCTAssertFalse(LuminanceCalculator.shouldUseDarkText(forLuminance: 0.5))
        // Just above 0.5 should use dark text
        XCTAssertTrue(LuminanceCalculator.shouldUseDarkText(forLuminance: 0.500001))
    }

    func test_shouldUseDarkText_withRGBComponents_works() {
        // White background - should use dark text
        XCTAssertTrue(LuminanceCalculator.shouldUseDarkText(red: 1.0, green: 1.0, blue: 1.0))
        // Black background - should use light text
        XCTAssertFalse(LuminanceCalculator.shouldUseDarkText(red: 0.0, green: 0.0, blue: 0.0))
    }

    // MARK: - RGB Components from Hex Tests

    func test_rgbComponents_white_returnsAllOnes() {
        let components = LuminanceCalculator.rgbComponents(from: "FFFFFF")
        XCTAssertEqual(components.red, 1.0, accuracy: 0.001)
        XCTAssertEqual(components.green, 1.0, accuracy: 0.001)
        XCTAssertEqual(components.blue, 1.0, accuracy: 0.001)
    }

    func test_rgbComponents_black_returnsAllZeros() {
        let components = LuminanceCalculator.rgbComponents(from: "000000")
        XCTAssertEqual(components.red, 0.0, accuracy: 0.001)
        XCTAssertEqual(components.green, 0.0, accuracy: 0.001)
        XCTAssertEqual(components.blue, 0.0, accuracy: 0.001)
    }

    func test_rgbComponents_pureRed_returnsCorrectValues() {
        let components = LuminanceCalculator.rgbComponents(from: "FF0000")
        XCTAssertEqual(components.red, 1.0, accuracy: 0.001)
        XCTAssertEqual(components.green, 0.0, accuracy: 0.001)
        XCTAssertEqual(components.blue, 0.0, accuracy: 0.001)
    }

    func test_rgbComponents_midGray_returnsHalfValues() {
        let components = LuminanceCalculator.rgbComponents(from: "808080")
        XCTAssertEqual(components.red, 128.0 / 255.0, accuracy: 0.001)
        XCTAssertEqual(components.green, 128.0 / 255.0, accuracy: 0.001)
        XCTAssertEqual(components.blue, 128.0 / 255.0, accuracy: 0.001)
    }

    // MARK: - App Theme Color Tests

    func test_aestheticColors_haveLightLuminance() {
        // Aesthetic palette should be mostly light colors
        let aestheticHexColors = ["E6B0AA", "D98880", "F1948A", "C39BD3", "F5B7B1", "FAD7A0", "E8DAEF", "D7BDE2"]
        
        for hex in aestheticHexColors {
            let luminance = LuminanceCalculator.relativeLuminance(hex: hex)
            XCTAssertGreaterThan(luminance, 0.3, "Aesthetic color \(hex) should have luminance > 0.3")
        }
    }

    func test_splurgeColors_haveVariedLuminance() {
        // Splurge palette has darker purples
        let darkPurples = ["884EA0", "7D3C98", "5B2C6F"]
        let lightPurples = ["D2B4DE"]
        let mediumPurples = ["AF7AC5", "A569BD"]
        
        for hex in darkPurples {
            let luminance = LuminanceCalculator.relativeLuminance(hex: hex)
            XCTAssertLessThan(luminance, 0.5, "Dark purple \(hex) should have luminance < 0.5")
        }
        
        for hex in lightPurples {
            let luminance = LuminanceCalculator.relativeLuminance(hex: hex)
            XCTAssertGreaterThan(luminance, 0.5, "Light purple \(hex) should have luminance > 0.5")
        }
        
        for hex in mediumPurples {
            let luminance = LuminanceCalculator.relativeLuminance(hex: hex)
            XCTAssertGreaterThan(luminance, 0.2, "Medium purple \(hex) should have luminance > 0.2")
        }
    }

    func test_backgroundColorF0EFE9_isLight() {
        // App background #F0EFE9 should be light
        let luminance = LuminanceCalculator.relativeLuminance(hex: "F0EFE9")
        XCTAssertGreaterThan(luminance, 0.7, "Background should be a light color")
        XCTAssertTrue(LuminanceCalculator.shouldUseDarkText(forLuminance: luminance))
    }

    // MARK: - Edge Cases

    func test_relativeLuminance_invalidHex_returnsZero() {
        let luminance = LuminanceCalculator.relativeLuminance(hex: "invalid")
        XCTAssertEqual(luminance, 0.0, accuracy: 0.001)
    }

    func test_relativeLuminance_emptyHex_returnsZero() {
        let luminance = LuminanceCalculator.relativeLuminance(hex: "")
        XCTAssertEqual(luminance, 0.0, accuracy: 0.001)
    }
}
