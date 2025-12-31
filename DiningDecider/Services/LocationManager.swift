import CoreLocation
import SwiftUI

/// Protocol for location providing - enables dependency injection for testing
protocol LocationProviding: AnyObject {
    var currentLocation: CLLocationCoordinate2D? { get }
    var authorizationStatus: CLAuthorizationStatus { get }

    func requestPermission()
    func startUpdatingLocation()
}

/// Extension to add convenience computed property
extension LocationProviding {
    var isAuthorized: Bool {
        authorizationStatus == .authorizedWhenInUse ||
        authorizationStatus == .authorizedAlways
    }
}

/// Manages device location services
@Observable
final class LocationManager: NSObject, LocationProviding {

    private let manager = CLLocationManager()

    private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined
    private(set) var currentLocation: CLLocationCoordinate2D?
    private(set) var lastError: Error?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        authorizationStatus = manager.authorizationStatus
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func startUpdatingLocation() {
        guard isAuthorized else { return }
        manager.requestLocation()
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus

        if isAuthorized {
            manager.requestLocation()
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        currentLocation = locations.first?.coordinate
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        lastError = error
    }
}
