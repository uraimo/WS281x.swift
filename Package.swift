import PackageDescription

let package = Package(
    name: "WS281X",
    targets: [],
    dependencies: [
        .Package(url: "https://github.com/uraimo/SwiftyGPIO.git",
                 majorVersion: 0)
    ]
)
