import SwiftUI

struct ContentView: View {
    @State private var rotation: Double = 0
    @State private var showResults = false
    @State private var landedCategory = "Rooftop"
    @State private var landedRestaurants: [Restaurant] = []

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

            VStack(spacing: 32) {
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

        // Get restaurants for the landed category
        let allRestaurants = restaurantLoader.restaurants(for: landedCategory)

        // Shuffle and take top 3
        landedRestaurants = allRestaurants.shuffled().prefix(3).map { $0 }

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
}

#Preview {
    ContentView()
}
