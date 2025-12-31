import XCTest
@testable import DiningDecider

final class PartySizeStepperTests: XCTestCase {

    // MARK: - Constants Tests

    func test_partySize_minimumValue_isOne() {
        XCTAssertEqual(PartySize.minimum, 1)
    }

    func test_partySize_maximumValue_isTwenty() {
        XCTAssertEqual(PartySize.maximum, 20)
    }

    func test_partySize_defaultValue_isTwo() {
        XCTAssertEqual(PartySize.defaultSize, 2)
    }

    // MARK: - Increment Tests

    func test_partySize_increment_fromTwo_returnsThree() {
        // Given
        let currentSize = 2

        // When
        let newSize = PartySize.increment(currentSize)

        // Then
        XCTAssertEqual(newSize, 3)
    }

    func test_partySize_increment_atMaximum_staysAtMaximum() {
        // Given
        let currentSize = PartySize.maximum

        // When
        let newSize = PartySize.increment(currentSize)

        // Then
        XCTAssertEqual(newSize, PartySize.maximum)
    }

    func test_partySize_increment_nearMaximum_goesToMaximum() {
        // Given
        let currentSize = 19

        // When
        let newSize = PartySize.increment(currentSize)

        // Then
        XCTAssertEqual(newSize, 20)
    }

    // MARK: - Decrement Tests

    func test_partySize_decrement_fromTwo_returnsOne() {
        // Given
        let currentSize = 2

        // When
        let newSize = PartySize.decrement(currentSize)

        // Then
        XCTAssertEqual(newSize, 1)
    }

    func test_partySize_decrement_atMinimum_staysAtMinimum() {
        // Given
        let currentSize = PartySize.minimum

        // When
        let newSize = PartySize.decrement(currentSize)

        // Then
        XCTAssertEqual(newSize, PartySize.minimum)
    }

    func test_partySize_decrement_fromTen_returnsNine() {
        // Given
        let currentSize = 10

        // When
        let newSize = PartySize.decrement(currentSize)

        // Then
        XCTAssertEqual(newSize, 9)
    }

    // MARK: - Bounds Checking Tests

    func test_partySize_canDecrement_atMinimum_returnsFalse() {
        XCTAssertFalse(PartySize.canDecrement(PartySize.minimum))
    }

    func test_partySize_canDecrement_aboveMinimum_returnsTrue() {
        XCTAssertTrue(PartySize.canDecrement(2))
        XCTAssertTrue(PartySize.canDecrement(10))
        XCTAssertTrue(PartySize.canDecrement(PartySize.maximum))
    }

    func test_partySize_canIncrement_atMaximum_returnsFalse() {
        XCTAssertFalse(PartySize.canIncrement(PartySize.maximum))
    }

    func test_partySize_canIncrement_belowMaximum_returnsTrue() {
        XCTAssertTrue(PartySize.canIncrement(1))
        XCTAssertTrue(PartySize.canIncrement(10))
        XCTAssertTrue(PartySize.canIncrement(19))
    }

    // MARK: - Edge Case Tests

    func test_partySize_isValid_withinRange_returnsTrue() {
        XCTAssertTrue(PartySize.isValid(1))
        XCTAssertTrue(PartySize.isValid(2))
        XCTAssertTrue(PartySize.isValid(10))
        XCTAssertTrue(PartySize.isValid(20))
    }

    func test_partySize_isValid_belowMinimum_returnsFalse() {
        XCTAssertFalse(PartySize.isValid(0))
        XCTAssertFalse(PartySize.isValid(-1))
    }

    func test_partySize_isValid_aboveMaximum_returnsFalse() {
        XCTAssertFalse(PartySize.isValid(21))
        XCTAssertFalse(PartySize.isValid(100))
    }
}
