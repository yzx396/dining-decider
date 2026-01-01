import SwiftUI
import DiningDeciderCore

// Re-export VibeMode from Core for app-wide usage
public typealias VibeMode = DiningDeciderCore.VibeMode

// MARK: - SwiftUI Extensions

extension DiningDeciderCore.VibeMode {
    /// The color used when this vibe is selected
    var selectedColor: Color {
        switch self {
        case .aesthetic: return Color.theme.vibeAesthetic
        case .splurge: return Color.theme.vibeSplurge
        case .standard: return Color.theme.vibeStandard
        }
    }

    /// The wheel sectors for this vibe mode (with SwiftUI Colors)
    var sectors: [WheelSector] {
        switch self {
        case .aesthetic: return WheelSector.aestheticSectors
        case .splurge: return WheelSector.splurgeSectors
        case .standard: return WheelSector.standardSectors
        }
    }
}
