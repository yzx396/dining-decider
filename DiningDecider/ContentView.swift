import SwiftUI
import CoreLocation
import DiningDeciderCore

struct ContentView: View {
    @State private var rotation: Double = 0
    @State private var showResults = false
    @State private var landedCategory = "Rooftop"
    @State private var landedRestaurants: [Restaurant] = []
    @State private var locationManager = LocationManager()
    @State private var searchRadius: SearchRadius = .defaultRadius

    // Vibe mode state
    @State private var selectedVibe: VibeMode = .defaultVibe

    // Manual location state
    @State private var locationMode: LocationMode = .currentLocation
    @State private var manualSearchText = ""
    @State private var manualLocation: CLLocationCoordinate2D?
    @State private var manualLocationName: String?

    // Party size state
    @State private var partySize: Int = PartySize.defaultSize

    // Dynamic sectors based on selected vibe
    private var sectors: [WheelSector] {
        selectedVibe.sectors
    }
    private let restaurantLoader: RestaurantLoading
    private let geocodingService: GeocodingProviding

    init() {
        // Initialize restaurant loader, fallback to empty if file not found
        if let loader = try? RestaurantLoader() {
            self.restaurantLoader = loader
        } else {
            // Fallback for testing/development
            self.restaurantLoader = MockRestaurantLoader()
        }

        self.geocodingService = GeocodingService()
    }

    // Computed property for the active location to use for filtering
    private var activeLocation: CLLocationCoordinate2D? {
        switch locationMode {
        case .currentLocation:
            return locationManager.currentLocation
        case .manual:
            return manualLocation
        }
    }

    // Whether we have a valid location to filter by
    private var hasValidLocation: Bool {
        switch locationMode {
        case .currentLocation:
            return locationManager.isAuthorized && locationManager.currentLocation != nil
        case .manual:
            return manualLocation != nil
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
                    geocodingService: geocodingService,
                    onRequestLocation: {
                        locationManager.requestPermission()
                    },
                    locationMode: $locationMode,
                    manualSearchText: $manualSearchText,
                    manualLocation: $manualLocation,
                    manualLocationName: $manualLocationName,
                    searchRadius: $searchRadius,
                    selectedVibe: $selectedVibe,
                    partySize: $partySize
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
                partySize: partySize,
                onSpinAgain: {
                    showResults = false
                }
            )
            .presentationDetents([.large])
        }
        .onChange(of: locationManager.isAuthorized) { _, isAuthorized in
            // If location becomes authorized and we're not in manual mode, switch to current
            if isAuthorized && locationMode == .currentLocation {
                locationManager.startUpdatingLocation()
            }
        }
        .onChange(of: selectedVibe) { _, _ in
            // Reset wheel rotation when vibe changes so wheel looks fresh
            rotation = 0
        }
    }

    private func handleSpinComplete(sectorIndex: Int) {
        landedCategory = sectors[sectorIndex].label

        // Get restaurants filtered by location and price level
        if hasValidLocation, let location = activeLocation {
            landedRestaurants = restaurantLoader.restaurantsFiltered(
                for: landedCategory,
                near: location,
                radiusMiles: searchRadius.miles,
                allowedPriceLevels: selectedVibe.allowedPriceLevels
            )
        } else {
            // Fallback: filter by price level only (no location)
            let allRestaurants = restaurantLoader.restaurants(for: landedCategory)
            let filteredByPrice = allRestaurants.filter { restaurant in
                selectedVibe.allowsPriceLevel(restaurant.priceLevel)
            }
            landedRestaurants = filteredByPrice.shuffled().prefix(3).map { $0 }
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
        restaurantsFiltered(
            for: category,
            near: location,
            radiusMiles: radiusMiles,
            allowedPriceLevels: nil
        )
    }

    func restaurantsFiltered(
        for category: String,
        near location: CLLocationCoordinate2D?,
        radiusMiles: Double,
        allowedPriceLevels: [Int]?
    ) -> [Restaurant] {
        guard location != nil else { return [] }
        if let levels = allowedPriceLevels {
            return Restaurant.skeletonData.filter { levels.contains($0.priceLevel) }
        }
        return Restaurant.skeletonData
    }
}

#Preview {
    ContentView()
}
