// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Localization",
    defaultLocalization: "en",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "Localization", targets: ["Localization"]),
    ],
    targets: [
        .target(
            name: "Localization",
            resources: [.process("Resources")]
        ),
    ]
)
