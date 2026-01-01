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

        // The pointer is at the top of the wheel (-90°/270°).
        // Sectors are drawn clockwise on screen: 0 at top, 1 to upper-right, etc.
        // When wheel rotates clockwise (positive rotation), the wheel moves
        // clockwise under the fixed pointer, so HIGHER-indexed sectors come
        // under the pointer.
        //
        // At rotation=0: pointer sees sector 0
        // At rotation=45: pointer sees sector 1 (sector 1 moved into pointer position)
        // At rotation=90: pointer sees sector 2
        // 
        // Formula: as rotation increases, sector index increases
        let sectorsRotated = Int(normalizedRotation / sectorAngle) % sectorCount
        return sectorsRotated
    }

    /// Calculates the angle of each sector in degrees
    /// - Parameter sectorCount: Number of sectors on the wheel
    /// - Returns: Angle in degrees for each sector
    public static func sectorAngle(sectorCount: Int) -> Double {
        guard sectorCount > 0 else { return 0 }
        return 360.0 / Double(sectorCount)
    }
}
