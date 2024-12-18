// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ElasticApmWrapper",
    products: [
        .library(
            name: "ElasticApmWrapper",
            targets: ["ElasticApmWrapper"]),
    ],
    targets: [
        .binaryTarget(
            name: "ElasticApmWrapper",
            path: "Frameworks/ElasticApmWrapper.xcframework"
        )
    ]
)
