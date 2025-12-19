// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "hupUI",
    platforms: [
        .iOS(.v15), .macOS(.v13),
    ],
    products: [
        .library(name: "hupUI", targets: ["hupUI"])
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", branch: "main"),
        .package(path: "../hupCommon"),
    ],
    targets: [
        .target(
            name: "hupUI",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "hupCommon", package: "hupCommon"),
            ]),
    ]
)
