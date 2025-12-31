import SwiftUI

struct WheelSectorShape: Shape {
    let startAngle: Angle
    let endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        path.move(to: center)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        path.closeSubpath()

        return path
    }
}

#Preview {
    ZStack {
        WheelSectorShape(
            startAngle: .degrees(0),
            endAngle: .degrees(90)
        )
        .fill(Color.theme.aestheticWheelColors[0])

        WheelSectorShape(
            startAngle: .degrees(90),
            endAngle: .degrees(180)
        )
        .fill(Color.theme.aestheticWheelColors[1])

        WheelSectorShape(
            startAngle: .degrees(180),
            endAngle: .degrees(270)
        )
        .fill(Color.theme.aestheticWheelColors[2])

        WheelSectorShape(
            startAngle: .degrees(270),
            endAngle: .degrees(360)
        )
        .fill(Color.theme.aestheticWheelColors[3])
    }
    .frame(width: 300, height: 300)
}
