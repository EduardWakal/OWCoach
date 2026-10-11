// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "OWCoachKit",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [
        .library(name: "OWCoachKit", targets: ["OWCoachKit"]),
    ],
    targets: [
        .target(name: "OWCoachKit"),
        .testTarget(
            name: "OWCoachKitTests",
            dependencies: ["OWCoachKit"],
            resources: [.copy("Fixtures")]
        ),
    ]
)
