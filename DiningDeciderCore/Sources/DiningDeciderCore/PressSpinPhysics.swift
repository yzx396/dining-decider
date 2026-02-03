import Foundation

/// Calculates spin velocity from press-and-hold duration on wheel center
public enum PressSpinPhysics {
    /// Radius of the center "press zone" in points
    public static let centerRadius: Double = 25
    
    /// Velocity gained per second of holding (degrees/second per second)
    public static let velocityPerSecond: Double = 600
    
    /// Maximum velocity cap (matches WheelPhysics.maxVelocity)
    public static let maxVelocity: Double = WheelPhysics.maxVelocity
    
    /// Calculate angular velocity based on how long the center was pressed
    /// - Parameter holdDuration: Duration in seconds the center was held
    /// - Returns: Angular velocity in degrees/second (always positive/clockwise)
    public static func velocity(fromHoldDuration duration: TimeInterval) -> Double {
        guard duration > 0 else { return 0 }
        
        // Linear velocity growth: velocity = duration * velocityPerSecond
        let calculatedVelocity = duration * velocityPerSecond
        
        // Cap at max velocity
        return min(calculatedVelocity, maxVelocity)
    }
    
    /// Calculate angular velocity with direction support
    /// - Parameters:
    ///   - duration: Duration in seconds the center was held
    ///   - clockwise: True for clockwise (positive), false for counter-clockwise (negative)
    /// - Returns: Angular velocity in degrees/second, signed based on direction
    public static func velocity(fromHoldDuration duration: TimeInterval, clockwise: Bool) -> Double {
        let magnitude = velocity(fromHoldDuration: duration)
        return clockwise ? magnitude : -magnitude
    }
    
    /// Check if a point is within the center press zone
    /// - Parameters:
    ///   - pointX: X coordinate of the touch point
    ///   - pointY: Y coordinate of the touch point
    ///   - wheelSize: Size of the wheel (width/height, assuming square)
    /// - Returns: True if point is within center radius
    public static func isInCenterRegion(
        pointX: Double,
        pointY: Double,
        wheelSize: Double
    ) -> Bool {
        let centerX = wheelSize / 2
        let centerY = wheelSize / 2
        
        let dx = pointX - centerX
        let dy = pointY - centerY
        let distance = sqrt(dx * dx + dy * dy)
        
        return distance <= centerRadius
    }
}
