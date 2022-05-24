// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ZLSwipeableViewSwift",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "ZLSwipeableViewSwift",
            targets: ["ZLSwipeableViewSwift"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ZLSwipeableViewSwift",
            dependencies: [],
            path: "ZLSwipeableViewSwift",
            exclude: ["Info.plist"]
        ),
    ]
)
