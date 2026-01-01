import Foundation

/// Utility for calculating distances between geographic coordinates
public enum DistanceCalculator {

    /// Default search radius in miles
    public static let defaultRadiusMiles: Double = 10.0

    /// Meters per mile conversion factor
    public static let metersPerMile: Double = 1609.34

    /// Earth's radius in meters (mean radius)
    private static let earthRadiusMeters: Double = 6_371_000

    /// Calculates the distance in miles between two coordinates using the Haversine formula
    /// - Parameters:
    ///   - fromLatitude: Starting latitude in degrees
    ///   - fromLongitude: Starting longitude in degrees
    ///   - toLatitude: Destination latitude in degrees
    ///   - toLongitude: Destination longitude in degrees
    /// - Returns: Distance in miles
    public static func distanceInMiles(
        fromLatitude: Double,
        fromLongitude: Double,
        toLatitude: Double,
        toLongitude: Double
    ) -> Double {
        let meters = distanceInMeters(
            fromLatitude: fromLatitude,
            fromLongitude: fromLongitude,
            toLatitude: toLatitude,
            toLongitude: toLongitude
        )
        return meters / metersPerMile
    }

    /// Calculates the distance in meters between two coordinates using the Haversine formula
    /// - Parameters:
    ///   - fromLatitude: Starting latitude in degrees
    ///   - fromLongitude: Starting longitude in degrees
    ///   - toLatitude: Destination latitude in degrees
    ///   - toLongitude: Destination longitude in degrees
    /// - Returns: Distance in meters
    public static func distanceInMeters(
        fromLatitude: Double,
        fromLongitude: Double,
        toLatitude: Double,
        toLongitude: Double
    ) -> Double {
        let lat1 = fromLatitude * .pi / 180
        let lat2 = toLatitude * .pi / 180
        let deltaLat = (toLatitude - fromLatitude) * .pi / 180
        let deltaLon = (toLongitude - fromLongitude) * .pi / 180

        let a = sin(deltaLat / 2) * sin(deltaLat / 2) +
                cos(lat1) * cos(lat2) *
                sin(deltaLon / 2) * sin(deltaLon / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))

        return earthRadiusMeters * c
    }

    /// Checks if a point is within a radius of a center point
    /// - Parameters:
    ///   - pointLatitude: The point's latitude to check
    ///   - pointLongitude: The point's longitude to check
    ///   - centerLatitude: The center latitude of the search area
    ///   - centerLongitude: The center longitude of the search area
    ///   - radiusMiles: The search radius in miles (default: 10 miles)
    /// - Returns: True if the point is within the radius
    public static func isWithinRadius(
        pointLatitude: Double,
        pointLongitude: Double,
        centerLatitude: Double,
        centerLongitude: Double,
        radiusMiles: Double = defaultRadiusMiles
    ) -> Bool {
        let distance = distanceInMiles(
            fromLatitude: centerLatitude,
            fromLongitude: centerLongitude,
            toLatitude: pointLatitude,
            toLongitude: pointLongitude
        )
        return distance <= radiusMiles
    }
}
