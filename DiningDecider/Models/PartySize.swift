import Foundation

/// Party size utilities and constants for the dining party size stepper
enum PartySize {
    /// Minimum allowed party size
    static let minimum = 1

    /// Maximum allowed party size
    static let maximum = 20

    /// Default party size
    static let defaultSize = 2

    /// Increment the party size by 1, capped at maximum
    /// - Parameter current: The current party size
    /// - Returns: The new party size after incrementing
    static func increment(_ current: Int) -> Int {
        min(current + 1, maximum)
    }

    /// Decrement the party size by 1, floored at minimum
    /// - Parameter current: The current party size
    /// - Returns: The new party size after decrementing
    static func decrement(_ current: Int) -> Int {
        max(current - 1, minimum)
    }

    /// Check if the party size can be decremented
    /// - Parameter current: The current party size
    /// - Returns: True if the current size is above minimum
    static func canDecrement(_ current: Int) -> Bool {
        current > minimum
    }

    /// Check if the party size can be incremented
    /// - Parameter current: The current party size
    /// - Returns: True if the current size is below maximum
    static func canIncrement(_ current: Int) -> Bool {
        current < maximum
    }

    /// Check if a party size is within valid range
    /// - Parameter size: The party size to validate
    /// - Returns: True if the size is between minimum and maximum (inclusive)
    static func isValid(_ size: Int) -> Bool {
        size >= minimum && size <= maximum
    }
}
