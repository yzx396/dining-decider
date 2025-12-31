import SwiftUI
import CoreLocation

/// The mode for location selection
enum LocationMode: Equatable {
    case currentLocation
    case manual
}

/// Card containing location display and controls
struct ControlsCard: View {
    let isLocationAuthorized: Bool
    let geocodingService: GeocodingProviding
    let onRequestLocation: () -> Void

    @Binding var locationMode: LocationMode
    @Binding var manualSearchText: String
    @Binding var manualLocation: CLLocationCoordinate2D?
    @Binding var manualLocationName: String?
    @Binding var searchRadius: SearchRadius
    @Binding var selectedVibe: VibeMode
    @Binding var partySize: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Top row: Location and Party Size
            topRow

            RadiusPicker(selectedRadius: $searchRadius)

            VibeSelector(selectedVibe: $selectedVibe)
        }
        .padding(20)
        .background(Color.theme.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    // MARK: - Top Row (Location + Party Size)

    private var topRow: some View {
        HStack(alignment: .top, spacing: 16) {
            locationSection
                .frame(maxWidth: .infinity, alignment: .leading)

            PartySizeStepper(partySize: $partySize)
        }
    }

    // MARK: - Location Section

    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("LOCATION")

            switch locationMode {
            case .currentLocation:
                if isLocationAuthorized {
                    currentLocationPill
                } else {
                    requestLocationButton
                }
            case .manual:
                manualLocationSection
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
                withAnimation(.easeInOut(duration: 0.2)) {
                    locationMode = .manual
                }
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
        VStack(spacing: 12) {
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

            // Option to enter location manually
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    locationMode = .manual
                }
            } label: {
                Text("Or enter location manually")
                    .font(.caption)
                    .foregroundColor(Color.theme.primaryButton)
            }
            .accessibilityLabel("Enter location manually")
            .accessibilityHint("Tap to type in a city or zip code")
        }
    }

    private var manualLocationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // If a location is selected, show it as a pill with change button
            if let locationName = manualLocationName, manualLocation != nil {
                selectedManualLocationPill(locationName)
            } else {
                // Show search field
                LocationInputView(
                    searchText: $manualSearchText,
                    selectedLocation: $manualLocation,
                    selectedLocationName: $manualLocationName,
                    geocodingService: geocodingService,
                    onLocationSelected: { }
                )
            }

            // Option to use current location instead
            if isLocationAuthorized {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        locationMode = .currentLocation
                        clearManualLocation()
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.caption2)
                        Text("Use current location")
                            .font(.caption)
                    }
                    .foregroundColor(Color.theme.primaryButton)
                }
                .accessibilityLabel("Switch to current location")
            }
        }
    }

    private func selectedManualLocationPill(_ name: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "mappin.circle.fill")
                .font(.caption)
                .foregroundColor(Color.theme.primaryButton)

            Text(name)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Color.theme.textPrimary)
                .lineLimit(1)

            Spacer()

            Button("Change") {
                clearManualLocation()
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
        .accessibilityLabel("Using \(name)")
        .accessibilityHint("Tap change to enter a different location")
    }

    // MARK: - Helpers

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.caption)
            .fontWeight(.medium)
            .tracking(0.5)
            .foregroundColor(Color.theme.label)
    }

    private func clearManualLocation() {
        manualSearchText = ""
        manualLocation = nil
        manualLocationName = nil
    }
}

// MARK: - Previews

#Preview("Location Authorized - Current") {
    struct PreviewWrapper: View {
        @State private var mode: LocationMode = .currentLocation
        @State private var searchText = ""
        @State private var location: CLLocationCoordinate2D?
        @State private var locationName: String?
        @State private var radius: SearchRadius = .defaultRadius
        @State private var vibe: VibeMode = .aesthetic
        @State private var partySize = PartySize.defaultSize

        var body: some View {
            ZStack {
                Color.theme.background.ignoresSafeArea()
                ControlsCard(
                    isLocationAuthorized: true,
                    geocodingService: PreviewGeocodingService(),
                    onRequestLocation: {},
                    locationMode: $mode,
                    manualSearchText: $searchText,
                    manualLocation: $location,
                    manualLocationName: $locationName,
                    searchRadius: $radius,
                    selectedVibe: $vibe,
                    partySize: $partySize
                )
                .padding()
            }
        }
    }
    return PreviewWrapper()
}

