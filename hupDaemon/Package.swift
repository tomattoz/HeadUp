// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "hupDaemon",
    platforms: [
        .iOS(.v15), .macOS(.v13),
    ],
    products: [
        .library(name: "hupDaemon", targets: ["hupDaemon"])
    ],
    dependencies: [
        .package(path: "../hupCommon"),
    ],
    targets: [
        .target(
            name: "hupDaemon",
            dependencies: [
                .product(name: "hupCommon", package: "hupCommon"),
            ]),
    ]
)
