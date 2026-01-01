import XCTest
import SwiftUI
import DiningDeciderCore
@testable import DiningDecider

/// Integration tests for SpinningWheelView haptic feedback.
/// These tests require iOS Simulator because they instantiate SwiftUI views.
/// Pure HapticManager logic tests are in HapticManagerTests.
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

    func test_spinningWheelView_initializesWithInjectedHapticManager() {
        // Given
        let sectors = WheelSector.skeletonSectors
        var rotation: Double = 0
        let binding = Binding(get: { rotation }, set: { rotation = $0 })

        // When
        let view = SpinningWheelView(
            sectors: sectors,
            rotation: binding,
            hapticManager: hapticManager
        )

        // Then - view should be created without crash
        XCTAssertNotNil(view)
    }

    func test_spinningWheelView_acceptsDifferentSectorCounts() {
        // Given
        var rotation: Double = 0
        let binding = Binding(get: { rotation }, set: { rotation = $0 })

        // When/Then - various sector counts should work
        let smallSectors = Array(WheelSector.skeletonSectors.prefix(4))
        let view1 = SpinningWheelView(sectors: smallSectors, rotation: binding, hapticManager: hapticManager)
        XCTAssertNotNil(view1)

        let largeSectors = WheelSector.skeletonSectors
        let view2 = SpinningWheelView(sectors: largeSectors, rotation: binding, hapticManager: hapticManager)
        XCTAssertNotNil(view2)
    }

    func test_spinningWheelView_acceptsOnSpinCompleteCallback() {
        // Given
        let sectors = WheelSector.skeletonSectors
        var rotation: Double = 0
        let binding = Binding(get: { rotation }, set: { rotation = $0 })
        var callbackCalled = false

        // When
        let view = SpinningWheelView(
            sectors: sectors,
            rotation: binding,
            hapticManager: hapticManager
        ) { _ in
            callbackCalled = true
        }

        // Then
        XCTAssertNotNil(view)
        // Note: We can't trigger the callback without UI interaction
        XCTAssertFalse(callbackCalled, "Callback should not be called during initialization")
    }
}
