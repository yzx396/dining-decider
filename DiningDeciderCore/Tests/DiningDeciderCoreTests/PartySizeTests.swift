import XCTest
@testable import DiningDeciderCore

final class PartySizeTests: XCTestCase {

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
        let newSize = PartySize.increment(2)
        XCTAssertEqual(newSize, 3)
    }

    func test_partySize_increment_atMaximum_staysAtMaximum() {
        let newSize = PartySize.increment(PartySize.maximum)
        XCTAssertEqual(newSize, PartySize.maximum)
    }

    func test_partySize_increment_nearMaximum_goesToMaximum() {
        let newSize = PartySize.increment(PartySize.maximum - 1)
        XCTAssertEqual(newSize, PartySize.maximum)
    }

    // MARK: - Decrement Tests

    func test_partySize_decrement_fromTwo_returnsOne() {
        let newSize = PartySize.decrement(2)
        XCTAssertEqual(newSize, 1)
    }

    func test_partySize_decrement_fromTen_returnsNine() {
        let newSize = PartySize.decrement(10)
        XCTAssertEqual(newSize, 9)
    }

    func test_partySize_decrement_atMinimum_staysAtMinimum() {
        let newSize = PartySize.decrement(PartySize.minimum)
        XCTAssertEqual(newSize, PartySize.minimum)
    }

    // MARK: - Can Increment Tests

    func test_partySize_canIncrement_belowMaximum_returnsTrue() {
        XCTAssertTrue(PartySize.canIncrement(10))
    }

    func test_partySize_canIncrement_atMaximum_returnsFalse() {
        XCTAssertFalse(PartySize.canIncrement(PartySize.maximum))
    }

    // MARK: - Can Decrement Tests

    func test_partySize_canDecrement_aboveMinimum_returnsTrue() {
        XCTAssertTrue(PartySize.canDecrement(5))
    }

    func test_partySize_canDecrement_atMinimum_returnsFalse() {
        XCTAssertFalse(PartySize.canDecrement(PartySize.minimum))
    }

    // MARK: - Validation Tests

    func test_partySize_isValid_withinRange_returnsTrue() {
        XCTAssertTrue(PartySize.isValid(1))
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
