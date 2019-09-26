// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "WS281x",
    products: [
        .library(
            name: "WS281x",
            targets: ["WS281x"]),
    ],
    dependencies: [
        .package(url: "https://github.com/uraimo/SwiftyGPIO.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "WS281x",
            dependencies: ["SwiftyGPIO"],
            path: ".",
            sources: ["Sources"])
    ]
)