// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "IntegraLiveSwift",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        // Command-line demo (can be built with swift build)
        .executable(
            name: "integra-demo",
            targets: ["IntegraLiveDemo"]
        ),
        // Library containing core models and logic
        .library(
            name: "IntegraLiveCore",
            targets: ["IntegraLiveCore"]
        ),
    ],
    dependencies: [
        // Add any dependencies here in the future
    ],
    targets: [
        // Core library with models and session management
        .target(
            name: "IntegraLiveCore",
            dependencies: [],
            path: "Sources/IntegraLiveCore"
        ),
        // Command-line demo executable
        .executableTarget(
            name: "IntegraLiveDemo",
            dependencies: ["IntegraLiveCore"],
            path: "Sources/IntegraLiveDemo"
        ),
        // Tests
        .testTarget(
            name: "IntegraLiveCoreTests",
            dependencies: ["IntegraLiveCore"],
            path: "Tests/IntegraLiveCoreTests"
        ),
    ]
)

// Note: The SwiftUI GUI app (IntegraLiveSwift) must be built with Xcode
// as it requires the macOS SDK. Open the package in Xcode to build the GUI.
