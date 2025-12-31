import XCTest
@testable import DiningDecider

final class WheelPhysicsTests: XCTestCase {

    // MARK: - Angular Velocity Calculation Tests

    func test_angularVelocity_withZeroDuration_returnsZero() {
        // Given
        let angleDelta = 90.0
        let duration = 0.0

        // When
        let velocity = WheelPhysics.angularVelocity(angleDelta: angleDelta, duration: duration)

        // Then
        XCTAssertEqual(velocity, 0)
    }

    func test_angularVelocity_withPositiveValues_calculatesCorrectly() {
        // Given: 90 degrees in 0.1 seconds = 900 degrees/second
        let angleDelta = 90.0
        let duration = 0.1

        // When
        let velocity = WheelPhysics.angularVelocity(angleDelta: angleDelta, duration: duration)

        // Then
        XCTAssertEqual(velocity, 900.0, accuracy: 0.001)
    }

    func test_angularVelocity_withNegativeAngle_returnsNegativeVelocity() {
        // Given: -45 degrees in 0.1 seconds = -450 degrees/second
        let angleDelta = -45.0
        let duration = 0.1

        // When
        let velocity = WheelPhysics.angularVelocity(angleDelta: angleDelta, duration: duration)

        // Then
        XCTAssertEqual(velocity, -450.0, accuracy: 0.001)
    }

    // MARK: - Angle From Point Tests

    func test_angleFromCenter_atRightOfCenter_returnsZero() {
        // Given: Point directly to the right of center
        let center = CGPoint(x: 100, y: 100)
        let point = CGPoint(x: 150, y: 100)

        // When
        let angle = WheelPhysics.angleFromCenter(center: center, point: point)

        // Then: Right = 0 degrees (or 0 radians)
        XCTAssertEqual(angle, 0, accuracy: 0.001)
    }

    func test_angleFromCenter_atBottomOfCenter_returns90Degrees() {
        // Given: Point directly below center
        let center = CGPoint(x: 100, y: 100)
        let point = CGPoint(x: 100, y: 150)

        // When
        let angle = WheelPhysics.angleFromCenter(center: center, point: point)

        // Then: Bottom = 90 degrees
        XCTAssertEqual(angle, 90, accuracy: 0.001)
    }

    func test_angleFromCenter_atLeftOfCenter_returns180Degrees() {
        // Given: Point directly to the left of center
        let center = CGPoint(x: 100, y: 100)
        let point = CGPoint(x: 50, y: 100)

        // When
        let angle = WheelPhysics.angleFromCenter(center: center, point: point)

        // Then: Left = 180 degrees (or -180)
        XCTAssertEqual(abs(angle), 180, accuracy: 0.001)
    }

    func test_angleFromCenter_atTopOfCenter_returnsMinus90Degrees() {
        // Given: Point directly above center
        let center = CGPoint(x: 100, y: 100)
        let point = CGPoint(x: 100, y: 50)

        // When
        let angle = WheelPhysics.angleFromCenter(center: center, point: point)

        // Then: Top = -90 degrees
        XCTAssertEqual(angle, -90, accuracy: 0.001)
    }

    // MARK: - Deceleration Tests

    func test_applyFriction_reducesVelocity() {
        // Given
        let velocity = 1000.0
        let friction = 0.98

        // When
        let newVelocity = WheelPhysics.applyFriction(velocity: velocity, friction: friction)

        // Then
        XCTAssertEqual(newVelocity, 980.0, accuracy: 0.001)
    }

    func test_applyFriction_withZeroVelocity_returnsZero() {
        // Given
        let velocity = 0.0
        let friction = 0.98

        // When
        let newVelocity = WheelPhysics.applyFriction(velocity: velocity, friction: friction)

        // Then
        XCTAssertEqual(newVelocity, 0.0, accuracy: 0.001)
    }

    func test_applyFriction_withNegativeVelocity_reducesAbsoluteValue() {
        // Given
        let velocity = -1000.0
        let friction = 0.98

        // When
        let newVelocity = WheelPhysics.applyFriction(velocity: velocity, friction: friction)

        // Then
        XCTAssertEqual(newVelocity, -980.0, accuracy: 0.001)
    }

    // MARK: - Stopping Condition Tests

    func test_shouldStop_withVelocityBelowThreshold_returnsTrue() {
        // Given
        let velocity = 0.5
        let threshold = 1.0

        // When
        let shouldStop = WheelPhysics.shouldStop(velocity: velocity, threshold: threshold)

        // Then
        XCTAssertTrue(shouldStop)
    }

    func test_shouldStop_withVelocityAboveThreshold_returnsFalse() {
        // Given
        let velocity = 100.0
        let threshold = 1.0

        // When
        let shouldStop = WheelPhysics.shouldStop(velocity: velocity, threshold: threshold)

        // Then
        XCTAssertFalse(shouldStop)
    }

    func test_shouldStop_withNegativeVelocityBelowThreshold_returnsTrue() {
        // Given
        let velocity = -0.5
        let threshold = 1.0

        // When
        let shouldStop = WheelPhysics.shouldStop(velocity: velocity, threshold: threshold)

        // Then
        XCTAssertTrue(shouldStop)
    }

    // MARK: - Clamped Velocity Tests

    func test_clampVelocity_withinRange_returnsUnchanged() {
        // Given
        let velocity = 500.0
        let maxVelocity = 2000.0

        // When
        let clamped = WheelPhysics.clampVelocity(velocity, max: maxVelocity)

        // Then
        XCTAssertEqual(clamped, 500.0, accuracy: 0.001)
    }

    func test_clampVelocity_exceedsMax_returnsClamped() {
        // Given
        let velocity = 3000.0
        let maxVelocity = 2000.0

        // When
        let clamped = WheelPhysics.clampVelocity(velocity, max: maxVelocity)

        // Then
        XCTAssertEqual(clamped, 2000.0, accuracy: 0.001)
    }

    func test_clampVelocity_negativeExceedsMax_returnsNegativeClamped() {
        // Given
        let velocity = -3000.0
        let maxVelocity = 2000.0

        // When
        let clamped = WheelPhysics.clampVelocity(velocity, max: maxVelocity)

        // Then
        XCTAssertEqual(clamped, -2000.0, accuracy: 0.001)
    }

    // MARK: - Rotation Delta Per Frame Tests

    func test_rotationDeltaPerFrame_calculatesCorrectly() {
        // Given: 60 fps, velocity of 360 degrees/second = 6 degrees per frame
        let velocity = 360.0
        let fps = 60.0

        // When
        let delta = WheelPhysics.rotationDeltaPerFrame(velocity: velocity, fps: fps)

        // Then
        XCTAssertEqual(delta, 6.0, accuracy: 0.001)
    }

    func test_rotationDeltaPerFrame_withZeroFps_returnsZero() {
        // Given
        let velocity = 360.0
        let fps = 0.0

        // When
        let delta = WheelPhysics.rotationDeltaPerFrame(velocity: velocity, fps: fps)

        // Then
        XCTAssertEqual(delta, 0.0, accuracy: 0.001)
    }
}
