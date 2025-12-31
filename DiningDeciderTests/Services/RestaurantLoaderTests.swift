import XCTest
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
        XCTAssertEqual(restaurants.count, 2)
        XCTAssertEqual(restaurants[0].name, "RH Rooftop")
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
        XCTAssertEqual(restaurant.name, "RH Rooftop")
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

    // MARK: - Helpers

    private func validRestaurantJSON() -> String {
        """
        {
          "Rooftop": [
            {
              "name": "RH Rooftop",
              "locs": ["SF", "NYC"],
              "query": "RH Rooftop Restaurant",
              "price": 3,
              "aesthetic": true,
              "avgCost": 70,
              "note": "Chandeliers, glass atrium, views.",
              "parking": "Valet / Public Lot."
            },
            {
              "name": "Charmaine's",
              "locs": ["SF"],
              "query": "Charmaine's Rooftop",
              "price": 3,
              "aesthetic": true,
              "avgCost": 45,
              "note": "Fire pits and chic decor.",
              "parking": "Valet."
            }
          ],
          "Cafe": [
            {
              "name": "Sightglass Coffee",
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
}
