import CoreLocation
import DiningDeciderCore

/// Fallback restaurant loader that returns skeleton data when the main loader fails.
/// Used when restaurants.json cannot be found or decoded.
final class FallbackRestaurantLoader: RestaurantLoading {
    var allCategories: [String] {
        ["Rooftop", "Cafe"]
    }

    func restaurants(for category: String) -> [Restaurant] {
        Restaurant.skeletonData
    }

    func restaurantsFiltered(
        for category: String,
        near location: CLLocationCoordinate2D?,
        radiusMiles: Double
    ) -> [Restaurant] {
        restaurantsFiltered(
            for: category,
            near: location,
            radiusMiles: radiusMiles,
            allowedPriceLevels: nil
        )
    }

    func restaurantsFiltered(
        for category: String,
        near location: CLLocationCoordinate2D?,
        radiusMiles: Double,
        allowedPriceLevels: [Int]?
    ) -> [Restaurant] {
        guard location != nil else { return [] }
        if let levels = allowedPriceLevels {
            return Restaurant.skeletonData.filter { levels.contains($0.priceLevel) }
        }
        return Restaurant.skeletonData
    }
}
