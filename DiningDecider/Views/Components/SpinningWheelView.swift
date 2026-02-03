import SwiftUI
import Combine
import DiningDeciderCore

struct SpinningWheelView: View {
    let sectors: [WheelSector]
    @Binding var rotation: Double
    let onSpinComplete: ((Int) -> Void)?
    let hapticManager: HapticManager

    @StateObject private var state = WheelState()

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
            let wheelSize = min(geometry.size.width, geometry.size.height)
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)

            WheelContent(
                sectors: sectors,
                rotation: rotation,
                wheelSize: wheelSize,
                state: state
            )
            .gesture(wheelGesture(center: center, wheelSize: wheelSize))
            .simultaneousGesture(stopGesture)
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .aspectRatio(1, contentMode: .fit)
        .onDisappear { cleanup() }
        .onChange(of: state.isSpinning) { _, isSpinning in
            handleSpinStateChange(isSpinning)
        }
    }
    
    private var stopGesture: some Gesture {
        TapGesture().onEnded { _ in
            if state.isSpinning {
                stopSpinning()
            }
        }
    }
    
    private func wheelGesture(center: CGPoint, wheelSize: CGFloat) -> some Gesture {
        DragGesture()
            .onChanged { value in
                GestureHandler.handleChanged(
                    value: value,
                    center: center,
                    wheelSize: wheelSize,
                    state: state,
                    rotation: $rotation,
                    hapticManager: hapticManager
                )
            }
            .onEnded { _ in
                GestureHandler.handleEnded(
                    state: state,
                    hapticManager: hapticManager,
                    onStartSpin: startSpin
                )
            }
    }
    
    private func handleSpinStateChange(_ isSpinning: Bool) {
        if isSpinning {
            SpinAnimator.start(
                state: state,
                rotation: $rotation,
                onComplete: completeSpin
            )
        }
    }
    
    private func startSpin() {
        state.isSpinning = true
    }
    
    private func stopSpinning() {
        SpinAnimator.stop(state: state)
        hapticManager.spinCompleted()
        notifySpinComplete()
    }
    
    private func completeSpin() {
        hapticManager.spinCompleted()
        notifySpinComplete()
    }
    
    private func notifySpinComplete() {
        let sectorIndex = WheelMath.landingSector(rotation: rotation, sectorCount: sectors.count)
        onSpinComplete?(sectorIndex)
    }
    
    private func cleanup() {
        state.cleanup()
    }
}

// MARK: - Constants

private enum WheelViewConstants {
    static let borderWidth: CGFloat = 8
    static let centerButtonSize: CGFloat = 50
    static let pointerOffset: CGFloat = 10
    static let pointerWidth: CGFloat = 20
    static let pointerHeight: CGFloat = 15
}

// MARK: - State Management

private final class WheelState: ObservableObject {
    @Published var angularVelocity: Double = 0
    @Published var isSpinning: Bool = false
    @Published var isDragging: Bool = false
    @Published var isPressing: Bool = false
    @Published var currentHoldDuration: TimeInterval = 0
    
    var lastAngle: Double = 0
    var lastDragTime: Date = Date()
    var pressStartTime: Date?
    var pressTimer: Timer?
    var displayLink: Timer?
    
    func cleanup() {
        pressTimer?.invalidate()
        pressTimer = nil
        displayLink?.invalidate()
        displayLink = nil
    }
}

// MARK: - Gesture Handling

private enum GestureHandler {
    static func handleChanged(
        value: DragGesture.Value,
        center: CGPoint,
        wheelSize: CGFloat,
        state: WheelState,
        rotation: Binding<Double>,
        hapticManager: HapticManager
    ) {
        // If already in a mode, stay in that mode
        if state.isDragging {
            DragMode.update(value: value, center: center, state: state, rotation: rotation)
            return
        }
        
        if state.isPressing {
            // Continue pressing, don't switch modes
            return
        }
        
        // First touch - determine mode based on location
        let isInCenter = PressSpinPhysics.isInCenterRegion(
            pointX: Double(value.startLocation.x),
            pointY: Double(value.startLocation.y),
            wheelSize: Double(wheelSize)
        )
        
        if isInCenter && !state.isSpinning {
            PressMode.start(state: state, hapticManager: hapticManager)
        } else {
            DragMode.start(value: value, center: center, state: state, hapticManager: hapticManager)
        }
    }
    
    static func handleEnded(
        state: WheelState,
        hapticManager: HapticManager,
        onStartSpin: @escaping () -> Void
    ) {
        if state.isPressing {
            PressMode.end(state: state, hapticManager: hapticManager, onStartSpin: onStartSpin)
        } else if state.isDragging {
            DragMode.end(state: state, hapticManager: hapticManager, onStartSpin: onStartSpin)
        }
    }
}