#Preview("Location Not Authorized") {
    struct PreviewWrapper: View {
        @State private var mode: LocationMode = .currentLocation
        @State private var searchText = ""
        @State private var location: CLLocationCoordinate2D?
        @State private var locationName: String?
        @State private var radius: SearchRadius = .defaultRadius
        @State private var vibe: VibeMode = .aesthetic
        @State private var partySize = PartySize.defaultSize

        var body: some View {
            ZStack {
                Color.theme.background.ignoresSafeArea()
                ControlsCard(
                    isLocationAuthorized: false,
                    geocodingService: PreviewGeocodingService(),
                    onRequestLocation: {},
                    locationMode: $mode,
                    manualSearchText: $searchText,
                    manualLocation: $location,
                    manualLocationName: $locationName,
                    searchRadius: $radius,
                    selectedVibe: $vibe,
                    partySize: $partySize
                )
                .padding()
            }
        }
    }
    return PreviewWrapper()
}

#Preview("Manual Location Entry") {
    struct PreviewWrapper: View {
        @State private var mode: LocationMode = .manual
        @State private var searchText = ""
        @State private var location: CLLocationCoordinate2D?
        @State private var locationName: String?
        @State private var radius: SearchRadius = .defaultRadius
        @State private var vibe: VibeMode = .splurge
        @State private var partySize = 4

        var body: some View {
            ZStack {
                Color.theme.background.ignoresSafeArea()
                ControlsCard(
                    isLocationAuthorized: true,
                    geocodingService: PreviewGeocodingService(),
                    onRequestLocation: {},
                    locationMode: $mode,
                    manualSearchText: $searchText,
                    manualLocation: $location,
                    manualLocationName: $locationName,
                    searchRadius: $radius,
                    selectedVibe: $vibe,
                    partySize: $partySize
                )
                .padding()
            }
        }
    }
    return PreviewWrapper()
}

#Preview("Manual Location Selected") {
    struct PreviewWrapper: View {
        @State private var mode: LocationMode = .manual
        @State private var searchText = "San Francisco"
        @State private var location: CLLocationCoordinate2D? = CLLocationCoordinate2D(
            latitude: 37.7749,
            longitude: -122.4194
        )
        @State private var locationName: String? = "San Francisco, CA"
        @State private var radius: SearchRadius = .defaultRadius
        @State private var vibe: VibeMode = .standard
        @State private var partySize = 6

        var body: some View {
            ZStack {
                Color.theme.background.ignoresSafeArea()
                ControlsCard(
                    isLocationAuthorized: true,
                    geocodingService: PreviewGeocodingService(),
                    onRequestLocation: {},
                    locationMode: $mode,
                    manualSearchText: $searchText,
                    manualLocation: $location,
                    manualLocationName: $locationName,
                    searchRadius: $radius,
                    selectedVibe: $vibe,
                    partySize: $partySize
                )
                .padding()
            }
        }
    }
    return PreviewWrapper()
}

// Preview helper
private class PreviewGeocodingService: GeocodingProviding {
    func geocode(address: String) async throws -> CLLocationCoordinate2D {
        try await Task.sleep(nanoseconds: 500_000_000)
        return CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
    }

    func autocomplete(query: String) async throws -> [LocationSuggestion] {
        try await Task.sleep(nanoseconds: 300_000_000)
        return [
            LocationSuggestion(title: "\(query) Francisco, CA", subtitle: "California, United States"),
            LocationSuggestion(title: "\(query) Jose, CA", subtitle: "California, United States"),
            LocationSuggestion(title: "\(query) Diego, CA", subtitle: "California, United States")
        ]
    }

    func geocode(suggestion: LocationSuggestion) async throws -> CLLocationCoordinate2D {
        try await geocode(address: suggestion.fullAddress)
    }
}
