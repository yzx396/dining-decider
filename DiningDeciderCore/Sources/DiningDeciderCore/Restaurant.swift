import Foundation
import CoreLocation

// MARK: - Price Level Tag

/// Represents a price level label with emoji and text.
public struct PriceLevelTag: Equatable, Sendable {
    public let emoji: String
    public let label: String

    public init(emoji: String, label: String) {
        self.emoji = emoji
        self.label = label
    }

    /// Formatted display string combining emoji and label.
    public var displayText: String {
        "\(emoji) \(label)"
    }

    public static let luxury = PriceLevelTag(emoji: "💎", label: "Luxury")
    public static let premium = PriceLevelTag(emoji: "✨", label: "Premium")
    public static let aesthetic = PriceLevelTag(emoji: "📸", label: "Aesthetic")
    public static let value = PriceLevelTag(emoji: "💰", label: "Value")
}

// MARK: - Restaurant

public struct Restaurant: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public let name: String
    public let lat: Double
    public let lng: Double
    public let priceLevel: Int
    public let averageCost: Int
    public let description: String
    public let parking: String
    public let mapQuery: String

    public init(
        id: UUID,
        name: String,
        lat: Double,
        lng: Double,
        priceLevel: Int,
        averageCost: Int,
        description: String,
        parking: String,
        mapQuery: String
    ) {
        self.id = id
        self.name = name
        self.lat = lat
        self.lng = lng
        self.priceLevel = priceLevel
        self.averageCost = averageCost
        self.description = description
        self.parking = parking
        self.mapQuery = mapQuery
    }

    public var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }

    public func totalCost(for partySize: Int) -> Int {
        averageCost * partySize
    }

    /// Returns the appropriate price level tag based on price level.
    ///
    /// - priceLevel 4: 💎 Luxury
    /// - priceLevel 3: ✨ Premium
    /// - priceLevel 2: 📸 Aesthetic
    /// - priceLevel 1 or other: 💰 Value
    public var priceLevelTag: PriceLevelTag {
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
    public var hasParkingInfo: Bool {
        !parking.trimmingCharacters(in: .whitespaces).isEmpty
    }
}
