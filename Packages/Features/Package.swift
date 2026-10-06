// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Features",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "Features", targets: ["Features"]),
    ],
    dependencies: [
        .package(path: "../Domain"),
        .package(path: "../Core"),
        .package(path: "../Localization"),
        .package(path: "../DesignSystem"),
        .package(path: "../TestSupport"),
    ],
    targets: [
        .target(
            name: "Features",
            dependencies: [
                "Domain",
                "Core",
                "Localization",
                "DesignSystem",
            ],
            swiftSettings: strictConcurrencySettings
        ),
        .testTarget(
            name: "FeaturesTests",
            dependencies: [
                "Features",
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
