import UIKit

// MARK: - Haptic Types

/// Enum representing different types of haptic feedback
enum HapticType: Equatable {
    case impact(ImpactStyle)
    case notification(NotificationType)
    case selection

    enum ImpactStyle: Equatable {
        case light
        case medium
        case heavy
    }

    enum NotificationType: Equatable {
        case success
        case warning
        case error
    }
}

// MARK: - Protocol

/// Protocol for haptic feedback providers, enabling testability
protocol HapticProviding {
    func triggerImpact(_ style: HapticType.ImpactStyle)
    func triggerNotification(_ type: HapticType.NotificationType)
    func triggerSelection()
}

// MARK: - System Haptic Provider

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

// MARK: - Haptic Manager

/// Manages haptic feedback throughout the app
/// Provides semantic methods for different user interactions
final class HapticManager {
    private let provider: HapticProviding

    /// Whether haptic feedback is enabled
    var isEnabled: Bool = true

    /// Initialize with a custom provider (for testing) or default to system haptics
    init(provider: HapticProviding = SystemHapticProvider()) {
        self.provider = provider
    }

    // MARK: - Wheel Interaction Haptics

    /// Trigger haptic when user first touches the wheel
    /// Uses light impact for subtle feedback
    func wheelTouchBegan() {
        guard isEnabled else { return }
        provider.triggerImpact(.light)
    }

    /// Trigger haptic when spin starts (user releases with velocity)
    /// Uses medium impact for noticeable feedback
    func spinStarted() {
        guard isEnabled else { return }
        provider.triggerImpact(.medium)
    }

    /// Trigger haptic when spin completes and lands on a sector
    /// Uses success notification for satisfying completion feedback
    func spinCompleted() {
        guard isEnabled else { return }
        provider.triggerNotification(.success)
    }

    // MARK: - General Haptics

    /// Trigger haptic for selection changes (e.g., picker changes)
    func selectionChanged() {
        guard isEnabled else { return }
        provider.triggerSelection()
    }
}
