import XCTest
import CoreLocation
@testable import DiningDecider

final class DistanceCalculatorTests: XCTestCase {

    // MARK: - Distance Calculation Tests

    func test_distanceInMiles_betweenSamePoint_isZero() {
        // Given
        let point = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)

        // When
        let distance = DistanceCalculator.distanceInMiles(from: point, to: point)

        // Then
        XCTAssertEqual(distance, 0, accuracy: 0.001)
    }

    func test_distanceInMiles_sfToOakland_isApproximately10Miles() {
        // Given
        let sf = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let oakland = CLLocationCoordinate2D(latitude: 37.8044, longitude: -122.2712)

        // When
        let distance = DistanceCalculator.distanceInMiles(from: sf, to: oakland)

        // Then: SF to Oakland is roughly 8-10 miles
        XCTAssertEqual(distance, 9, accuracy: 2)
    }

    func test_distanceInMiles_sfToNYC_isApproximately2500Miles() {
        // Given
        let sf = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let nyc = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)

        // When
        let distance = DistanceCalculator.distanceInMiles(from: sf, to: nyc)

        // Then: SF to NYC is roughly 2,500 miles
        XCTAssertEqual(distance, 2570, accuracy: 100)
    }

    // MARK: - Radius Check Tests

    func test_isWithinRadius_whenPointIsInRange_returnsTrue() {
        // Given
        let center = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let nearby = CLLocationCoordinate2D(latitude: 37.78, longitude: -122.42)

        // When
        let isWithin = DistanceCalculator.isWithinRadius(
            point: nearby,
            center: center,
            radiusMiles: 5
        )

        // Then
        XCTAssertTrue(isWithin)
    }

    func test_isWithinRadius_whenPointIsOutOfRange_returnsFalse() {
        // Given
        let sf = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let oakland = CLLocationCoordinate2D(latitude: 37.8044, longitude: -122.2712)

        // When: Oakland is ~9 miles from SF, check with 5 mile radius
        let isWithin = DistanceCalculator.isWithinRadius(
            point: oakland,
            center: sf,
            radiusMiles: 5
        )

        // Then
        XCTAssertFalse(isWithin)
    }

    func test_isWithinRadius_whenPointIsExactlyAtRadius_returnsTrue() {
        // Given
        let center = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let point = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)

        // When: Same point should be within any positive radius
        let isWithin = DistanceCalculator.isWithinRadius(
            point: point,
            center: center,
            radiusMiles: 0.001
        )

        // Then
        XCTAssertTrue(isWithin)
    }

    func test_isWithinRadius_withDefaultRadius_uses10Miles() {
        // Given
        let sf = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        // Point ~5 miles away
        let nearby = CLLocationCoordinate2D(latitude: 37.82, longitude: -122.42)

        // When: Use default radius
        let isWithin = DistanceCalculator.isWithinRadius(
            point: nearby,
            center: sf
        )

        // Then: Should be within default 10 miles
        XCTAssertTrue(isWithin)
    }

    // MARK: - Performance Tests

    func test_distanceCalculation_performance() {
        let sf = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let oakland = CLLocationCoordinate2D(latitude: 37.8044, longitude: -122.2712)

        measure {
            for _ in 0..<1000 {
                _ = DistanceCalculator.distanceInMiles(from: sf, to: oakland)
            }
        }
    }

    func test_radiusCheck_performance() {
        let center = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let points = (0..<100).map { i in
            CLLocationCoordinate2D(
                latitude: 37.7 + Double(i) * 0.01,
                longitude: -122.4 + Double(i) * 0.01
            )
        }

        measure {
            for point in points {
                _ = DistanceCalculator.isWithinRadius(point: point, center: center, radiusMiles: 10)
            }
        }
    }
}
