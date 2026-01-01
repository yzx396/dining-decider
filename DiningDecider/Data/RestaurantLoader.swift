import Foundation
import CoreLocation
import DiningDeciderCore

/// Error types for restaurant loading
enum RestaurantLoaderError: Error, LocalizedError {
    case fileNotFound
    case decodingFailed(Error)

    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "Restaurant data file not found in bundle"
        case .decodingFailed(let error):
            return "Failed to decode restaurant data: \(error.localizedDescription)"
        }
    }
}

/// Protocol for restaurant loading - enables dependency injection for testing
protocol RestaurantLoading {
    var allCategories: [String] { get }
    func restaurants(for category: String) -> [Restaurant]
    func restaurantsFiltered(
        for category: String,
        near location: CLLocationCoordinate2D?,
        radiusMiles: Double
    ) -> [Restaurant]
    func restaurantsFiltered(
        for category: String,
        near location: CLLocationCoordinate2D?,
        radiusMiles: Double,
        allowedPriceLevels: [Int]?
    ) -> [Restaurant]
}

/// Raw restaurant data matching JSON structure
private struct RawRestaurant: Codable {
    let name: String
    let lat: Double
    let lng: Double
    let locs: [String]
    let query: String
    let price: Int
    let aesthetic: Bool
    let avgCost: Int
    let note: String
    let parking: String

    func toRestaurant() -> Restaurant {
        Restaurant(
            id: UUID(),
            name: name,
            lat: lat,
            lng: lng,
            priceLevel: price,
            averageCost: avgCost,
            description: note,
            parking: parking,
            mapQuery: query
        )
    }
}

/// Loads restaurant data from bundled JSON
final class RestaurantLoader: RestaurantLoading {

    private let categorizedRestaurants: [String: [Restaurant]]
    var loadError: RestaurantLoaderError?

    var allCategories: [String] {
        Array(categorizedRestaurants.keys).sorted()
    }

    /// Initialize from app bundle
    init(bundle: Bundle = .main) throws {
        guard let url = bundle.url(forResource: "restaurants", withExtension: "json") else {
            throw RestaurantLoaderError.fileNotFound
        }

        do {
            let data = try Data(contentsOf: url)
            let rawData = try JSONDecoder().decode([String: [RawRestaurant]].self, from: data)
            self.categorizedRestaurants = rawData.mapValues { rawRestaurants in
                rawRestaurants.map { $0.toRestaurant() }
            }
        } catch let error as RestaurantLoaderError {
            throw error
        } catch {
            throw RestaurantLoaderError.decodingFailed(error)
        }
    }

    /// Initialize from raw data (for testing)
    init(data: Data) throws {
        do {
            let rawData = try JSONDecoder().decode([String: [RawRestaurant]].self, from: data)
            self.categorizedRestaurants = rawData.mapValues { rawRestaurants in
                rawRestaurants.map { $0.toRestaurant() }
            }
        } catch {
            throw RestaurantLoaderError.decodingFailed(error)
        }
    }

    func restaurants(for category: String) -> [Restaurant] {
        categorizedRestaurants[category] ?? []
    }

    /// Returns restaurants filtered by distance from a location
    /// - Parameters:
    ///   - category: The category to filter
    ///   - location: User's current location (returns empty if nil)
    ///   - radiusMiles: Search radius in miles (default 10)
    /// - Returns: Up to 3 shuffled restaurants within the radius
    func restaurantsFiltered(
        for category: String,
        near location: CLLocationCoordinate2D?,
        radiusMiles: Double = DistanceCalculator.defaultRadiusMiles
    ) -> [Restaurant] {
        restaurantsFiltered(
            for: category,
            near: location,
            radiusMiles: radiusMiles,
            allowedPriceLevels: nil
        )
    }

    /// Returns restaurants filtered by distance and price level
    /// - Parameters:
    ///   - category: The category to filter
    ///   - location: User's current location (returns empty if nil)
    ///   - radiusMiles: Search radius in miles
    ///   - allowedPriceLevels: Price levels to include (1-4), nil means all
    /// - Returns: Up to 3 shuffled restaurants matching criteria
    func restaurantsFiltered(
        for category: String,
        near location: CLLocationCoordinate2D?,
        radiusMiles: Double,
        allowedPriceLevels: [Int]?
    ) -> [Restaurant] {
        guard let location = location else {
            return []
        }

        // Empty array means no restaurants should match
        if let levels = allowedPriceLevels, levels.isEmpty {
            return []
        }

        return restaurants(for: category)
            .filter { restaurant in
                // Filter by distance
                let withinRadius = DistanceCalculator.isWithinRadius(
                    pointLatitude: restaurant.coordinate.latitude,
                    pointLongitude: restaurant.coordinate.longitude,
                    centerLatitude: location.latitude,
                    centerLongitude: location.longitude,
                    radiusMiles: radiusMiles
                )

                // Filter by price level if specified
                let matchesPrice: Bool
                if let levels = allowedPriceLevels {
                    matchesPrice = levels.contains(restaurant.priceLevel)
                } else {
                    matchesPrice = true
                }

                return withinRadius && matchesPrice
            }
            .shuffled()
            .prefix(3)
            .map { $0 }
    }
}
