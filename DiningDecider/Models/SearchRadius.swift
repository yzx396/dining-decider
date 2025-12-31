import Foundation

/// Represents the available search radius options for filtering restaurants
enum SearchRadius: String, CaseIterable, Identifiable {
    case fiveMiles
    case tenMiles
    case fifteenMiles
    case twentyFiveMiles

    /// The numeric miles value for this radius
    var miles: Double {
        switch self {
        case .fiveMiles: return 5.0
        case .tenMiles: return 10.0
        case .fifteenMiles: return 15.0
        case .twentyFiveMiles: return 25.0
        }
    }

    /// The display label for the UI
    var label: String {
        switch self {
        case .fiveMiles: return "5 mi"
        case .tenMiles: return "10 mi"
        case .fifteenMiles: return "15 mi"
        case .twentyFiveMiles: return "25 mi"
        }
    }

    /// The default search radius (10 miles)
    static let defaultRadius: SearchRadius = .tenMiles

    /// Identifiable conformance
    var id: String { rawValue }
}
