import XCTest
import SwiftUI
@testable import DiningDecider

final class SpinningWheelViewHapticTests: XCTestCase {

    var mockHapticProvider: MockHapticProvider!
    var hapticManager: HapticManager!

    override func setUp() {
        super.setUp()
        mockHapticProvider = MockHapticProvider()
        hapticManager = HapticManager(provider: mockHapticProvider)
    }

    override func tearDown() {
        mockHapticProvider = nil
        hapticManager = nil
        super.tearDown()
    }

    // MARK: - SpinningWheelView Initialization Tests

    func test_spinningWheelView_initializesWithHapticManager() {
        // Given
        let sectors = WheelSector.skeletonSectors

        // When
        var rotation: Double = 0
        let binding = Binding(get: { rotation }, set: { rotation = $0 })
        _ = SpinningWheelView(
            sectors: sectors,
            rotation: binding,
            hapticManager: hapticManager
        )

        // Then - no crash means initialization works
        XCTAssertTrue(true, "SpinningWheelView should initialize with haptic manager")
    }

    func test_spinningWheelView_initializesWithDefaultHapticManager() {
        // Given
        let sectors = WheelSector.skeletonSectors

        // When
        var rotation: Double = 0
        let binding = Binding(get: { rotation }, set: { rotation = $0 })
        _ = SpinningWheelView(
            sectors: sectors,
            rotation: binding
        )

        // Then - no crash means default initialization works
        XCTAssertTrue(true, "SpinningWheelView should initialize with default haptic manager")
    }

    // MARK: - HapticManager Integration Tests

    func test_hapticManager_wheelTouchBegan_triggersLightHaptic() {
        // When
        hapticManager.wheelTouchBegan()

        // Then
        XCTAssertEqual(mockHapticProvider.lightHapticCount, 1)
        XCTAssertEqual(mockHapticProvider.lastHapticType, .impact(.light))
    }

    func test_hapticManager_spinStarted_triggersMediumHaptic() {
        // When
        hapticManager.spinStarted()

        // Then
        XCTAssertEqual(mockHapticProvider.mediumHapticCount, 1)
        XCTAssertEqual(mockHapticProvider.lastHapticType, .impact(.medium))
    }

    func test_hapticManager_spinCompleted_triggersSuccessHaptic() {
        // When
        hapticManager.spinCompleted()

        // Then
        XCTAssertEqual(mockHapticProvider.successHapticCount, 1)
        XCTAssertEqual(mockHapticProvider.lastHapticType, .notification(.success))
    }

    // MARK: - Full Spin Cycle Test

    func test_fullSpinCycle_triggersHapticsInCorrectOrder() {
        // When - simulating what SpinningWheelView does
        hapticManager.wheelTouchBegan()    // User touches wheel
        hapticManager.spinStarted()        // User releases with velocity
        hapticManager.spinCompleted()      // Wheel stops spinning

        // Then
        XCTAssertEqual(mockHapticProvider.hapticCallOrder.count, 3)
        XCTAssertEqual(mockHapticProvider.hapticCallOrder[0], .impact(.light))
        XCTAssertEqual(mockHapticProvider.hapticCallOrder[1], .impact(.medium))
        XCTAssertEqual(mockHapticProvider.hapticCallOrder[2], .notification(.success))
    }
}
