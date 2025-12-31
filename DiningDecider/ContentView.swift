import SwiftUI

struct ContentView: View {
    @State private var rotation: Double = 0
    @State private var showResults = false
    @State private var landedCategory = "Rooftop"

    private let sectors = WheelSector.skeletonSectors

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
                restaurants: Restaurant.skeletonData,
                onSpinAgain: {
                    showResults = false
                }
            )
            .presentationDetents([.large])
        }
    }

    private func handleSpinComplete(sectorIndex: Int) {
        landedCategory = sectors[sectorIndex].label
        showResults = true
    }
}

#Preview {
    ContentView()
}
