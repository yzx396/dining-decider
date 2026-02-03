import SwiftUI
import DiningDeciderCore

/// A row of three pill-shaped buttons for selecting vibe mode
struct VibeSelector: View {
    @Binding var selectedVibe: VibeMode

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Section label
            Text("CIRCUMSTANCE / VIBE")
                .font(.caption)
                .fontWeight(.medium)
                .tracking(0.5)
                .foregroundColor(Color.theme.label)

            // Three vibe buttons in a row
            HStack(spacing: 8) {
                ForEach(VibeMode.allCases) { vibe in
                    VibeButton(
                        vibe: vibe,
                        isSelected: selectedVibe == vibe,
                        action: { selectedVibe = vibe }
                    )
                }
            }
        }
    }
}

/// Individual vibe selection button
private struct VibeButton: View {
    let vibe: VibeMode
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 4) {
                Text(vibe.emoji)
                    .font(.caption)
                Text(vibe.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .padding(.horizontal, 6)
            .background(isSelected ? vibe.selectedColor : Color.theme.cardBackground)
            .foregroundColor(isSelected ? .white : Color.theme.textPrimary)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : Color.theme.borderColor, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(vibe.displayName) vibe")
        .accessibilityHint(isSelected ? "Currently selected" : "Double tap to select")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

#Preview {
    VStack {
        VibeSelector(selectedVibe: .constant(.aesthetic))
            .padding()

        VibeSelector(selectedVibe: .constant(.splurge))
            .padding()

        VibeSelector(selectedVibe: .constant(.standard))
            .padding()
    }
    .background(Color.theme.background)
}
