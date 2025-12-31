import CoreLocation
@testable import DiningDecider

/// Mock implementation of LocationProviding for testing
final class MockLocationProvider: LocationProviding {
    var currentLocation: CLLocationCoordinate2D?
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var requestPermissionCalled = false
    var startUpdatingCalled = false

    func requestPermission() {
        requestPermissionCalled = true
    }

    func startUpdatingLocation() {
        startUpdatingCalled = true
    }

    // Helper to simulate location authorization
    func simulateAuthorization(_ status: CLAuthorizationStatus) {
        authorizationStatus = status
    }

    // Helper to simulate location update
    func simulateLocationUpdate(_ coordinate: CLLocationCoordinate2D) {
        currentLocation = coordinate
    }
}
