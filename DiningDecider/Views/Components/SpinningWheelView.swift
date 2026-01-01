import SwiftUI
import DiningDeciderCore

struct SpinningWheelView: View {
    let sectors: [WheelSector]
    @Binding var rotation: Double
    let onSpinComplete: ((Int) -> Void)?
    let hapticManager: HapticManager

    @State private var angularVelocity: Double = 0
    @State private var lastAngle: Double = 0
    @State private var lastDragTime: Date = Date()
    @State private var isSpinning: Bool = false
    @State private var isDragging: Bool = false
    @State private var displayLink: Timer?

    private let borderWidth: CGFloat = 8
    private let centerDotSize: CGFloat = 50

    init(
        sectors: [WheelSector],
        rotation: Binding<Double>,
        hapticManager: HapticManager = HapticManager(),
        onSpinComplete: ((Int) -> Void)? = nil
    ) {
        self.sectors = sectors
        self._rotation = rotation
        self.hapticManager = hapticManager
        self.onSpinComplete = onSpinComplete
    }

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)

            ZStack {
                // Wheel sectors
                wheelSectors
                    .frame(width: size - borderWidth * 2, height: size - borderWidth * 2)
                    .rotationEffect(.degrees(rotation))

                // Border
                Circle()
                    .strokeBorder(Color.theme.wheelBorder, lineWidth: borderWidth)
                    .frame(width: size, height: size)

                // Center dot
                Circle()
                    .fill(Color.theme.wheelCenter)
                    .frame(width: centerDotSize, height: centerDotSize)
                    .shadow(color: .black.opacity(0.1), radius: 2, y: 1)

                // Pointer indicator (top)
                pointerIndicator
                    .offset(y: -size / 2 + 10)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .contentShape(Circle())
            .gesture(dragGesture(center: center))
        }
        .aspectRatio(1, contentMode: .fit)
        .onDisappear {
            stopAnimation()
        }
    }

    private var wheelSectors: some View {
        ZStack {
            ForEach(Array(sectors.enumerated()), id: \.element.id) { index, sector in
                let sectorAngle = 360.0 / Double(sectors.count)
                let startAngle = Double(index) * sectorAngle - 90
                let endAngle = startAngle + sectorAngle

                ZStack {
                    // Sector shape
                    WheelSectorShape(
                        startAngle: .degrees(startAngle),
                        endAngle: .degrees(endAngle)
                    )
                    .fill(sector.color)

                    // Sector label
                    sectorLabel(sector.label, color: sector.color, at: index, sectorAngle: sectorAngle)
                }
            }
        }
    }

    private func sectorLabel(_ text: String, color: Color, at index: Int, sectorAngle: Double) -> some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let radius = size / 2 * 0.65
            let midAngle = Double(index) * sectorAngle + sectorAngle / 2 - 90
            // Wrap 2-word categories onto two lines
            let wrappedText = text.contains(" ") ? text.replacingOccurrences(of: " ", with: "\n") : text

            Text(wrappedText)
                .font(.caption)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .lineSpacing(-2)
                .foregroundColor(color.contrastTextColor)
                .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                .rotationEffect(.degrees(midAngle + 90))
                .position(
                    x: geometry.size.width / 2 + CGFloat(cos(midAngle * .pi / 180)) * radius,
                    y: geometry.size.height / 2 + CGFloat(sin(midAngle * .pi / 180)) * radius
                )
        }
    }

    private var pointerIndicator: some View {
        Triangle()
            .fill(Color.theme.title)
            .frame(width: 20, height: 15)
    }

    // MARK: - Drag Gesture

    private func dragGesture(center: CGPoint) -> some Gesture {
        DragGesture()
            .onChanged { value in
                handleDragChanged(value: value, center: center)
            }
            .onEnded { value in
                handleDragEnded(value: value, center: center)
            }
    }

    private func handleDragChanged(value: DragGesture.Value, center: CGPoint) {
        // Stop any ongoing animation when user starts dragging
        if !isDragging {
            isDragging = true
            stopAnimation()
            // Light haptic when user first touches the wheel
            hapticManager.wheelTouchBegan()
        }

        let currentAngle = WheelPhysics.angleFromCenter(
            centerX: Double(center.x),
            centerY: Double(center.y),
            pointX: Double(value.location.x),
            pointY: Double(value.location.y)
        )
        let now = Date()

        if lastDragTime != Date.distantPast {
            let angleDelta = angleDifference(from: lastAngle, to: currentAngle)
            let timeDelta = now.timeIntervalSince(lastDragTime)

            // Update rotation immediately to follow finger
            rotation += angleDelta

            // Calculate velocity for momentum
            if timeDelta > 0 {
                angularVelocity = WheelPhysics.angularVelocity(angleDelta: angleDelta, duration: timeDelta)
            }
        }

        lastAngle = currentAngle
        lastDragTime = now
    }

    private func handleDragEnded(value: DragGesture.Value, center: CGPoint) {
        isDragging = false

        // Amplify velocity for more satisfying spin feel
        let amplifiedVelocity = angularVelocity * 1.5
        angularVelocity = WheelPhysics.clampVelocity(amplifiedVelocity, max: WheelPhysics.maxVelocity)

        // Only start momentum animation if we have meaningful velocity
        if abs(angularVelocity) > WheelPhysics.defaultStopThreshold {
            isSpinning = true
            // Medium haptic when spin starts
            hapticManager.spinStarted()
            startDecelerationAnimation()
        }
    }

    /// Calculate shortest angle difference (handles wrap-around at 180/-180)
    private func angleDifference(from: Double, to: Double) -> Double {
        var diff = to - from
        while diff > 180 { diff -= 360 }
        while diff < -180 { diff += 360 }
        return diff
    }

    // MARK: - Animation

    private func startDecelerationAnimation() {
        displayLink = Timer.scheduledTimer(withTimeInterval: 1.0 / WheelPhysics.defaultFPS, repeats: true) { _ in
            updateSpinAnimation()
        }
    }

    private func updateSpinAnimation() {
        guard isSpinning else {
            stopAnimation()
            return
        }

        // Apply rotation based on current velocity
        let delta = WheelPhysics.rotationDeltaPerFrame(velocity: angularVelocity, fps: WheelPhysics.defaultFPS)
        rotation += delta

        // Apply friction to slow down
        angularVelocity = WheelPhysics.applyFriction(velocity: angularVelocity, friction: WheelPhysics.defaultFriction)

        // Check if we should stop
        if WheelPhysics.shouldStop(velocity: angularVelocity, threshold: WheelPhysics.defaultStopThreshold) {
            completeSpinAnimation()
        }
    }

    private func completeSpinAnimation() {
        isSpinning = false
        angularVelocity = 0
        stopAnimation()

        // Success haptic when spin completes
        hapticManager.spinCompleted()

        // Calculate landing sector and notify
        let sectorIndex = WheelMath.landingSector(rotation: rotation, sectorCount: sectors.count)
        print("🎡 DEBUG: rotation=\(rotation), sectorCount=\(sectors.count), sectorIndex=\(sectorIndex), label=\(sectors[sectorIndex].label)")
        onSpinComplete?(sectorIndex)
    }

    private func stopAnimation() {
        displayLink?.invalidate()
        displayLink = nil
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var rotation: Double = 0

        var body: some View {
            SpinningWheelView(
                sectors: WheelSector.skeletonSectors,
                rotation: $rotation
            ) { sectorIndex in
                print("Landed on sector: \(sectorIndex)")
            }
            .frame(width: 300, height: 300)
            .padding()
            .background(Color.theme.background)
        }
    }

    return PreviewWrapper()
}
