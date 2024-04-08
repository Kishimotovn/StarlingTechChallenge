// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

private let modules = [
    "AppRoot",
    "APIClient",
    "AuthClient",
    "ConfigConstant",
    "DataLoad",
    "XCTestDebugSupport",
]

let package = Package(
    name: "starling-ios",
    platforms: [
        .iOS("17.0"),
        .macOS(.v13),
    ],
    products: modules.map {
        .library(name: $0, targets: [$0])
    },
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", .upToNextMajor(from: "1.9.0"))
    ],
    targets: [
        .target(
            name: "AppRoot",
            dependencies: [
                "DataLoad",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "APIClient",
            dependencies: [
                "AuthClient",
                "ConfigConstant",
                "XCTestDebugSupport",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "AuthClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "ConfigConstant",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "DataLoad",
            dependencies: [
                "APIClient",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .testTarget(
            name: "AppRootTests",
            dependencies: ["AppRoot"]
        ),
        .testTarget(
            name: "DataLoadTests",
            dependencies: ["DataLoad"]
        ),
        .target(name: "XCTestDebugSupport"),
    ]
)
