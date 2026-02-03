import SwiftUI
import Combine
import DiningDeciderCore

struct SpinningWheelView: View {
    let sectors: [WheelSector]
    @Binding var rotation: Double
    let onSpinComplete: ((Int) -> Void)?
    let hapticManager: HapticManager

    @StateObject private var viewState = WheelViewState()

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
                viewState: viewState
            )
            .gesture(wheelGesture(center: center, wheelSize: wheelSize))
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .aspectRatio(1, contentMode: .fit)
        .onDisappear { cleanup() }
        .onChange(of: viewState.spinState.isSpinning) { _, isSpinning in
            handleSpinStateChange(isSpinning)
        }
    }
    
    private func wheelGesture(center: CGPoint, wheelSize: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                GestureHandler.handleChanged(
                    value: value,
                    center: center,
                    wheelSize: wheelSize,
                    viewState: viewState,
                    rotation: $rotation,
                    hapticManager: hapticManager,
                    sectorCount: sectors.count,
                    onStopSpin: { gen in safeCompleteSpin(forGeneration: gen) }
                )
            }
            .onEnded { _ in
                GestureHandler.handleEnded(
                    viewState: viewState,
                    hapticManager: hapticManager,
                    onStartSpin: startSpin
                )
            }
    }
    
    private func handleSpinStateChange(_ isSpinning: Bool) {
        if isSpinning {
            let generation = viewState.spinState.generation
            SpinAnimator.start(
                viewState: viewState,
                rotation: $rotation,
                onComplete: { safeCompleteSpin(forGeneration: generation) }
            )
        }
    }
    
    private func startSpin() {
        // SpinState.startSpin is called in GestureHandler, which sets isSpinning
        // The onChange handler above will trigger the animation
    }
    
    /// Safely completes spin only if generation matches (prevents race condition - Bug #2)
    private func safeCompleteSpin(forGeneration generation: Int) {
        guard viewState.spinState.shouldComplete(forGeneration: generation) else {
            return // Stale callback, ignore
        }
        
        viewState.spinState.stopSpin()
        hapticManager.spinCompleted()
        notifySpinComplete()
    }
    
    private func notifySpinComplete() {
        // Use safeLandingSector to prevent crash on empty sectors (Bug #3)
        guard let sectorIndex = WheelMath.safeLandingSector(
            rotation: rotation,
            sectorCount: sectors.count
        ) else {
            return // No sectors, nothing to report
        }
        onSpinComplete?(sectorIndex)
    }
    
    private func cleanup() {
        viewState.cleanup()
    }
}

// MARK: - Constants

private enum WheelViewConstants {
    // Layout
    static let borderWidth: CGFloat = 8
    static let centerButtonSize: CGFloat = 50
    static let pointerOffset: CGFloat = 10
    static let pointerWidth: CGFloat = 20
    static let pointerHeight: CGFloat = 15
    
    // Angles
    static let fullRotation: Double = 360.0
    static let halfRotation: Double = 180.0
    static let quarterRotation: Double = 90.0
    
    // Timing
    static let stopSpinDelay: TimeInterval = 0.5
    static let pressTimerInterval: TimeInterval = 0.05
    static let hapticFeedbackInterval: TimeInterval = 0.5
    
    /// Minimum tap duration for press-to-spin (Bug #7 documentation)
    /// Quick taps (< 0.3s) are treated as 0.3s to ensure minimum spin velocity.
    /// This provides consistent UX where even a tap produces a visible spin.
    static let minimumTapDuration: TimeInterval = 0.3
    
    /// Drag velocity amplification factor (Bug #8 documentation)
    /// Applied at drag release to make the wheel feel more responsive.
    /// A 1.5x multiplier means the wheel continues 50% faster than the drag speed.
    static let dragVelocityAmplification: Double = 1.5
}

// MARK: - View State Management

/// Observable wrapper around SpinState for SwiftUI integration
private final class WheelViewState: ObservableObject {
    let spinState = SpinState()
    
    // Display link for smooth animation (Bug #4 fix)
    var displayLink: CADisplayLink?
    var displayLinkTarget: DisplayLinkTarget?
    
