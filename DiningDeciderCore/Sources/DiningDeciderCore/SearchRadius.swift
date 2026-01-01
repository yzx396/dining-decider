import Foundation

/// Represents the available search radius options for filtering restaurants
public enum SearchRadius: String, CaseIterable, Identifiable {
    case fiveMiles
    case tenMiles
    case fifteenMiles
    case twentyFiveMiles

    /// The numeric miles value for this radius
    public var miles: Double {
        switch self {
        case .fiveMiles: return 5.0
        case .tenMiles: return 10.0
        case .fifteenMiles: return 15.0
        case .twentyFiveMiles: return 25.0
        }
    }

    /// The display label for the UI
    public var label: String {
        switch self {
        case .fiveMiles: return "5 mi"
        case .tenMiles: return "10 mi"
        case .fifteenMiles: return "15 mi"
        case .twentyFiveMiles: return "25 mi"
        }
    }

    /// The default search radius (10 miles)
    public static let defaultRadius: SearchRadius = .tenMiles

    /// Identifiable conformance
    public var id: String { rawValue }
}
