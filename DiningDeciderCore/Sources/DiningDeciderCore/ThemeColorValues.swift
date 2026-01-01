import Foundation

/// Centralized color hex values for light and dark modes.
/// These values are used by the main app to create adaptive SwiftUI Colors.
public enum ThemeColorValues {

    // MARK: - Background & Surfaces

    public enum Background {
        public static let light = "F0EFE9"  // Warm cream
        public static let dark = "1C1C1E"   // iOS system dark
    }

    public enum CardBackground {
        public static let light = "FFFFFF"  // White
        public static let dark = "2C2C2E"   // Elevated surface
    }

    // MARK: - Text Colors

    public enum Title {
        public static let light = "5E5B52"  // Muted charcoal
        public static let dark = "E5E5E5"   // Light gray
    }

    public enum Label {
        public static let light = "999999"  // Gray
        public static let dark = "8E8E93"   // iOS secondary label
    }

    public enum TextPrimary {
        public static let light = "333333"  // Dark gray
        public static let dark = "F5F5F5"   // Near white
    }

    public enum TextSecondary {
        public static let light = "FAFAFA"  // Off-white (for dark backgrounds)
        public static let dark = "FAFAFA"   // Same in dark mode
    }

    // MARK: - Interactive Elements

    public enum PrimaryButton {
        public static let light = "C8A299"  // Dusty rose
        public static let dark = "C8A299"   // Same - brand color
    }

    public enum PrimaryButtonText {
        public static let light = "FFFFFF"
        public static let dark = "FFFFFF"
    }

    public enum DisabledButton {
        public static let light = "DDDDDD"
        public static let dark = "48484A"   // Darker for dark mode
    }

    public enum Border {
        public static let light = "E0E0E0"  // Light gray
        public static let dark = "3A3A3C"   // iOS separator dark
    }

    // MARK: - Wheel Elements

    public enum WheelBorder {
        public static let light = "EAE8E1"  // Beige
        public static let dark = "3A3A3C"   // Dark border
    }

    public enum WheelCenter {
        public static let light = "FFFFFF"  // White
        public static let dark = "2C2C2E"   // Dark gray
    }

    // MARK: - Vibe Colors (Brand colors - same in both modes)

    public enum VibeAesthetic {
        public static let color = "D98880"  // Rose/coral
    }

    public enum VibeSplurge {
        public static let color = "884EA0"  // Deep purple
    }

    public enum VibeStandard {
        public static let color = "7F8C8D"  // Muted gray
    }

    // MARK: - Wheel Sector Colors (Same in both modes - vibrant)

    public static let aestheticWheelColors = [
        "E6B0AA",  // Soft pink
        "D98880",  // Rose
        "F1948A",  // Coral pink
        "C39BD3",  // Lavender
        "F5B7B1",  // Light pink
        "FAD7A0",  // Peach
        "E8DAEF",  // Light purple
        "D7BDE2"   // Soft purple
    ]

    public static let splurgeWheelColors = [
        "884EA0",  // Deep purple
        "AF7AC5",  // Medium purple
        "7D3C98",  // Dark purple
        "5B2C6F",  // Deeper purple
        "D2B4DE",  // Light purple
        "A569BD"   // Purple
    ]

    public static let standardWheelColors = [
        "A4B494",  // Sage green
        "DCC7AA",  // Tan
        "B5C0D0",  // Blue gray
        "E4B7B2",  // Dusty rose
        "C4C3D0",  // Soft gray
        "9FAEB5",  // Steel blue
        "D8DCD6",  // Light gray
        "C8A299"   // Warm gray
    ]
}
