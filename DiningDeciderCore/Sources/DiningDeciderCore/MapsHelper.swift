import Foundation

/// A utility for generating Apple Maps URLs.
/// Core version with pure URL generation - no UIKit dependencies.
public enum MapsHelper {

    // MARK: - URL Generation

    /// Generates an Apple Maps URL using coordinates and a name.
    ///
    /// - Parameters:
    ///   - name: The name to display as the query
    ///   - latitude: The latitude coordinate
    ///   - longitude: The longitude coordinate
    /// - Returns: A URL that will open Apple Maps at the location, or nil if URL creation fails
    public static func mapsURL(name: String, latitude: Double, longitude: Double) -> URL? {
        let encodedName = name.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed
        ) ?? ""

        let urlString = "maps://?ll=\(latitude),\(longitude)&q=\(encodedName)"
        return URL(string: urlString)
    }

    /// Generates an Apple Maps URL using a search query.
    ///
    /// - Parameter query: The search query
    /// - Returns: A URL that will search Apple Maps for the query
    public static func fallbackMapsURL(query: String) -> URL? {
        let encodedQuery = query.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed
        ) ?? ""

        let urlString = "maps://?q=\(encodedQuery)"
        return URL(string: urlString)
    }
}
