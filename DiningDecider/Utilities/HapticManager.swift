import UIKit
import DiningDeciderCore

// MARK: - System Haptic Provider (iOS-specific)

/// System implementation using UIKit haptic feedback generators
final class SystemHapticProvider: HapticProviding {
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let selectionGenerator = UISelectionFeedbackGenerator()

    init() {
        // Prepare generators for reduced latency
        lightImpact.prepare()
        mediumImpact.prepare()
        heavyImpact.prepare()
        notificationGenerator.prepare()
        selectionGenerator.prepare()
    }

    func triggerImpact(_ style: HapticType.ImpactStyle) {
        switch style {
        case .light:
            lightImpact.impactOccurred()
            lightImpact.prepare()
        case .medium:
            mediumImpact.impactOccurred()
            mediumImpact.prepare()
        case .heavy:
            heavyImpact.impactOccurred()
            heavyImpact.prepare()
        }
    }

    func triggerNotification(_ type: HapticType.NotificationType) {
        switch type {
        case .success:
            notificationGenerator.notificationOccurred(.success)
        case .warning:
            notificationGenerator.notificationOccurred(.warning)
        case .error:
            notificationGenerator.notificationOccurred(.error)
        }
        notificationGenerator.prepare()
    }

    func triggerSelection() {
        selectionGenerator.selectionChanged()
        selectionGenerator.prepare()
    }
}

// MARK: - Convenience Extension

extension HapticManager {
    /// Create a HapticManager with the system haptic provider
    convenience init() {
        self.init(provider: SystemHapticProvider())
    }
}
