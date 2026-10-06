// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Bootstrap",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "Bootstrap", targets: ["Bootstrap"]),
    ],
    dependencies: [
        .package(path: "../Domain"),
        .package(path: "../Core"),
        .package(path: "../Data"),
        .package(path: "../Features"),
    ],
    targets: [
        .target(
            name: "Bootstrap",
            dependencies: [
                "Domain",
                "Core",
                "Data",
                "Features",
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