    // Press timer for hold duration feedback
    var pressTimer: Timer?
    
    // Published for UI updates
    @Published var currentHoldDuration: TimeInterval = 0
    
    func cleanup() {
        pressTimer?.invalidate()
        pressTimer = nil
        displayLink?.invalidate()
        displayLink = nil
        displayLinkTarget = nil
    }
}

/// Target class for CADisplayLink (required because CADisplayLink uses target-action)
private final class DisplayLinkTarget {
    var onUpdate: (() -> Void)?
    
    @objc func update(_ displayLink: CADisplayLink) {
        onUpdate?()
    }
}

// MARK: - Gesture Handling

private enum GestureHandler {
    static func handleChanged(
        value: DragGesture.Value,
        center: CGPoint,
        wheelSize: CGFloat,
        viewState: WheelViewState,
        rotation: Binding<Double>,
        hapticManager: HapticManager,
        sectorCount: Int,
        onStopSpin: @escaping (Int) -> Void
    ) {
        let state = viewState.spinState
        
        if shouldContinueCurrentMode(state: state) {
            updateCurrentMode(value: value, center: center, state: state, rotation: rotation)
            return
        }
        
        stopSpinningIfNeeded(
            viewState: viewState,
            hapticManager: hapticManager,
            sectorCount: sectorCount,
            onStopSpin: onStopSpin
        )
        startInteractionMode(
            value: value,
            center: center,
            wheelSize: wheelSize,
            viewState: viewState,
            hapticManager: hapticManager
        )
    }
    
    static func handleEnded(
        viewState: WheelViewState,
        hapticManager: HapticManager,
        onStartSpin: @escaping () -> Void
    ) {
        let state = viewState.spinState
        
        if state.isPressing {
            PressMode.end(viewState: viewState, hapticManager: hapticManager, onStartSpin: onStartSpin)
        } else if state.isDragging {
            DragMode.end(viewState: viewState, hapticManager: hapticManager, onStartSpin: onStartSpin)
        }
    }
    
    // MARK: - Helper Methods
    
    private static func shouldContinueCurrentMode(state: SpinState) -> Bool {
        state.isDragging || state.isPressing
    }
    
    private static func updateCurrentMode(
        value: DragGesture.Value,
        center: CGPoint,
        state: SpinState,
        rotation: Binding<Double>
    ) {
        if state.isDragging {
            DragMode.update(value: value, center: center, state: state, rotation: rotation)
        }
        // Press mode doesn't need updates during drag
    }
    
    private static func stopSpinningIfNeeded(
        viewState: WheelViewState,
        hapticManager: HapticManager,
        sectorCount: Int,
        onStopSpin: @escaping (Int) -> Void
    ) {
        let state = viewState.spinState
        guard state.isSpinning else { return }
        
        // Capture generation before stopping
        let generation = state.generation
        
        SpinAnimator.stop(viewState: viewState)
        state.stopSpin()
        
        // Delay popup so user can see where the wheel landed
        // Pass generation to prevent race condition (Bug #2)
        DispatchQueue.main.asyncAfter(deadline: .now() + WheelViewConstants.stopSpinDelay) {
            onStopSpin(generation)
        }
    }
    
    private static func startInteractionMode(
        value: DragGesture.Value,
        center: CGPoint,
        wheelSize: CGFloat,
        viewState: WheelViewState,
        hapticManager: HapticManager
    ) {
        // Use PressSpinPhysics for center detection (Bug #6 - remove duplication)
        let isInCenter = PressSpinPhysics.isInCenterRegion(
            pointX: Double(value.startLocation.x - center.x + wheelSize / 2),
            pointY: Double(value.startLocation.y - center.y + wheelSize / 2),
            wheelSize: Double(wheelSize)
        )
        
        if isInCenter {
            PressMode.start(viewState: viewState, hapticManager: hapticManager)
        } else {
            DragMode.start(value: value, center: center, viewState: viewState, hapticManager: hapticManager)
        }
    }
}

// MARK: - Press Mode

