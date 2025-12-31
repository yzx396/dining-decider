import XCTest
import CoreLocation
@testable import DiningDecider

final class RestaurantLoaderTests: XCTestCase {

    // MARK: - Loading Tests

    func test_init_withValidJSON_loadsSuccessfully() throws {
        // Given
        let json = validRestaurantJSON()
        let data = json.data(using: .utf8)!

        // When
        let loader = try RestaurantLoader(data: data)

        // Then
        XCTAssertNotNil(loader)
    }

    func test_init_withInvalidJSON_throws() {
        // Given
        let invalidJSON = "{ invalid json }"
        let data = invalidJSON.data(using: .utf8)!

        // When/Then
        XCTAssertThrowsError(try RestaurantLoader(data: data))
    }

    // MARK: - Category Tests

    func test_allCategories_returnsAllCategoryNames() throws {
        // Given
        let json = validRestaurantJSON()
        let data = json.data(using: .utf8)!
        let loader = try RestaurantLoader(data: data)

        // When
        let categories = loader.allCategories

        // Then
        XCTAssertEqual(categories.count, 2)
        XCTAssertTrue(categories.contains("Rooftop"))
        XCTAssertTrue(categories.contains("Cafe"))
    }

    func test_allCategories_returnsSortedList() throws {
        // Given
        let json = validRestaurantJSON()
        let data = json.data(using: .utf8)!
        let loader = try RestaurantLoader(data: data)

        // When
        let categories = loader.allCategories

        // Then
        XCTAssertEqual(categories, categories.sorted())
    }

    // MARK: - Restaurant Retrieval Tests

    func test_restaurants_forValidCategory_returnsRestaurants() throws {
        // Given
        let json = validRestaurantJSON()
        let data = json.data(using: .utf8)!
        let loader = try RestaurantLoader(data: data)

        // When
        let restaurants = loader.restaurants(for: "Rooftop")

        // Then
        XCTAssertEqual(restaurants.count, 3)
        XCTAssertEqual(restaurants[0].name, "RH Rooftop SF")
        XCTAssertEqual(restaurants[1].name, "Charmaine's")
    }

    func test_restaurants_forInvalidCategory_returnsEmptyArray() throws {
        // Given
        let json = validRestaurantJSON()
        let data = json.data(using: .utf8)!
        let loader = try RestaurantLoader(data: data)

        // When
        let restaurants = loader.restaurants(for: "NonExistent")

        // Then
        XCTAssertTrue(restaurants.isEmpty)
    }

    func test_restaurants_containsCorrectData() throws {
        // Given
        let json = validRestaurantJSON()
        let data = json.data(using: .utf8)!
        let loader = try RestaurantLoader(data: data)

        // When
        let restaurants = loader.restaurants(for: "Rooftop")
        let restaurant = restaurants.first!

        // Then
        XCTAssertEqual(restaurant.name, "RH Rooftop SF")
        XCTAssertEqual(restaurant.priceLevel, 3)
        XCTAssertEqual(restaurant.averageCost, 70)
        XCTAssertEqual(restaurant.description, "Chandeliers, glass atrium, views.")
        XCTAssertEqual(restaurant.parking, "Valet / Public Lot.")
        XCTAssertEqual(restaurant.mapQuery, "RH Rooftop Restaurant")
    }

    // MARK: - Protocol Conformance Tests

    func test_loaderConformsToRestaurantLoadingProtocol() throws {
        // Given
        let json = validRestaurantJSON()
        let data = json.data(using: .utf8)!

        // When
        let loader: RestaurantLoading = try RestaurantLoader(data: data)

        // Then
        XCTAssertNotNil(loader)
    }

    // MARK: - Bundle Loading Tests

    func test_initFromBundle_loadsRealData() throws {
        // When
        let loader = try RestaurantLoader()

        // Then
        XCTAssertFalse(loader.allCategories.isEmpty)
        XCTAssertTrue(loader.allCategories.contains("Rooftop"))
    }

    // MARK: - Distance Filtering Tests

    func test_restaurants_containsCoordinates() throws {
        // Given
        let json = validRestaurantJSON()
        let data = json.data(using: .utf8)!
        let loader = try RestaurantLoader(data: data)

        // When
        let restaurants = loader.restaurants(for: "Rooftop")
        let restaurant = restaurants.first!

        // Then
        XCTAssertEqual(restaurant.lat, 37.7877, accuracy: 0.0001)
        XCTAssertEqual(restaurant.lng, -122.4085, accuracy: 0.0001)
    }

    func test_restaurantsFiltered_byDistance_returnsOnlyNearby() throws {
        // Given
        let json = validRestaurantJSON()
        let data = json.data(using: .utf8)!
        let loader = try RestaurantLoader(data: data)
        let sfCenter = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)

        // When: Filter with 10 mile radius - should get SF restaurants only
        let restaurants = loader.restaurantsFiltered(
            for: "Rooftop",
            near: sfCenter,
            radiusMiles: 10
        )

