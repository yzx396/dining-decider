import Foundation
import CoreLocation

/// Utility for calculating distances between geographic coordinates
enum DistanceCalculator {

    /// Default search radius in miles
    static let defaultRadiusMiles: Double = 10.0

    /// Calculates the distance in miles between two coordinates using CLLocation
    /// - Parameters:
    ///   - from: Starting coordinate
    ///   - to: Destination coordinate
    /// - Returns: Distance in miles
    static func distanceInMiles(
        from: CLLocationCoordinate2D,
        to: CLLocationCoordinate2D
    ) -> Double {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)

        // CLLocation.distance returns meters
        let meters = fromLocation.distance(from: toLocation)

        // Convert meters to miles (1 mile = 1609.34 meters)
        return meters / 1609.34
    }

    /// Checks if a point is within a radius of a center point
    /// - Parameters:
    ///   - point: The point to check
    ///   - center: The center of the search area
    ///   - radiusMiles: The search radius in miles (default: 10 miles)
    /// - Returns: True if the point is within the radius
    static func isWithinRadius(
        point: CLLocationCoordinate2D,
        center: CLLocationCoordinate2D,
        radiusMiles: Double = defaultRadiusMiles
    ) -> Bool {
        let distance = distanceInMiles(from: center, to: point)
        return distance <= radiusMiles
    }
}
