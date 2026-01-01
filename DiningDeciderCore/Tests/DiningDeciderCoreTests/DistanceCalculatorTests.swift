import XCTest
@testable import DiningDeciderCore

final class DistanceCalculatorTests: XCTestCase {

    // Known coordinates for testing
    let sanFrancisco = (latitude: 37.7749, longitude: -122.4194)
    let oakland = (latitude: 37.8044, longitude: -122.2712)
    let losAngeles = (latitude: 34.0522, longitude: -118.2437)

    // MARK: - Distance Calculation Tests

    func test_distanceInMiles_sameLocation_returnsZero() {
        let distance = DistanceCalculator.distanceInMiles(
            fromLatitude: sanFrancisco.latitude,
            fromLongitude: sanFrancisco.longitude,
            toLatitude: sanFrancisco.latitude,
            toLongitude: sanFrancisco.longitude
        )
        XCTAssertEqual(distance, 0.0, accuracy: 0.001)
    }

    func test_distanceInMiles_sfToOakland_returnsApproximately10Miles() {
        let distance = DistanceCalculator.distanceInMiles(
            fromLatitude: sanFrancisco.latitude,
            fromLongitude: sanFrancisco.longitude,
            toLatitude: oakland.latitude,
            toLongitude: oakland.longitude
        )
        // SF to Oakland is approximately 8-10 miles
        XCTAssertGreaterThan(distance, 7.0)
        XCTAssertLessThan(distance, 12.0)
    }

    func test_distanceInMiles_sfToLA_returnsApproximately380Miles() {
        let distance = DistanceCalculator.distanceInMiles(
            fromLatitude: sanFrancisco.latitude,
            fromLongitude: sanFrancisco.longitude,
            toLatitude: losAngeles.latitude,
            toLongitude: losAngeles.longitude
        )
        // SF to LA is approximately 380 miles
        XCTAssertGreaterThan(distance, 340.0)
        XCTAssertLessThan(distance, 420.0)
    }

    func test_distanceInMiles_isSymmetric() {
        let distanceAB = DistanceCalculator.distanceInMiles(
            fromLatitude: sanFrancisco.latitude,
            fromLongitude: sanFrancisco.longitude,
            toLatitude: oakland.latitude,
            toLongitude: oakland.longitude
        )
        let distanceBA = DistanceCalculator.distanceInMiles(
            fromLatitude: oakland.latitude,
            fromLongitude: oakland.longitude,
            toLatitude: sanFrancisco.latitude,
            toLongitude: sanFrancisco.longitude
        )
        XCTAssertEqual(distanceAB, distanceBA, accuracy: 0.001)
    }

    // MARK: - Distance in Meters Tests

    func test_distanceInMeters_sameLocation_returnsZero() {
        let distance = DistanceCalculator.distanceInMeters(
            fromLatitude: sanFrancisco.latitude,
            fromLongitude: sanFrancisco.longitude,
            toLatitude: sanFrancisco.latitude,
            toLongitude: sanFrancisco.longitude
        )
        XCTAssertEqual(distance, 0.0, accuracy: 0.001)
    }

    func test_distanceInMeters_sfToOakland_returnsApproximately15000Meters() {
        let distance = DistanceCalculator.distanceInMeters(
            fromLatitude: sanFrancisco.latitude,
            fromLongitude: sanFrancisco.longitude,
            toLatitude: oakland.latitude,
            toLongitude: oakland.longitude
        )
        // SF to Oakland is approximately 12-16 km
        XCTAssertGreaterThan(distance, 12000.0)
        XCTAssertLessThan(distance, 18000.0)
    }

    // MARK: - Is Within Radius Tests

    func test_isWithinRadius_sameLocation_returnsTrue() {
        let isWithin = DistanceCalculator.isWithinRadius(
            pointLatitude: sanFrancisco.latitude,
            pointLongitude: sanFrancisco.longitude,
            centerLatitude: sanFrancisco.latitude,
            centerLongitude: sanFrancisco.longitude,
            radiusMiles: 10.0
        )
        XCTAssertTrue(isWithin)
    }

    func test_isWithinRadius_oaklandFromSF_with10MileRadius_returnsTrue() {
        let isWithin = DistanceCalculator.isWithinRadius(
            pointLatitude: oakland.latitude,
            pointLongitude: oakland.longitude,
            centerLatitude: sanFrancisco.latitude,
            centerLongitude: sanFrancisco.longitude,
            radiusMiles: 10.0
        )
        XCTAssertTrue(isWithin)
    }

    func test_isWithinRadius_laFromSF_with10MileRadius_returnsFalse() {
        let isWithin = DistanceCalculator.isWithinRadius(
            pointLatitude: losAngeles.latitude,
            pointLongitude: losAngeles.longitude,
            centerLatitude: sanFrancisco.latitude,
            centerLongitude: sanFrancisco.longitude,
            radiusMiles: 10.0
        )
        XCTAssertFalse(isWithin)
    }

    func test_isWithinRadius_usesDefaultRadius() {
        // Default radius is 10 miles, Oakland is within 10 miles of SF
        let isWithin = DistanceCalculator.isWithinRadius(
            pointLatitude: oakland.latitude,
            pointLongitude: oakland.longitude,
            centerLatitude: sanFrancisco.latitude,
            centerLongitude: sanFrancisco.longitude
        )
        XCTAssertTrue(isWithin)
    }

    // MARK: - Constants Tests

    func test_defaultRadiusMiles_isTen() {
        XCTAssertEqual(DistanceCalculator.defaultRadiusMiles, 10.0)
    }

    func test_metersPerMile_isCorrect() {
        XCTAssertEqual(DistanceCalculator.metersPerMile, 1609.34, accuracy: 0.01)
    }
}