        // Then: Only SF restaurants within 10 miles
        XCTAssertEqual(restaurants.count, 2) // RH Rooftop SF and Charmaine's
        XCTAssertTrue(restaurants.allSatisfy { $0.name.contains("SF") || $0.name == "Charmaine's" || $0.name == "RH Rooftop SF" })
    }

    func test_restaurantsFiltered_withSmallRadius_excludesDistantRestaurants() throws {
        // Given
        let json = validRestaurantJSON()
        let data = json.data(using: .utf8)!
        let loader = try RestaurantLoader(data: data)
        let sfCenter = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)

        // When: Filter with 1 mile radius - very restrictive
        let restaurants = loader.restaurantsFiltered(
            for: "Rooftop",
            near: sfCenter,
            radiusMiles: 1
        )

        // Then: Should get restaurants within 1 mile
        XCTAssertLessThanOrEqual(restaurants.count, 2)
    }

    func test_restaurantsFiltered_returnsMaxThree() throws {
        // Given
        let json = jsonWithManyRestaurants()
        let data = json.data(using: .utf8)!
        let loader = try RestaurantLoader(data: data)
        let sfCenter = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)

        // When
        let restaurants = loader.restaurantsFiltered(
            for: "TestCategory",
            near: sfCenter,
            radiusMiles: 50
        )

        // Then: Should return at most 3
        XCTAssertLessThanOrEqual(restaurants.count, 3)
    }

    func test_restaurantsFiltered_withNoLocation_returnsEmpty() throws {
        // Given
        let json = validRestaurantJSON()
        let data = json.data(using: .utf8)!
        let loader = try RestaurantLoader(data: data)

        // When: No location provided (nil center)
        let restaurants = loader.restaurantsFiltered(
            for: "Rooftop",
            near: nil,
            radiusMiles: 10
        )

        // Then: Returns empty when no location
        XCTAssertTrue(restaurants.isEmpty)
    }

    // MARK: - Price Level Filtering Tests

    func test_restaurantsFiltered_byPriceLevels_returnsOnlyMatchingPrices() throws {
        // Given
        let json = jsonWithMixedPriceLevels()
        let data = json.data(using: .utf8)!
        let loader = try RestaurantLoader(data: data)
        let sfCenter = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)

        // When: Filter for only high price levels (3, 4) - Splurge mode
        let restaurants = loader.restaurantsFiltered(
            for: "MixedCategory",
            near: sfCenter,
            radiusMiles: 50,
            allowedPriceLevels: [3, 4]
        )

        // Then: Should only return price level 3 and 4 restaurants
        XCTAssertTrue(restaurants.allSatisfy { $0.priceLevel >= 3 })
    }

    func test_restaurantsFiltered_byLowPriceLevels_excludesExpensive() throws {
        // Given
        let json = jsonWithMixedPriceLevels()
        let data = json.data(using: .utf8)!
        let loader = try RestaurantLoader(data: data)
        let sfCenter = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)

        // When: Filter for only low price levels (1, 2) - Standard mode
        let restaurants = loader.restaurantsFiltered(
            for: "MixedCategory",
            near: sfCenter,
            radiusMiles: 50,
            allowedPriceLevels: [1, 2]
        )

        // Then: Should only return price level 1 and 2 restaurants
        XCTAssertTrue(restaurants.allSatisfy { $0.priceLevel <= 2 })
    }

    func test_restaurantsFiltered_withAllPriceLevels_includesAll() throws {
        // Given
        let json = jsonWithMixedPriceLevels()
        let data = json.data(using: .utf8)!
        let loader = try RestaurantLoader(data: data)
        let sfCenter = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)

        // When: Filter for all price levels (1-4) - Aesthetic mode
        let restaurants = loader.restaurantsFiltered(
            for: "MixedCategory",
            near: sfCenter,
            radiusMiles: 50,
            allowedPriceLevels: [1, 2, 3, 4]
        )

        // Then: Should return restaurants of all price levels (up to 3)
        XCTAssertEqual(restaurants.count, 3)
    }

    func test_restaurantsFiltered_withNilPriceLevels_includesAll() throws {
        // Given
        let json = jsonWithMixedPriceLevels()
        let data = json.data(using: .utf8)!
        let loader = try RestaurantLoader(data: data)
        let sfCenter = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)

        // When: No price filter (nil) - should include all
        let restaurants = loader.restaurantsFiltered(
            for: "MixedCategory",
            near: sfCenter,
            radiusMiles: 50,
            allowedPriceLevels: nil
        )

        // Then: Should return restaurants of all price levels (up to 3)
        XCTAssertEqual(restaurants.count, 3)
    }

    func test_restaurantsFiltered_withEmptyPriceLevels_returnsEmpty() throws {
        // Given
        let json = jsonWithMixedPriceLevels()
        let data = json.data(using: .utf8)!
        let loader = try RestaurantLoader(data: data)
        let sfCenter = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)

        // When: Empty price levels array
        let restaurants = loader.restaurantsFiltered(
            for: "MixedCategory",
            near: sfCenter,
            radiusMiles: 50,
            allowedPriceLevels: []
        )

        // Then: Should return no restaurants
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
