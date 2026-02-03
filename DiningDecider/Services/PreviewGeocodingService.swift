import CoreLocation

/// Mock geocoding service for SwiftUI previews
final class PreviewGeocodingService: GeocodingProviding {
    func geocode(address: String) async throws -> CLLocationCoordinate2D {
        try await Task.sleep(nanoseconds: 500_000_000)
        return CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
    }

    func autocomplete(query: String) async throws -> [LocationSuggestion] {
        try await Task.sleep(nanoseconds: 300_000_000)
        return [
            LocationSuggestion(title: "\(query) Francisco, CA", subtitle: "California, United States"),
            LocationSuggestion(title: "\(query) Jose, CA", subtitle: "California, United States"),
            LocationSuggestion(title: "\(query) Diego, CA", subtitle: "California, United States")
        ]
    }

    func geocode(suggestion: LocationSuggestion) async throws -> CLLocationCoordinate2D {
        try await geocode(address: suggestion.fullAddress)
    }
}
