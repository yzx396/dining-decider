import Foundation

/// Pure data representation of a wheel sector without SwiftUI dependencies.
/// Used for sector labels and color hex values.
public struct WheelSectorData: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let label: String
    public let colorHex: String

    public init(id: UUID = UUID(), label: String, colorHex: String) {
        self.id = id
        self.label = label
        self.colorHex = colorHex
    }
}

// MARK: - Sector Data Factory

extension WheelSectorData {
    /// Creates sector data for a vibe mode using labels and color hex values
    public static func sectors(for vibeMode: VibeMode) -> [WheelSectorData] {
        let labels = vibeMode.sectorLabels
        let colorHexes: [String]

        switch vibeMode {
        case .aesthetic:
            colorHexes = ThemeColorValues.aestheticWheelColors
        case .splurge:
            colorHexes = ThemeColorValues.splurgeWheelColors
        case .standard:
            colorHexes = ThemeColorValues.standardWheelColors
        }

        return zip(labels, colorHexes).map { label, hex in
            WheelSectorData(label: label, colorHex: hex)
        }
    }

    /// Aesthetic mode sectors (8 sectors)
    public static var aestheticSectors: [WheelSectorData] {
        sectors(for: .aesthetic)
    }

    /// Splurge mode sectors (6 sectors)
    public static var splurgeSectors: [WheelSectorData] {
        sectors(for: .splurge)
    }

    /// Standard mode sectors (8 sectors)
    public static var standardSectors: [WheelSectorData] {
        sectors(for: .standard)
    }
}
