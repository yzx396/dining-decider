import Foundation
import CoreLocation
import DiningDeciderCore

// Re-export Restaurant and PriceLevelTag from Core for app-wide usage
public typealias Restaurant = DiningDeciderCore.Restaurant
public typealias PriceLevelTag = DiningDeciderCore.PriceLevelTag

// MARK: - Skeleton Data (App Layer Extension)

extension DiningDeciderCore.Restaurant {
    static let skeletonData: [Restaurant] = [
        Restaurant(
            id: UUID(),
            name: "RH Rooftop",
            lat: 37.7855,
            lng: -122.4064,
            priceLevel: 3,
            averageCost: 65,
            description: "Stunning views with upscale American fare",
            parking: "Valet available",
            mapQuery: "RH Rooftop San Francisco"
        ),
        Restaurant(
            id: UUID(),
            name: "Charmaine's",
            lat: 37.7873,
            lng: -122.4101,
            priceLevel: 3,
            averageCost: 55,
            description: "Stylish rooftop bar with city skyline views",
            parking: "Street parking",
            mapQuery: "Charmaine's San Francisco"
        ),
        Restaurant(
            id: UUID(),
            name: "El Techo",
            lat: 37.7599,
            lng: -122.4148,
            priceLevel: 2,
            averageCost: 35,
            description: "Vibrant Latin rooftop with colorful atmosphere",
            parking: "Street parking",
            mapQuery: "El Techo San Francisco"
        )
    ]
}
