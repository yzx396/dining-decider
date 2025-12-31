import SwiftUI

struct WheelSector: Identifiable {
    let id = UUID()
    let label: String
    let color: Color
}

// MARK: - Skeleton Data

extension WheelSector {
    static let skeletonSectors: [WheelSector] = [
        WheelSector(label: "Rooftop", color: Color.theme.aestheticWheelColors[0]),
        WheelSector(label: "Cafe", color: Color.theme.aestheticWheelColors[1]),
        WheelSector(label: "Brunch", color: Color.theme.aestheticWheelColors[2]),
        WheelSector(label: "Bakery", color: Color.theme.aestheticWheelColors[3])
    ]
}
