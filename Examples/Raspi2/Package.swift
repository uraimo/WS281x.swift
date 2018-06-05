import PackageDescription

let package = Package(
    name: "TestWS2812",
    dependencies: [
        .Package(url: "https://github.com/uraimo/WS281x.swift.git",
                 majorVersion: 2)
    ]
)
