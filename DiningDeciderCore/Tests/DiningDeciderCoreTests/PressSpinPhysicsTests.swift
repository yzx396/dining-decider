import XCTest
@testable import DiningDeciderCore

/// Tests for calculating spin velocity from press-and-hold duration
final class PressSpinPhysicsTests: XCTestCase {
    
    // MARK: - Velocity from Hold Duration
    
    func test_velocityFromHoldDuration_withZeroDuration_returnsZero() {
        let velocity = PressSpinPhysics.velocity(fromHoldDuration: 0)
        XCTAssertEqual(velocity, 0, accuracy: 0.001)
    }
    
    func test_velocityFromHoldDuration_withShortPress_returnsLowVelocity() {
        // 0.1 seconds = just a tap, should give minimal velocity
        let velocity = PressSpinPhysics.velocity(fromHoldDuration: 0.1)
        XCTAssertGreaterThan(velocity, 0)
        XCTAssertLessThan(velocity, 100) // Low velocity
    }
    
    func test_velocityFromHoldDuration_withMediumPress_returnsMediumVelocity() {
        // 0.5 seconds = moderate hold
        let velocity = PressSpinPhysics.velocity(fromHoldDuration: 0.5)
        XCTAssertGreaterThan(velocity, 100)
        XCTAssertLessThan(velocity, 500)
    }
    
    func test_velocityFromHoldDuration_withLongPress_returnsHighVelocity() {
        // 1.0 seconds = long hold
        let velocity = PressSpinPhysics.velocity(fromHoldDuration: 1.0)
        XCTAssertGreaterThan(velocity, 500)
    }
    
    func test_velocityFromHoldDuration_withVeryLongPress_capsAtMaxVelocity() {
        // Both durations exceed max velocity (2000 / 600 = 3.33s threshold)
        let velocity1 = PressSpinPhysics.velocity(fromHoldDuration: 4.0)
        let velocity2 = PressSpinPhysics.velocity(fromHoldDuration: 10.0)
        
        // Both should be capped at max velocity
        XCTAssertEqual(velocity1, velocity2, accuracy: 1.0)
        XCTAssertEqual(velocity1, PressSpinPhysics.maxVelocity, accuracy: 1.0)
        XCTAssertLessThanOrEqual(velocity1, PressSpinPhysics.maxVelocity)
    }
    
    func test_velocityFromHoldDuration_growsLinearly() {
        // Velocity should grow proportionally with time (linear or near-linear)
        let v1 = PressSpinPhysics.velocity(fromHoldDuration: 0.2)
        let v2 = PressSpinPhysics.velocity(fromHoldDuration: 0.4)
        let v3 = PressSpinPhysics.velocity(fromHoldDuration: 0.6)
        
        // Each step should increase velocity
        XCTAssertGreaterThan(v2, v1)
        XCTAssertGreaterThan(v3, v2)
        
        // Roughly linear growth (within reason)
        let ratio1 = v2 / v1
        let ratio2 = v3 / v2
        XCTAssertEqual(ratio1, ratio2, accuracy: 0.5) // Allow some variance
    }
    
    // MARK: - Center Detection
    
    func test_isInCenterRegion_atExactCenter_returnsTrue() {
        let wheelSize: Double = 300
        let centerX = wheelSize / 2
        let centerY = wheelSize / 2
        
        let result = PressSpinPhysics.isInCenterRegion(
            pointX: centerX,
            pointY: centerY,
            wheelSize: wheelSize
        )
        
        XCTAssertTrue(result)
    }
    
    func test_isInCenterRegion_nearCenter_returnsTrue() {
        let wheelSize: Double = 300
        let centerX = wheelSize / 2
        let centerY = wheelSize / 2
        
        // Point slightly offset from center (within center dot)
        let result = PressSpinPhysics.isInCenterRegion(
            pointX: centerX + 10,
            pointY: centerY + 10,
            wheelSize: wheelSize
        )
        
        XCTAssertTrue(result)
    }
    
    func test_isInCenterRegion_atEdgeOfCenter_returnsTrue() {
        let wheelSize: Double = 300
        let centerX = wheelSize / 2
        let centerY = wheelSize / 2
        
        // Point at edge of center dot (25 pixels from center)
        let result = PressSpinPhysics.isInCenterRegion(
            pointX: centerX + 24,
            pointY: centerY,
            wheelSize: wheelSize
        )
        
        XCTAssertTrue(result)
    }
    
    func test_isInCenterRegion_outsideCenter_returnsFalse() {
        let wheelSize: Double = 300
        let centerX = wheelSize / 2
        let centerY = wheelSize / 2
        
        // Point outside center dot (50 pixels from center)
        let result = PressSpinPhysics.isInCenterRegion(
            pointX: centerX + 50,
            pointY: centerY,
            wheelSize: wheelSize
        )
        
        XCTAssertFalse(result)
    }
    
    func test_isInCenterRegion_atWheelEdge_returnsFalse() {
        let wheelSize: Double = 300
        
        // Point at edge of wheel
        let result = PressSpinPhysics.isInCenterRegion(
            pointX: 0,
            pointY: 0,
            wheelSize: wheelSize
        )
        
        XCTAssertFalse(result)
    }
    
    // MARK: - Constants
    
    func test_centerRadius_isPositive() {
        XCTAssertGreaterThan(PressSpinPhysics.centerRadius, 0)
    }
    
    func test_velocityPerSecond_isPositive() {
        XCTAssertGreaterThan(PressSpinPhysics.velocityPerSecond, 0)
    }
    
    func test_maxVelocity_isReasonable() {
        // Should be greater than velocity per second (otherwise max is reached instantly)
        XCTAssertGreaterThan(PressSpinPhysics.maxVelocity, PressSpinPhysics.velocityPerSecond)
        // Should match WheelPhysics max velocity for consistency
        XCTAssertEqual(PressSpinPhysics.maxVelocity, WheelPhysics.maxVelocity)
    }
    
    // MARK: - Bidirectional Spin Tests (Bug #5)
    
    func test_velocityWithDirection_clockwise_returnsPositive() {
        let velocity = PressSpinPhysics.velocity(fromHoldDuration: 0.5, clockwise: true)
        XCTAssertGreaterThan(velocity, 0)
    }
    
    func test_velocityWithDirection_counterClockwise_returnsNegative() {
        let velocity = PressSpinPhysics.velocity(fromHoldDuration: 0.5, clockwise: false)
        XCTAssertLessThan(velocity, 0)
    }
    
    func test_velocityWithDirection_sameMagnitude() {
        let cwVelocity = PressSpinPhysics.velocity(fromHoldDuration: 0.5, clockwise: true)
        let ccwVelocity = PressSpinPhysics.velocity(fromHoldDuration: 0.5, clockwise: false)
        
        XCTAssertEqual(abs(cwVelocity), abs(ccwVelocity), accuracy: 0.001)
    }
    
    func test_velocityWithDirection_respectsMaxVelocity() {
        let cwVelocity = PressSpinPhysics.velocity(fromHoldDuration: 10.0, clockwise: true)
        let ccwVelocity = PressSpinPhysics.velocity(fromHoldDuration: 10.0, clockwise: false)
        
        XCTAssertLessThanOrEqual(cwVelocity, PressSpinPhysics.maxVelocity)
        XCTAssertGreaterThanOrEqual(ccwVelocity, -PressSpinPhysics.maxVelocity)
    }
}
