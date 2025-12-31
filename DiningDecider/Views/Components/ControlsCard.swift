import SwiftUI
import CoreLocation

/// Card containing location display and controls
struct ControlsCard: View {
    let isLocationAuthorized: Bool
    let onRequestLocation: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            locationSection
        }
        .padding(20)
        .background(Color.theme.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    // MARK: - Location Section

    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("LOCATION")

            if isLocationAuthorized {
                currentLocationPill
            } else {
                requestLocationButton
            }
        }
    }

    private var currentLocationPill: some View {
        HStack(spacing: 6) {
            Image(systemName: "location.fill")
                .font(.caption)
                .foregroundColor(Color.theme.primaryButton)

            Text("Current Location")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Color.theme.textPrimary)

            Spacer()

            Button("Change") {
                // Future: Switch to manual entry mode
            }
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(Color.theme.primaryButton)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.theme.background)
        .cornerRadius(8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Using current location")
        .accessibilityHint("Tap change to enter a different location")
    }

    private var requestLocationButton: some View {
        Button(action: onRequestLocation) {
            HStack(spacing: 8) {
                Image(systemName: "location")
                    .font(.subheadline)

                Text("Use Current Location")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(Color.theme.label)
            }
            .foregroundColor(Color.theme.primaryButton)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.theme.background)
            .cornerRadius(8)
        }
        .accessibilityLabel("Use current location")
        .accessibilityHint("Tap to enable location services")
    }

    // MARK: - Helpers

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.caption)
            .fontWeight(.medium)
            .tracking(0.5)
            .foregroundColor(Color.theme.label)
    }
}

// MARK: - Previews

#Preview("Location Authorized") {
    ZStack {
        Color.theme.background.ignoresSafeArea()
        ControlsCard(
            isLocationAuthorized: true,
            onRequestLocation: {}
        )
        .padding()
    }
}

#Preview("Location Not Authorized") {
    ZStack {
        Color.theme.background.ignoresSafeArea()
        ControlsCard(
            isLocationAuthorized: false,
            onRequestLocation: {}
        )
        .padding()
    }
}
