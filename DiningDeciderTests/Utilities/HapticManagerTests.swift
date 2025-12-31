import XCTest
@testable import DiningDecider

final class HapticManagerTests: XCTestCase {

    var mockProvider: MockHapticProvider!
    var sut: HapticManager!

    override func setUp() {
        super.setUp()
        mockProvider = MockHapticProvider()
        sut = HapticManager(provider: mockProvider)
    }

    override func tearDown() {
        mockProvider = nil
        sut = nil
        super.tearDown()
    }

    // MARK: - Wheel Touch Haptic Tests

    func test_wheelTouchBegan_triggersLightImpact() {
        // When
        sut.wheelTouchBegan()

        // Then
        XCTAssertEqual(mockProvider.lightHapticCount, 1, "Should trigger exactly one light haptic on touch")
    }

    func test_wheelTouchBegan_setsCorrectHapticType() {
        // When
        sut.wheelTouchBegan()

        // Then
        XCTAssertEqual(mockProvider.lastHapticType, .impact(.light), "Last haptic should be light impact")
    }

    // MARK: - Spin Start Haptic Tests

    func test_spinStarted_triggersMediumImpact() {
        // When
        sut.spinStarted()

        // Then
        XCTAssertEqual(mockProvider.mediumHapticCount, 1, "Should trigger exactly one medium haptic on spin start")
    }

    func test_spinStarted_setsCorrectHapticType() {
        // When
        sut.spinStarted()

        // Then
        XCTAssertEqual(mockProvider.lastHapticType, .impact(.medium), "Last haptic should be medium impact")
    }

    // MARK: - Spin Complete Haptic Tests

    func test_spinCompleted_triggersSuccessNotification() {
        // When
        sut.spinCompleted()

        // Then
        XCTAssertEqual(mockProvider.successHapticCount, 1, "Should trigger exactly one success haptic on spin complete")
    }

    func test_spinCompleted_setsCorrectHapticType() {
        // When
        sut.spinCompleted()

        // Then
        XCTAssertEqual(mockProvider.lastHapticType, .notification(.success), "Last haptic should be success notification")
    }

    // MARK: - Multiple Haptics Tests

    func test_fullSpinCycle_triggersCorrectSequence() {
        // When - simulating a full spin cycle
        sut.wheelTouchBegan()
        sut.spinStarted()
        sut.spinCompleted()

        // Then
        XCTAssertEqual(mockProvider.lightHapticCount, 1, "Should have 1 light haptic")
        XCTAssertEqual(mockProvider.mediumHapticCount, 1, "Should have 1 medium haptic")
        XCTAssertEqual(mockProvider.successHapticCount, 1, "Should have 1 success haptic")
    }

    func test_fullSpinCycle_maintainsCorrectOrder() {
        // When
        sut.wheelTouchBegan()
        sut.spinStarted()
        sut.spinCompleted()

        // Then
        XCTAssertEqual(mockProvider.hapticCallOrder.count, 3, "Should have 3 haptic calls")
        XCTAssertEqual(mockProvider.hapticCallOrder[0], .impact(.light), "First should be light impact")
        XCTAssertEqual(mockProvider.hapticCallOrder[1], .impact(.medium), "Second should be medium impact")
        XCTAssertEqual(mockProvider.hapticCallOrder[2], .notification(.success), "Third should be success notification")
    }

    // MARK: - Haptic Disabled Tests

    func test_whenHapticsDisabled_wheelTouchDoesNotTrigger() {
        // Given
        sut.isEnabled = false

        // When
        sut.wheelTouchBegan()

        // Then
        XCTAssertEqual(mockProvider.lightHapticCount, 0, "Should not trigger haptic when disabled")
    }

    func test_whenHapticsDisabled_spinStartedDoesNotTrigger() {
        // Given
        sut.isEnabled = false

        // When
        sut.spinStarted()

        // Then
        XCTAssertEqual(mockProvider.mediumHapticCount, 0, "Should not trigger haptic when disabled")
    }

    func test_whenHapticsDisabled_spinCompletedDoesNotTrigger() {
        // Given
        sut.isEnabled = false

        // When
        sut.spinCompleted()

        // Then
        XCTAssertEqual(mockProvider.successHapticCount, 0, "Should not trigger haptic when disabled")
    }

    func test_whenReenabled_hapticsWorkAgain() {
        // Given
        sut.isEnabled = false
        sut.wheelTouchBegan()
        XCTAssertEqual(mockProvider.lightHapticCount, 0)

        // When
        sut.isEnabled = true
        sut.wheelTouchBegan()

        // Then
        XCTAssertEqual(mockProvider.lightHapticCount, 1, "Should trigger haptic after re-enabling")
    }

    // MARK: - Selection Haptic Tests

    func test_selectionChanged_triggersSelectionHaptic() {
        // When
        sut.selectionChanged()

        // Then
        XCTAssertEqual(mockProvider.selectionHapticCount, 1, "Should trigger selection haptic")
    }

    // MARK: - Default Provider Tests

    func test_defaultInitializer_createsSystemProvider() {
        // When
        let manager = HapticManager()

        // Then
        XCTAssertTrue(manager.isEnabled, "Haptics should be enabled by default")
    }
}
