// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Core",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "Core", targets: ["Core"]),
    ],
    dependencies: [
        .package(path: "../Domain"),
    ],
    targets: [
        .target(
            name: "Core",
            dependencies: ["Domain"],
            swiftSettings: strictConcurrencySettings
        ),
        .testTarget(
            name: "CoreTests",
            dependencies: ["Core"],
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
