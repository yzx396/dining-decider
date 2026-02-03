import SwiftUI
import CoreLocation

/// Text field with autocomplete for manual location entry
struct LocationInputView: View {
    @Binding var searchText: String
    @Binding var selectedLocation: CLLocationCoordinate2D?
    @Binding var selectedLocationName: String?

    let geocodingService: GeocodingProviding
    let onLocationSelected: () -> Void

    @State private var suggestions: [LocationSuggestion] = []
    @State private var isSearching = false
    @State private var showSuggestions = false
    @State private var isGeocoding = false
    @State private var errorMessage: String?

    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            searchField
            if showSuggestions && !suggestions.isEmpty {
                suggestionsList
            }
            if let error = errorMessage {
                errorView(error)
            }
        }
    }

    // MARK: - Search Field

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.subheadline)
                .foregroundColor(Color.theme.label)

            TextField("Enter city or zip", text: $searchText)
                .font(.subheadline)
                .foregroundColor(Color.theme.textPrimary)
                .focused($isTextFieldFocused)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.words)
                .submitLabel(.search)
                .onSubmit {
                    geocodeCurrentText()
                }
                .onChange(of: searchText) { _, newValue in
                    handleSearchTextChange(newValue)
                }

            if isSearching || isGeocoding {
                ProgressView()
                    .scaleEffect(0.8)
            } else if !searchText.isEmpty {
                Button {
                    clearSearch()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.subheadline)
                        .foregroundColor(Color.theme.label)
                }
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.theme.background)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.theme.label.opacity(0.3), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Location search field")
        .accessibilityHint("Enter a city name or zip code")
    }

    // MARK: - Suggestions List

    private var suggestionsList: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(suggestions) { suggestion in
                suggestionRow(suggestion)
                if suggestion != suggestions.last {
                    Divider()
                        .padding(.leading, 12)
                }
            }
        }
        .background(Color.theme.cardBackground)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }

    private func suggestionRow(_ suggestion: LocationSuggestion) -> some View {
        Button {
            selectSuggestion(suggestion)
        } label: {
            VStack(alignment: .leading, spacing: 2) {
                Text(suggestion.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color.theme.textPrimary)

                if !suggestion.subtitle.isEmpty {
                    Text(suggestion.subtitle)
                        .font(.caption)
                        .foregroundColor(Color.theme.label)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(suggestion.title), \(suggestion.subtitle)")
        .accessibilityHint("Tap to select this location")
    }

    // MARK: - Error View

    private func errorView(_ message: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "exclamationmark.circle")
                .font(.caption)
            Text(message)
                .font(.caption)
        }
        .foregroundColor(.red)
        .accessibilityLabel("Error: \(message)")
    }

    // MARK: - Actions

    private func handleSearchTextChange(_ text: String) {
        errorMessage = nil

        guard text.count >= 2 else {
            suggestions = []
            showSuggestions = false
            return
        }

        showSuggestions = true
        performAutocomplete(text)
    }

    private func performAutocomplete(_ query: String) {
        isSearching = true

        Task {
            do {
                let results = try await geocodingService.autocomplete(query: query)
                await MainActor.run {
                    suggestions = results
                    isSearching = false
                }
            } catch {
                await MainActor.run {
                    suggestions = []
                    isSearching = false
                }
            }
        }
    }

    private func selectSuggestion(_ suggestion: LocationSuggestion) {
        searchText = suggestion.title
        showSuggestions = false
        isTextFieldFocused = false
        geocodeSuggestion(suggestion)
    }

    private func geocodeSuggestion(_ suggestion: LocationSuggestion) {
        isGeocoding = true
        errorMessage = nil

        Task {
            do {
                let coordinate = try await geocodingService.geocode(suggestion: suggestion)
                await MainActor.run {
                    selectedLocation = coordinate
                    selectedLocationName = suggestion.title
                    isGeocoding = false
                    onLocationSelected()
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Could not find location"
                    isGeocoding = false
                }
            }
        }
    }

    private func geocodeCurrentText() {
        guard !searchText.isEmpty else { return }

        isGeocoding = true
        errorMessage = nil
        showSuggestions = false

        Task {
            do {
                let coordinate = try await geocodingService.geocode(address: searchText)
                await MainActor.run {
                    selectedLocation = coordinate
                    selectedLocationName = searchText
                    isGeocoding = false
                    onLocationSelected()
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Could not find location"
                    isGeocoding = false
                }
            }
        }
    }

    private func clearSearch() {
        searchText = ""
        suggestions = []
        showSuggestions = false
        errorMessage = nil
        selectedLocation = nil
        selectedLocationName = nil
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @State private var searchText = ""
        @State private var location: CLLocationCoordinate2D?
        @State private var locationName: String?

        var body: some View {
            ZStack {
                Color.theme.background.ignoresSafeArea()

                VStack {
                    LocationInputView(
                        searchText: $searchText,
                        selectedLocation: $location,
                        selectedLocationName: $locationName,
                        geocodingService: PreviewGeocodingService(),
                        onLocationSelected: {
                            print("Location selected: \(locationName ?? "none")")
                        }
                    )
                    .padding()

                    if let name = locationName, let loc = location {
                        Text("Selected: \(name)")
                        Text("Lat: \(loc.latitude), Lng: \(loc.longitude)")
                    }

                    Spacer()
                }
            }
        }
    }

    return PreviewWrapper()
}


