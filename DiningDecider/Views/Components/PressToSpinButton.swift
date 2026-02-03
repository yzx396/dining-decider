import SwiftUI
import DiningDeciderCore

/// A pressable button in the center of the wheel that builds up spin velocity
struct PressToSpinButton: View {
    let size: CGFloat
    let isPressing: Bool
    let holdDuration: TimeInterval
    
    private var pressProgress: Double {
        ProgressCalculator.calculate(
            holdDuration: holdDuration,
            maxDuration: PressToSpinButtonConstants.maxHoldDuration
        )
    }
    
    var body: some View {
        ZStack {
            OuterGlowRing(size: size, isPressing: isPressing)
            ProgressRing(size: size, isPressing: isPressing, progress: pressProgress)
            ButtonBody(size: size, isPressing: isPressing)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressing)
    }
}

// MARK: - Constants

private enum PressToSpinButtonConstants {
    /// Maximum duration to reach 100% velocity (2000 / 600 = 3.33s)
    static let maxHoldDuration: TimeInterval = PressSpinPhysics.maxVelocity / PressSpinPhysics.velocityPerSecond
    
    static let glowSizeMultiplier: CGFloat = 1.2
    static let glowInnerRadius: CGFloat = 0.3
    static let glowOuterRadius: CGFloat = 0.6
    static let glowOpacity: Double = 0.3
    static let glowAnimationDuration: Double = 0.3
    
    static let progressRingLineWidth: CGFloat = 4
    static let progressRingOffset: CGFloat = 8
    static let progressAnimationDuration: Double = 0.05
    
    static let innerShadowLineWidth: CGFloat = 2
    
    static let iconSizeMultiplier: CGFloat = 0.3
    static let textSizeMultiplier: CGFloat = 0.15
    static let textOpacity: Double = 0.9
    static let contentSpacing: CGFloat = 2
    
    static let pressingScale: CGFloat = 0.95
    static let contentPressingScale: CGFloat = 0.9
    
    static let shadowRadius: (pressed: CGFloat, normal: CGFloat) = (8, 4)
    static let shadowY: (pressed: CGFloat, normal: CGFloat) = (2, 3)
    static let shadowOpacity: (pressed: Double, normal: Double) = (0.5, 0.2)
    
    static let gradientOpacity: (pressed: (top: Double, bottom: Double), normal: (top: Double, bottom: Double)) = (
        pressed: (0.9, 0.7),
        normal: (0.7, 0.5)
    )
    
    static let innerShadowOpacity: (pressed: (light: Double, dark: Double), normal: (light: Double, dark: Double)) = (
        pressed: (0.1, 0.1),
        normal: (0.3, 0.1)
    )
}

// MARK: - Helper

private enum ProgressCalculator {
    static func calculate(holdDuration: TimeInterval, maxDuration: TimeInterval) -> Double {
        min(holdDuration / maxDuration, 1.0)
    }
}

// MARK: - Subviews

private struct OuterGlowRing: View {
    let size: CGFloat
    let isPressing: Bool
    
    var body: some View {
        if isPressing {
            Circle()
                .fill(glowGradient)
                .frame(width: glowSize, height: glowSize)
                .animation(.easeInOut(duration: PressToSpinButtonConstants.glowAnimationDuration), value: isPressing)
        }
    }
    
    private var glowSize: CGFloat {
        size * PressToSpinButtonConstants.glowSizeMultiplier
    }
    
    private var glowGradient: RadialGradient {
        RadialGradient(
            gradient: Gradient(colors: [
                Color.theme.primaryButton.opacity(PressToSpinButtonConstants.glowOpacity),
                Color.theme.primaryButton.opacity(0)
            ]),
            center: .center,
            startRadius: size * PressToSpinButtonConstants.glowInnerRadius,
            endRadius: size * PressToSpinButtonConstants.glowOuterRadius
        )
    }
}

private struct ProgressRing: View {
    let size: CGFloat
    let isPressing: Bool
    let progress: Double
    
    var body: some View {
        Circle()
            .trim(from: 0, to: isPressing ? progress : 0)
            .stroke(
                Color.theme.primaryButton,
                style: StrokeStyle(
                    lineWidth: PressToSpinButtonConstants.progressRingLineWidth,
                    lineCap: .round
                )
            )
            .frame(width: ringSize, height: ringSize)
            .rotationEffect(.degrees(-90))
            .animation(.linear(duration: PressToSpinButtonConstants.progressAnimationDuration), value: progress)
    }
    
