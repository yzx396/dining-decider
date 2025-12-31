import Foundation
import CoreGraphics

/// Physics calculations for wheel momentum and deceleration
enum WheelPhysics {

    /// Default friction coefficient for wheel deceleration (0.98 = 2% reduction per frame)
    static let defaultFriction: Double = 0.98

    /// Default threshold for considering the wheel stopped (degrees/second)
    static let defaultStopThreshold: Double = 1.0

    /// Maximum allowed angular velocity (degrees/second)
    static let maxVelocity: Double = 2000.0

    /// Default frame rate for physics calculations
    static let defaultFPS: Double = 60.0

    /// Calculates angular velocity from angle change over time
    /// - Parameters:
    ///   - angleDelta: Change in angle (degrees)
    ///   - duration: Time elapsed (seconds)
    /// - Returns: Angular velocity in degrees per second
    static func angularVelocity(angleDelta: Double, duration: Double) -> Double {
        guard duration > 0 else { return 0 }
        return angleDelta / duration
    }

    /// Calculates angle in degrees from center to a point
    /// - Parameters:
    ///   - center: Center point
    ///   - point: Target point
    /// - Returns: Angle in degrees (-180 to 180)
    static func angleFromCenter(center: CGPoint, point: CGPoint) -> Double {
        let deltaX = point.x - center.x
        let deltaY = point.y - center.y
        let radians = atan2(deltaY, deltaX)
        return radians * 180 / .pi
    }

    /// Applies friction to reduce velocity
    /// - Parameters:
    ///   - velocity: Current angular velocity
    ///   - friction: Friction coefficient (0.0 to 1.0)
    /// - Returns: New velocity after friction applied
    static func applyFriction(velocity: Double, friction: Double) -> Double {
        return velocity * friction
    }

    /// Determines if the wheel should stop spinning
    /// - Parameters:
    ///   - velocity: Current angular velocity
    ///   - threshold: Minimum velocity to keep spinning
    /// - Returns: True if wheel should stop
    static func shouldStop(velocity: Double, threshold: Double) -> Bool {
        return abs(velocity) < threshold
    }

    /// Clamps velocity to maximum allowed value
    /// - Parameters:
    ///   - velocity: Input velocity
    ///   - max: Maximum allowed absolute velocity
    /// - Returns: Clamped velocity
    static func clampVelocity(_ velocity: Double, max: Double) -> Double {
        if velocity > max {
            return max
        } else if velocity < -max {
            return -max
        }
        return velocity
    }

    /// Calculates rotation change for one frame
    /// - Parameters:
    ///   - velocity: Angular velocity in degrees per second
    ///   - fps: Frames per second
    /// - Returns: Rotation delta in degrees
    static func rotationDeltaPerFrame(velocity: Double, fps: Double) -> Double {
        guard fps > 0 else { return 0 }
        return velocity / fps
    }
}
