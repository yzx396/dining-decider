import Foundation
import DiningDeciderCore
@testable import DiningDecider

/// Mock implementation of HapticProviding for testing
final class MockHapticProvider: HapticProviding {
    // Track which haptics were triggered
    private(set) var lightHapticCount: Int = 0
    private(set) var mediumHapticCount: Int = 0
    private(set) var heavyHapticCount: Int = 0
    private(set) var successHapticCount: Int = 0
    private(set) var warningHapticCount: Int = 0
    private(set) var errorHapticCount: Int = 0
    private(set) var selectionHapticCount: Int = 0

    // Track the last haptic type triggered
    private(set) var lastHapticType: HapticType?

    // Track call order
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
