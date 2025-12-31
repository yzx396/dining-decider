import Foundation

enum WheelMath {
    /// Calculates which sector the wheel lands on based on rotation
    /// - Parameters:
    ///   - rotation: The total rotation in degrees
    ///   - sectorCount: Number of sectors on the wheel
    /// - Returns: Index of the landing sector (0-based)
    static func landingSector(rotation: Double, sectorCount: Int) -> Int {
        guard sectorCount > 0 else { return 0 }

        // Normalize rotation to 0-360 range
        var normalizedRotation = rotation.truncatingRemainder(dividingBy: 360)
        if normalizedRotation < 0 {
            normalizedRotation += 360
        }

        let sectorAngle = 360.0 / Double(sectorCount)
        let sectorIndex = Int(normalizedRotation / sectorAngle)

        return sectorIndex % sectorCount
    }

    /// Calculates the angle of each sector in degrees
    /// - Parameter sectorCount: Number of sectors on the wheel
    /// - Returns: Angle in degrees for each sector
    static func sectorAngle(sectorCount: Int) -> Double {
        guard sectorCount > 0 else { return 0 }
        return 360.0 / Double(sectorCount)
    }
}
