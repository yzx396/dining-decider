import SwiftUI

struct SpinningWheelView: View {
    let sectors: [WheelSector]
    let rotation: Double

    private let borderWidth: CGFloat = 8
    private let centerDotSize: CGFloat = 50

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)

            ZStack {
                // Wheel sectors
                wheelSectors
                    .frame(width: size - borderWidth * 2, height: size - borderWidth * 2)
                    .rotationEffect(.degrees(rotation))

                // Border
                Circle()
                    .strokeBorder(Color.theme.wheelBorder, lineWidth: borderWidth)
                    .frame(width: size, height: size)

                // Center dot
                Circle()
                    .fill(Color.theme.wheelCenter)
                    .frame(width: centerDotSize, height: centerDotSize)
                    .shadow(color: .black.opacity(0.1), radius: 2, y: 1)

                // Pointer indicator (top)
                pointerIndicator
                    .offset(y: -size / 2 + 10)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private var wheelSectors: some View {
        ZStack {
            ForEach(Array(sectors.enumerated()), id: \.element.id) { index, sector in
                let sectorAngle = 360.0 / Double(sectors.count)
                let startAngle = Double(index) * sectorAngle - 90
                let endAngle = startAngle + sectorAngle

                ZStack {
                    // Sector shape
                    WheelSectorShape(
                        startAngle: .degrees(startAngle),
                        endAngle: .degrees(endAngle)
                    )
                    .fill(sector.color)

                    // Sector label
                    sectorLabel(sector.label, at: index, sectorAngle: sectorAngle)
                }
            }
        }
    }

    private func sectorLabel(_ text: String, at index: Int, sectorAngle: Double) -> some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let radius = size / 2 * 0.65
            let midAngle = Double(index) * sectorAngle + sectorAngle / 2 - 90

            Text(text)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                .rotationEffect(.degrees(midAngle + 90))
                .position(
                    x: geometry.size.width / 2 + CGFloat(cos(midAngle * .pi / 180)) * radius,
                    y: geometry.size.height / 2 + CGFloat(sin(midAngle * .pi / 180)) * radius
                )
        }
    }

    private var pointerIndicator: some View {
        Triangle()
            .fill(Color.theme.title)
            .frame(width: 20, height: 15)
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    SpinningWheelView(
        sectors: WheelSector.skeletonSectors,
        rotation: 0
    )
    .frame(width: 300, height: 300)
    .padding()
    .background(Color.theme.background)
}
