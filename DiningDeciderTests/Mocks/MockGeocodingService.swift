import CoreLocation
@testable import DiningDecider

/// Mock implementation of GeocodingProviding for testing
final class MockGeocodingService: GeocodingProviding {

    // MARK: - Configurable Results

    var geocodeResult: Result<CLLocationCoordinate2D, Error> = .success(
        CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
    )
    var autocompleteResult: Result<[LocationSuggestion], Error> = .success([])

    // MARK: - Call Tracking

    var lastSearchedAddress: String?
    var lastAutocompleteQuery: String?
    var geocodeCallCount = 0
    var autocompleteCallCount = 0

    // MARK: - GeocodingProviding

    func geocode(address: String) async throws -> CLLocationCoordinate2D {
        lastSearchedAddress = address
        geocodeCallCount += 1

        switch geocodeResult {
        case .success(let coordinate):
            return coordinate
        case .failure(let error):
            throw error
        }
    }

    func autocomplete(query: String) async throws -> [LocationSuggestion] {
        lastAutocompleteQuery = query
        autocompleteCallCount += 1

        switch autocompleteResult {
        case .success(let suggestions):
            return suggestions
        case .failure(let error):
            throw error
        }
    }

    func geocode(suggestion: LocationSuggestion) async throws -> CLLocationCoordinate2D {
        return try await geocode(address: suggestion.fullAddress)
    }

    // MARK: - Test Helpers

    func reset() {
        lastSearchedAddress = nil
        lastAutocompleteQuery = nil
        geocodeCallCount = 0
        autocompleteCallCount = 0
        geocodeResult = .success(CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194))
        autocompleteResult = .success([])
    }
}
