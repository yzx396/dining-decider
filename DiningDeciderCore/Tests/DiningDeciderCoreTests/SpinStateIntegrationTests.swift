import XCTest
@testable import DiningDeciderCore

/// Integration tests verifying SpinState works correctly with physics calculations
final class SpinStateIntegrationTests: XCTestCase {
    
    // MARK: - Drag to Spin Flow
    
    func test_dragToSpin_flow() {
        let state = SpinState()
        let startTime = Date()
        
        // Start drag
        state.startDrag(at: startTime, angle: 0)
        XCTAssertTrue(state.isDragging)
        XCTAssertEqual(state.lastDragTime, startTime)
        
        // Update drag multiple times
        let time1 = startTime.addingTimeInterval(0.016) // ~60fps
        let result1 = state.updateDrag(currentAngle: 10, at: time1)
        XCTAssertNotNil(result1)
        XCTAssertEqual(result1!.angleDelta, 10, accuracy: 0.001)
        
        let time2 = startTime.addingTimeInterval(0.032)
        let result2 = state.updateDrag(currentAngle: 25, at: time2)
        XCTAssertNotNil(result2)
        XCTAssertEqual(result2!.angleDelta, 15, accuracy: 0.001) // 25 - 10 = 15
        
        // Calculate velocity from last update
        let velocity = WheelPhysics.angularVelocity(
            angleDelta: result2!.angleDelta,
            duration: result2!.timeDelta
        )
        state.updateVelocity(velocity)
        
        // End drag
        state.endDrag()
        XCTAssertFalse(state.isDragging)
        
        // Start spin with amplified velocity
        let amplifiedVelocity = velocity * 1.5
        state.startSpin(velocity: amplifiedVelocity)
        
        XCTAssertTrue(state.isSpinning)
        XCTAssertEqual(state.generation, 1)
        XCTAssertGreaterThan(state.angularVelocity, 0)
    }
    
    // MARK: - Press to Spin Flow
    
    func test_pressToSpin_flow() {
        let state = SpinState()
        let startTime = Date()
        
        // Start press
        state.startPress(at: startTime)
        XCTAssertTrue(state.isPressing)
        
        // Update press
        let updateTime = startTime.addingTimeInterval(0.5)
        state.updatePress(at: updateTime)
        XCTAssertEqual(state.currentHoldDuration, 0.5, accuracy: 0.01)
        
        // End press
        let endTime = startTime.addingTimeInterval(1.0)
        let duration = state.endPress(at: endTime)
        XCTAssertEqual(duration, 1.0, accuracy: 0.01)
        XCTAssertFalse(state.isPressing)
        
        // Calculate velocity from duration
        let velocity = PressSpinPhysics.velocity(fromHoldDuration: duration)
        XCTAssertEqual(velocity, 600, accuracy: 1) // 1s * 600 deg/s/s
        
        // Start spin
        state.startSpin(velocity: velocity)
        XCTAssertTrue(state.isSpinning)
        XCTAssertEqual(state.angularVelocity, 600, accuracy: 1)
    }
    
    // MARK: - Race Condition Prevention (Bug #2)
    
    func test_raceCondition_interruptedSpin_ignoresStaleCallback() {
        let state = SpinState()
        
        // First spin starts
        state.startSpin(velocity: 500)
        let firstGeneration = state.generation
        XCTAssertEqual(firstGeneration, 1)
        XCTAssertTrue(state.shouldComplete(forGeneration: firstGeneration))
        
        // User interrupts by starting new interaction
        state.stopSpin()
        state.startSpin(velocity: 600)
        let secondGeneration = state.generation
        XCTAssertEqual(secondGeneration, 2)
        
        // Stale callback from first spin should be ignored
        XCTAssertFalse(state.shouldComplete(forGeneration: firstGeneration))
        
        // Current generation should still be valid
        XCTAssertTrue(state.shouldComplete(forGeneration: secondGeneration))
    }
    
    func test_raceCondition_stoppedSpin_ignoresCallback() {
        let state = SpinState()
        
        state.startSpin(velocity: 500)
        let generation = state.generation
        
        // Spin completes naturally
        state.stopSpin()
        
        // Delayed callback should not proceed
        XCTAssertFalse(state.shouldComplete(forGeneration: generation))
    }
    
    // MARK: - Angle Wraparound (Bug #9)
    
    func test_dragAcross180Boundary_calculatesCorrectly() {
        let state = SpinState()
        let startTime = Date()
        
        // Start at 170°
        state.startDrag(at: startTime, angle: 170)
        
        // Drag across to -170° (crossing the 180° boundary)
        let result = state.updateDrag(currentAngle: -170, at: startTime.addingTimeInterval(0.1))
        
        XCTAssertNotNil(result)
        // Should interpret as +20° (clockwise), not -340°
        XCTAssertEqual(result!.angleDelta, 20, accuracy: 0.001)
    }
    
    func test_dragAcrossNegative180Boundary_calculatesCorrectly() {
        let state = SpinState()
        let startTime = Date()
        
        // Start at -170°
        state.startDrag(at: startTime, angle: -170)
        
        // Drag across to 170° (crossing the -180° boundary)
        let result = state.updateDrag(currentAngle: 170, at: startTime.addingTimeInterval(0.1))
        
        XCTAssertNotNil(result)
        // Should interpret as -20° (counter-clockwise), not +340°
        XCTAssertEqual(result!.angleDelta, -20, accuracy: 0.001)
    }
    
    // MARK: - Safe Landing Sector (Bug #3)
    
    func test_safeLandingSector_withValidSectors_returnsIndex() {
        // Simulate spin completing at 90° rotation with 8 sectors
        let rotation = 90.0
        let sectorCount = 8
        
        let sectorIndex = WheelMath.safeLandingSector(rotation: rotation, sectorCount: sectorCount)
        
        XCTAssertNotNil(sectorIndex)
        XCTAssertTrue(sectorIndex! >= 0 && sectorIndex! < sectorCount)
    }
    
    func test_safeLandingSector_withEmptySectors_returnsNil() {
        let rotation = 90.0
        let sectorCount = 0
        
        let sectorIndex = WheelMath.safeLandingSector(rotation: rotation, sectorCount: sectorCount)
        
        XCTAssertNil(sectorIndex)
    }
    
    // MARK: - Bidirectional Press Spin (Bug #5)
    
    func test_bidirectionalSpin_clockwise() {
        let velocity = PressSpinPhysics.velocity(fromHoldDuration: 1.0, clockwise: true)
        XCTAssertGreaterThan(velocity, 0)
        
        let state = SpinState()
        state.startSpin(velocity: velocity)
        
        // Positive velocity = clockwise
        XCTAssertGreaterThan(state.angularVelocity, 0)
    }
    
    func test_bidirectionalSpin_counterClockwise() {
        let velocity = PressSpinPhysics.velocity(fromHoldDuration: 1.0, clockwise: false)
        XCTAssertLessThan(velocity, 0)
        
        let state = SpinState()
        state.startSpin(velocity: velocity)
        
        // Negative velocity = counter-clockwise
        XCTAssertLessThan(state.angularVelocity, 0)
    }
}
