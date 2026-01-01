import Foundation

public enum WheelMath {
    /// Calculates which sector the wheel lands on based on rotation
    /// - Parameters:
    ///   - rotation: The total rotation in degrees
    ///   - sectorCount: Number of sectors on the wheel
    /// - Returns: Index of the landing sector (0-based)
    public static func landingSector(rotation: Double, sectorCount: Int) -> Int {
        guard sectorCount > 0 else { return 0 }

        let sectorAngle = 360.0 / Double(sectorCount)

        // Normalize rotation to 0-360 range
        var normalizedRotation = rotation.truncatingRemainder(dividingBy: 360)
        if normalizedRotation < 0 {
            normalizedRotation += 360
        }

        // The pointer is FIXED at the top of the wheel (-90°/270°).
        // Sectors are drawn clockwise starting from -90°.
        //
        // We want to return the sector whose CENTER is closest to the pointer.
        // Sector centers pass the pointer at: 22.5°, 67.5°, 112.5°, etc.
        // (sector 7 at 22.5°, sector 6 at 67.5°, sector 5 at 112.5°, ...)
        //
        // Using ceiling division ensures we transition when the center passes:
        //   - rotation in [0°, 45°]: sector whose center just passed (or is at) pointer
        //   - At exactly 0°: sectors 0 and 7 equidistant, return 0 by convention
        //   - At 45°+ε: sector 6's center is closer, return 6
        //
        // When wheel rotates clockwise (positive), we traverse sectors in
        // reverse order: 0 → 7 → 6 → 5 → ...
        let sectorsRotated: Int
        if normalizedRotation == 0 {
            sectorsRotated = 0
        } else {
            sectorsRotated = Int(ceil(normalizedRotation / sectorAngle)) % sectorCount
        }
        return (sectorCount - sectorsRotated) % sectorCount
    }

    /// Calculates the angle of each sector in degrees
    /// - Parameter sectorCount: Number of sectors on the wheel
    /// - Returns: Angle in degrees for each sector
    public static func sectorAngle(sectorCount: Int) -> Double {
        guard sectorCount > 0 else { return 0 }
        return 360.0 / Double(sectorCount)
    }
}
