import XCTest
import CoreLocation
@testable import DiningDecider

final class GeocodingServiceTests: XCTestCase {

    var mockService: MockGeocodingService!

    override func setUp() {
        super.setUp()
        mockService = MockGeocodingService()
    }

    override func tearDown() {
        mockService = nil
        super.tearDown()
    }

    // MARK: - Geocoding Tests

    func test_geocode_withValidAddress_returnsCoordinate() async throws {
        // Given
        let expectedCoordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        mockService.geocodeResult = .success(expectedCoordinate)

        // When
        let result = try await mockService.geocode(address: "San Francisco, CA")

        // Then
        XCTAssertEqual(result.latitude, expectedCoordinate.latitude, accuracy: 0.0001)
        XCTAssertEqual(result.longitude, expectedCoordinate.longitude, accuracy: 0.0001)
    }

    func test_geocode_withInvalidAddress_throwsError() async {
        // Given
        mockService.geocodeResult = .failure(GeocodingError.noResults)

        // When/Then
        do {
            _ = try await mockService.geocode(address: "XYZ Invalid Address 12345")
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as? GeocodingError, GeocodingError.noResults)
        }
    }

    func test_geocode_withEmptyAddress_throwsError() async {
        // Given
        mockService.geocodeResult = .failure(GeocodingError.invalidAddress)

        // When/Then
        do {
            _ = try await mockService.geocode(address: "")
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as? GeocodingError, GeocodingError.invalidAddress)
        }
    }

    func test_geocode_recordsSearchedAddress() async throws {
        // Given
        let address = "Los Angeles, CA"
        mockService.geocodeResult = .success(CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437))

        // When
        _ = try await mockService.geocode(address: address)

        // Then
        XCTAssertEqual(mockService.lastSearchedAddress, address)
    }

    // MARK: - Autocomplete Tests

    func test_autocomplete_withPartialQuery_returnsSuggestions() async throws {
        // Given
        let suggestions = [
            LocationSuggestion(title: "San Francisco, CA", subtitle: "California, United States"),
            LocationSuggestion(title: "San Jose, CA", subtitle: "California, United States"),
            LocationSuggestion(title: "San Diego, CA", subtitle: "California, United States")
        ]
        mockService.autocompleteResult = .success(suggestions)

        // When
        let result = try await mockService.autocomplete(query: "San")

        // Then
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result[0].title, "San Francisco, CA")
    }

    func test_autocomplete_withEmptyQuery_returnsEmptyArray() async throws {
        // Given
        mockService.autocompleteResult = .success([])

        // When
        let result = try await mockService.autocomplete(query: "")

        // Then
        XCTAssertTrue(result.isEmpty)
    }

    func test_autocomplete_withNoMatches_returnsEmptyArray() async throws {
        // Given
        mockService.autocompleteResult = .success([])

        // When
        let result = try await mockService.autocomplete(query: "XYZABC123")

        // Then
        XCTAssertTrue(result.isEmpty)
    }

    func test_autocomplete_recordsSearchedQuery() async throws {
        // Given
        let query = "New York"
        mockService.autocompleteResult = .success([])

        // When
        _ = try await mockService.autocomplete(query: query)

        // Then
        XCTAssertEqual(mockService.lastAutocompleteQuery, query)
    }

    // MARK: - Geocode Suggestion Tests

    func test_geocodeSuggestion_returnsCoordinateForSuggestion() async throws {
        // Given
        let suggestion = LocationSuggestion(
            title: "San Francisco, CA",
            subtitle: "California, United States"
        )
        let expectedCoordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        mockService.geocodeResult = .success(expectedCoordinate)

        // When
        let result = try await mockService.geocode(suggestion: suggestion)

        // Then
        XCTAssertEqual(result.latitude, expectedCoordinate.latitude, accuracy: 0.0001)
        XCTAssertEqual(result.longitude, expectedCoordinate.longitude, accuracy: 0.0001)
    }
}

// MARK: - LocationSuggestion Tests

final class LocationSuggestionTests: XCTestCase {

    func test_locationSuggestion_hasCorrectProperties() {
        // Given/When
        let suggestion = LocationSuggestion(
            title: "San Francisco, CA",
            subtitle: "California, United States"
        )

        // Then
        XCTAssertEqual(suggestion.title, "San Francisco, CA")
        XCTAssertEqual(suggestion.subtitle, "California, United States")
    }

    func test_locationSuggestion_equatableByTitle() {
        // Given
        let suggestion1 = LocationSuggestion(title: "San Francisco", subtitle: "CA")
        let suggestion2 = LocationSuggestion(title: "San Francisco", subtitle: "California")
        let suggestion3 = LocationSuggestion(title: "Los Angeles", subtitle: "CA")

        // Then
        XCTAssertEqual(suggestion1, suggestion2)
        XCTAssertNotEqual(suggestion1, suggestion3)
    }

    func test_locationSuggestion_fullAddress() {
        // Given
        let suggestion = LocationSuggestion(
            title: "123 Main St",
            subtitle: "San Francisco, CA"
        )

        // Then
        XCTAssertEqual(suggestion.fullAddress, "123 Main St, San Francisco, CA")
    }
}