// MARK: - Press Mode

private enum PressMode {
    static let timerInterval: TimeInterval = 0.05
    static let hapticIntervalMultiplier = 10
    static let hapticIntervalModulo = 5
    
    static func start(state: WheelState, hapticManager: HapticManager) {
        state.isPressing = true
        state.pressStartTime = Date()
        state.currentHoldDuration = 0
        
        SpinAnimator.stop(state: state)
        hapticManager.wheelTouchBegan()
        
        state.pressTimer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { _ in
            updateTimer(state: state, hapticManager: hapticManager)
        }
    }
    
    static func end(
        state: WheelState,
        hapticManager: HapticManager,
        onStartSpin: @escaping () -> Void
    ) {
        state.isPressing = false
        state.pressTimer?.invalidate()
        state.pressTimer = nil
        
        let velocity = PressSpinPhysics.velocity(fromHoldDuration: state.currentHoldDuration)
        
        if velocity > WheelPhysics.defaultStopThreshold {
            state.angularVelocity = velocity
            hapticManager.spinStarted()
            onStartSpin()
        }
        
        state.pressStartTime = nil
        state.currentHoldDuration = 0
    }
    
    private static func updateTimer(state: WheelState, hapticManager: HapticManager) {
        guard let startTime = state.pressStartTime else { return }
        state.currentHoldDuration = Date().timeIntervalSince(startTime)
        
        // Haptic feedback every 0.5 seconds
        let duration = state.currentHoldDuration
        if duration > 0 && Int(duration * Double(hapticIntervalMultiplier)) % hapticIntervalModulo == 0 {
            hapticManager.wheelTouchBegan()
        }
    }
}

// MARK: - Drag Mode

private enum DragMode {
    static let velocityAmplification: Double = 1.5
    
    static func start(
        value: DragGesture.Value,
        center: CGPoint,
        state: WheelState,
        hapticManager: HapticManager
    ) {
        state.isDragging = true
        SpinAnimator.stop(state: state)
        hapticManager.wheelTouchBegan()
        
        state.lastAngle = calculateAngle(value: value, center: center)
        state.lastDragTime = Date()
    }
    
    static func update(
        value: DragGesture.Value,
        center: CGPoint,
        state: WheelState,
        rotation: Binding<Double>
    ) {
        let currentAngle = calculateAngle(value: value, center: center)
        let now = Date()

        guard state.lastDragTime != Date.distantPast else { return }
        
        let angleDelta = AngleCalculator.difference(from: state.lastAngle, to: currentAngle)
        let timeDelta = now.timeIntervalSince(state.lastDragTime)

        rotation.wrappedValue += angleDelta

        if timeDelta > 0 {
            state.angularVelocity = WheelPhysics.angularVelocity(angleDelta: angleDelta, duration: timeDelta)
        }

        state.lastAngle = currentAngle
        state.lastDragTime = now
    }
    
    static func end(
        state: WheelState,
        hapticManager: HapticManager,
        onStartSpin: @escaping () -> Void
    ) {
        state.isDragging = false

        let amplifiedVelocity = state.angularVelocity * velocityAmplification
        state.angularVelocity = WheelPhysics.clampVelocity(amplifiedVelocity, max: WheelPhysics.maxVelocity)

        if abs(state.angularVelocity) > WheelPhysics.defaultStopThreshold {
            hapticManager.spinStarted()
            onStartSpin()
        }
    }
    
    private static func calculateAngle(value: DragGesture.Value, center: CGPoint) -> Double {
        WheelPhysics.angleFromCenter(
            centerX: Double(center.x),
            centerY: Double(center.y),
            pointX: Double(value.location.x),
            pointY: Double(value.location.y)
        )
    }
}

// MARK: - Spin Animation

private enum SpinAnimator {
    static func start(
        state: WheelState,
        rotation: Binding<Double>,
        onComplete: @escaping () -> Void
    ) {
        state.displayLink = Timer.scheduledTimer(
            withTimeInterval: 1.0 / WheelPhysics.defaultFPS,
            repeats: true
        ) { _ in
            update(state: state, rotation: rotation, onComplete: onComplete)
        }
    }
    
    static func stop(state: WheelState) {
        state.displayLink?.invalidate()
        state.displayLink = nil
    }
    
