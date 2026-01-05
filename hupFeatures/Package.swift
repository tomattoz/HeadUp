// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "hupFeatures",
    platforms: [
        .iOS(.v15), .macOS(.v13),
    ],
    products: [
        .library(name: "hupUtils", targets: ["hupUtils"]),
        .library(name: "hupSwitUI", targets: ["hupSwitUI"]),
        .library(name: "hupShared", targets: ["hupShared"]),
        .library(name: "hupApplicationsList", targets: ["hupApplicationsList"]),
        .library(name: "hupSplitView", targets: ["hupSplitView"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", branch: "main"),
    ],
    targets: [
        .target(
            name: "hupSwitUI",
        ),
        .target(
            name: "hupUtils",
        ),
        .target(
            name: "hupShared",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]),
        .target(
            name: "hupApplicationsList",
            dependencies: [
                "hupShared",
                "hupUtils",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]),
        .target(
            name: "hupApplicationDetails",
            dependencies: [
                "hupSwitUI",
                "hupShared",
                "hupUtils",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]),
        .target(
            name: "hupSplitView",
            dependencies: [
                "hupUtils",
                "hupShared",
                "hupApplicationsList",
                "hupApplicationDetails",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]),
    ]
)
