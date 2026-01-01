import XCTest
@testable import DiningDeciderCore

final class MapsHelperTests: XCTestCase {

    // MARK: - URL Generation Tests

    func test_mapsURL_withCoordinates_generatesCorrectURL() {
        // When
        let url = MapsHelper.mapsURL(
            name: "Test Restaurant",
            latitude: 37.7749,
            longitude: -122.4194
        )

        // Then
        XCTAssertNotNil(url)
        XCTAssertTrue(url?.absoluteString.contains("maps://") == true)
        XCTAssertTrue(url?.absoluteString.contains("37.7749") == true)
        XCTAssertTrue(url?.absoluteString.contains("-122.4194") == true)
    }

    func test_mapsURL_includesNameAsQuery() {
        // When
        let url = MapsHelper.mapsURL(
            name: "Gary Danko",
            latitude: 37.8059,
            longitude: -122.4209
        )

        // Then
        XCTAssertNotNil(url)
        let urlString = url?.absoluteString ?? ""
        XCTAssertTrue(urlString.contains("q="))
    }

    func test_mapsURL_withSpecialCharactersInName_encodesCorrectly() {
        // When
        let url = MapsHelper.mapsURL(
            name: "Jack's Wife Freda",
            latitude: 40.7285,
            longitude: -73.9986
        )

        // Then
        XCTAssertNotNil(url)
        XCTAssertTrue(url?.absoluteString.contains("maps://") == true)
    }

    func test_mapsURL_withAmpersandInName_encodesCorrectly() {
        // When
        let url = MapsHelper.mapsURL(
            name: "Son & Garden",
            latitude: 37.7955,
            longitude: -122.4032
        )

        // Then
        XCTAssertNotNil(url)
        let urlString = url?.absoluteString ?? ""
        // Ampersand should be encoded
        XCTAssertFalse(urlString.contains("&G"))
    }

    // MARK: - Fallback URL Tests

    func test_fallbackMapsURL_usesQuery() {
        // When
        let url = MapsHelper.fallbackMapsURL(query: "Test Place San Francisco")

        // Then
        XCTAssertNotNil(url)
        XCTAssertTrue(url?.absoluteString.contains("maps://") == true)
        XCTAssertTrue(url?.absoluteString.contains("q=") == true)
    }

    func test_fallbackMapsURL_encodesSpaces() {
        // When
        let url = MapsHelper.fallbackMapsURL(query: "Test Place San Francisco")

        // Then
        XCTAssertNotNil(url)
        let urlString = url?.absoluteString ?? ""
        // Spaces should be encoded as %20
        XCTAssertTrue(urlString.contains("%20") || urlString.contains("+"))
    }

    // MARK: - Edge Cases

    func test_mapsURL_withZeroCoordinates_stillGeneratesURL() {
        // When
        let url = MapsHelper.mapsURL(
            name: "Null Island Restaurant",
            latitude: 0.0,
            longitude: 0.0
        )

        // Then
        XCTAssertNotNil(url)
    }

    func test_mapsURL_withNegativeCoordinates_generatesCorrectURL() {
        // When (Sydney, Australia)
        let url = MapsHelper.mapsURL(
            name: "Sydney Restaurant",
            latitude: -33.8688,
            longitude: 151.2093
        )

        // Then
        XCTAssertNotNil(url)
        let urlString = url?.absoluteString ?? ""
        XCTAssertTrue(urlString.contains("-33.8688"))
        XCTAssertTrue(urlString.contains("151.2093"))
    }

    func test_mapsURL_withEmptyName_stillGeneratesURL() {
        // When
        let url = MapsHelper.mapsURL(
            name: "",
            latitude: 37.7749,
            longitude: -122.4194
        )

        // Then
        XCTAssertNotNil(url)
        XCTAssertTrue(url?.absoluteString.contains("ll=") == true)
    }

    func test_fallbackMapsURL_withEmptyQuery_stillGeneratesURL() {
        // When
        let url = MapsHelper.fallbackMapsURL(query: "")

        // Then
        XCTAssertNotNil(url)
    }

    // MARK: - URL Scheme Tests

    func test_mapsURL_hasCorrectScheme() {
        // When
        let url = MapsHelper.mapsURL(
            name: "Test",
            latitude: 37.7749,
            longitude: -122.4194
        )

        // Then
        XCTAssertEqual(url?.scheme, "maps")
    }

    func test_fallbackMapsURL_hasCorrectScheme() {
        // When
        let url = MapsHelper.fallbackMapsURL(query: "Test")

        // Then
        XCTAssertEqual(url?.scheme, "maps")
    }
}