    private static func update(
        state: WheelState,
        rotation: Binding<Double>,
        onComplete: @escaping () -> Void
    ) {
        guard state.isSpinning else {
            stop(state: state)
            return
        }

        let delta = WheelPhysics.rotationDeltaPerFrame(
            velocity: state.angularVelocity,
            fps: WheelPhysics.defaultFPS
        )
        rotation.wrappedValue += delta

        state.angularVelocity = WheelPhysics.applyFriction(
            velocity: state.angularVelocity,
            friction: WheelPhysics.defaultFriction
        )

        if WheelPhysics.shouldStop(
            velocity: state.angularVelocity,
            threshold: WheelPhysics.defaultStopThreshold
        ) {
            complete(state: state, onComplete: onComplete)
        }
    }
    
    private static func complete(state: WheelState, onComplete: @escaping () -> Void) {
        state.isSpinning = false
        state.angularVelocity = 0
        stop(state: state)
        onComplete()
    }
}

// MARK: - Helper

private enum AngleCalculator {
    static func difference(from: Double, to: Double) -> Double {
        var diff = to - from
        while diff > 180 { diff -= 360 }
        while diff < -180 { diff += 360 }
        return diff
    }
}

// MARK: - UI Components

private struct WheelContent: View {
    let sectors: [WheelSector]
    let rotation: Double
    let wheelSize: CGFloat
    @ObservedObject var state: WheelState
    
    var body: some View {
        ZStack {
            WheelSectors(sectors: sectors, size: wheelSize)
                .rotationEffect(.degrees(rotation))
            
            WheelBorder(size: wheelSize)
            
            PressToSpinButton(
                size: WheelViewConstants.centerButtonSize,
                isPressing: state.isPressing,
                holdDuration: state.currentHoldDuration
            )
            
            PointerIndicator()
                .offset(y: -wheelSize / 2 + WheelViewConstants.pointerOffset)
        }
        .contentShape(Circle())
    }
}

private struct WheelSectors: View {
    let sectors: [WheelSector]
    let size: CGFloat
    
    var body: some View {
        ZStack {
            ForEach(Array(sectors.enumerated()), id: \.element.id) { index, sector in
                WheelSectorView(
                    sector: sector,
                    index: index,
                    totalSectors: sectors.count
                )
            }
        }
        .frame(
            width: size - WheelViewConstants.borderWidth * 2,
            height: size - WheelViewConstants.borderWidth * 2
        )
    }
}

private struct WheelSectorView: View {
    let sector: WheelSector
    let index: Int
    let totalSectors: Int
    
    private var sectorAngle: Double {
        360.0 / Double(totalSectors)
    }
    
    private var startAngle: Double {
        Double(index) * sectorAngle - 90
    }
    
    private var endAngle: Double {
        startAngle + sectorAngle
    }
    
    var body: some View {
        ZStack {
            WheelSectorShape(
                startAngle: .degrees(startAngle),
                endAngle: .degrees(endAngle)
            )
            .fill(sector.color)
            
            SectorLabel(
                text: sector.label,
                color: sector.color,
                index: index,
                sectorAngle: sectorAngle
            )
        }
    }
}

private struct SectorLabel: View {
    let text: String
    let color: Color
    let index: Int
    let sectorAngle: Double
    
    private let radiusMultiplier: CGFloat = 0.65
    private let angleOffset: Double = 90
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let radius = size / 2 * radiusMultiplier
            let midAngle = Double(index) * sectorAngle + sectorAngle / 2 - angleOffset
            
            Text(wrappedText)
                .font(.caption)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .lineSpacing(-2)
                .foregroundColor(color.contrastTextColor)
                .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                .rotationEffect(.degrees(midAngle + angleOffset))
                .position(labelPosition(size: size, radius: radius, midAngle: midAngle))
        }
    }
    
    private var wrappedText: String {
        text.contains(" ") ? text.replacingOccurrences(of: " ", with: "\n") : text
    }
    
    private func labelPosition(size: CGFloat, radius: CGFloat, midAngle: Double) -> CGPoint {
        CGPoint(
            x: size / 2 + CGFloat(cos(midAngle * .pi / 180)) * radius,
            y: size / 2 + CGFloat(sin(midAngle * .pi / 180)) * radius
        )
    }
}

private struct WheelBorder: View {
    let size: CGFloat
    
    var body: some View {
        Circle()
            .strokeBorder(Color.theme.wheelBorder, lineWidth: WheelViewConstants.borderWidth)
            .frame(width: size, height: size)
    }
}

private struct PointerIndicator: View {
    var body: some View {
        Triangle()
            .fill(Color.theme.title)
            .frame(
                width: WheelViewConstants.pointerWidth,
                height: WheelViewConstants.pointerHeight
            )
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Preview

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
