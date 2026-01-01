import XCTest
@testable import DiningDeciderCore

final class WheelSectorDataTests: XCTestCase {

    // MARK: - Initialization Tests

    func test_wheelSectorData_canBeInitialized() {
        let sector = WheelSectorData(label: "Rooftop", colorHex: "E6B0AA")
        XCTAssertEqual(sector.label, "Rooftop")
        XCTAssertEqual(sector.colorHex, "E6B0AA")
    }

    func test_wheelSectorData_hasUniqueId() {
        let sector1 = WheelSectorData(label: "Test", colorHex: "FFFFFF")
        let sector2 = WheelSectorData(label: "Test", colorHex: "FFFFFF")
        XCTAssertNotEqual(sector1.id, sector2.id)
    }

    func test_wheelSectorData_canUseCustomId() {
        let customId = UUID()
        let sector = WheelSectorData(id: customId, label: "Test", colorHex: "FFFFFF")
        XCTAssertEqual(sector.id, customId)
    }

    // MARK: - Aesthetic Sectors Tests

    func test_aestheticSectors_hasCorrectCount() {
        let sectors = WheelSectorData.aestheticSectors
        XCTAssertEqual(sectors.count, 8)
    }

    func test_aestheticSectors_containsExpectedLabels() {
        let sectors = WheelSectorData.aestheticSectors
        let labels = sectors.map { $0.label }
        XCTAssertTrue(labels.contains("Garden Cafe"))
        XCTAssertTrue(labels.contains("Floral Brunch"))
        XCTAssertTrue(labels.contains("Rooftop"))
        XCTAssertTrue(labels.contains("Tea Room"))
    }

    func test_aestheticSectors_usesAestheticWheelColors() {
        let sectors = WheelSectorData.aestheticSectors
        let hexes = sectors.map { $0.colorHex }
        let expectedHexes = ThemeColorValues.aestheticWheelColors
        XCTAssertEqual(hexes, expectedHexes)
    }

    // MARK: - Splurge Sectors Tests

    func test_splurgeSectors_hasCorrectCount() {
        let sectors = WheelSectorData.splurgeSectors
        XCTAssertEqual(sectors.count, 6)
    }

    func test_splurgeSectors_containsExpectedLabels() {
        let sectors = WheelSectorData.splurgeSectors
        let labels = sectors.map { $0.label }
        XCTAssertTrue(labels.contains("Seafood"))
        XCTAssertTrue(labels.contains("Steakhouse"))
        XCTAssertTrue(labels.contains("Omakase"))
        XCTAssertTrue(labels.contains("Fine Dining"))
    }

    func test_splurgeSectors_usesSplurgeWheelColors() {
        let sectors = WheelSectorData.splurgeSectors
        let hexes = sectors.map { $0.colorHex }
        let expectedHexes = ThemeColorValues.splurgeWheelColors
        XCTAssertEqual(hexes, expectedHexes)
    }

    // MARK: - Standard Sectors Tests

    func test_standardSectors_hasCorrectCount() {
        let sectors = WheelSectorData.standardSectors
        XCTAssertEqual(sectors.count, 8)
    }

    func test_standardSectors_containsExpectedLabels() {
        let sectors = WheelSectorData.standardSectors
        let labels = sectors.map { $0.label }
        XCTAssertTrue(labels.contains("Hot Pot"))
        XCTAssertTrue(labels.contains("Noodles"))
        XCTAssertTrue(labels.contains("Korean BBQ"))
        XCTAssertTrue(labels.contains("Dim Sum"))
    }

    func test_standardSectors_usesStandardWheelColors() {
        let sectors = WheelSectorData.standardSectors
        let hexes = sectors.map { $0.colorHex }
        let expectedHexes = ThemeColorValues.standardWheelColors
        XCTAssertEqual(hexes, expectedHexes)
    }

    // MARK: - Factory Method Tests

    func test_sectors_forAesthetic_returnsSameAsAestheticSectors() {
        let factorySectors = WheelSectorData.sectors(for: .aesthetic)
        let staticSectors = WheelSectorData.aestheticSectors
        XCTAssertEqual(factorySectors.count, staticSectors.count)
        for (factory, staticSector) in zip(factorySectors, staticSectors) {
            XCTAssertEqual(factory.label, staticSector.label)
            XCTAssertEqual(factory.colorHex, staticSector.colorHex)
        }
    }

    func test_sectors_forSplurge_returnsSameAsSplurgeSectors() {
        let factorySectors = WheelSectorData.sectors(for: .splurge)
        let staticSectors = WheelSectorData.splurgeSectors
        XCTAssertEqual(factorySectors.count, staticSectors.count)
        for (factory, staticSector) in zip(factorySectors, staticSectors) {
            XCTAssertEqual(factory.label, staticSector.label)
            XCTAssertEqual(factory.colorHex, staticSector.colorHex)
        }
    }

    func test_sectors_forStandard_returnsSameAsStandardSectors() {
        let factorySectors = WheelSectorData.sectors(for: .standard)
        let staticSectors = WheelSectorData.standardSectors
        XCTAssertEqual(factorySectors.count, staticSectors.count)
        for (factory, staticSector) in zip(factorySectors, staticSectors) {
            XCTAssertEqual(factory.label, staticSector.label)
            XCTAssertEqual(factory.colorHex, staticSector.colorHex)
        }
    }

    // MARK: - Color Hex Validity Tests

    func test_allSectorColors_areValidHexStrings() {
        let allSectors = WheelSectorData.aestheticSectors +
                        WheelSectorData.splurgeSectors +
                        WheelSectorData.standardSectors

        for sector in allSectors {
            XCTAssertEqual(sector.colorHex.count, 6,
                "\(sector.label) hex '\(sector.colorHex)' should be 6 characters")

            let validHex = sector.colorHex.allSatisfy {
                $0.isHexDigit
            }
            XCTAssertTrue(validHex,
                "\(sector.label) hex '\(sector.colorHex)' should only contain hex digits")
        }
    }

    // MARK: - Equatable Tests

    func test_wheelSectorData_equality() {
        let id = UUID()
        let sector1 = WheelSectorData(id: id, label: "Test", colorHex: "FFFFFF")
        let sector2 = WheelSectorData(id: id, label: "Test", colorHex: "FFFFFF")
        XCTAssertEqual(sector1, sector2)
    }

    func test_wheelSectorData_inequality_differentLabel() {
        let id = UUID()
        let sector1 = WheelSectorData(id: id, label: "Test1", colorHex: "FFFFFF")
        let sector2 = WheelSectorData(id: id, label: "Test2", colorHex: "FFFFFF")
        XCTAssertNotEqual(sector1, sector2)
    }

    func test_wheelSectorData_inequality_differentColor() {
        let id = UUID()
        let sector1 = WheelSectorData(id: id, label: "Test", colorHex: "FFFFFF")
        let sector2 = WheelSectorData(id: id, label: "Test", colorHex: "000000")
        XCTAssertNotEqual(sector1, sector2)
    }
}
