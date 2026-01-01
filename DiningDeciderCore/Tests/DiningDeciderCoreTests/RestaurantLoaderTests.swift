import XCTest
import CoreLocation
@testable import DiningDeciderCore

final class RestaurantLoaderTests: XCTestCase {

    // MARK: - Loading Tests

    func test_init_withValidJSON_loadsSuccessfully() throws {
        let json = validRestaurantJSON()
        let data = json.data(using: .utf8)!
        let loader = try RestaurantLoader(data: data)
        XCTAssertNotNil(loader)
    }

    func test_init_withInvalidJSON_throws() {
        let invalidJSON = "{ invalid json }"
        let data = invalidJSON.data(using: .utf8)!
        XCTAssertThrowsError(try RestaurantLoader(data: data))
    }

    func test_init_withEmptyJSON_createsEmptyLoader() throws {
        let data = "{}".data(using: .utf8)!
        let loader = try RestaurantLoader(data: data)
        XCTAssertTrue(loader.allCategories.isEmpty)
    }

    // MARK: - Category Tests

    func test_allCategories_returnsAllCategoryNames() throws {
        let json = validRestaurantJSON()
        let data = json.data(using: .utf8)!
        let loader = try RestaurantLoader(data: data)

        let categories = loader.allCategories

        XCTAssertEqual(categories.count, 2)
        XCTAssertTrue(categories.contains("Rooftop"))
        XCTAssertTrue(categories.contains("Cafe"))
    }

    func test_allCategories_returnsSortedList() throws {
        let json = validRestaurantJSON()
        let data = json.data(using: .utf8)!
        let loader = try RestaurantLoader(data: data)

        let categories = loader.allCategories

        XCTAssertEqual(categories, categories.sorted())
    }

    // MARK: - Restaurant Retrieval Tests

    func test_restaurants_forValidCategory_returnsRestaurants() throws {
        let json = validRestaurantJSON()
        let data = json.data(using: .utf8)!
        let loader = try RestaurantLoader(data: data)

        let restaurants = loader.restaurants(for: "Rooftop")

        XCTAssertEqual(restaurants.count, 3)
        XCTAssertEqual(restaurants[0].name, "RH Rooftop SF")
        XCTAssertEqual(restaurants[1].name, "Charmaine's")
    }

    func test_restaurants_forInvalidCategory_returnsEmptyArray() throws {
        let json = validRestaurantJSON()
        let data = json.data(using: .utf8)!
        let loader = try RestaurantLoader(data: data)

        let restaurants = loader.restaurants(for: "NonExistent")

        XCTAssertTrue(restaurants.isEmpty)
    }

    func test_restaurants_containsCorrectData() throws {
        let json = validRestaurantJSON()
        let data = json.data(using: .utf8)!
        let loader = try RestaurantLoader(data: data)

        let restaurants = loader.restaurants(for: "Rooftop")
        let restaurant = restaurants.first!

        XCTAssertEqual(restaurant.name, "RH Rooftop SF")
        XCTAssertEqual(restaurant.priceLevel, 3)
        XCTAssertEqual(restaurant.averageCost, 70)
        XCTAssertEqual(restaurant.description, "Chandeliers, glass atrium, views.")
        XCTAssertEqual(restaurant.parking, "Valet / Public Lot.")
        XCTAssertEqual(restaurant.mapQuery, "RH Rooftop Restaurant")
    }

    // MARK: - Distance Filtering Tests

    func test_restaurants_containsCoordinates() throws {
        let json = validRestaurantJSON()
        let data = json.data(using: .utf8)!
        let loader = try RestaurantLoader(data: data)

        let restaurants = loader.restaurants(for: "Rooftop")
        let restaurant = restaurants.first!

        XCTAssertEqual(restaurant.lat, 37.7877, accuracy: 0.0001)
        XCTAssertEqual(restaurant.lng, -122.4085, accuracy: 0.0001)
    }

    func test_restaurantsFiltered_byDistance_returnsOnlyNearby() throws {
        let json = validRestaurantJSON()
        let data = json.data(using: .utf8)!
        let loader = try RestaurantLoader(data: data)
        let sfCenter = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)

