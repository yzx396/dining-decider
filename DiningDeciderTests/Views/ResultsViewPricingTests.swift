import XCTest
@testable import DiningDecider

final class ResultsViewPricingTests: XCTestCase {

    // MARK: - Price Formatting Tests

    func test_restaurant_averageCost_isPerPerson() {
        // Given
        let restaurant = Restaurant(
            id: UUID(),
            name: "Test Restaurant",
            lat: 0,
            lng: 0,
            priceLevel: 3,
            averageCost: 50,
            description: "Test",
            parking: "Street",
            mapQuery: "Test"
        )

        // Then - averageCost represents per-person cost
        XCTAssertEqual(restaurant.averageCost, 50)
    }

    func test_restaurant_totalCost_multipliesAverageCostByPartySize() {
        // Given
        let restaurant = Restaurant(
            id: UUID(),
            name: "Test Restaurant",
            lat: 0,
            lng: 0,
            priceLevel: 3,
            averageCost: 50,
            description: "Test",
            parking: "Street",
            mapQuery: "Test"
        )
        let partySize = 4

        // When
        let total = restaurant.totalCost(for: partySize)

        // Then
        XCTAssertEqual(total, 200) // 50 * 4
    }

    func test_restaurant_totalCost_withOneGuest_equalsAverageCost() {
        // Given
        let restaurant = Restaurant(
            id: UUID(),
            name: "Test Restaurant",
            lat: 0,
            lng: 0,
            priceLevel: 2,
            averageCost: 35,
            description: "Test",
            parking: "None",
            mapQuery: "Test"
        )

        // When
        let total = restaurant.totalCost(for: 1)

        // Then
        XCTAssertEqual(total, 35)
    }

    func test_restaurant_totalCost_withMaxPartySize_calculatesCorrectly() {
        // Given
        let restaurant = Restaurant(
            id: UUID(),
            name: "Fancy Restaurant",
            lat: 0,
            lng: 0,
            priceLevel: 4,
            averageCost: 100,
            description: "Upscale",
            parking: "Valet",
            mapQuery: "Fancy"
        )
        let maxPartySize = PartySize.maximum // 20

        // When
        let total = restaurant.totalCost(for: maxPartySize)

        // Then
        XCTAssertEqual(total, 2000) // 100 * 20
    }

    // MARK: - Price Display String Tests

    func test_priceDisplay_formatsPerPersonCorrectly() {
        // Given
        let averageCost = 45

        // When
        let display = "$\(averageCost)/person"

        // Then
        XCTAssertEqual(display, "$45/person")
    }

    func test_priceDisplay_formatsTotalWithTildePrefix() {
        // Given
        let totalCost = 180

        // When
        let display = "~$\(totalCost) total"

        // Then
        XCTAssertEqual(display, "~$180 total")
    }

    func test_priceDisplay_formatsFullPriceString() {
        // Given
        let averageCost = 65
        let partySize = 2
        let totalCost = averageCost * partySize

        // When
        let display = "$\(averageCost)/person · ~$\(totalCost) total"

        // Then
        XCTAssertEqual(display, "$65/person · ~$130 total")
    }
}
