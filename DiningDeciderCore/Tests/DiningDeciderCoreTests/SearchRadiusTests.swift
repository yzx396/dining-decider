import XCTest
@testable import DiningDeciderCore

final class SearchRadiusTests: XCTestCase {

    // MARK: - All Cases Tests

    func test_allCases_containsFourOptions() {
        XCTAssertEqual(SearchRadius.allCases.count, 4)
    }

    func test_allCases_hasCorrectOrder() {
        let expected: [SearchRadius] = [.fiveMiles, .tenMiles, .fifteenMiles, .twentyFiveMiles]
        XCTAssertEqual(SearchRadius.allCases, expected)
    }

    // MARK: - Miles Value Tests

    func test_fiveMiles_hasCorrectValue() {
        XCTAssertEqual(SearchRadius.fiveMiles.miles, 5.0)
    }

    func test_tenMiles_hasCorrectValue() {
        XCTAssertEqual(SearchRadius.tenMiles.miles, 10.0)
    }

    func test_fifteenMiles_hasCorrectValue() {
        XCTAssertEqual(SearchRadius.fifteenMiles.miles, 15.0)
    }

    func test_twentyFiveMiles_hasCorrectValue() {
        XCTAssertEqual(SearchRadius.twentyFiveMiles.miles, 25.0)
    }

    // MARK: - Label Tests

    func test_fiveMiles_hasCorrectLabel() {
        XCTAssertEqual(SearchRadius.fiveMiles.label, "5 mi")
    }

    func test_tenMiles_hasCorrectLabel() {
        XCTAssertEqual(SearchRadius.tenMiles.label, "10 mi")
    }

    func test_fifteenMiles_hasCorrectLabel() {
        XCTAssertEqual(SearchRadius.fifteenMiles.label, "15 mi")
    }

    func test_twentyFiveMiles_hasCorrectLabel() {
        XCTAssertEqual(SearchRadius.twentyFiveMiles.label, "25 mi")
    }

    // MARK: - Default Radius Tests

    func test_defaultRadius_isTenMiles() {
        XCTAssertEqual(SearchRadius.defaultRadius, .tenMiles)
    }

    func test_defaultRadius_hasMilesValue10() {
        XCTAssertEqual(SearchRadius.defaultRadius.miles, 10.0)
    }

    // MARK: - Identifiable Tests

    func test_id_returnsUniqueValuesForEachCase() {
        let ids = SearchRadius.allCases.map { $0.id }
        let uniqueIds = Set(ids)
        XCTAssertEqual(ids.count, uniqueIds.count)
    }

    // MARK: - Integration with DistanceCalculator

    func test_milesValue_matchesDistanceCalculatorDefault() {
        XCTAssertEqual(SearchRadius.defaultRadius.miles, DistanceCalculator.defaultRadiusMiles)
    }
}
