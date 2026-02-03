import XCTest
@testable import DiningDeciderCore

/// Tests for SpinState management - tracking spin generations and preventing race conditions
final class SpinStateTests: XCTestCase {
    
    // MARK: - Spin Generation Tests (Bug #2: Race Condition)
    
    func test_initialGeneration_isZero() {
        let state = SpinState()
        XCTAssertEqual(state.generation, 0)
    }
    
    func test_startSpin_incrementsGeneration() {
        let state = SpinState()
        let initialGen = state.generation
        
        state.startSpin(velocity: 500)
        
        XCTAssertEqual(state.generation, initialGen + 1)
    }
    
    func test_startSpin_setsIsSpinningTrue() {
        let state = SpinState()
        
        state.startSpin(velocity: 500)
        
        XCTAssertTrue(state.isSpinning)
    }
    
    func test_startSpin_setsVelocity() {
        let state = SpinState()
        
        state.startSpin(velocity: 500)
        
        XCTAssertEqual(state.angularVelocity, 500)
    }
    
    func test_stopSpin_setsIsSpinningFalse() {
        let state = SpinState()
        state.startSpin(velocity: 500)
        
        state.stopSpin()
        
        XCTAssertFalse(state.isSpinning)
    }
    
    func test_stopSpin_zerosVelocity() {
        let state = SpinState()
        state.startSpin(velocity: 500)
        
        state.stopSpin()
        
        XCTAssertEqual(state.angularVelocity, 0)
    }
    
    func test_shouldCompleteForGeneration_returnsTrueForCurrentGeneration() {
        let state = SpinState()
        state.startSpin(velocity: 500)
        let currentGen = state.generation
        
        XCTAssertTrue(state.shouldComplete(forGeneration: currentGen))
    }
    
    func test_shouldCompleteForGeneration_returnsFalseForOldGeneration() {
        let state = SpinState()
        state.startSpin(velocity: 500)
        let oldGen = state.generation
        
        // User starts new interaction, incrementing generation
        state.startSpin(velocity: 600)
        
        XCTAssertFalse(state.shouldComplete(forGeneration: oldGen))
    }
    
    func test_shouldCompleteForGeneration_returnsFalseWhenNotSpinning() {
        let state = SpinState()
        state.startSpin(velocity: 500)
        let gen = state.generation
        state.stopSpin()
        
        // Even with matching generation, shouldn't complete if already stopped
        XCTAssertFalse(state.shouldComplete(forGeneration: gen))
    }
    
    func test_multipleSpinStarts_eachIncrementsGeneration() {
        let state = SpinState()
        
        state.startSpin(velocity: 100)
        XCTAssertEqual(state.generation, 1)
        
        state.startSpin(velocity: 200)
        XCTAssertEqual(state.generation, 2)
        
        state.startSpin(velocity: 300)
        XCTAssertEqual(state.generation, 3)
    }
    
    // MARK: - Drag State Tests (Bug #1: Dead Guard Fix)
    
    func test_initialDragTime_isNil() {
        let state = SpinState()
        XCTAssertNil(state.lastDragTime)
    }
    
    func test_startDrag_setsLastDragTime() {
        let state = SpinState()
        let now = Date()
        
        state.startDrag(at: now, angle: 45.0)
        
        XCTAssertEqual(state.lastDragTime, now)
    }
    
    func test_startDrag_setsLastAngle() {
        let state = SpinState()
        
        state.startDrag(at: Date(), angle: 45.0)
        
        XCTAssertEqual(state.lastAngle, 45.0)
    }
    
    func test_updateDrag_withNilLastDragTime_returnsNil() {
        let state = SpinState()
        
        let result = state.updateDrag(currentAngle: 90.0, at: Date())
        
        XCTAssertNil(result)
    }
    
    func test_updateDrag_withValidLastDragTime_returnsDelta() {
        let state = SpinState()
        let startTime = Date()
        state.startDrag(at: startTime, angle: 45.0)
        
        let updateTime = startTime.addingTimeInterval(0.1)
        let result = state.updateDrag(currentAngle: 90.0, at: updateTime)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.angleDelta, 45.0, accuracy: 0.001)
        XCTAssertEqual(result!.timeDelta, 0.1, accuracy: 0.001)
    }
    
    func test_updateDrag_updatesLastAngleAndTime() {
        let state = SpinState()
        let startTime = Date()
        state.startDrag(at: startTime, angle: 45.0)
        
        let updateTime = startTime.addingTimeInterval(0.1)
        _ = state.updateDrag(currentAngle: 90.0, at: updateTime)
        
        XCTAssertEqual(state.lastAngle, 90.0)
        XCTAssertEqual(state.lastDragTime, updateTime)
    }
    
    func test_endDrag_clearsLastDragTime() {
        let state = SpinState()
        state.startDrag(at: Date(), angle: 45.0)
        
        state.endDrag()
        
        XCTAssertNil(state.lastDragTime)
    }
    
    // MARK: - Press State Tests
    
    func test_initialPressStartTime_isNil() {
        let state = SpinState()
        XCTAssertNil(state.pressStartTime)
    }
    
    func test_startPress_setsPressStartTime() {
        let state = SpinState()
        let now = Date()
        
        state.startPress(at: now)
        
        XCTAssertEqual(state.pressStartTime, now)
    }
    
    func test_startPress_setsIsPressing() {
        let state = SpinState()
        
        state.startPress(at: Date())
        
        XCTAssertTrue(state.isPressing)
    }
    
    func test_endPress_returnsHoldDuration() {
        let state = SpinState()
        let startTime = Date()
        state.startPress(at: startTime)
        
        let endTime = startTime.addingTimeInterval(0.5)
        let duration = state.endPress(at: endTime)
        
        XCTAssertEqual(duration, 0.5, accuracy: 0.001)
    }
    
    func test_endPress_withNilStartTime_returnsZero() {
        let state = SpinState()
        
        let duration = state.endPress(at: Date())
        
        XCTAssertEqual(duration, 0)
    }
    
    func test_endPress_clearsIsPressing() {
        let state = SpinState()
        state.startPress(at: Date())
        
        _ = state.endPress(at: Date())
        
        XCTAssertFalse(state.isPressing)
    }
    
    func test_endPress_clearsPressStartTime() {
        let state = SpinState()
        state.startPress(at: Date())
        
        _ = state.endPress(at: Date())
        
        XCTAssertNil(state.pressStartTime)
    }
}
