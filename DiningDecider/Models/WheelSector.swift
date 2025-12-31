import SwiftUI

struct WheelSector: Identifiable {
    let id = UUID()
    let label: String
    let color: Color
}

// MARK: - Skeleton Data (4 sectors)

extension WheelSector {
    static let skeletonSectors: [WheelSector] = [
        WheelSector(label: "Rooftop", color: Color.theme.aestheticWheelColors[0]),
        WheelSector(label: "Cafe", color: Color.theme.aestheticWheelColors[1]),
        WheelSector(label: "Brunch", color: Color.theme.aestheticWheelColors[2]),
        WheelSector(label: "Bakery", color: Color.theme.aestheticWheelColors[3])
    ]
}

// MARK: - Aesthetic Mode (8 sectors)

extension WheelSector {
    static let aestheticSectors: [WheelSector] = [
        WheelSector(label: "Garden Cafe", color: Color.theme.aestheticWheelColors[0]),
        WheelSector(label: "Floral Brunch", color: Color.theme.aestheticWheelColors[1]),
        WheelSector(label: "Rooftop", color: Color.theme.aestheticWheelColors[2]),
        WheelSector(label: "Tea Room", color: Color.theme.aestheticWheelColors[3]),
        WheelSector(label: "Minimalist", color: Color.theme.aestheticWheelColors[4]),
        WheelSector(label: "Patio", color: Color.theme.aestheticWheelColors[5]),
        WheelSector(label: "Retro Vibe", color: Color.theme.aestheticWheelColors[6]),
        WheelSector(label: "Cute Bakery", color: Color.theme.aestheticWheelColors[7])
    ]
}

// MARK: - Splurge Mode (6 sectors)

extension WheelSector {
    static let splurgeSectors: [WheelSector] = [
        WheelSector(label: "Seafood", color: Color.theme.splurgeWheelColors[0]),
        WheelSector(label: "Steakhouse", color: Color.theme.splurgeWheelColors[1]),
        WheelSector(label: "Omakase", color: Color.theme.splurgeWheelColors[2]),
        WheelSector(label: "Fine Dining", color: Color.theme.splurgeWheelColors[3]),
        WheelSector(label: "French", color: Color.theme.splurgeWheelColors[4]),
        WheelSector(label: "Italian", color: Color.theme.splurgeWheelColors[5])
    ]
}

// MARK: - Standard Mode (8 sectors)

extension WheelSector {
    static let standardSectors: [WheelSector] = [
        WheelSector(label: "Hot Pot", color: Color.theme.standardWheelColors[0]),
        WheelSector(label: "Tea / Cafe", color: Color.theme.standardWheelColors[1]),
        WheelSector(label: "Noodles", color: Color.theme.standardWheelColors[2]),
        WheelSector(label: "Dessert", color: Color.theme.standardWheelColors[3]),
        WheelSector(label: "Dim Sum", color: Color.theme.standardWheelColors[4]),
        WheelSector(label: "Skewers", color: Color.theme.standardWheelColors[5]),
        WheelSector(label: "Korean BBQ", color: Color.theme.standardWheelColors[6]),
        WheelSector(label: "Bakery", color: Color.theme.standardWheelColors[7])
    ]
}
