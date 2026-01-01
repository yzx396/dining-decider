import XCTest
@testable import DiningDeciderCore

final class PriceCalculatorTests: XCTestCase {

    // MARK: - Total Cost Tests

    func test_totalCost_multipliesAverageCostByPartySize() {
        let total = PriceCalculator.totalCost(averageCostPerPerson: 50, partySize: 4)
        XCTAssertEqual(total, 200)
    }

    func test_totalCost_withOneGuest_equalsAverageCost() {
        let total = PriceCalculator.totalCost(averageCostPerPerson: 35, partySize: 1)
        XCTAssertEqual(total, 35)
    }

    func test_totalCost_withMaxPartySize_calculatesCorrectly() {
        let total = PriceCalculator.totalCost(averageCostPerPerson: 100, partySize: PartySize.maximum)
        XCTAssertEqual(total, 2000)
    }

    func test_totalCost_withZeroPartySize_returnsZero() {
        let total = PriceCalculator.totalCost(averageCostPerPerson: 50, partySize: 0)
        XCTAssertEqual(total, 0)
    }

    // MARK: - Format Per Person Tests

    func test_formatPerPerson_formatsCorrectly() {
        let display = PriceCalculator.formatPerPerson(45)
        XCTAssertEqual(display, "$45/person")
    }

    func test_formatPerPerson_withZero_formatsCorrectly() {
        let display = PriceCalculator.formatPerPerson(0)
        XCTAssertEqual(display, "$0/person")
    }

    func test_formatPerPerson_withLargeValue_formatsCorrectly() {
        let display = PriceCalculator.formatPerPerson(500)
        XCTAssertEqual(display, "$500/person")
    }

    // MARK: - Format Total Tests

    func test_formatTotal_formatsTotalWithTildePrefix() {
        let display = PriceCalculator.formatTotal(180)
        XCTAssertEqual(display, "~$180 total")
    }

    func test_formatTotal_withZero_formatsCorrectly() {
        let display = PriceCalculator.formatTotal(0)
        XCTAssertEqual(display, "~$0 total")
    }

    // MARK: - Format Full Price Tests

    func test_formatFullPrice_formatsFullPriceString() {
        let display = PriceCalculator.formatFullPrice(averageCost: 65, partySize: 2)
        XCTAssertEqual(display, "$65/person · ~$130 total")
    }

    func test_formatFullPrice_withOneGuest_showsSamePerPersonAndTotal() {
        let display = PriceCalculator.formatFullPrice(averageCost: 50, partySize: 1)
        XCTAssertEqual(display, "$50/person · ~$50 total")
    }

    func test_formatFullPrice_withLargeParty_calculatesCorrectly() {
        let display = PriceCalculator.formatFullPrice(averageCost: 25, partySize: 10)
        XCTAssertEqual(display, "$25/person · ~$250 total")
    }
}
