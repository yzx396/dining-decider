import XCTest
@testable import DiningDecider

final class MapsHelperTests: XCTestCase {

    // MARK: - URL Generation Tests

    func test_mapsURL_withCoordinates_generatesCorrectURL() {
        // Given
        let restaurant = Restaurant(
            id: UUID(),
            name: "Test Restaurant",
            lat: 37.7749,
            lng: -122.4194,
            priceLevel: 2,
            averageCost: 30,
            description: "Test description",
            parking: "Street parking",
            mapQuery: "Test Restaurant SF"
        )

        // When
        let url = MapsHelper.mapsURL(for: restaurant)

        // Then
        XCTAssertNotNil(url)
        XCTAssertTrue(url?.absoluteString.contains("maps://") == true)
        XCTAssertTrue(url?.absoluteString.contains("37.7749") == true)
        XCTAssertTrue(url?.absoluteString.contains("-122.4194") == true)
    }

    func test_mapsURL_includesRestaurantNameAsQuery() {
        // Given
        let restaurant = Restaurant(
            id: UUID(),
            name: "Gary Danko",
            lat: 37.8059,
            lng: -122.4209,
            priceLevel: 4,
            averageCost: 170,
            description: "Classic luxury",
            parking: "Valet",
            mapQuery: "Gary Danko SF"
        )

        // When
        let url = MapsHelper.mapsURL(for: restaurant)

        // Then
        XCTAssertNotNil(url)
        let urlString = url?.absoluteString ?? ""
        XCTAssertTrue(urlString.contains("q="))
    }

    func test_mapsURL_withSpecialCharactersInName_encodesCorrectly() {
        // Given
        let restaurant = Restaurant(
            id: UUID(),
            name: "Jack's Wife Freda",
            lat: 40.7285,
            lng: -73.9986,
            priceLevel: 2,
            averageCost: 35,
            description: "Cute illustrations",
            parking: "Street",
            mapQuery: "Jack's Wife Freda"
        )

        // When
        let url = MapsHelper.mapsURL(for: restaurant)

        // Then
        XCTAssertNotNil(url)
        // URL should be valid even with special characters
        XCTAssertTrue(url?.absoluteString.contains("maps://") == true)
    }

    func test_mapsURL_withAmpersandInName_encodesCorrectly() {
        // Given
        let restaurant = Restaurant(
            id: UUID(),
            name: "Son & Garden",
            lat: 37.7955,
            lng: -122.4032,
            priceLevel: 3,
            averageCost: 50,
            description: "Flower walls",
            parking: "Street",
            mapQuery: "Son & Garden"
        )

        // When
        let url = MapsHelper.mapsURL(for: restaurant)

        // Then
        XCTAssertNotNil(url)
        // Ampersand should be encoded
        let urlString = url?.absoluteString ?? ""
        XCTAssertFalse(urlString.contains("&G"))  // Should be encoded, not raw &
    }

    // MARK: - Fallback URL Tests

    func test_fallbackMapsURL_usesMapQuery() {
        // Given
        let restaurant = Restaurant(
            id: UUID(),
            name: "Test Place",
            lat: 0.0,
            lng: 0.0,
            priceLevel: 2,
            averageCost: 25,
            description: "Test",
            parking: "None",
            mapQuery: "Test Place San Francisco"
        )

        // When
        let url = MapsHelper.fallbackMapsURL(for: restaurant)

        // Then
        XCTAssertNotNil(url)
        XCTAssertTrue(url?.absoluteString.contains("maps://") == true)
        XCTAssertTrue(url?.absoluteString.contains("q=") == true)
    }

    // MARK: - Edge Cases

    func test_mapsURL_withZeroCoordinates_stillGeneratesURL() {
        // Given
        let restaurant = Restaurant(
            id: UUID(),
            name: "Null Island Restaurant",
            lat: 0.0,
            lng: 0.0,
            priceLevel: 1,
            averageCost: 10,
            description: "At null island",
            parking: "None",
            mapQuery: "Null Island"
        )

        // When
        let url = MapsHelper.mapsURL(for: restaurant)

        // Then
        XCTAssertNotNil(url)
    }

    func test_mapsURL_withNegativeCoordinates_generatesCorrectURL() {
        // Given (Sydney, Australia)
        let restaurant = Restaurant(
            id: UUID(),
            name: "Sydney Restaurant",
            lat: -33.8688,
            lng: 151.2093,
            priceLevel: 3,
            averageCost: 60,
            description: "Sydney dining",
            parking: "Street",
            mapQuery: "Sydney Restaurant"
        )

        // When
        let url = MapsHelper.mapsURL(for: restaurant)

        // Then
        XCTAssertNotNil(url)
        let urlString = url?.absoluteString ?? ""
        XCTAssertTrue(urlString.contains("-33.8688"))
        XCTAssertTrue(urlString.contains("151.2093"))
    }
}
