import XCTest
@testable import DiningDeciderCore

/// Tests for AngleMath angle difference calculations (Bug #9: Angle Jump Edge Case)
final class AngleMathTests: XCTestCase {
    
    // MARK: - Basic Difference Tests
    
    func test_difference_sameAngle_returnsZero() {
        let diff = AngleMath.difference(from: 45, to: 45)
        XCTAssertEqual(diff, 0, accuracy: 0.001)
    }
    
    func test_difference_smallPositive_returnsPositive() {
        let diff = AngleMath.difference(from: 10, to: 20)
        XCTAssertEqual(diff, 10, accuracy: 0.001)
    }
    
    func test_difference_smallNegative_returnsNegative() {
        let diff = AngleMath.difference(from: 20, to: 10)
        XCTAssertEqual(diff, -10, accuracy: 0.001)
    }
    
    // MARK: - Wraparound Tests (Bug #9)
    
    func test_difference_crossingPositive180_wrapsCorrectly() {
        // From 170° to -170° should be +20° (shortest path clockwise)
        let diff = AngleMath.difference(from: 170, to: -170)
        XCTAssertEqual(diff, 20, accuracy: 0.001)
    }
    
    func test_difference_crossingNegative180_wrapsCorrectly() {
        // From -170° to 170° should be -20° (shortest path counter-clockwise)
        let diff = AngleMath.difference(from: -170, to: 170)
        XCTAssertEqual(diff, -20, accuracy: 0.001)
    }
    
    func test_difference_exactlyAt180_returnsCorrectSign() {
        // From 0° to 180° - exactly half rotation
        let diff = AngleMath.difference(from: 0, to: 180)
        // Could be +180 or -180, but should be within bounds
        XCTAssertTrue(abs(diff) <= 180.0)
    }
    
    func test_difference_exactlyAtMinus180_returnsCorrectSign() {
        let diff = AngleMath.difference(from: 0, to: -180)
        XCTAssertTrue(abs(diff) <= 180.0)
    }
    
    func test_difference_largePositiveJump_normalizes() {
        // If raw diff is 350°, should normalize to -10°
        let diff = AngleMath.difference(from: 0, to: 350)
        XCTAssertEqual(diff, -10, accuracy: 0.001)
    }
    
    func test_difference_largeNegativeJump_normalizes() {
        // If raw diff is -350°, should normalize to +10°
        let diff = AngleMath.difference(from: 0, to: -350)
        XCTAssertEqual(diff, 10, accuracy: 0.001)
    }
    
    // MARK: - Edge Cases
    
    func test_difference_fullRotation_returnsZero() {
        // 360° difference should normalize to 0°
        let diff = AngleMath.difference(from: 0, to: 360)
        XCTAssertEqual(diff, 0, accuracy: 0.001)
    }
    
    func test_difference_negativeFullRotation_returnsZero() {
        let diff = AngleMath.difference(from: 0, to: -360)
        XCTAssertEqual(diff, 0, accuracy: 0.001)
    }
    
    func test_difference_multipleRotations_normalizes() {
        // 720° should normalize to 0°
        let diff = AngleMath.difference(from: 0, to: 720)
        XCTAssertEqual(diff, 0, accuracy: 0.001)
    }
    
    func test_difference_alwaysWithinBounds() {
        // Test many random-ish angles to ensure result is always in [-180, 180]
        let testAngles: [Double] = [0, 45, 90, 135, 179, 180, 181, 270, 359, 360, 450, -45, -90, -180, -270]
        
        for fromAngle in testAngles {
            for toAngle in testAngles {
                let diff = AngleMath.difference(from: fromAngle, to: toAngle)
                XCTAssertGreaterThanOrEqual(diff, -180.0, "Diff \(diff) from \(fromAngle) to \(toAngle) is below -180")
                XCTAssertLessThanOrEqual(diff, 180.0, "Diff \(diff) from \(fromAngle) to \(toAngle) is above 180")
            }
        }
    }
    
    // MARK: - Constants
    
    func test_constants_haveCorrectValues() {
        XCTAssertEqual(AngleMath.fullRotation, 360.0)
        XCTAssertEqual(AngleMath.halfRotation, 180.0)
    }
}
