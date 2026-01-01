import Foundation
import UIKit
import DiningDeciderCore

/// A utility for opening restaurant locations in Apple Maps.
/// Uses Core for URL generation, adds UIKit-specific opening functionality.
enum MapsHelper {

    // MARK: - URL Generation (Delegates to Core)

    /// Generates an Apple Maps URL for a restaurant using its coordinates.
    static func mapsURL(for restaurant: Restaurant) -> URL? {
        DiningDeciderCore.MapsHelper.mapsURL(
            name: restaurant.name,
            latitude: restaurant.lat,
            longitude: restaurant.lng
        )
    }

    /// Generates an Apple Maps URL using the restaurant's search query.
    static func fallbackMapsURL(for restaurant: Restaurant) -> URL? {
        DiningDeciderCore.MapsHelper.fallbackMapsURL(query: restaurant.mapQuery)
    }

    // MARK: - Opening Maps (UIKit-specific)

    /// Opens Apple Maps for a restaurant.
    ///
    /// First attempts to use coordinates for precise location.
    /// Falls back to search query if coordinate URL fails.
    ///
    /// - Parameter restaurant: The restaurant to open in Maps
    static func openMaps(for restaurant: Restaurant) {
        // Try coordinate-based URL first (more precise)
        if let url = mapsURL(for: restaurant), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
            return
        }

        // Fallback to query-based URL
        if let url = fallbackMapsURL(for: restaurant), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}
