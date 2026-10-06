// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "DesignSystem",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "DesignSystem", targets: ["DesignSystem"]),
    ],
    dependencies: [
        .package(path: "../Localization"),
        .package(path: "../Core"),
        .package(path: "../Domain"),
    ],
    targets: [
        .target(
            name: "DesignSystem",
            dependencies: [
                "Localization",
                "Core",
                "Domain",
            ],
            resources: [.process("Resources")]
        ),
    ]
)