    private var ringSize: CGFloat {
        size + PressToSpinButtonConstants.progressRingOffset
    }
}

private struct ButtonBody: View {
    let size: CGFloat
    let isPressing: Bool
    
    var body: some View {
        ZStack {
            BackgroundGradient(size: size, isPressing: isPressing)
            InnerShadowBorder(isPressing: isPressing)
            ButtonContent(size: size, isPressing: isPressing)
        }
        .frame(width: size, height: size)
        .shadow(
            color: shadowColor,
            radius: shadowRadius,
            y: shadowY
        )
        .scaleEffect(isPressing ? PressToSpinButtonConstants.pressingScale : 1.0)
    }
    
    private var shadowColor: Color {
        isPressing
            ? Color.theme.primaryButton.opacity(PressToSpinButtonConstants.shadowOpacity.pressed)
            : Color.black.opacity(PressToSpinButtonConstants.shadowOpacity.normal)
    }
    
    private var shadowRadius: CGFloat {
        isPressing ? PressToSpinButtonConstants.shadowRadius.pressed : PressToSpinButtonConstants.shadowRadius.normal
    }
    
    private var shadowY: CGFloat {
        isPressing ? PressToSpinButtonConstants.shadowY.pressed : PressToSpinButtonConstants.shadowY.normal
    }
}

private struct BackgroundGradient: View {
    let size: CGFloat
    let isPressing: Bool
    
    var body: some View {
        Circle()
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: gradientColors),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }
    
    private var gradientColors: [Color] {
        let opacity = isPressing
            ? PressToSpinButtonConstants.gradientOpacity.pressed
            : PressToSpinButtonConstants.gradientOpacity.normal
        
        return [
            Color.theme.primaryButton.opacity(opacity.top),
            Color.theme.primaryButton.opacity(opacity.bottom)
        ]
    }
}

private struct InnerShadowBorder: View {
    let isPressing: Bool
    
    var body: some View {
        Circle()
            .strokeBorder(
                LinearGradient(
                    gradient: Gradient(colors: borderColors),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: PressToSpinButtonConstants.innerShadowLineWidth
            )
    }
    
    private var borderColors: [Color] {
        let opacity = isPressing
            ? PressToSpinButtonConstants.innerShadowOpacity.pressed
            : PressToSpinButtonConstants.innerShadowOpacity.normal
        
        return [
            Color.white.opacity(opacity.light),
            Color.black.opacity(opacity.dark)
        ]
    }
}

private struct ButtonContent: View {
    let size: CGFloat
    let isPressing: Bool
    
    var body: some View {
        VStack(spacing: PressToSpinButtonConstants.contentSpacing) {
            ButtonIcon(size: size, isPressing: isPressing)
            
            if !isPressing {
                ButtonLabel(size: size)
            }
        }
        .scaleEffect(isPressing ? PressToSpinButtonConstants.contentPressingScale : 1.0)
    }
}

private struct ButtonIcon: View {
    let size: CGFloat
    let isPressing: Bool
    
    var body: some View {
        Image(systemName: iconName)
            .font(.system(size: iconSize))
            .foregroundColor(.white)
    }
    
    private var iconName: String {
        isPressing ? "hand.raised.fill" : "hand.point.down.fill"
    }
    
    private var iconSize: CGFloat {
        size * PressToSpinButtonConstants.iconSizeMultiplier
    }
}

private struct ButtonLabel: View {
    let size: CGFloat
    
    var body: some View {
        Text("PRESS")
            .font(.system(size: textSize, weight: .bold, design: .rounded))
            .foregroundColor(.white.opacity(PressToSpinButtonConstants.textOpacity))
    }
    
    private var textSize: CGFloat {
        size * PressToSpinButtonConstants.textSizeMultiplier
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 40) {
        PressToSpinButton(size: 60, isPressing: false, holdDuration: 0)
        PressToSpinButton(size: 60, isPressing: true, holdDuration: 0.8)
        PressToSpinButton(size: 60, isPressing: true, holdDuration: 2.5)
        PressToSpinButton(size: 60, isPressing: true, holdDuration: 3.3)
    }
    .padding()
    .background(Color.theme.background)
}
