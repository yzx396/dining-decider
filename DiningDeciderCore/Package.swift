// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DiningDeciderCore",
    platforms: [
        .macOS(.v13),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "DiningDeciderCore",
            targets: ["DiningDeciderCore"]),
    ],
    targets: [
        .target(
            name: "DiningDeciderCore",
            dependencies: []),
        .testTarget(
            name: "DiningDeciderCoreTests",
            dependencies: ["DiningDeciderCore"]),
    ]
)
