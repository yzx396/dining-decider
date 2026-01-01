import SwiftUI
import DiningDeciderCore

struct ResultsView: View {
    let category: String
    let restaurants: [Restaurant]
    let partySize: Int
    let onSpinAgain: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 4) {
                        Text(category)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color.theme.title)

                        Text("Recommendations")
                            .font(.subheadline)
                            .foregroundColor(Color.theme.label)
                    }
                    .padding(.top, 8)

                    // Restaurant cards with map buttons
                    VStack(spacing: 16) {
                        ForEach(restaurants) { restaurant in
                            RestaurantCard(restaurant: restaurant, partySize: partySize)
                        }
                    }
                    .padding(.horizontal)

                    // Spin Again button
                    Button(action: onSpinAgain) {
                        Text("SPIN AGAIN")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .tracking(0.5)
                            .foregroundColor(Color.theme.primaryButtonText)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.theme.primaryButton)
                            .clipShape(Capsule())
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
            }
            .background(Color.theme.background)
        }
    }
}

// Note: RestaurantCard is now in its own file at Views/Components/RestaurantCard.swift

#Preview("Party of 2") {
    ResultsView(
        category: "Rooftop",
        restaurants: Restaurant.skeletonData,
        partySize: 2,
        onSpinAgain: {}
    )
}

#Preview("Party of 6") {
    ResultsView(
        category: "Fine Dining",
        restaurants: Restaurant.skeletonData,
        partySize: 6,
        onSpinAgain: {}
    )
}

#Preview("Solo Diner") {
    ResultsView(
        category: "Cafe",
        restaurants: Restaurant.skeletonData,
        partySize: 1,
        onSpinAgain: {}
    )
}