private enum PressMode {
    static func start(viewState: WheelViewState, hapticManager: HapticManager) {
        let state = viewState.spinState
        let now = Date()
        
        state.startPress(at: now)
        SpinAnimator.stop(viewState: viewState)
        hapticManager.wheelTouchBegan()
        
        viewState.pressTimer = Timer.scheduledTimer(
            withTimeInterval: WheelViewConstants.pressTimerInterval,
            repeats: true
        ) { _ in
            updateTimer(viewState: viewState, hapticManager: hapticManager)
        }
    }
    
    static func end(
        viewState: WheelViewState,
        hapticManager: HapticManager,
        onStartSpin: @escaping () -> Void
    ) {
        let state = viewState.spinState
        
        viewState.pressTimer?.invalidate()
        viewState.pressTimer = nil
        
        let now = Date()
        var holdDuration = state.endPress(at: now)
        
        // Apply minimum tap duration (Bug #7)
        // This ensures even quick taps produce a visible spin
        holdDuration = max(holdDuration, WheelViewConstants.minimumTapDuration)
        
        let velocity = PressSpinPhysics.velocity(fromHoldDuration: holdDuration)
        
        if velocity > WheelPhysics.defaultStopThreshold {
            state.startSpin(velocity: velocity)
            hapticManager.spinStarted()
            onStartSpin()
        }
        
        viewState.currentHoldDuration = 0
    }
    
    private static func updateTimer(viewState: WheelViewState, hapticManager: HapticManager) {
        let state = viewState.spinState
        let now = Date()
        state.updatePress(at: now)
        viewState.currentHoldDuration = state.currentHoldDuration
        
        if shouldTriggerHapticFeedback(duration: state.currentHoldDuration) {
            hapticManager.wheelTouchBegan()
        }
    }
    
    private static func shouldTriggerHapticFeedback(duration: TimeInterval) -> Bool {
        guard duration > 0 else { return false }
        
        let interval = WheelViewConstants.hapticFeedbackInterval
        let timerInterval = WheelViewConstants.pressTimerInterval
        let intervals = Int(duration / interval)
        let previousIntervals = Int((duration - timerInterval) / interval)
        
        return intervals > previousIntervals
    }
}

// MARK: - Drag Mode

private enum DragMode {
    static func start(
        value: DragGesture.Value,
        center: CGPoint,
        viewState: WheelViewState,
        hapticManager: HapticManager
    ) {
        let state = viewState.spinState
        let now = Date()
        let angle = calculateAngle(value: value, center: center)
        
        state.startDrag(at: now, angle: angle)
        SpinAnimator.stop(viewState: viewState)
        hapticManager.wheelTouchBegan()
    }
    
    static func update(
        value: DragGesture.Value,
        center: CGPoint,
        state: SpinState,
        rotation: Binding<Double>
    ) {
        let currentAngle = calculateAngle(value: value, center: center)
        let now = Date()
        
        // Bug #1 fix: updateDrag returns nil if drag wasn't properly started
        guard let result = state.updateDrag(currentAngle: currentAngle, at: now) else {
            return
        }
        
        rotation.wrappedValue += result.angleDelta
        
        if result.timeDelta > 0 {
            let velocity = WheelPhysics.angularVelocity(
                angleDelta: result.angleDelta,
                duration: result.timeDelta
            )
            state.updateVelocity(velocity)
        }
    }
    
