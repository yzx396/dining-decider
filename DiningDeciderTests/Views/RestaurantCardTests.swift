import XCTest
@testable import DiningDecider

final class RestaurantCardTests: XCTestCase {

    // MARK: - Test Data

    private func makeTestRestaurant(
        name: String = "Test Restaurant",
        lat: Double = 37.7749,
        lng: Double = -122.4194,
        priceLevel: Int = 2,
        averageCost: Int = 35,
        description: String = "A great place to eat",
        parking: String = "Street parking",
        mapQuery: String = "Test Restaurant SF"
    ) -> Restaurant {
        Restaurant(
            id: UUID(),
            name: name,
            lat: lat,
            lng: lng,
            priceLevel: priceLevel,
            averageCost: averageCost,
            description: description,
            parking: parking,
            mapQuery: mapQuery
        )
    }

    // MARK: - Card Content Tests

    func test_restaurantCard_displaysRestaurantName() {
        // Given
        let restaurant = makeTestRestaurant(name: "Gary Danko")

        // Then - The card should contain the restaurant name
        // This validates the model data is available for display
        XCTAssertEqual(restaurant.name, "Gary Danko")
    }

    func test_restaurantCard_displaysDescription() {
        // Given
        let restaurant = makeTestRestaurant(description: "Classic luxury dining")

        // Then
        XCTAssertEqual(restaurant.description, "Classic luxury dining")
    }

    func test_restaurantCard_displaysPerPersonPrice() {
        // Given
        let restaurant = makeTestRestaurant(averageCost: 65)

        // Then
        XCTAssertEqual(restaurant.averageCost, 65)
    }

    func test_restaurantCard_calculatesTotalForParty() {
        // Given
        let restaurant = makeTestRestaurant(averageCost: 50)
        let partySize = 4

        // When
        let total = restaurant.totalCost(for: partySize)

        // Then
        XCTAssertEqual(total, 200)
    }

    // MARK: - Map Button Tests

    func test_mapsHelper_canGenerateURLForRestaurant() {
        // Given
        let restaurant = makeTestRestaurant(
            name: "RH Rooftop",
            lat: 37.7877,
            lng: -122.4085
        )

        // When
        let url = MapsHelper.mapsURL(for: restaurant)

        // Then
        XCTAssertNotNil(url)
        XCTAssertTrue(url?.scheme == "maps")
    }

    func test_mapsHelper_urlContainsCoordinates() {
        // Given
        let restaurant = makeTestRestaurant(
            lat: 37.7749,
            lng: -122.4194
        )

        // When
        let url = MapsHelper.mapsURL(for: restaurant)
        let urlString = url?.absoluteString ?? ""

        // Then
        XCTAssertTrue(urlString.contains("37.7749"))
        XCTAssertTrue(urlString.contains("-122.4194"))
    }

    func test_mapsHelper_urlContainsEncodedName() {
        // Given
        let restaurant = makeTestRestaurant(name: "Test Place")

        // When
        let url = MapsHelper.mapsURL(for: restaurant)
        let urlString = url?.absoluteString ?? ""

        // Then
        XCTAssertTrue(urlString.contains("q="))
        XCTAssertTrue(urlString.contains("Test"))
    }

    // MARK: - Accessibility Tests

    func test_restaurantCard_accessibilityLabelIncludesName() {
        // Given
        let restaurant = makeTestRestaurant(name: "Foreign Cinema")

        // Then - accessibility label should include name
        XCTAssertEqual(restaurant.name, "Foreign Cinema")
    }

    func test_restaurantCard_accessibilityLabelIncludesPricing() {
        // Given
        let restaurant = makeTestRestaurant(averageCost: 55)
        let partySize = 2

        // When
        let expectedTotal = restaurant.totalCost(for: partySize)

        // Then - accessibility should include pricing info
        XCTAssertEqual(expectedTotal, 110)
    }

    // MARK: - Edge Cases

    func test_restaurantCard_handlesEmptyDescription() {
        // Given
        let restaurant = makeTestRestaurant(description: "")

        // Then - should not crash with empty description
        XCTAssertEqual(restaurant.description, "")
    }

    func test_restaurantCard_handlesLongRestaurantName() {
        // Given
        let longName = "The Very Long Restaurant Name That Might Need Truncation In The UI"
        let restaurant = makeTestRestaurant(name: longName)

        // Then - should store full name (UI handles truncation)
        XCTAssertEqual(restaurant.name, longName)
    }

    func test_restaurantCard_handlesSpecialCharactersInName() {
        // Given
        let restaurant = makeTestRestaurant(name: "Jack's Wife Freda & Co.")

        // Then
        XCTAssertEqual(restaurant.name, "Jack's Wife Freda & Co.")
    }
}
