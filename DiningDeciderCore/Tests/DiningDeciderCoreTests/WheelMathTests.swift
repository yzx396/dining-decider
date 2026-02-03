import XCTest
@testable import DiningDeciderCore

final class WheelMathTests: XCTestCase {

    // MARK: - Landing Sector Tests
    //
    // Visual layout with 8 sectors (45° each):
    // - Sectors are drawn CLOCKWISE on screen starting from the top (-90°)
    // - Sector 0: -90° to -45° (top, extending to upper-right)
    // - Sector 1: -45° to 0° (upper-right to right)
    // - etc.
    //
    // The pointer is FIXED at the TOP (-90°/270°).
    // We return the sector whose CENTER is closest to the pointer.
    //
    // Sector centers pass the pointer at rotation values:
    // - 22.5°: sector 7's center
    // - 67.5°: sector 6's center
    // - 112.5°: sector 5's center
    // - etc.
    //
    // Using ceiling division, transitions happen at 45°, 90°, 135°, etc.
    // (equidistant points between consecutive sector centers)
    //
    // When wheel rotates clockwise (positive), we traverse sectors in
    // REVERSE order: 0 → 7 → 6 → 5 → ...

    func test_landingSector_withZeroRotation_returnsFirstSector() {
        // At rotation=0, sector 0 is at top, pointer sees sector 0
        let sector = WheelMath.landingSector(rotation: 0, sectorCount: 8)
        XCTAssertEqual(sector, 0)
    }

    func test_landingSector_withFullRotation_returnsFirstSector() {
        let sector = WheelMath.landingSector(rotation: 360, sectorCount: 8)
        XCTAssertEqual(sector, 0)
    }

    func test_landingSector_withMultipleFullRotations_returnsFirstSector() {
        let sector = WheelMath.landingSector(rotation: 720, sectorCount: 8)
        XCTAssertEqual(sector, 0)
    }

    func test_landingSector_withOneSectorRotation_returnsPreviousSector() {
        // Rotate 45° clockwise: wheel moves CW, sector 7 comes under pointer
        let sector = WheelMath.landingSector(rotation: 45, sectorCount: 8)
        XCTAssertEqual(sector, 7)
    }

    func test_landingSector_withHalfRotation_returnsOppositeSector() {
        // 180° rotation: sector 4 is at top (4 steps back from 0 = 4)
        let sector = WheelMath.landingSector(rotation: 180, sectorCount: 8)
        XCTAssertEqual(sector, 4)
    }

    func test_landingSector_withNegativeRotation_handlesCorrectly() {
        // -45° (counterclockwise): wheel moves CCW, sector 1 comes under pointer
        let sector = WheelMath.landingSector(rotation: -45, sectorCount: 8)
        XCTAssertEqual(sector, 1)
    }

    func test_landingSector_withZeroSectors_returnsZero() {
        let sector = WheelMath.landingSector(rotation: 90, sectorCount: 0)
        XCTAssertEqual(sector, 0)
    }

    func test_landingSector_withSixSectors_calculatesCorrectly() {
        // 6 sectors, 60° each
        // 60° clockwise rotation: sector 5 comes to top (one step back from 0)
        let sector = WheelMath.landingSector(rotation: 60, sectorCount: 6)
        XCTAssertEqual(sector, 5)
    }

    func test_landingSector_allSectorsAccessible() {
        // Verify each sector is accessible with proper rotation
        // Clockwise rotation traverses sectors in reverse: 0 → 7 → 6 → 5 → ...
        XCTAssertEqual(WheelMath.landingSector(rotation: 0, sectorCount: 8), 0)
        XCTAssertEqual(WheelMath.landingSector(rotation: 45, sectorCount: 8), 7)
        XCTAssertEqual(WheelMath.landingSector(rotation: 90, sectorCount: 8), 6)
        XCTAssertEqual(WheelMath.landingSector(rotation: 135, sectorCount: 8), 5)
        XCTAssertEqual(WheelMath.landingSector(rotation: 180, sectorCount: 8), 4)
        XCTAssertEqual(WheelMath.landingSector(rotation: 225, sectorCount: 8), 3)
        XCTAssertEqual(WheelMath.landingSector(rotation: 270, sectorCount: 8), 2)
        XCTAssertEqual(WheelMath.landingSector(rotation: 315, sectorCount: 8), 1)
    }

    func test_landingSector_withLargeRotation() {
        // 1624° = 4*360 + 184° = 184° effective
        // ceil(184 / 45) = 5 → (8-5) % 8 = sector 3
        // At 184°, sector 3's center (251.5°) is closer to pointer (270°)
        // than sector 4's center (296.5°)
        let sector = WheelMath.landingSector(rotation: 1624, sectorCount: 8)
        XCTAssertEqual(sector, 3)
    }

    // MARK: - Sector Angle Tests

    func test_sectorAngle_withEightSectors_returns45() {
        let angle = WheelMath.sectorAngle(sectorCount: 8)
        XCTAssertEqual(angle, 45.0)
    }

    func test_sectorAngle_withSixSectors_returns60() {
        let angle = WheelMath.sectorAngle(sectorCount: 6)
        XCTAssertEqual(angle, 60.0)
    }

    func test_sectorAngle_withZeroSectors_returnsZero() {
        let angle = WheelMath.sectorAngle(sectorCount: 0)
        XCTAssertEqual(angle, 0.0)
    }

    func test_sectorAngle_withOneSector_returns360() {
        let angle = WheelMath.sectorAngle(sectorCount: 1)
        XCTAssertEqual(angle, 360.0)
    }
    
    // MARK: - Safe Landing Sector Tests (Bug #3: Empty Sectors)
    
    func test_safeLandingSector_withValidIndex_returnsSector() {
        let result = WheelMath.safeLandingSector(rotation: 45, sectorCount: 8)
        XCTAssertEqual(result, 7)
    }
    
    func test_safeLandingSector_withZeroSectors_returnsNil() {
        let result = WheelMath.safeLandingSector(rotation: 45, sectorCount: 0)
        XCTAssertNil(result)
    }
    
    func test_safeLandingSector_withNegativeSectors_returnsNil() {
        let result = WheelMath.safeLandingSector(rotation: 45, sectorCount: -1)
        XCTAssertNil(result)
    }
    
    func test_safeLandingSector_allValidRotations_returnValidIndices() {
        for rotation in stride(from: 0, through: 720, by: 45) {
            let result = WheelMath.safeLandingSector(rotation: Double(rotation), sectorCount: 8)
            XCTAssertNotNil(result)
            XCTAssertTrue(result! >= 0 && result! < 8, "Index \(result!) out of bounds for rotation \(rotation)")
        }
    }
}
