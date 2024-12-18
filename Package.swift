// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ElasticApmWrapper",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "ElasticApmWrapper",
            type: .dynamic,
            targets: ["ElasticApmWrapper"]),
    ],
    dependencies:[
        .package(name: "apm-agent-ios", url: "https://github.com/elastic/apm-agent-ios.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "ElasticApmWrapper",
            dependencies: [
                .product(name: "ElasticApm", package: "apm-agent-ios")
            ]
        ),
    ]
)
