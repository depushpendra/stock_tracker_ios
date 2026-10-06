// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "TestSupport",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "TestSupport", targets: ["TestSupport"]),
    ],
    dependencies: [
        .package(path: "../Domain"),
        .package(path: "../Core"),
    ],
    targets: [
        .target(
            name: "TestSupport",
            dependencies: [
                "Domain",
                "Core",
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
