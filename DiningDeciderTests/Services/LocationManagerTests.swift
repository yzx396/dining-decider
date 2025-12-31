import XCTest
import CoreLocation
@testable import DiningDecider

final class LocationManagerTests: XCTestCase {

    // MARK: - Mock Tests (Testing the mock itself for protocol compliance)

    func test_mockLocationProvider_initialState_hasNoLocation() {
        // Given
        let mock = MockLocationProvider()

        // Then
        XCTAssertNil(mock.currentLocation)
        XCTAssertEqual(mock.authorizationStatus, .notDetermined)
    }

    func test_mockLocationProvider_requestPermission_setsFlag() {
        // Given
        let mock = MockLocationProvider()

        // When
        mock.requestPermission()

        // Then
        XCTAssertTrue(mock.requestPermissionCalled)
    }

    func test_mockLocationProvider_simulateLocationUpdate_setsLocation() {
        // Given
        let mock = MockLocationProvider()
        let expectedCoordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)

        // When
        mock.simulateLocationUpdate(expectedCoordinate)

        // Then
        XCTAssertNotNil(mock.currentLocation)
        XCTAssertEqual(mock.currentLocation?.latitude, expectedCoordinate.latitude)
        XCTAssertEqual(mock.currentLocation?.longitude, expectedCoordinate.longitude)
    }

    func test_mockLocationProvider_simulateAuthorization_setsStatus() {
        // Given
        let mock = MockLocationProvider()

        // When
        mock.simulateAuthorization(.authorizedWhenInUse)

        // Then
        XCTAssertEqual(mock.authorizationStatus, .authorizedWhenInUse)
    }

    // MARK: - Protocol Compliance Tests

    func test_locationProvider_conformsToProtocol() {
        // Given
        let mock: LocationProviding = MockLocationProvider()

        // Then: Protocol properties should be accessible
        _ = mock.currentLocation
        _ = mock.authorizationStatus
    }

    func test_locationProvider_isAuthorized_whenAuthorizedWhenInUse() {
        // Given
        let mock = MockLocationProvider()
        mock.simulateAuthorization(.authorizedWhenInUse)

        // When
        let isAuthorized = mock.isAuthorized

        // Then
        XCTAssertTrue(isAuthorized)
    }

    func test_locationProvider_isAuthorized_whenAuthorizedAlways() {
        // Given
        let mock = MockLocationProvider()
        mock.simulateAuthorization(.authorizedAlways)

        // When
        let isAuthorized = mock.isAuthorized

        // Then
        XCTAssertTrue(isAuthorized)
    }

    func test_locationProvider_isNotAuthorized_whenDenied() {
        // Given
        let mock = MockLocationProvider()
        mock.simulateAuthorization(.denied)

        // When
        let isAuthorized = mock.isAuthorized

        // Then
        XCTAssertFalse(isAuthorized)
    }

    func test_locationProvider_isNotAuthorized_whenNotDetermined() {
        // Given
        let mock = MockLocationProvider()

        // When
        let isAuthorized = mock.isAuthorized

        // Then
        XCTAssertFalse(isAuthorized)
    }
}
