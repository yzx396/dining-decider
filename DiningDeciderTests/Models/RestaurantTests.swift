import XCTest
import CoreLocation
@testable import DiningDecider

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

    // MARK: - Price Level Tag Tests

    func test_priceLevelTag_level4_returnsLuxury() {
        // Given
        let restaurant = makeRestaurant(priceLevel: 4)

        // When
        let tag = restaurant.priceLevelTag

        // Then
        XCTAssertEqual(tag.emoji, "💎")
        XCTAssertEqual(tag.label, "Luxury")
    }

    func test_priceLevelTag_level3_returnsPremium() {
        // Given
        let restaurant = makeRestaurant(priceLevel: 3)

        // When
        let tag = restaurant.priceLevelTag

        // Then
        XCTAssertEqual(tag.emoji, "✨")
        XCTAssertEqual(tag.label, "Premium")
    }

    func test_priceLevelTag_level2_returnsAesthetic() {
        // Given
        let restaurant = makeRestaurant(priceLevel: 2)

        // When
        let tag = restaurant.priceLevelTag

        // Then
        XCTAssertEqual(tag.emoji, "📸")
        XCTAssertEqual(tag.label, "Aesthetic")
    }

    func test_priceLevelTag_level1_returnsValue() {
        // Given
        let restaurant = makeRestaurant(priceLevel: 1)

        // When
        let tag = restaurant.priceLevelTag

        // Then
        XCTAssertEqual(tag.emoji, "💰")
        XCTAssertEqual(tag.label, "Value")
    }

    func test_priceLevelTag_invalidLevel_defaultsToValue() {
        // Given
        let restaurant = makeRestaurant(priceLevel: 0)

        // When
        let tag = restaurant.priceLevelTag

        // Then
        XCTAssertEqual(tag.emoji, "💰")
        XCTAssertEqual(tag.label, "Value")
    }

    // MARK: - Parking Info Tests

    func test_hasParkingInfo_withParking_returnsTrue() {
        // Given
        let restaurant = makeRestaurant(parking: "Valet available")

        // Then
        XCTAssertTrue(restaurant.hasParkingInfo)
    }

    func test_hasParkingInfo_withEmptyString_returnsFalse() {
        // Given
        let restaurant = makeRestaurant(parking: "")

        // Then
        XCTAssertFalse(restaurant.hasParkingInfo)
    }

    func test_hasParkingInfo_withWhitespaceOnly_returnsFalse() {
        // Given
        let restaurant = makeRestaurant(parking: "   ")

        // Then
        XCTAssertFalse(restaurant.hasParkingInfo)
    }

    // MARK: - Helper

    private func makeRestaurant(
        priceLevel: Int = 2,
        parking: String = "Street parking"
    ) -> Restaurant {
        Restaurant(
            id: UUID(),
            name: "Test Restaurant",
            lat: 37.7749,
            lng: -122.4194,
            priceLevel: priceLevel,
            averageCost: 35,
            description: "Test description",
            parking: parking,
            mapQuery: "Test Restaurant SF"
        )
    }
}
