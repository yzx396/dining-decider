import XCTest
import CoreLocation
@testable import DiningDeciderCore

final class RestaurantTests: XCTestCase {

    // MARK: - Initialization Tests

    func test_restaurant_canBeInitialized() {
        // Given/When
        let restaurant = Restaurant(
            id: UUID(),
            name: "Test Restaurant",
            lat: 37.7749,
            lng: -122.4194,
            priceLevel: 2,
            averageCost: 25,
            description: "A great place to eat",
            parking: "Street parking",
            mapQuery: "Test Restaurant SF"
        )

        // Then
        XCTAssertEqual(restaurant.name, "Test Restaurant")
        XCTAssertEqual(restaurant.priceLevel, 2)
        XCTAssertEqual(restaurant.averageCost, 25)
    }

    func test_restaurant_coordinateProperty_returnsCorrectCoordinate() {
        // Given
        let restaurant = Restaurant(
            id: UUID(),
            name: "Test",
            lat: 37.7749,
            lng: -122.4194,
            priceLevel: 2,
            averageCost: 25,
            description: "Test",
            parking: "None",
            mapQuery: "Test"
        )

        // When
        let coordinate = restaurant.coordinate

        // Then
        XCTAssertEqual(coordinate.latitude, 37.7749, accuracy: 0.0001)
        XCTAssertEqual(coordinate.longitude, -122.4194, accuracy: 0.0001)
    }

    // MARK: - Identifiable Tests

    func test_restaurant_isIdentifiable() {
        // Given
        let id = UUID()
        let restaurant = Restaurant(
            id: id,
            name: "Test",
            lat: 0,
            lng: 0,
            priceLevel: 1,
            averageCost: 10,
            description: "",
            parking: "",
            mapQuery: ""
        )

        // Then
        XCTAssertEqual(restaurant.id, id)
    }

    // MARK: - Total Cost Calculation

    func test_restaurant_totalCost_calculatesCorrectly() {
        // Given
        let restaurant = Restaurant(
            id: UUID(),
            name: "Test",
            lat: 0,
            lng: 0,
            priceLevel: 3,
            averageCost: 50,
            description: "",
            parking: "",
            mapQuery: ""
        )
        let partySize = 4

        // When
        let total = restaurant.totalCost(for: partySize)

        // Then
        XCTAssertEqual(total, 200)
    }

    func test_restaurant_totalCost_withOneGuest_equalsAverageCost() {
        let restaurant = makeRestaurant(averageCost: 65)
        XCTAssertEqual(restaurant.totalCost(for: 1), 65)
    }

    func test_restaurant_totalCost_withZeroGuests_returnsZero() {
        let restaurant = makeRestaurant(averageCost: 50)
        XCTAssertEqual(restaurant.totalCost(for: 0), 0)
    }

    // MARK: - Price Level Tag Tests

    func test_priceLevelTag_level4_returnsLuxury() {
        let restaurant = makeRestaurant(priceLevel: 4)
        let tag = restaurant.priceLevelTag
        XCTAssertEqual(tag.emoji, "💎")
        XCTAssertEqual(tag.label, "Luxury")
    }

    func test_priceLevelTag_level3_returnsPremium() {
        let restaurant = makeRestaurant(priceLevel: 3)
        let tag = restaurant.priceLevelTag
        XCTAssertEqual(tag.emoji, "✨")
        XCTAssertEqual(tag.label, "Premium")
    }

    func test_priceLevelTag_level2_returnsAesthetic() {
        let restaurant = makeRestaurant(priceLevel: 2)
        let tag = restaurant.priceLevelTag
        XCTAssertEqual(tag.emoji, "📸")
        XCTAssertEqual(tag.label, "Aesthetic")
    }

    func test_priceLevelTag_level1_returnsValue() {
        let restaurant = makeRestaurant(priceLevel: 1)
        let tag = restaurant.priceLevelTag
        XCTAssertEqual(tag.emoji, "💰")
        XCTAssertEqual(tag.label, "Value")
    }

    func test_priceLevelTag_invalidLevel_defaultsToValue() {
        let restaurant = makeRestaurant(priceLevel: 0)
        let tag = restaurant.priceLevelTag
        XCTAssertEqual(tag.emoji, "💰")
        XCTAssertEqual(tag.label, "Value")
    }

    func test_priceLevelTag_negativelevel_defaultsToValue() {
        let restaurant = makeRestaurant(priceLevel: -1)
        let tag = restaurant.priceLevelTag
        XCTAssertEqual(tag, .value)
    }

    // MARK: - Parking Info Tests

    func test_hasParkingInfo_withParking_returnsTrue() {
        let restaurant = makeRestaurant(parking: "Valet available")
        XCTAssertTrue(restaurant.hasParkingInfo)
    }

    func test_hasParkingInfo_withEmptyString_returnsFalse() {
        let restaurant = makeRestaurant(parking: "")
        XCTAssertFalse(restaurant.hasParkingInfo)
    }

    func test_hasParkingInfo_withWhitespaceOnly_returnsFalse() {
        let restaurant = makeRestaurant(parking: "   ")
        XCTAssertFalse(restaurant.hasParkingInfo)
    }

    // MARK: - PriceLevelTag Tests

    func test_priceLevelTag_displayText_combinesEmojiAndLabel() {
        XCTAssertEqual(PriceLevelTag.luxury.displayText, "💎 Luxury")
        XCTAssertEqual(PriceLevelTag.premium.displayText, "✨ Premium")
        XCTAssertEqual(PriceLevelTag.aesthetic.displayText, "📸 Aesthetic")
        XCTAssertEqual(PriceLevelTag.value.displayText, "💰 Value")
    }

    func test_priceLevelTag_equality() {
        let tag1 = PriceLevelTag(emoji: "💎", label: "Luxury")
        let tag2 = PriceLevelTag.luxury
        XCTAssertEqual(tag1, tag2)
    }

    // MARK: - Edge Cases

    func test_restaurant_handlesEmptyDescription() {
        let restaurant = makeRestaurant(description: "")
        XCTAssertEqual(restaurant.description, "")
    }

    func test_restaurant_handlesLongName() {
        let longName = "The Very Long Restaurant Name That Might Need Truncation In The UI"
        let restaurant = makeRestaurant(name: longName)
        XCTAssertEqual(restaurant.name, longName)
    }

    func test_restaurant_handlesSpecialCharactersInName() {
        let restaurant = makeRestaurant(name: "Jack's Wife Freda & Co.")
        XCTAssertEqual(restaurant.name, "Jack's Wife Freda & Co.")
    }

    // MARK: - Helper

    private func makeRestaurant(
        name: String = "Test Restaurant",
        priceLevel: Int = 2,
        averageCost: Int = 35,
        description: String = "Test description",
        parking: String = "Street parking"
    ) -> Restaurant {
        Restaurant(
            id: UUID(),
            name: name,
            lat: 37.7749,
            lng: -122.4194,
            priceLevel: priceLevel,
            averageCost: averageCost,
            description: description,
            parking: parking,
            mapQuery: "Test Restaurant SF"
        )
    }
}
