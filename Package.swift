// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

private let modules = [
    "AppRoot",
    "XCTestDebugSupport"
]

let package = Package(
    name: "starling-ios",
    platforms: [
        .iOS("16.4.0"),
        .macOS(.v13),
    ],
    products: modules.map {
        .library(name: $0, targets: [$0])
    },
    dependencies: [
        .package(url: "https://github.com/oliverfoggin/swift-composable-subscriber", .upToNextMajor(from: "1.0.4")),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", .upToNextMajor(from: "1.6.0")),
        .package(url: "https://github.com/pointfreeco/swift-tagged", from: "0.6.0"),
        .package(url: "https://github.com/pointfreeco/swift-url-routing.git", from: "0.5.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AppRoot",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .testTarget(
            name: "AppRootTests",
            dependencies: ["AppRoot"]
        ),
        .target(name: "XCTestDebugSupport"),
    ]
)
