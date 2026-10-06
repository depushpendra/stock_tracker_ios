// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Data",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "Data", targets: ["Data"]),
    ],
    dependencies: [
        .package(path: "../Domain"),
        .package(path: "../Core"),
        .package(path: "../TestSupport"),
    ],
    targets: [
        .target(
            name: "Data",
            dependencies: [
                "Domain",
                "Core",
            ],
            resources: [.process("Resources")],
            swiftSettings: strictConcurrencySettings
        ),
        .testTarget(
            name: "DataTests",
            dependencies: [
                "Data",
                "Core",
                "Domain",
                "TestSupport",
            ],
            swiftSettings: strictConcurrencySettings
        ),
    ]
)

private var strictConcurrencySettings: [SwiftSetting] {
    [
        .swiftLanguageMode(.v6),
        .enableUpcomingFeature("StrictConcurrency"),
    ]
}
