// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BikeWorkoutHealthKitMac",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "BikeWorkoutHealthKitMac", targets: ["BikeWorkoutHealthKitMac"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "BikeWorkoutHealthKitMac",
            dependencies: [],
            path: "Sources"
        )
    ]
)
