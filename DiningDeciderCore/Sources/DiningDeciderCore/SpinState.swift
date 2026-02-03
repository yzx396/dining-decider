import Foundation

/// Result of a drag update containing angle and time deltas
public struct DragUpdateResult {
    public let angleDelta: Double
    public let timeDelta: TimeInterval
    
    public init(angleDelta: Double, timeDelta: TimeInterval) {
        self.angleDelta = angleDelta
        self.timeDelta = timeDelta
    }
}

/// Manages spin state with generation tracking to prevent race conditions.
/// Each new spin increments the generation, allowing stale completion callbacks to be ignored.
public final class SpinState {
    
    // MARK: - Spin State
    
    /// Current spin generation - incremented each time a spin starts
    public private(set) var generation: Int = 0
    
    /// Whether the wheel is currently spinning
    public private(set) var isSpinning: Bool = false
    
    /// Current angular velocity in degrees per second
    public private(set) var angularVelocity: Double = 0
    
    // MARK: - Drag State
    
    /// Last recorded angle during drag (nil if not dragging)
    public private(set) var lastAngle: Double = 0
    
    /// Last recorded time during drag (nil when drag hasn't started)
    public private(set) var lastDragTime: Date?
    
    /// Whether currently dragging
    public private(set) var isDragging: Bool = false
    
    // MARK: - Press State
    
    /// Time when press started (nil if not pressing)
    public private(set) var pressStartTime: Date?
    
    /// Whether currently pressing center
    public private(set) var isPressing: Bool = false
    
    /// Current hold duration for UI feedback
    public private(set) var currentHoldDuration: TimeInterval = 0
    
    // MARK: - Initialization
    
    public init() {}
    
    // MARK: - Spin Methods
    
    /// Starts a new spin, incrementing the generation
    /// - Parameter velocity: Initial angular velocity in degrees/second
    public func startSpin(velocity: Double) {
        generation += 1
        isSpinning = true
        angularVelocity = velocity
    }
    
    /// Stops the current spin
    public func stopSpin() {
        isSpinning = false
        angularVelocity = 0
    }
    
    /// Updates angular velocity (used during spin animation)
    /// - Parameter velocity: New velocity value
    public func updateVelocity(_ velocity: Double) {
        angularVelocity = velocity
    }
    
    /// Checks if completion should proceed for a given generation
    /// - Parameter forGeneration: The generation when spin started
    /// - Returns: True if this generation is current and still spinning
    public func shouldComplete(forGeneration gen: Int) -> Bool {
        return gen == generation && isSpinning
    }
    
    /// Atomically checks if completion should proceed and stops the spin.
    /// Use this for manual stops where the user touches the wheel to stop it.
    /// This prevents the race condition where stopSpin() is called before the completion check.
    /// - Parameter forGeneration: The generation when the spin started
    /// - Returns: True if completion should proceed (generation matches and was spinning)
    public func completeManualStop(forGeneration gen: Int) -> Bool {
        guard gen == generation && isSpinning else {
            return false
        }
        stopSpin()
        return true
    }
    
    // MARK: - Drag Methods
    
    /// Starts a drag gesture
    /// - Parameters:
    ///   - time: Current time
    ///   - angle: Current angle from center
    public func startDrag(at time: Date, angle: Double) {
        isDragging = true
        lastDragTime = time
        lastAngle = angle
    }
    
    /// Updates drag state and returns deltas for rotation calculation
    /// - Parameters:
    ///   - currentAngle: Current angle from center
    ///   - time: Current time
    /// - Returns: Angle and time deltas, or nil if drag hasn't properly started
    public func updateDrag(currentAngle: Double, at time: Date) -> DragUpdateResult? {
        guard let lastTime = lastDragTime else {
            return nil
        }
        
        let angleDelta = AngleMath.difference(from: lastAngle, to: currentAngle)
        let timeDelta = time.timeIntervalSince(lastTime)
        
        // Update state for next call
        lastAngle = currentAngle
        lastDragTime = time
        
        return DragUpdateResult(angleDelta: angleDelta, timeDelta: timeDelta)
    }
    
    /// Ends drag gesture
    public func endDrag() {
        isDragging = false
        lastDragTime = nil
    }
    
    // MARK: - Press Methods
    
    /// Starts a press gesture on the center
    /// - Parameter time: Current time
    public func startPress(at time: Date) {
        isPressing = true
        pressStartTime = time
        currentHoldDuration = 0
    }
    
    /// Updates hold duration for feedback
    /// - Parameter time: Current time
    public func updatePress(at time: Date) {
        guard let startTime = pressStartTime else { return }
        currentHoldDuration = time.timeIntervalSince(startTime)
    }
    
    /// Ends press gesture and returns hold duration
    /// - Parameter time: Current time
    /// - Returns: Total hold duration
    @discardableResult
    public func endPress(at time: Date) -> TimeInterval {
        guard let startTime = pressStartTime else {
            isPressing = false
            return 0
        }
        
        let duration = time.timeIntervalSince(startTime)
        isPressing = false
        pressStartTime = nil
        currentHoldDuration = 0
        
        return duration
    }
    
    /// Resets all state
    public func reset() {
        generation = 0
        isSpinning = false
        angularVelocity = 0
        lastAngle = 0
        lastDragTime = nil
        isDragging = false
        pressStartTime = nil
        isPressing = false
        currentHoldDuration = 0
    }
}

// MARK: - Angle Math

/// Pure functions for angle calculations
public enum AngleMath {
    
    /// Full rotation in degrees
    public static let fullRotation: Double = 360.0
    
    /// Half rotation in degrees
    public static let halfRotation: Double = 180.0
    
    /// Calculates the shortest angular difference between two angles
    /// Handles wraparound at ±180°
    /// - Parameters:
    ///   - from: Starting angle in degrees
    ///   - to: Ending angle in degrees
    /// - Returns: Signed difference in degrees (-180 to 180)
    public static func difference(from: Double, to: Double) -> Double {
        var diff = to - from
        
        // Normalize to -180...180 range
        while diff > halfRotation {
            diff -= fullRotation
        }
        while diff < -halfRotation {
            diff += fullRotation
        }
        
        return diff
    }
}
