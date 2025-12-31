import SwiftUI

struct ContentView: View {
    @State private var rotation: Double = 0
    @State private var showResults = false
    @State private var isSpinning = false
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
                    rotation: rotation
                )
                .frame(width: 300, height: 300)
                .onTapGesture {
                    guard !isSpinning else { return }
                    spin()
                }
                .accessibilityLabel("Spinning wheel")
                .accessibilityHint("Tap to spin and get a restaurant recommendation")

                // Hint text
                Text(isSpinning ? "Spinning..." : "Tap wheel to spin")
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

    private func spin() {
        isSpinning = true

        // Random rotation between 720 and 1080 degrees (2-3 full spins)
        let spinAmount = Double.random(in: 720...1080)

        withAnimation(.easeOut(duration: 2)) {
            rotation += spinAmount
        }

        // Calculate landing sector after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let sectorIndex = WheelMath.landingSector(
                rotation: rotation,
                sectorCount: sectors.count
            )
            landedCategory = sectors[sectorIndex].label
            isSpinning = false
            showResults = true
        }
    }
}

#Preview {
    ContentView()
}
