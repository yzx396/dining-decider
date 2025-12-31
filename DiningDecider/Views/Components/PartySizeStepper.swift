import SwiftUI

/// A custom stepper for selecting party size with circular +/- buttons
struct PartySizeStepper: View {
    @Binding var partySize: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel

            stepperControls
        }
    }

    // MARK: - Section Label

    private var sectionLabel: some View {
        Text("PARTY SIZE")
            .font(.caption)
            .fontWeight(.medium)
            .tracking(0.5)
            .foregroundColor(Color.theme.label)
    }

    // MARK: - Stepper Controls

    private var stepperControls: some View {
        HStack(spacing: 16) {
            decrementButton
            sizeDisplay
            incrementButton
        }
    }

    // MARK: - Decrement Button

    private var decrementButton: some View {
        let canDecrement = PartySize.canDecrement(partySize)

        return Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                partySize = PartySize.decrement(partySize)
            }
        } label: {
            Image(systemName: "minus")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(canDecrement ? Color.theme.textPrimary : Color.theme.disabledButton)
                .frame(width: 36, height: 36)
                .background(Color.theme.cardBackground)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(canDecrement ? Color.theme.borderColor : Color.theme.disabledButton, lineWidth: 1)
                )
        }
        .disabled(!canDecrement)
        .accessibilityLabel("Decrease party size")
        .accessibilityHint(canDecrement ? "Current size is \(partySize). Double tap to decrease." : "Minimum party size reached")
    }

    // MARK: - Size Display

    private var sizeDisplay: some View {
        Text("\(partySize)")
            .font(.title2)
            .fontWeight(.medium)
            .foregroundColor(Color.theme.textPrimary)
            .frame(minWidth: 40)
            .accessibilityLabel("Party size: \(partySize) \(partySize == 1 ? "person" : "people")")
    }

    // MARK: - Increment Button

    private var incrementButton: some View {
        let canIncrement = PartySize.canIncrement(partySize)

        return Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                partySize = PartySize.increment(partySize)
            }
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(canIncrement ? Color.theme.textPrimary : Color.theme.disabledButton)
                .frame(width: 36, height: 36)
                .background(Color.theme.cardBackground)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(canIncrement ? Color.theme.borderColor : Color.theme.disabledButton, lineWidth: 1)
                )
        }
        .disabled(!canIncrement)
        .accessibilityLabel("Increase party size")
        .accessibilityHint(canIncrement ? "Current size is \(partySize). Double tap to increase." : "Maximum party size reached")
    }
}

// MARK: - Previews

#Preview("Default Size (2)") {
    struct PreviewWrapper: View {
        @State private var partySize = PartySize.defaultSize

        var body: some View {
            ZStack {
                Color.theme.background.ignoresSafeArea()
                PartySizeStepper(partySize: $partySize)
                    .padding()
            }
        }
    }
    return PreviewWrapper()
}

#Preview("Minimum Size (1)") {
    struct PreviewWrapper: View {
        @State private var partySize = PartySize.minimum

        var body: some View {
            ZStack {
                Color.theme.background.ignoresSafeArea()
                PartySizeStepper(partySize: $partySize)
                    .padding()
            }
        }
    }
    return PreviewWrapper()
}

#Preview("Maximum Size (20)") {
    struct PreviewWrapper: View {
        @State private var partySize = PartySize.maximum

        var body: some View {
            ZStack {
                Color.theme.background.ignoresSafeArea()
                PartySizeStepper(partySize: $partySize)
                    .padding()
            }
        }
    }
    return PreviewWrapper()
}

#Preview("In Card Context") {
    struct PreviewWrapper: View {
        @State private var partySize = 4

        var body: some View {
            ZStack {
                Color.theme.background.ignoresSafeArea()
                VStack(spacing: 16) {
                    PartySizeStepper(partySize: $partySize)
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
