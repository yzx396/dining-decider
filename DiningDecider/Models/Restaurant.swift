import Foundation
import CoreLocation

// MARK: - Price Level Tag

/// Represents a price level label with emoji and text.
struct PriceLevelTag: Equatable {
    let emoji: String
    let label: String

    /// Formatted display string combining emoji and label.
    var displayText: String {
        "\(emoji) \(label)"
    }

    static let luxury = PriceLevelTag(emoji: "💎", label: "Luxury")
    static let premium = PriceLevelTag(emoji: "✨", label: "Premium")
    static let aesthetic = PriceLevelTag(emoji: "📸", label: "Aesthetic")
    static let value = PriceLevelTag(emoji: "💰", label: "Value")
}

// MARK: - Restaurant

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

    /// Returns the appropriate price level tag based on price level.
    ///
    /// - priceLevel 4: 💎 Luxury
    /// - priceLevel 3: ✨ Premium
    /// - priceLevel 2: 📸 Aesthetic
    /// - priceLevel 1 or other: 💰 Value
    var priceLevelTag: PriceLevelTag {
        switch priceLevel {
        case 4:
            return .luxury
        case 3:
            return .premium
        case 2:
            return .aesthetic
        default:
            return .value
        }
    }

    /// Returns true if parking information is available (non-empty, non-whitespace).
    var hasParkingInfo: Bool {
        !parking.trimmingCharacters(in: .whitespaces).isEmpty
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
