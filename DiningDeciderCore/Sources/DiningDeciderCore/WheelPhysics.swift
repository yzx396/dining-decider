import Foundation

/// Physics calculations for wheel momentum and deceleration
public enum WheelPhysics {

    /// Conversion factor from radians to degrees
    private static let radiansToDegrees: Double = 180.0 / .pi

    /// Default friction coefficient for wheel deceleration (0.99 = 1% reduction per frame)
    public static let defaultFriction: Double = 0.99

    /// Default threshold for considering the wheel stopped (degrees/second)
    public static let defaultStopThreshold: Double = 1.0

    /// Maximum allowed angular velocity (degrees/second)
    public static let maxVelocity: Double = 2000.0

    /// Default frame rate for physics calculations
    public static let defaultFPS: Double = 60.0

    /// Calculates angular velocity from angle change over time
    /// - Parameters:
    ///   - angleDelta: Change in angle (degrees)
    ///   - duration: Time elapsed (seconds)
    /// - Returns: Angular velocity in degrees per second
    public static func angularVelocity(angleDelta: Double, duration: Double) -> Double {
        guard duration > 0 else { return 0 }
        return angleDelta / duration
    }

    /// Calculates angle in degrees from center to a point
    /// - Parameters:
    ///   - centerX: Center point X coordinate
    ///   - centerY: Center point Y coordinate
    ///   - pointX: Target point X coordinate
    ///   - pointY: Target point Y coordinate
    /// - Returns: Angle in degrees (-180 to 180)
    public static func angleFromCenter(centerX: Double, centerY: Double, pointX: Double, pointY: Double) -> Double {
        let deltaX = pointX - centerX
        let deltaY = pointY - centerY
        let radians = atan2(deltaY, deltaX)
        return radians * radiansToDegrees
    }

    /// Applies friction to reduce velocity
    /// - Parameters:
    ///   - velocity: Current angular velocity
    ///   - friction: Friction coefficient (0.0 to 1.0)
    /// - Returns: New velocity after friction applied
    public static func applyFriction(velocity: Double, friction: Double) -> Double {
        velocity * friction
    }

    /// Determines if the wheel should stop spinning
    /// - Parameters:
    ///   - velocity: Current angular velocity
    ///   - threshold: Minimum velocity to keep spinning
    /// - Returns: True if wheel should stop
    public static func shouldStop(velocity: Double, threshold: Double) -> Bool {
        abs(velocity) < threshold
    }

    /// Clamps velocity to maximum allowed value
    /// - Parameters:
    ///   - velocity: Input velocity
    ///   - max: Maximum allowed absolute velocity
    /// - Returns: Clamped velocity
    public static func clampVelocity(_ velocity: Double, max: Double) -> Double {
        min(max, Swift.max(-max, velocity))
    }

    /// Calculates rotation change for one frame
    /// - Parameters:
    ///   - velocity: Angular velocity in degrees per second
    ///   - fps: Frames per second
    /// - Returns: Rotation delta in degrees
    public static func rotationDeltaPerFrame(velocity: Double, fps: Double) -> Double {
        guard fps > 0 else { return 0 }
        return velocity / fps
    }
}
