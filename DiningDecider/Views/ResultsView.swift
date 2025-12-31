import SwiftUI

struct ResultsView: View {
    let category: String
    let restaurants: [Restaurant]
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

                    // Restaurant cards
                    VStack(spacing: 16) {
                        ForEach(restaurants) { restaurant in
                            RestaurantCard(restaurant: restaurant)
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

struct RestaurantCard: View {
    let restaurant: Restaurant

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Name
            Text(restaurant.name)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(Color.theme.textPrimary)

            // Description
            Text("\"\(restaurant.description)\"")
                .font(.subheadline)
                .italic()
                .foregroundColor(Color.theme.label)
                .lineLimit(2)

            // Price
            Text("$\(restaurant.averageCost)/person")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Color.theme.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color.theme.cardBackground)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }
}

#Preview {
    ResultsView(
        category: "Rooftop",
        restaurants: Restaurant.skeletonData,
        onSpinAgain: {}
    )
}
