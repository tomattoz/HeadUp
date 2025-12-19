// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "hupCommon",
    platforms: [
        .iOS(.v15), .macOS(.v13)
    ],
    products: [
        .library(name: "hupCommon", targets: ["hupCommon"])
    ],
    targets: [
        .target(name: "hupCommon")
    ]
)
