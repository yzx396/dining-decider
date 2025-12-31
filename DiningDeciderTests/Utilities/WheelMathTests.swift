import XCTest
@testable import DiningDecider

final class WheelMathTests: XCTestCase {

    // MARK: - Landing Sector Tests

    func test_landingSector_withZeroRotation_returnsFirstSector() {
        // Given
        let sectorCount = 4
        let rotation = 0.0

        // When
        let index = WheelMath.landingSector(rotation: rotation, sectorCount: sectorCount)

        // Then
        XCTAssertEqual(index, 0)
    }

    func test_landingSector_withFullRotation_returnsFirstSector() {
        // Given
        let sectorCount = 4
        let rotation = 360.0

        // When
        let index = WheelMath.landingSector(rotation: rotation, sectorCount: sectorCount)

        // Then
        XCTAssertEqual(index, 0)
    }

    func test_landingSector_withMultipleFullRotations_returnsFirstSector() {
        // Given
        let sectorCount = 4
        let rotation = 720.0

        // When
        let index = WheelMath.landingSector(rotation: rotation, sectorCount: sectorCount)

        // Then
        XCTAssertEqual(index, 0)
    }

    func test_landingSector_with90Degrees_returnsSecondSector() {
        // Given: 4 sectors, each 90 degrees
        let sectorCount = 4
        let rotation = 90.0

        // When
        let index = WheelMath.landingSector(rotation: rotation, sectorCount: sectorCount)

        // Then
        XCTAssertEqual(index, 1)
    }

    func test_landingSector_with180Degrees_returnsThirdSector() {
        // Given: 4 sectors, each 90 degrees
        let sectorCount = 4
        let rotation = 180.0

        // When
        let index = WheelMath.landingSector(rotation: rotation, sectorCount: sectorCount)

        // Then
        XCTAssertEqual(index, 2)
    }

    func test_landingSector_with8Sectors_calculatesCorrectly() {
        // Given: 8 sectors, each 45 degrees
        let sectorCount = 8
        let rotation = 135.0  // Middle of sector 3 (index 3)

        // When
        let index = WheelMath.landingSector(rotation: rotation, sectorCount: sectorCount)

        // Then
        XCTAssertEqual(index, 3)
    }

    func test_landingSector_withNegativeRotation_handlesCorrectly() {
        // Given
        let sectorCount = 4
        let rotation = -90.0

        // When
        let index = WheelMath.landingSector(rotation: rotation, sectorCount: sectorCount)

        // Then
        XCTAssertEqual(index, 3)  // -90 is equivalent to 270
    }

    // MARK: - Sector Angle Tests

    func test_sectorAngle_with4Sectors_returns90Degrees() {
        // When
        let angle = WheelMath.sectorAngle(sectorCount: 4)

        // Then
        XCTAssertEqual(angle, 90.0, accuracy: 0.001)
    }

    func test_sectorAngle_with8Sectors_returns45Degrees() {
        // When
        let angle = WheelMath.sectorAngle(sectorCount: 8)

        // Then
        XCTAssertEqual(angle, 45.0, accuracy: 0.001)
    }

    // MARK: - Performance Tests

    func test_landingSector_performance() {
        measure {
            for rotation in stride(from: 0.0, to: 3600.0, by: 1.0) {
                _ = WheelMath.landingSector(rotation: rotation, sectorCount: 8)
            }
        }
    }
}
