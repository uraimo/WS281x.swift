import PackageDescription

let package = Package(
    name: "TestWS2812",
    targets: [],
    dependencies: [
        .Package(url: "https://github.com/uraimo/WS281x.swift.git",
                 majorVersion: 1)
    ]
)
