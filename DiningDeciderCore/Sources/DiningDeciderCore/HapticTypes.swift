import Foundation

// MARK: - Haptic Types

/// Enum representing different types of haptic feedback
public enum HapticType: Equatable {
    case impact(ImpactStyle)
    case notification(NotificationType)
    case selection

    public enum ImpactStyle: Equatable {
        case light
        case medium
        case heavy
    }

    public enum NotificationType: Equatable {
        case success
        case warning
        case error
    }
}

// MARK: - Protocol

/// Protocol for haptic feedback providers, enabling testability
public protocol HapticProviding {
    func triggerImpact(_ style: HapticType.ImpactStyle)
    func triggerNotification(_ type: HapticType.NotificationType)
    func triggerSelection()
}

// MARK: - Haptic Manager

/// Manages haptic feedback throughout the app
/// Provides semantic methods for different user interactions
public final class HapticManager {
    private let provider: HapticProviding

    /// Whether haptic feedback is enabled
    public var isEnabled: Bool = true

    /// Initialize with a custom provider (for testing)
    public init(provider: HapticProviding) {
        self.provider = provider
    }

    // MARK: - Wheel Interaction Haptics

    /// Trigger haptic when user first touches the wheel
    /// Uses light impact for subtle feedback
    public func wheelTouchBegan() {
        guard isEnabled else { return }
        provider.triggerImpact(.light)
    }

    /// Trigger haptic when spin starts (user releases with velocity)
    /// Uses medium impact for noticeable feedback
    public func spinStarted() {
        guard isEnabled else { return }
        provider.triggerImpact(.medium)
    }

    /// Trigger haptic when spin completes and lands on a sector
    /// Uses success notification for satisfying completion feedback
    public func spinCompleted() {
        guard isEnabled else { return }
        provider.triggerNotification(.success)
    }

    // MARK: - General Haptics

    /// Trigger haptic for selection changes (e.g., picker changes)
    public func selectionChanged() {
        guard isEnabled else { return }
        provider.triggerSelection()
    }
}
