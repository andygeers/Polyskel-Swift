// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "Polyskel",
    products: [
        .library(name: "Polyskel", targets: ["Polyskel"]),
    ],
    dependencies: [
        .package(url: "https://github.com/nicklockwood/Euclid.git", .upToNextMinor(from: "0.8.15")),
    ],
    targets: [
        .target(
            name: "Polyskel",
            dependencies: ["Euclid"],
            path: "Polyskel/Classes"
        ),
        .testTarget(
            name: "PolyskelTests",
            dependencies: ["Polyskel", "Euclid"],
            path: "Tests/PolyskelTests"
        ),
    ]
)
