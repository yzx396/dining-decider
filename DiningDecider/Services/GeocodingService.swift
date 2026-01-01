import MapKit

// MARK: - Error Types

/// Errors that can occur during geocoding operations
enum GeocodingError: Error, Equatable {
    case invalidAddress
    case noResults
    case networkError
    case unknown
}

// MARK: - Location Suggestion Model

/// A location suggestion from autocomplete
struct LocationSuggestion: Identifiable, Equatable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String

    /// The full address combining title and subtitle
    var fullAddress: String {
        if subtitle.isEmpty {
            return title
        }
        return "\(title), \(subtitle)"
    }

    static func == (lhs: LocationSuggestion, rhs: LocationSuggestion) -> Bool {
        lhs.title == rhs.title
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
}

// MARK: - Protocol

/// Protocol for geocoding services - enables dependency injection for testing
protocol GeocodingProviding {
    /// Geocodes an address string to coordinates
    func geocode(address: String) async throws -> CLLocationCoordinate2D

    /// Provides autocomplete suggestions for a partial address query
    func autocomplete(query: String) async throws -> [LocationSuggestion]

    /// Geocodes a location suggestion to coordinates
    func geocode(suggestion: LocationSuggestion) async throws -> CLLocationCoordinate2D
}

// MARK: - Implementation

/// Geocoding service using Apple's MKLocalSearch and MKLocalSearchCompleter
final class GeocodingService: NSObject, GeocodingProviding {

    private var completer: MKLocalSearchCompleter?
    private var completionContinuation: CheckedContinuation<[LocationSuggestion], Error>?

    override init() {
        super.init()
    }

    func geocode(address: String) async throws -> CLLocationCoordinate2D {
        guard !address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw GeocodingError.invalidAddress
        }

        do {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = address
            request.resultTypes = .address

            let search = MKLocalSearch(request: request)
            let response = try await search.start()

            guard let mapItem = response.mapItems.first else {
                throw GeocodingError.noResults
            }

            return mapItem.location.coordinate
        } catch let error as GeocodingError {
            throw error
        } catch {
            throw GeocodingError.networkError
        }
    }

    func autocomplete(query: String) async throws -> [LocationSuggestion] {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return []
        }

        return try await withCheckedThrowingContinuation { continuation in
            let completer = MKLocalSearchCompleter()
            completer.delegate = self
            completer.resultTypes = .address
            self.completer = completer
            self.completionContinuation = continuation
            completer.queryFragment = query
        }
    }

    func geocode(suggestion: LocationSuggestion) async throws -> CLLocationCoordinate2D {
        return try await geocode(address: suggestion.fullAddress)
    }
}

// MARK: - MKLocalSearchCompleterDelegate

extension GeocodingService: MKLocalSearchCompleterDelegate {

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        let suggestions = completer.results.prefix(5).map { result in
            LocationSuggestion(
                title: result.title,
                subtitle: result.subtitle
            )
        }
        completionContinuation?.resume(returning: Array(suggestions))
        completionContinuation = nil
        self.completer = nil
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        completionContinuation?.resume(throwing: GeocodingError.networkError)
        completionContinuation = nil
        self.completer = nil
    }
}
