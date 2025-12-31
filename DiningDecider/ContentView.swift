import SwiftUI
import CoreLocation

struct ContentView: View {
    @State private var rotation: Double = 0
    @State private var showResults = false
    @State private var landedCategory = "Rooftop"
    @State private var landedRestaurants: [Restaurant] = []
    @State private var locationManager = LocationManager()
    @State private var searchRadius: Double = DistanceCalculator.defaultRadiusMiles

    private let sectors = WheelSector.aestheticSectors
    private let restaurantLoader: RestaurantLoading

    init() {
        // Initialize restaurant loader, fallback to empty if file not found
        if let loader = try? RestaurantLoader() {
            self.restaurantLoader = loader
        } else {
            // Fallback for testing/development
            self.restaurantLoader = MockRestaurantLoader()
        }
    }

    var body: some View {
        ZStack {
            Color.theme.background
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Controls Card
                ControlsCard(
                    isLocationAuthorized: locationManager.isAuthorized,
                    onRequestLocation: {
                        locationManager.requestPermission()
                    }
                )
                .padding(.horizontal, 20)
                .padding(.top, 16)

                Spacer()

                // Wheel
                SpinningWheelView(
                    sectors: sectors,
                    rotation: $rotation
                ) { sectorIndex in
                    handleSpinComplete(sectorIndex: sectorIndex)
                }
                .frame(width: 300, height: 300)
                .accessibilityLabel("Spinning wheel")
                .accessibilityHint("Swipe to spin and get a restaurant recommendation")
                .accessibilityAddTraits(.allowsDirectInteraction)

                // Hint text
                Text("Swipe wheel to spin")
                    .font(.subheadline)
                    .foregroundColor(Color.theme.label)

                Spacer()

                // Footer
                HStack(spacing: 8) {
                    Image(systemName: "fork.knife")
                        .foregroundColor(Color.theme.label)
                    Text("Dining Decider")
                        .font(.footnote)
                        .foregroundColor(Color.theme.label)
                }
                .padding(.bottom, 24)
            }
        }
        .sheet(isPresented: $showResults) {
            ResultsView(
                category: landedCategory,
                restaurants: landedRestaurants,
                onSpinAgain: {
                    showResults = false
                }
            )
            .presentationDetents([.large])
        }
    }

    private func handleSpinComplete(sectorIndex: Int) {
        landedCategory = sectors[sectorIndex].label

        // Get restaurants filtered by location if available
        if locationManager.isAuthorized, let location = locationManager.currentLocation {
            landedRestaurants = restaurantLoader.restaurantsFiltered(
                for: landedCategory,
                near: location,
                radiusMiles: searchRadius
            )
        } else {
            // Fallback: show all restaurants (shuffled, up to 3) when no location
            let allRestaurants = restaurantLoader.restaurants(for: landedCategory)
            landedRestaurants = allRestaurants.shuffled().prefix(3).map { $0 }
        }

        showResults = true
    }
}

// MARK: - Mock Loader for Development/Testing

private final class MockRestaurantLoader: RestaurantLoading {
    var allCategories: [String] {
        ["Rooftop", "Cafe"]
    }

    func restaurants(for category: String) -> [Restaurant] {
        Restaurant.skeletonData
    }

    func restaurantsFiltered(
        for category: String,
        near location: CLLocationCoordinate2D?,
        radiusMiles: Double
    ) -> [Restaurant] {
        guard location != nil else { return [] }
        return Restaurant.skeletonData
    }
}

#Preview {
    ContentView()
}
