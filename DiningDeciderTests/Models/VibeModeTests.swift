import XCTest
@testable import DiningDecider

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

    // MARK: - Categories Tests

    func test_sectors_aesthetic_returns8Sectors() {
        XCTAssertEqual(VibeMode.aesthetic.sectors.count, 8)
    }

    func test_sectors_aesthetic_containsAestheticCategories() {
        let categories = VibeMode.aesthetic.sectors.map { $0.label }
        XCTAssertTrue(categories.contains("Garden Cafe"))
        XCTAssertTrue(categories.contains("Floral Brunch"))
        XCTAssertTrue(categories.contains("Rooftop"))
    }

    func test_sectors_splurge_returns6Sectors() {
        XCTAssertEqual(VibeMode.splurge.sectors.count, 6)
    }

    func test_sectors_splurge_containsSplurgeCategories() {
        let categories = VibeMode.splurge.sectors.map { $0.label }
        XCTAssertTrue(categories.contains("Seafood"))
        XCTAssertTrue(categories.contains("Steakhouse"))
        XCTAssertTrue(categories.contains("Omakase"))
    }

    func test_sectors_standard_returns8Sectors() {
        XCTAssertEqual(VibeMode.standard.sectors.count, 8)
    }

    func test_sectors_standard_containsStandardCategories() {
        let categories = VibeMode.standard.sectors.map { $0.label }
        XCTAssertTrue(categories.contains("Hot Pot"))
        XCTAssertTrue(categories.contains("Noodles"))
        XCTAssertTrue(categories.contains("Korean BBQ"))
    }

    // MARK: - Price Level Filtering Tests

    func test_allowedPriceLevels_aesthetic_allowsAllLevels() {
        // Aesthetic mode shows all price levels (1-4)
        XCTAssertEqual(VibeMode.aesthetic.allowedPriceLevels, [1, 2, 3, 4])
    }

    func test_allowedPriceLevels_splurge_allowsOnlyHighPrices() {
        // Splurge shows only $$$ / $$$$ restaurants (3-4)
        XCTAssertEqual(VibeMode.splurge.allowedPriceLevels, [3, 4])
    }

    func test_allowedPriceLevels_standard_allowsOnlyLowPrices() {
        // Standard shows only $ / $$ restaurants (1-2)
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
}
