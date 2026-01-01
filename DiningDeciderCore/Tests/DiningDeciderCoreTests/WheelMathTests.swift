import XCTest
@testable import DiningDeciderCore

final class WheelMathTests: XCTestCase {

    // MARK: - Landing Sector Tests
    //
    // Visual layout with 8 sectors (45° each):
    // - Sectors are drawn CLOCKWISE on screen starting from the top (-90°)
    // - Sector 0 is at 12:00 position
    // - Sector 1 is at ~1:30 position (clockwise from sector 0)
    // - Sector 2 is at ~3:00 position
    // - etc.
    //
    // The pointer is fixed at the TOP (12:00 position)
    //
    // When wheel rotates CLOCKWISE (positive rotation):
    // - The wheel moves clockwise under the fixed pointer
    // - HIGHER-indexed sectors come under the pointer
    //
    // So: rotation increases → sector index INCREASES

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

    func test_landingSector_withOneSectorRotation_returnsNextSector() {
        // Rotate 45° clockwise, sector 1 comes to top
        let sector = WheelMath.landingSector(rotation: 45, sectorCount: 8)
        XCTAssertEqual(sector, 1)
    }

    func test_landingSector_withHalfRotation_returnsOppositeSector() {
        // 180° rotation: sector 4 is at top
        let sector = WheelMath.landingSector(rotation: 180, sectorCount: 8)
        XCTAssertEqual(sector, 4)
    }

    func test_landingSector_withNegativeRotation_handlesCorrectly() {
        // -45° (counterclockwise), sector 7 comes to top
        let sector = WheelMath.landingSector(rotation: -45, sectorCount: 8)
        XCTAssertEqual(sector, 7)
    }

    func test_landingSector_withZeroSectors_returnsZero() {
        let sector = WheelMath.landingSector(rotation: 90, sectorCount: 0)
        XCTAssertEqual(sector, 0)
    }

    func test_landingSector_withSixSectors_calculatesCorrectly() {
        // 6 sectors, 60° each
        // 60° clockwise rotation: sector 1 comes to top
        let sector = WheelMath.landingSector(rotation: 60, sectorCount: 6)
        XCTAssertEqual(sector, 1)
    }

    func test_landingSector_allSectorsAccessible() {
        // Verify each sector is accessible with proper rotation
        XCTAssertEqual(WheelMath.landingSector(rotation: 0, sectorCount: 8), 0)
        XCTAssertEqual(WheelMath.landingSector(rotation: 45, sectorCount: 8), 1)
        XCTAssertEqual(WheelMath.landingSector(rotation: 90, sectorCount: 8), 2)
        XCTAssertEqual(WheelMath.landingSector(rotation: 135, sectorCount: 8), 3)
        XCTAssertEqual(WheelMath.landingSector(rotation: 180, sectorCount: 8), 4)
        XCTAssertEqual(WheelMath.landingSector(rotation: 225, sectorCount: 8), 5)
        XCTAssertEqual(WheelMath.landingSector(rotation: 270, sectorCount: 8), 6)
        XCTAssertEqual(WheelMath.landingSector(rotation: 315, sectorCount: 8), 7)
    }
    
    func test_landingSector_withLargeRotation() {
        // 1624° = 4*360 + 184° = 184° effective
        // 184 / 45 = 4.08 → sector 4
        let sector = WheelMath.landingSector(rotation: 1624, sectorCount: 8)
        XCTAssertEqual(sector, 4)
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
}
