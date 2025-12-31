import SwiftUI

/// Represents the three vibe modes for restaurant filtering
enum VibeMode: String, CaseIterable, Identifiable {
    case aesthetic
    case splurge
    case standard

    var id: String { rawValue }

    /// The default vibe mode when the app launches
    static var defaultVibe: VibeMode { .aesthetic }

    /// Display name shown on the button
    var displayName: String {
        switch self {
        case .aesthetic: return "Pretty Pics"
        case .splurge: return "Splurge"
        case .standard: return "Hungry"
        }
    }

    /// Emoji prefix for the button
    var emoji: String {
        switch self {
        case .aesthetic: return "✨"
        case .splurge: return "💸"
        case .standard: return "🍜"
        }
    }

    /// The color used when this vibe is selected
    var selectedColor: Color {
        switch self {
        case .aesthetic: return Color.theme.vibeAesthetic
        case .splurge: return Color.theme.vibeSplurge
        case .standard: return Color.theme.vibeStandard
        }
    }

    /// The wheel sectors for this vibe mode
    var sectors: [WheelSector] {
        switch self {
        case .aesthetic: return WheelSector.aestheticSectors
        case .splurge: return WheelSector.splurgeSectors
        case .standard: return WheelSector.standardSectors
        }
    }

    /// Price levels allowed for this vibe mode (1-4 scale)
    var allowedPriceLevels: [Int] {
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
    func allowsPriceLevel(_ level: Int) -> Bool {
        allowedPriceLevels.contains(level)
    }
}
