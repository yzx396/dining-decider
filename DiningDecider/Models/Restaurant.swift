import Foundation
import CoreLocation

struct Restaurant: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let lat: Double
    let lng: Double
    let priceLevel: Int
    let averageCost: Int
    let description: String
    let parking: String
    let mapQuery: String

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }

    func totalCost(for partySize: Int) -> Int {
        averageCost * partySize
    }
}

// MARK: - Skeleton Data

extension Restaurant {
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
