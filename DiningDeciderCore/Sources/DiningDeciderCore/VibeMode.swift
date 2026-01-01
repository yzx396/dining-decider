import Foundation

/// Represents the three vibe modes for restaurant filtering.
/// Core version with pure data - no SwiftUI dependencies.
public enum VibeMode: String, CaseIterable, Identifiable, Sendable {
    case aesthetic
    case splurge
    case standard

    public var id: String { rawValue }

    /// The default vibe mode when the app launches
    public static var defaultVibe: VibeMode { .aesthetic }

    /// Display name shown on the button
    public var displayName: String {
        switch self {
        case .aesthetic: return "Pretty Pics"
        case .splurge: return "Splurge"
        case .standard: return "Hungry"
        }
    }

    /// Emoji prefix for the button
    public var emoji: String {
        switch self {
        case .aesthetic: return "✨"
        case .splurge: return "💸"
        case .standard: return "🍜"
        }
    }

    /// Number of wheel sectors for this vibe mode
    public var sectorCount: Int {
        switch self {
        case .aesthetic: return 8
        case .splurge: return 6
        case .standard: return 8
        }
    }

    /// Sector labels for this vibe mode
    public var sectorLabels: [String] {
        switch self {
        case .aesthetic:
            return ["Garden Cafe", "Floral Brunch", "Rooftop", "Tea Room",
                    "Minimalist", "Patio", "Retro Vibe", "Cute Bakery"]
        case .splurge:
            return ["Seafood", "Steakhouse", "Omakase", "Fine Dining", "French", "Italian"]
        case .standard:
            return ["Hot Pot", "Tea / Cafe", "Noodles", "Dessert",
                    "Dim Sum", "Skewers", "Korean BBQ", "Bakery"]
        }
    }

    /// Price levels allowed for this vibe mode (1-4 scale)
    public var allowedPriceLevels: [Int] {
        switch self {
        case .aesthetic:
            // Aesthetic shows all price levels
            return [1, 2, 3, 4]
        case .splurge:
            // Splurge shows only $$$ / $$$$ restaurants
            return [3, 4]
        case .standard:
            // Standard shows only $ / $$ restaurants
            return [1, 2]
        }
    }

    /// Checks if a price level is allowed for this vibe mode
    public func allowsPriceLevel(_ level: Int) -> Bool {
        allowedPriceLevels.contains(level)
    }
}
