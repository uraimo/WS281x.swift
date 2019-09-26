// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "TestWS281x",
    dependencies: [
        .package(url: "https://github.com/uraimo/SwiftyGPIO.git", from: "1.0.0"),
        .package(url: "https://github.com/uraimo/WS281x.swift.git",from: "2.0.0")
    ],
    targets: [
        .target(name: "TestWS281x", 
                dependencies: ["SwiftyGPIO","WS281x"],
                path: "Sources")
    ]
) 