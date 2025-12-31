import XCTest
@testable import DiningDecider

final class SearchRadiusTests: XCTestCase {

    // MARK: - All Cases Tests

    func test_allCases_containsFourOptions() {
        // Given/When
        let allCases = SearchRadius.allCases

        // Then
        XCTAssertEqual(allCases.count, 4)
    }

    func test_allCases_hasCorrectOrder() {
        // Given/When
        let allCases = SearchRadius.allCases

        // Then
        XCTAssertEqual(allCases[0], .fiveMiles)
        XCTAssertEqual(allCases[1], .tenMiles)
        XCTAssertEqual(allCases[2], .fifteenMiles)
        XCTAssertEqual(allCases[3], .twentyFiveMiles)
    }

    // MARK: - Miles Value Tests

    func test_fiveMiles_hasCorrectValue() {
        // Given/When
        let radius = SearchRadius.fiveMiles

        // Then
        XCTAssertEqual(radius.miles, 5.0)
    }

    func test_tenMiles_hasCorrectValue() {
        // Given/When
        let radius = SearchRadius.tenMiles

        // Then
        XCTAssertEqual(radius.miles, 10.0)
    }

    func test_fifteenMiles_hasCorrectValue() {
        // Given/When
        let radius = SearchRadius.fifteenMiles

        // Then
        XCTAssertEqual(radius.miles, 15.0)
    }

    func test_twentyFiveMiles_hasCorrectValue() {
        // Given/When
        let radius = SearchRadius.twentyFiveMiles

        // Then
        XCTAssertEqual(radius.miles, 25.0)
    }

    // MARK: - Display Label Tests

    func test_fiveMiles_hasCorrectLabel() {
        // Given/When
        let radius = SearchRadius.fiveMiles

        // Then
        XCTAssertEqual(radius.label, "5 mi")
    }

    func test_tenMiles_hasCorrectLabel() {
        // Given/When
        let radius = SearchRadius.tenMiles

        // Then
        XCTAssertEqual(radius.label, "10 mi")
    }

    func test_fifteenMiles_hasCorrectLabel() {
        // Given/When
        let radius = SearchRadius.fifteenMiles

        // Then
        XCTAssertEqual(radius.label, "15 mi")
    }

    func test_twentyFiveMiles_hasCorrectLabel() {
        // Given/When
        let radius = SearchRadius.twentyFiveMiles

        // Then
        XCTAssertEqual(radius.label, "25 mi")
    }

    // MARK: - Default Value Tests

    func test_defaultRadius_isTenMiles() {
        // Given/When
        let defaultRadius = SearchRadius.defaultRadius

        // Then
        XCTAssertEqual(defaultRadius, .tenMiles)
    }

    func test_defaultRadius_hasMilesValue10() {
        // Given/When
        let defaultRadius = SearchRadius.defaultRadius

        // Then
        XCTAssertEqual(defaultRadius.miles, 10.0)
    }

    // MARK: - Identifiable Conformance

    func test_id_returnsUniqueValuesForEachCase() {
        // Given
        let allCases = SearchRadius.allCases

        // When
        let ids = Set(allCases.map { $0.id })

        // Then
        XCTAssertEqual(ids.count, allCases.count)
    }

    // MARK: - Integration with DistanceCalculator

    func test_milesValue_matchesDistanceCalculatorDefault() {
        // Given
        let defaultRadius = SearchRadius.defaultRadius

        // Then
        XCTAssertEqual(defaultRadius.miles, DistanceCalculator.defaultRadiusMiles)
    }
}
