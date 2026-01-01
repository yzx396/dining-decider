import XCTest
@testable import DiningDeciderCore

final class VibeModeTests: XCTestCase {

    // MARK: - Display Name Tests

    func test_displayName_aesthetic_returnsPrettyPics() {
        XCTAssertEqual(VibeMode.aesthetic.displayName, "Pretty Pics")
    }

    func test_displayName_splurge_returnsSplurge() {
        XCTAssertEqual(VibeMode.splurge.displayName, "Splurge")
    }

    func test_displayName_standard_returnsHungry() {
        XCTAssertEqual(VibeMode.standard.displayName, "Hungry")
    }

    // MARK: - Emoji Tests

    func test_emoji_aesthetic_returnsSparkles() {
        XCTAssertEqual(VibeMode.aesthetic.emoji, "✨")
    }

    func test_emoji_splurge_returnsMoneyWings() {
        XCTAssertEqual(VibeMode.splurge.emoji, "💸")
    }

    func test_emoji_standard_returnsNoodleBowl() {
        XCTAssertEqual(VibeMode.standard.emoji, "🍜")
    }

    // MARK: - Sector Count Tests

    func test_sectorCount_aesthetic_returns8() {
        XCTAssertEqual(VibeMode.aesthetic.sectorCount, 8)
    }

    func test_sectorCount_splurge_returns6() {
        XCTAssertEqual(VibeMode.splurge.sectorCount, 6)
    }

    func test_sectorCount_standard_returns8() {
        XCTAssertEqual(VibeMode.standard.sectorCount, 8)
    }

    // MARK: - Sector Labels Tests

    func test_sectorLabels_aesthetic_containsAestheticCategories() {
        let labels = VibeMode.aesthetic.sectorLabels
        XCTAssertEqual(labels.count, 8)
        XCTAssertTrue(labels.contains("Garden Cafe"))
        XCTAssertTrue(labels.contains("Floral Brunch"))
        XCTAssertTrue(labels.contains("Rooftop"))
    }

    func test_sectorLabels_splurge_containsSplurgeCategories() {
        let labels = VibeMode.splurge.sectorLabels
        XCTAssertEqual(labels.count, 6)
        XCTAssertTrue(labels.contains("Seafood"))
        XCTAssertTrue(labels.contains("Steakhouse"))
        XCTAssertTrue(labels.contains("Omakase"))
    }

    func test_sectorLabels_standard_containsStandardCategories() {
        let labels = VibeMode.standard.sectorLabels
        XCTAssertEqual(labels.count, 8)
        XCTAssertTrue(labels.contains("Hot Pot"))
        XCTAssertTrue(labels.contains("Noodles"))
        XCTAssertTrue(labels.contains("Korean BBQ"))
    }

    // MARK: - Price Level Filtering Tests

    func test_allowedPriceLevels_aesthetic_allowsAllLevels() {
        XCTAssertEqual(VibeMode.aesthetic.allowedPriceLevels, [1, 2, 3, 4])
    }

    func test_allowedPriceLevels_splurge_allowsOnlyHighPrices() {
        XCTAssertEqual(VibeMode.splurge.allowedPriceLevels, [3, 4])
    }

    func test_allowedPriceLevels_standard_allowsOnlyLowPrices() {
        XCTAssertEqual(VibeMode.standard.allowedPriceLevels, [1, 2])
    }

    func test_allowsPriceLevel_aesthetic_allowsLevel1() {
        XCTAssertTrue(VibeMode.aesthetic.allowsPriceLevel(1))
    }

    func test_allowsPriceLevel_aesthetic_allowsLevel4() {
        XCTAssertTrue(VibeMode.aesthetic.allowsPriceLevel(4))
    }

    func test_allowsPriceLevel_splurge_deniesLevel1() {
        XCTAssertFalse(VibeMode.splurge.allowsPriceLevel(1))
    }

    func test_allowsPriceLevel_splurge_deniesLevel2() {
        XCTAssertFalse(VibeMode.splurge.allowsPriceLevel(2))
    }

    func test_allowsPriceLevel_splurge_allowsLevel3() {
        XCTAssertTrue(VibeMode.splurge.allowsPriceLevel(3))
    }

    func test_allowsPriceLevel_splurge_allowsLevel4() {
        XCTAssertTrue(VibeMode.splurge.allowsPriceLevel(4))
    }

    func test_allowsPriceLevel_standard_allowsLevel1() {
        XCTAssertTrue(VibeMode.standard.allowsPriceLevel(1))
    }

    func test_allowsPriceLevel_standard_allowsLevel2() {
        XCTAssertTrue(VibeMode.standard.allowsPriceLevel(2))
    }

    func test_allowsPriceLevel_standard_deniesLevel3() {
        XCTAssertFalse(VibeMode.standard.allowsPriceLevel(3))
    }

    func test_allowsPriceLevel_standard_deniesLevel4() {
        XCTAssertFalse(VibeMode.standard.allowsPriceLevel(4))
    }

    // MARK: - Default Value Tests

    func test_defaultVibe_isAesthetic() {
        XCTAssertEqual(VibeMode.defaultVibe, .aesthetic)
    }

    // MARK: - CaseIterable Tests

    func test_allCases_containsThreeVibes() {
        XCTAssertEqual(VibeMode.allCases.count, 3)
    }

    func test_allCases_inCorrectOrder() {
        XCTAssertEqual(VibeMode.allCases, [.aesthetic, .splurge, .standard])
    }

    // MARK: - Identifiable Tests

    func test_id_returnsRawValue() {
        XCTAssertEqual(VibeMode.aesthetic.id, "aesthetic")
        XCTAssertEqual(VibeMode.splurge.id, "splurge")
        XCTAssertEqual(VibeMode.standard.id, "standard")
    }

    // MARK: - Button Label Format Tests

    func test_buttonLabel_aesthetic_hasCorrectFormat() {
        let vibe = VibeMode.aesthetic
        XCTAssertEqual("\(vibe.emoji) \(vibe.displayName)", "✨ Pretty Pics")
    }

    func test_buttonLabel_splurge_hasCorrectFormat() {
        let vibe = VibeMode.splurge
        XCTAssertEqual("\(vibe.emoji) \(vibe.displayName)", "💸 Splurge")
    }

    func test_buttonLabel_standard_hasCorrectFormat() {
        let vibe = VibeMode.standard
        XCTAssertEqual("\(vibe.emoji) \(vibe.displayName)", "🍜 Hungry")
    }
}
