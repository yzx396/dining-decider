import SwiftUI
import CoreLocation
import DiningDeciderCore

/// Holds the result of a wheel spin for sheet presentation
struct SpinResult: Identifiable {
    let id = UUID()
    let category: String
    let restaurants: [Restaurant]
}

struct ContentView: View {
    @State private var rotation: Double = 0
    @State private var spinResult: SpinResult?  // nil until spin completes
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

    // Loading state for API calls
    @State private var isLoading = false

    // Dynamic sectors based on selected vibe
    private var sectors: [WheelSector] {
        selectedVibe.sectors
    }
    private let restaurantLoader: RestaurantLoading
    private let geocodingService: GeocodingProviding
    private let apiService: RestaurantAPIProviding?

    init() {
        // Initialize restaurant loader, fallback to empty if file not found
        if let loader = try? RestaurantLoader() {
            self.restaurantLoader = loader
        } else {
            // Fallback for testing/development
            self.restaurantLoader = MockRestaurantLoader()
        }

        self.geocodingService = GeocodingService()

        // Initialize API service if configured
        if APIConfig.isConfigured {
            self.apiService = APIService()
        } else {
            self.apiService = nil
        }
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

            ScrollViewReader { proxy in
                ScrollView {
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
                        .id("controls")

                        Spacer()
                            .frame(height: 40)

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
                            .frame(height: 40)

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
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: locationMode) { _, newMode in
                    // Scroll to top when switching to manual mode to ensure text field is visible
                    if newMode == .manual {
                        withAnimation {
                            proxy.scrollTo("controls", anchor: .top)
                        }
                    }
                }
            }
        }
        .sheet(item: $spinResult) { result in
            ResultsView(
                category: result.category,
                restaurants: result.restaurants,
                partySize: partySize,
                onSpinAgain: {
                    spinResult = nil
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
        let category = sectors[sectorIndex].label

        // Try API first if configured and we have a location
        if let api = apiService, hasValidLocation, let location = activeLocation {
            isLoading = true
            Task {
                do {
                    let restaurants = try await api.fetchRestaurants(
                        category: category,
                        location: location,
                        radiusMiles: searchRadius.miles,
                        priceLevels: selectedVibe.allowedPriceLevels
                    )
                    await MainActor.run {
                        isLoading = false
                        spinResult = SpinResult(category: category, restaurants: restaurants)
                    }
                } catch {
                    // Fallback to local data on API error
                    print("API error, falling back to local: \(error)")
                    await MainActor.run {
                        isLoading = false
                        let localRestaurants = fetchLocalRestaurants(category: category)
                        spinResult = SpinResult(category: category, restaurants: localRestaurants)
                    }
                }
            }
        } else {
            // Use local data
            let restaurants = fetchLocalRestaurants(category: category)
            spinResult = SpinResult(category: category, restaurants: restaurants)
        }
    }

    private func fetchLocalRestaurants(category: String) -> [Restaurant] {
        if hasValidLocation, let location = activeLocation {
            return restaurantLoader.restaurantsFiltered(
                for: category,
                near: location,
                radiusMiles: searchRadius.miles,
                allowedPriceLevels: selectedVibe.allowedPriceLevels
            )
        } else {
            // Fallback: filter by price level only (no location)
            let allRestaurants = restaurantLoader.restaurants(for: category)
            let filteredByPrice = allRestaurants.filter { restaurant in
                selectedVibe.allowsPriceLevel(restaurant.priceLevel)
            }
            return filteredByPrice.shuffled().prefix(3).map { $0 }
        }
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
