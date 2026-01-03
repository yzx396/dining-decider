import Foundation
import CoreLocation
@testable import DiningDecider
import DiningDeciderCore

final class MockAPIService: RestaurantAPIProviding {

    var stubbedRestaurants: [Restaurant] = []
    var stubbedCategories: [String] = []
    var errorToThrow: APIError?

    // Track calls for verification
    var fetchRestaurantsCalled = false
    var fetchCategoriesCalled = false
    var lastCategory: String?
    var lastLocation: CLLocationCoordinate2D?
    var lastRadiusMiles: Double?
    var lastPriceLevels: [Int]?

    func fetchRestaurants(
        category: String,
        location: CLLocationCoordinate2D,
        radiusMiles: Double,
        priceLevels: [Int]?
    ) async throws -> [Restaurant] {
        fetchRestaurantsCalled = true
        lastCategory = category
        lastLocation = location
        lastRadiusMiles = radiusMiles
        lastPriceLevels = priceLevels

        if let error = errorToThrow {
            throw error
        }

        return stubbedRestaurants
    }

    func fetchCategories() async throws -> [String] {
        fetchCategoriesCalled = true

        if let error = errorToThrow {
            throw error
        }

        return stubbedCategories
    }

    func reset() {
        stubbedRestaurants = []
        stubbedCategories = []
        errorToThrow = nil
        fetchRestaurantsCalled = false
        fetchCategoriesCalled = false
        lastCategory = nil
        lastLocation = nil
        lastRadiusMiles = nil
        lastPriceLevels = nil
    }
}
