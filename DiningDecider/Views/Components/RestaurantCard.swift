import SwiftUI

/// A card displaying restaurant details with a map button.
///
/// Shows the restaurant name, price level tag, description, parking info,
/// pricing information, and a button to open the location in Apple Maps.
struct RestaurantCard: View {
    let restaurant: Restaurant
    let partySize: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header: Name + Map button
            headerRow

            // Price level tag (💎 Luxury, ✨ Premium, etc.)
            priceLevelTagRow

            // Description in quotes
            descriptionRow

            // Parking info (shown only if available)
            if restaurant.hasParkingInfo {
                parkingRow
            }

            // Price with per-person and total
            priceDisplay
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color.theme.cardBackground)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityText)
        .accessibilityHint("Double tap Map button to open in Apple Maps")
    }

    // MARK: - Header Row

    private var headerRow: some View {
        HStack(alignment: .top) {
            // Restaurant name
            Text(restaurant.name)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(Color.theme.textPrimary)
                .lineLimit(2)

            Spacer()

            // Map button
            mapButton
        }
    }

    // MARK: - Map Button

    private var mapButton: some View {
        Button(action: openInMaps) {
            Image(systemName: "map.fill")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(Color.theme.primaryButton)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .accessibilityLabel("Open \(restaurant.name) in Maps")
        .accessibilityAddTraits(.isButton)
    }

    // MARK: - Price Level Tag Row

    private var priceLevelTagRow: some View {
        Text(restaurant.priceLevelTag.displayText)
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(Color.theme.label)
    }

    // MARK: - Description Row

    private var descriptionRow: some View {
        Text("\"\(restaurant.description)\"")
            .font(.subheadline)
            .italic()
            .foregroundColor(Color.theme.label)
            .lineLimit(2)
    }

    // MARK: - Parking Row

    private var parkingRow: some View {
        HStack(spacing: 6) {
            Text("🚗")
                .font(.subheadline)
            Text(restaurant.parking)
                .font(.subheadline)
                .foregroundColor(Color.theme.label)
        }
    }

    // MARK: - Price Display

    private var priceDisplay: some View {
        HStack(spacing: 4) {
            Text("$\(restaurant.averageCost)/person")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Color.theme.textPrimary)

            Text("·")
                .font(.subheadline)
                .foregroundColor(Color.theme.label)

            Text("~$\(restaurant.totalCost(for: partySize)) total")
                .font(.subheadline)
                .foregroundColor(Color.theme.label)
        }
    }

    // MARK: - Actions

    private func openInMaps() {
        MapsHelper.openMaps(for: restaurant)
    }

    // MARK: - Accessibility

    private var accessibilityText: String {
        let personText = partySize == 1 ? "person" : "people"
        let priceLevelText = "\(restaurant.priceLevelTag.label) restaurant"
        let parkingText = restaurant.hasParkingInfo ? " Parking: \(restaurant.parking)." : ""

        return "\(restaurant.name). \(priceLevelText). \(restaurant.description).\(parkingText) $\(restaurant.averageCost) per person, approximately $\(restaurant.totalCost(for: partySize)) total for \(partySize) \(personText)"
    }
}

// MARK: - Previews

#Preview("Standard Card") {
    RestaurantCard(
        restaurant: Restaurant(
            id: UUID(),
            name: "RH Rooftop",
            lat: 37.7855,
            lng: -122.4064,
            priceLevel: 3,
            averageCost: 65,
            description: "Stunning views with upscale American fare",
            parking: "Valet available",
            mapQuery: "RH Rooftop San Francisco"
        ),
        partySize: 2
    )
    .padding()
    .background(Color.theme.background)
}

#Preview("Long Name") {
    RestaurantCard(
        restaurant: Restaurant(
            id: UUID(),
            name: "The Very Long Restaurant Name That Might Be Truncated",
            lat: 37.7855,
            lng: -122.4064,
            priceLevel: 2,
            averageCost: 35,
            description: "A cozy spot with great food and even better atmosphere for dining",
            parking: "Street parking",
            mapQuery: "Long Name Restaurant"
        ),
        partySize: 4
    )
    .padding()
    .background(Color.theme.background)
}

#Preview("Party of 1") {
    RestaurantCard(
        restaurant: Restaurant(
            id: UUID(),
            name: "Solo Dining Spot",
            lat: 37.7855,
            lng: -122.4064,
            priceLevel: 1,
            averageCost: 15,
            description: "Quick and tasty",
            parking: "Street",
            mapQuery: "Solo Spot"
        ),
        partySize: 1
    )
    .padding()
    .background(Color.theme.background)
}

#Preview("Luxury - No Parking") {
    RestaurantCard(
        restaurant: Restaurant(
            id: UUID(),
            name: "Gary Danko",
            lat: 37.8059,
            lng: -122.4209,
            priceLevel: 4,
            averageCost: 170,
            description: "Classic luxury dining with impeccable service",
            parking: "",
            mapQuery: "Gary Danko San Francisco"
        ),
        partySize: 2
    )
    .padding()
    .background(Color.theme.background)
}
