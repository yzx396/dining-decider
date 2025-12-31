import Foundation
import UIKit

/// A utility for opening restaurant locations in Apple Maps.
///
/// Provides methods to generate Maps URLs with coordinates and search queries,
/// and to open those URLs in the Maps app.
enum MapsHelper {

    // MARK: - URL Generation

    /// Generates an Apple Maps URL for a restaurant using its coordinates.
    ///
    /// The URL includes both the coordinates (for precise positioning) and
    /// the restaurant name as a query (for display in Maps).
    ///
    /// - Parameter restaurant: The restaurant to generate a URL for
    /// - Returns: A URL that will open Apple Maps at the restaurant location, or nil if URL creation fails
    static func mapsURL(for restaurant: Restaurant) -> URL? {
        let encodedName = restaurant.name.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed
        ) ?? ""

        let urlString = "maps://?ll=\(restaurant.lat),\(restaurant.lng)&q=\(encodedName)"
        return URL(string: urlString)
    }

    /// Generates an Apple Maps URL using the restaurant's search query.
    ///
    /// This is a fallback method that uses the mapQuery field instead of coordinates.
    /// Useful when coordinates might be inaccurate or unavailable.
    ///
    /// - Parameter restaurant: The restaurant to generate a URL for
    /// - Returns: A URL that will search Apple Maps for the restaurant
    static func fallbackMapsURL(for restaurant: Restaurant) -> URL? {
        let encodedQuery = restaurant.mapQuery.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed
        ) ?? ""

        let urlString = "maps://?q=\(encodedQuery)"
        return URL(string: urlString)
    }

    // MARK: - Opening Maps

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
