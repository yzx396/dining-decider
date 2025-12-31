import XCTest
import SwiftUI
@testable import DiningDecider

final class VibeSelectorTests: XCTestCase {

    // MARK: - Initialization Tests

    func test_vibeSelector_hasThreeButtons() {
        // VibeMode.allCases has exactly 3 options
        XCTAssertEqual(VibeMode.allCases.count, 3)
    }

    func test_vibeSelector_defaultsToAesthetic() {
        XCTAssertEqual(VibeMode.defaultVibe, .aesthetic)
    }

    // MARK: - Display Tests

    func test_vibeButton_aesthetic_hasCorrectLabel() {
        let vibe = VibeMode.aesthetic
        XCTAssertEqual("\(vibe.emoji) \(vibe.displayName)", "✨ Pretty Pics")
    }

    func test_vibeButton_splurge_hasCorrectLabel() {
        let vibe = VibeMode.splurge
        XCTAssertEqual("\(vibe.emoji) \(vibe.displayName)", "💸 Splurge")
    }

    func test_vibeButton_standard_hasCorrectLabel() {
        let vibe = VibeMode.standard
        XCTAssertEqual("\(vibe.emoji) \(vibe.displayName)", "🍜 Hungry")
    }

    // MARK: - Color Tests

    func test_aesthetic_selectedColor_isDustyRose() {
        let color = VibeMode.aesthetic.selectedColor
        XCTAssertEqual(color, Color.theme.vibeAesthetic)
    }

    func test_splurge_selectedColor_isDeepPurple() {
        let color = VibeMode.splurge.selectedColor
        XCTAssertEqual(color, Color.theme.vibeSplurge)
    }

    func test_standard_selectedColor_isMutedGray() {
        let color = VibeMode.standard.selectedColor
        XCTAssertEqual(color, Color.theme.vibeStandard)
    }

    // MARK: - Sector Color Tests

    func test_aesthetic_wheelColors_hasCorrectCount() {
        XCTAssertEqual(VibeMode.aesthetic.sectors.count, 8)
    }

    func test_splurge_wheelColors_hasCorrectCount() {
        XCTAssertEqual(VibeMode.splurge.sectors.count, 6)
    }

    func test_standard_wheelColors_hasCorrectCount() {
        XCTAssertEqual(VibeMode.standard.sectors.count, 8)
    }
}
