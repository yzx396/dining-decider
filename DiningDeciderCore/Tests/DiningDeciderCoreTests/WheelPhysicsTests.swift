import XCTest
@testable import DiningDeciderCore

final class WheelPhysicsTests: XCTestCase {

    // MARK: - Angular Velocity Tests

    func test_angularVelocity_withPositiveValues_calculatesCorrectly() {
        let velocity = WheelPhysics.angularVelocity(angleDelta: 180, duration: 0.5)
        XCTAssertEqual(velocity, 360.0)
    }

    func test_angularVelocity_withZeroDuration_returnsZero() {
        let velocity = WheelPhysics.angularVelocity(angleDelta: 180, duration: 0)
        XCTAssertEqual(velocity, 0.0)
    }

    func test_angularVelocity_withNegativeDelta_returnsNegative() {
        let velocity = WheelPhysics.angularVelocity(angleDelta: -90, duration: 0.5)
        XCTAssertEqual(velocity, -180.0)
    }

    // MARK: - Angle From Center Tests

    func test_angleFromCenter_rightOfCenter_returnsZero() {
        let angle = WheelPhysics.angleFromCenter(centerX: 100, centerY: 100, pointX: 200, pointY: 100)
        XCTAssertEqual(angle, 0.0, accuracy: 0.001)
    }

    func test_angleFromCenter_belowCenter_returns90() {
        let angle = WheelPhysics.angleFromCenter(centerX: 100, centerY: 100, pointX: 100, pointY: 200)
        XCTAssertEqual(angle, 90.0, accuracy: 0.001)
    }

    func test_angleFromCenter_leftOfCenter_returns180OrMinus180() {
        let angle = WheelPhysics.angleFromCenter(centerX: 100, centerY: 100, pointX: 0, pointY: 100)
        XCTAssertEqual(abs(angle), 180.0, accuracy: 0.001)
    }

    func test_angleFromCenter_aboveCenter_returnsMinus90() {
        let angle = WheelPhysics.angleFromCenter(centerX: 100, centerY: 100, pointX: 100, pointY: 0)
        XCTAssertEqual(angle, -90.0, accuracy: 0.001)
    }

    // MARK: - Friction Tests

    func test_applyFriction_reducesVelocity() {
        let newVelocity = WheelPhysics.applyFriction(velocity: 100, friction: 0.98)
        XCTAssertEqual(newVelocity, 98.0)
    }

    func test_applyFriction_withZeroFriction_stopsImmediately() {
        let newVelocity = WheelPhysics.applyFriction(velocity: 100, friction: 0)
        XCTAssertEqual(newVelocity, 0.0)
    }

    func test_applyFriction_withNoFriction_maintainsVelocity() {
        let newVelocity = WheelPhysics.applyFriction(velocity: 100, friction: 1.0)
        XCTAssertEqual(newVelocity, 100.0)
    }

    // MARK: - Should Stop Tests

    func test_shouldStop_belowThreshold_returnsTrue() {
        XCTAssertTrue(WheelPhysics.shouldStop(velocity: 0.5, threshold: 1.0))
    }

    func test_shouldStop_atThreshold_returnsFalse() {
        XCTAssertFalse(WheelPhysics.shouldStop(velocity: 1.0, threshold: 1.0))
    }

    func test_shouldStop_aboveThreshold_returnsFalse() {
        XCTAssertFalse(WheelPhysics.shouldStop(velocity: 100, threshold: 1.0))
    }

    func test_shouldStop_negativeVelocity_usesAbsoluteValue() {
        XCTAssertTrue(WheelPhysics.shouldStop(velocity: -0.5, threshold: 1.0))
        XCTAssertFalse(WheelPhysics.shouldStop(velocity: -100, threshold: 1.0))
    }

    // MARK: - Clamp Velocity Tests

    func test_clampVelocity_belowMax_unchanged() {
        let clamped = WheelPhysics.clampVelocity(500, max: 2000)
        XCTAssertEqual(clamped, 500)
    }

    func test_clampVelocity_aboveMax_clampedToMax() {
        let clamped = WheelPhysics.clampVelocity(3000, max: 2000)
        XCTAssertEqual(clamped, 2000)
    }

    func test_clampVelocity_negativeAboveMax_clampedToNegativeMax() {
        let clamped = WheelPhysics.clampVelocity(-3000, max: 2000)
        XCTAssertEqual(clamped, -2000)
    }

    // MARK: - Rotation Delta Tests

    func test_rotationDeltaPerFrame_at60fps_calculatesCorrectly() {
        let delta = WheelPhysics.rotationDeltaPerFrame(velocity: 360, fps: 60)
        XCTAssertEqual(delta, 6.0)
    }

    func test_rotationDeltaPerFrame_withZeroFps_returnsZero() {
        let delta = WheelPhysics.rotationDeltaPerFrame(velocity: 360, fps: 0)
        XCTAssertEqual(delta, 0.0)
    }

    // MARK: - Constants Tests

    func test_defaultConstants_haveExpectedValues() {
        XCTAssertEqual(WheelPhysics.defaultFriction, 0.99)
        XCTAssertEqual(WheelPhysics.defaultStopThreshold, 1.0)
        XCTAssertEqual(WheelPhysics.maxVelocity, 2000.0)
        XCTAssertEqual(WheelPhysics.defaultFPS, 60.0)
    }
}
