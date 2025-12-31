import SwiftUI

/// A segmented picker for selecting search radius
struct RadiusPicker: View {
    @Binding var selectedRadius: SearchRadius

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel

            radiusOptions
        }
    }

    // MARK: - Section Label

    private var sectionLabel: some View {
        Text("SEARCH RADIUS")
            .font(.caption)
            .fontWeight(.medium)
            .tracking(0.5)
            .foregroundColor(Color.theme.label)
    }

    // MARK: - Radius Options

    private var radiusOptions: some View {
        HStack(spacing: 0) {
            ForEach(SearchRadius.allCases) { radius in
                radiusButton(for: radius)
            }
        }
        .background(Color.theme.background)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.theme.disabledButton, lineWidth: 1)
        )
    }

    private func radiusButton(for radius: SearchRadius) -> some View {
        let isSelected = selectedRadius == radius

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedRadius = radius
            }
        } label: {
            Text(radius.label)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? Color.theme.primaryButtonText : Color.theme.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(isSelected ? Color.theme.primaryButton : Color.clear)
        }
        .accessibilityLabel("\(radius.label) radius")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityHint("Double tap to select this radius")
    }
}

// MARK: - Previews

#Preview("Default Selection (10 mi)") {
    struct PreviewWrapper: View {
        @State private var radius: SearchRadius = .defaultRadius

        var body: some View {
            ZStack {
                Color.theme.background.ignoresSafeArea()
                RadiusPicker(selectedRadius: $radius)
                    .padding()
            }
        }
    }
    return PreviewWrapper()
}

#Preview("5 mi Selected") {
    struct PreviewWrapper: View {
        @State private var radius: SearchRadius = .fiveMiles

        var body: some View {
            ZStack {
                Color.theme.background.ignoresSafeArea()
                RadiusPicker(selectedRadius: $radius)
                    .padding()
            }
        }
    }
    return PreviewWrapper()
}

#Preview("25 mi Selected") {
    struct PreviewWrapper: View {
        @State private var radius: SearchRadius = .twentyFiveMiles

        var body: some View {
            ZStack {
                Color.theme.background.ignoresSafeArea()
                RadiusPicker(selectedRadius: $radius)
                    .padding()
            }
        }
    }
    return PreviewWrapper()
}

#Preview("In Card Context") {
    struct PreviewWrapper: View {
        @State private var radius: SearchRadius = .tenMiles

        var body: some View {
            ZStack {
                Color.theme.background.ignoresSafeArea()
                VStack(spacing: 16) {
                    RadiusPicker(selectedRadius: $radius)
                }
                .padding(20)
                .background(Color.theme.cardBackground)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                .padding()
            }
        }
    }
    return PreviewWrapper()
}