    static func end(
        viewState: WheelViewState,
        hapticManager: HapticManager,
        onStartSpin: @escaping () -> Void
    ) {
        let state = viewState.spinState
        state.endDrag()
        
        // Apply velocity amplification (Bug #8)
        // This makes the wheel feel more responsive by continuing faster than drag speed
        let amplifiedVelocity = state.angularVelocity * WheelViewConstants.dragVelocityAmplification
        let clampedVelocity = WheelPhysics.clampVelocity(amplifiedVelocity, max: WheelPhysics.maxVelocity)
        
        if abs(clampedVelocity) > WheelPhysics.defaultStopThreshold {
            state.startSpin(velocity: clampedVelocity)
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
    /// Starts spin animation using CADisplayLink for smooth 60fps/120fps animation (Bug #4 fix)
    static func start(
        viewState: WheelViewState,
        rotation: Binding<Double>,
        onComplete: @escaping () -> Void
    ) {
        // Create target for CADisplayLink
        let target = DisplayLinkTarget()
        viewState.displayLinkTarget = target
        
        target.onUpdate = { [weak viewState] in
            guard let viewState = viewState else { return }
            update(viewState: viewState, rotation: rotation, onComplete: onComplete)
        }
        
        let displayLink = CADisplayLink(target: target, selector: #selector(DisplayLinkTarget.update(_:)))
        displayLink.add(to: .main, forMode: .common)
        viewState.displayLink = displayLink
    }
    
    static func stop(viewState: WheelViewState) {
        viewState.displayLink?.invalidate()
        viewState.displayLink = nil
        viewState.displayLinkTarget = nil
    }
    
    private static func update(
        viewState: WheelViewState,
        rotation: Binding<Double>,
        onComplete: @escaping () -> Void
    ) {
        let state = viewState.spinState
        
        guard state.isSpinning else {
            stop(viewState: viewState)
            return
        }

        let delta = WheelPhysics.rotationDeltaPerFrame(
            velocity: state.angularVelocity,
            fps: WheelPhysics.defaultFPS
        )
        rotation.wrappedValue += delta

        let newVelocity = WheelPhysics.applyFriction(
            velocity: state.angularVelocity,
            friction: WheelPhysics.defaultFriction
        )
        state.updateVelocity(newVelocity)

        if WheelPhysics.shouldStop(
            velocity: state.angularVelocity,
            threshold: WheelPhysics.defaultStopThreshold
        ) {
            stop(viewState: viewState)
            onComplete()
        }
    }
}

// MARK: - UI Components

private struct WheelContent: View {
    let sectors: [WheelSector]
    let rotation: Double
    let wheelSize: CGFloat
    @ObservedObject var viewState: WheelViewState
    
    var body: some View {
        ZStack {
            WheelSectors(sectors: sectors, size: wheelSize)
                .rotationEffect(.degrees(rotation))
            
            WheelBorder(size: wheelSize)
            
            PressToSpinButton(
                size: WheelViewConstants.centerButtonSize,
                isPressing: viewState.spinState.isPressing,
                holdDuration: viewState.currentHoldDuration
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
        WheelViewConstants.fullRotation / Double(totalSectors)
    }
    
    private var startAngle: Double {
        Double(index) * sectorAngle - WheelViewConstants.quarterRotation
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
    
    private enum Constants {
        static let radiusMultiplier: CGFloat = 0.65
        static let lineSpacing: CGFloat = -2
        static let shadowOpacity: Double = 0.3
        static let shadowRadius: CGFloat = 1
        static let shadowOffset: (x: CGFloat, y: CGFloat) = (0, 1)
    }
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let radius = size / 2 * Constants.radiusMultiplier
            let midAngle = Double(index) * sectorAngle + sectorAngle / 2 - WheelViewConstants.quarterRotation
            
            Text(wrappedText)
                .font(.caption)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .lineSpacing(Constants.lineSpacing)
                .foregroundColor(color.contrastTextColor)
                .shadow(
                    color: .black.opacity(Constants.shadowOpacity),
                    radius: Constants.shadowRadius,
                    x: Constants.shadowOffset.x,
                    y: Constants.shadowOffset.y
                )
                .rotationEffect(.degrees(midAngle + WheelViewConstants.quarterRotation))
                .position(labelPosition(size: size, radius: radius, midAngle: midAngle))
        }
    }
    
    private var wrappedText: String {
        text.contains(" ") ? text.replacingOccurrences(of: " ", with: "\n") : text
    }
    
    private func labelPosition(size: CGFloat, radius: CGFloat, midAngle: Double) -> CGPoint {
        let radians = midAngle * .pi / WheelViewConstants.halfRotation
        return CGPoint(
            x: size / 2 + CGFloat(cos(radians)) * radius,
            y: size / 2 + CGFloat(sin(radians)) * radius
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
