import XCTest
@testable import DiningDeciderCore

/// Mock implementation of HapticProviding for testing
final class MockHapticProvider: HapticProviding {
    private(set) var lightHapticCount: Int = 0
    private(set) var mediumHapticCount: Int = 0
    private(set) var heavyHapticCount: Int = 0
    private(set) var successHapticCount: Int = 0
    private(set) var warningHapticCount: Int = 0
    private(set) var errorHapticCount: Int = 0
    private(set) var selectionHapticCount: Int = 0
    private(set) var lastHapticType: HapticType?
    private(set) var hapticCallOrder: [HapticType] = []

    func triggerImpact(_ style: HapticType.ImpactStyle) {
        switch style {
        case .light:
            lightHapticCount += 1
            lastHapticType = .impact(.light)
            hapticCallOrder.append(.impact(.light))
        case .medium:
            mediumHapticCount += 1
            lastHapticType = .impact(.medium)
            hapticCallOrder.append(.impact(.medium))
        case .heavy:
            heavyHapticCount += 1
            lastHapticType = .impact(.heavy)
            hapticCallOrder.append(.impact(.heavy))
        }
    }

    func triggerNotification(_ type: HapticType.NotificationType) {
        switch type {
        case .success:
            successHapticCount += 1
            lastHapticType = .notification(.success)
            hapticCallOrder.append(.notification(.success))
        case .warning:
            warningHapticCount += 1
            lastHapticType = .notification(.warning)
            hapticCallOrder.append(.notification(.warning))
        case .error:
            errorHapticCount += 1
            lastHapticType = .notification(.error)
            hapticCallOrder.append(.notification(.error))
        }
    }

    func triggerSelection() {
        selectionHapticCount += 1
        lastHapticType = .selection
        hapticCallOrder.append(.selection)
    }

    func reset() {
        lightHapticCount = 0
        mediumHapticCount = 0
        heavyHapticCount = 0
        successHapticCount = 0
        warningHapticCount = 0
        errorHapticCount = 0
        selectionHapticCount = 0
        lastHapticType = nil
        hapticCallOrder = []
    }
}

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
        sut.wheelTouchBegan()
        XCTAssertEqual(mockProvider.lightHapticCount, 1)
    }

    func test_wheelTouchBegan_setsCorrectHapticType() {
        sut.wheelTouchBegan()
        XCTAssertEqual(mockProvider.lastHapticType, .impact(.light))
    }

    // MARK: - Spin Start Haptic Tests

    func test_spinStarted_triggersMediumImpact() {
        sut.spinStarted()
        XCTAssertEqual(mockProvider.mediumHapticCount, 1)
    }

    func test_spinStarted_setsCorrectHapticType() {
        sut.spinStarted()
        XCTAssertEqual(mockProvider.lastHapticType, .impact(.medium))
    }

    // MARK: - Spin Complete Haptic Tests

    func test_spinCompleted_triggersSuccessNotification() {
        sut.spinCompleted()
        XCTAssertEqual(mockProvider.successHapticCount, 1)
    }

    func test_spinCompleted_setsCorrectHapticType() {
        sut.spinCompleted()
        XCTAssertEqual(mockProvider.lastHapticType, .notification(.success))
    }

    // MARK: - Multiple Haptics Tests

    func test_fullSpinCycle_triggersCorrectSequence() {
        sut.wheelTouchBegan()
        sut.spinStarted()
        sut.spinCompleted()

        XCTAssertEqual(mockProvider.lightHapticCount, 1)
        XCTAssertEqual(mockProvider.mediumHapticCount, 1)
        XCTAssertEqual(mockProvider.successHapticCount, 1)
    }

    func test_fullSpinCycle_maintainsCorrectOrder() {
        sut.wheelTouchBegan()
        sut.spinStarted()
        sut.spinCompleted()

        XCTAssertEqual(mockProvider.hapticCallOrder.count, 3)
        XCTAssertEqual(mockProvider.hapticCallOrder[0], .impact(.light))
        XCTAssertEqual(mockProvider.hapticCallOrder[1], .impact(.medium))
        XCTAssertEqual(mockProvider.hapticCallOrder[2], .notification(.success))
    }

    // MARK: - Haptic Disabled Tests

    func test_whenHapticsDisabled_wheelTouchDoesNotTrigger() {
        sut.isEnabled = false
        sut.wheelTouchBegan()
        XCTAssertEqual(mockProvider.lightHapticCount, 0)
    }

    func test_whenHapticsDisabled_spinStartedDoesNotTrigger() {
        sut.isEnabled = false
        sut.spinStarted()
        XCTAssertEqual(mockProvider.mediumHapticCount, 0)
    }

    func test_whenHapticsDisabled_spinCompletedDoesNotTrigger() {
        sut.isEnabled = false
        sut.spinCompleted()
        XCTAssertEqual(mockProvider.successHapticCount, 0)
    }

    func test_whenReenabled_hapticsWorkAgain() {
        sut.isEnabled = false
        sut.wheelTouchBegan()
        XCTAssertEqual(mockProvider.lightHapticCount, 0)

        sut.isEnabled = true
        sut.wheelTouchBegan()
        XCTAssertEqual(mockProvider.lightHapticCount, 1)
    }

    // MARK: - Selection Haptic Tests

    func test_selectionChanged_triggersSelectionHaptic() {
        sut.selectionChanged()
        XCTAssertEqual(mockProvider.selectionHapticCount, 1)
    }

    func test_selectionChanged_setsCorrectHapticType() {
        sut.selectionChanged()
        XCTAssertEqual(mockProvider.lastHapticType, .selection)
    }

    // MARK: - Enabled by Default

    func test_isEnabled_defaultsToTrue() {
        XCTAssertTrue(sut.isEnabled)
    }
}
