import Foundation

/// Pure price calculation functions for restaurant pricing
public enum PriceCalculator {
    
    /// Calculate total cost for a party
    /// - Parameters:
    ///   - averageCostPerPerson: The average cost per person
    ///   - partySize: The number of people in the party
    /// - Returns: The total cost for the entire party
    public static func totalCost(averageCostPerPerson: Int, partySize: Int) -> Int {
        averageCostPerPerson * partySize
    }
    
    /// Format per-person price display string
    /// - Parameter averageCost: The average cost per person
    /// - Returns: Formatted string like "$45/person"
    public static func formatPerPerson(_ averageCost: Int) -> String {
        "$\(averageCost)/person"
    }
    
    /// Format total price display string
    /// - Parameter totalCost: The total cost
    /// - Returns: Formatted string like "~$180 total"
    public static func formatTotal(_ totalCost: Int) -> String {
        "~$\(totalCost) total"
    }
    
    /// Format full price display string
    /// - Parameters:
    ///   - averageCost: The average cost per person
    ///   - partySize: The number of people
    /// - Returns: Formatted string like "$65/person · ~$130 total"
    public static func formatFullPrice(averageCost: Int, partySize: Int) -> String {
        let total = totalCost(averageCostPerPerson: averageCost, partySize: partySize)
        return "\(formatPerPerson(averageCost)) · \(formatTotal(total))"
    }
}