        let restaurants = loader.restaurantsFiltered(
            for: "Rooftop",
            near: sfCenter,
            radiusMiles: 10
        )

        // Only SF restaurants within 10 miles
        XCTAssertEqual(restaurants.count, 2)
    }

    func test_restaurantsFiltered_withSmallRadius_excludesDistantRestaurants() throws {
        let json = validRestaurantJSON()
        let data = json.data(using: .utf8)!
        let loader = try RestaurantLoader(data: data)
        let sfCenter = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)

        let restaurants = loader.restaurantsFiltered(
            for: "Rooftop",
            near: sfCenter,
            radiusMiles: 1
        )

        XCTAssertLessThanOrEqual(restaurants.count, 2)
    }

    func test_restaurantsFiltered_returnsMaxThree() throws {
        let json = jsonWithManyRestaurants()
        let data = json.data(using: .utf8)!
        let loader = try RestaurantLoader(data: data)
        let sfCenter = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)

        let restaurants = loader.restaurantsFiltered(
            for: "TestCategory",
            near: sfCenter,
            radiusMiles: 50
        )

        XCTAssertLessThanOrEqual(restaurants.count, 3)
    }

    func test_restaurantsFiltered_withNoLocation_returnsEmpty() throws {
        let json = validRestaurantJSON()
        let data = json.data(using: .utf8)!
        let loader = try RestaurantLoader(data: data)

        let restaurants = loader.restaurantsFiltered(
            for: "Rooftop",
            near: nil,
            radiusMiles: 10
        )

        XCTAssertTrue(restaurants.isEmpty)
    }

    // MARK: - Price Level Filtering Tests

    func test_restaurantsFiltered_byPriceLevels_returnsOnlyMatchingPrices() throws {
        let json = jsonWithMixedPriceLevels()
        let data = json.data(using: .utf8)!
        let loader = try RestaurantLoader(data: data)
        let sfCenter = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)

        let restaurants = loader.restaurantsFiltered(
            for: "MixedCategory",
            near: sfCenter,
            radiusMiles: 50,
            allowedPriceLevels: [3, 4]
        )

        XCTAssertTrue(restaurants.allSatisfy { $0.priceLevel >= 3 })
    }

    func test_restaurantsFiltered_byLowPriceLevels_excludesExpensive() throws {
        let json = jsonWithMixedPriceLevels()
        let data = json.data(using: .utf8)!
        let loader = try RestaurantLoader(data: data)
        let sfCenter = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)

        let restaurants = loader.restaurantsFiltered(
            for: "MixedCategory",
            near: sfCenter,
            radiusMiles: 50,
            allowedPriceLevels: [1, 2]
        )

        XCTAssertTrue(restaurants.allSatisfy { $0.priceLevel <= 2 })
    }

    func test_restaurantsFiltered_withAllPriceLevels_includesAll() throws {
        let json = jsonWithMixedPriceLevels()
        let data = json.data(using: .utf8)!
        let loader = try RestaurantLoader(data: data)
        let sfCenter = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)

        let restaurants = loader.restaurantsFiltered(
            for: "MixedCategory",
            near: sfCenter,
            radiusMiles: 50,
            allowedPriceLevels: [1, 2, 3, 4]
        )

        XCTAssertEqual(restaurants.count, 3)
    }

    func test_restaurantsFiltered_withNilPriceLevels_includesAll() throws {
        let json = jsonWithMixedPriceLevels()
        let data = json.data(using: .utf8)!
        let loader = try RestaurantLoader(data: data)
        let sfCenter = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)

        let restaurants = loader.restaurantsFiltered(
            for: "MixedCategory",
            near: sfCenter,
            radiusMiles: 50,
            allowedPriceLevels: nil
        )

        XCTAssertEqual(restaurants.count, 3)
    }

    func test_restaurantsFiltered_withEmptyPriceLevels_returnsEmpty() throws {
        let json = jsonWithMixedPriceLevels()
        let data = json.data(using: .utf8)!
        let loader = try RestaurantLoader(data: data)
        let sfCenter = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)

        let restaurants = loader.restaurantsFiltered(
            for: "MixedCategory",
            near: sfCenter,
            radiusMiles: 50,
            allowedPriceLevels: []
        )

        XCTAssertTrue(restaurants.isEmpty)
    }

    // MARK: - Helpers

    private func validRestaurantJSON() -> String {
        """
        {
          "Rooftop": [
            {
              "name": "RH Rooftop SF",
              "lat": 37.7877,
              "lng": -122.4085,
              "locs": ["SF"],
              "query": "RH Rooftop Restaurant",
              "price": 3,
              "aesthetic": true,
              "avgCost": 70,
              "note": "Chandeliers, glass atrium, views.",
              "parking": "Valet / Public Lot."
            },
            {
              "name": "Charmaine's",
              "lat": 37.7873,
              "lng": -122.4101,
              "locs": ["SF"],
              "query": "Charmaine's Rooftop",
              "price": 3,
              "aesthetic": true,
              "avgCost": 45,
              "note": "Fire pits and chic decor.",
              "parking": "Valet."
            },
            {
              "name": "RH Rooftop NYC",
              "lat": 40.7409,
              "lng": -73.9897,
              "locs": ["NYC"],
              "query": "RH Rooftop Restaurant NYC",
              "price": 3,
              "aesthetic": true,
              "avgCost": 70,
              "note": "NYC location.",
              "parking": "Street."
            }
          ],
          "Cafe": [
            {
              "name": "Sightglass Coffee",
              "lat": 37.7749,
              "lng": -122.4194,
              "locs": ["SF"],
              "query": "Sightglass Coffee San Francisco",
              "price": 2,
              "aesthetic": true,
              "avgCost": 15,
              "note": "Industrial-chic coffee roastery.",
              "parking": "Street parking."
            }
          ]
        }
        """
    }

    private func jsonWithManyRestaurants() -> String {
        """
        {
          "TestCategory": [
            { "name": "Restaurant 1", "lat": 37.78, "lng": -122.41, "locs": ["SF"], "query": "R1", "price": 2, "aesthetic": true, "avgCost": 30, "note": "Note 1", "parking": "Street" },
            { "name": "Restaurant 2", "lat": 37.79, "lng": -122.42, "locs": ["SF"], "query": "R2", "price": 2, "aesthetic": true, "avgCost": 30, "note": "Note 2", "parking": "Street" },
            { "name": "Restaurant 3", "lat": 37.77, "lng": -122.40, "locs": ["SF"], "query": "R3", "price": 2, "aesthetic": true, "avgCost": 30, "note": "Note 3", "parking": "Street" },
            { "name": "Restaurant 4", "lat": 37.76, "lng": -122.43, "locs": ["SF"], "query": "R4", "price": 2, "aesthetic": true, "avgCost": 30, "note": "Note 4", "parking": "Street" },
            { "name": "Restaurant 5", "lat": 37.75, "lng": -122.44, "locs": ["SF"], "query": "R5", "price": 2, "aesthetic": true, "avgCost": 30, "note": "Note 5", "parking": "Street" }
          ]
        }
        """
    }

    private func jsonWithMixedPriceLevels() -> String {
        """
        {
          "MixedCategory": [
            { "name": "Budget Place", "lat": 37.78, "lng": -122.41, "locs": ["SF"], "query": "B1", "price": 1, "aesthetic": false, "avgCost": 10, "note": "Cheap", "parking": "Street" },
            { "name": "Mid Range", "lat": 37.79, "lng": -122.42, "locs": ["SF"], "query": "M1", "price": 2, "aesthetic": true, "avgCost": 30, "note": "Moderate", "parking": "Street" },
            { "name": "Upscale Spot", "lat": 37.77, "lng": -122.40, "locs": ["SF"], "query": "U1", "price": 3, "aesthetic": true, "avgCost": 80, "note": "Nice", "parking": "Valet" },
            { "name": "Luxury Dining", "lat": 37.76, "lng": -122.43, "locs": ["SF"], "query": "L1", "price": 4, "aesthetic": true, "avgCost": 200, "note": "Fancy", "parking": "Valet" }
          ]
        }
        """
    }
}
