// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "SwiftDetailer",
    platforms: [.macOS("11.0"), .iOS("14.0")],
    products: [
        .library(name: "Detailer", targets: ["Detailer"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Detailer",
            dependencies: [],
            path: "Sources"
        ),
//        .testTarget(
//            name: "DetailerTests",
//            dependencies: [
//                "Detailer",
//            ],
//            path: "Tests"
//        ),
    ]
)
