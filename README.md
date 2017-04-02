![WS281x](https://github.com/uraimo/WS281x.swift/raw/master/logo.png)
##WS281x.swift

*A Swift library for WS2812x (WS2811,WS2812,WS2812B) RGB led strips, rings, sticks, matrixes, etc...*

<p>
<img src="https://img.shields.io/badge/os-linux-green.svg?style=flat" alt="Linux-only" />
<a href="https://developer.apple.com/swift"><img src="https://img.shields.io/badge/swift3-compatible-4BC51D.svg?style=flat" alt="Swift 3 compatible" /></a>
<a href="https://raw.githubusercontent.com/uraimo/5110lcd_pcd8544.swift/master/LICENSE"><img src="http://img.shields.io/badge/license-BSD-blue.svg?style=flat" alt="License: BSD" /></a>
</p>
 

# Summary

This simple library read the values produced by the MCP3008 10 bits SPI-driven ADC. This components is able to convert analogical signal (with a voltage range defined by Vref, most of the time you'll put Vref and Vdd to 5V) to an integer value between 0 and 1023. This kind of component is extremely useful for example for boards like the RaspberryPis that don't have their own analog input pins like an Arduino.

![MCP3008 diagram](https://github.com/uraimo/MCP3008.swift/raw/master/mcp3008.png)

## Supported Boards

Every board supported by [SwiftyGPIO](https://github.com/uraimo/SwiftyGPIO): RaspberryPis, BeagleBones, C.H.I.P., etc...

To use this library, you'll need a Linux ARM board with Swift 3.x.

The example below will use a RaspberryPi 2 board but you can easily modify the example to use one the the other supported boards, a full working demo projects for the RaspberryPi2 is available in the `Examples` directory.

## Usage

The first thing we need to do is to obtain an instance of `SPIOutput` from SwiftyGPIO and use it to initialize the `MCP3008` object:

```swift
import SwiftyGPIO
import MCP3008

let spis = SwiftyGPIO.hardwareSPIs(for:.RaspberryPi2)!
let spi = spis[0]
let m = MCP3008(spi)
```

Then use `readValue` to read the current converted value (0...1023) from one of the analog inputs:

```swift
m.readValue(0) //CH0 pin
```

## Installation

Please refer to the [SwiftyGPIO](https://github.com/uraimo/SwiftyGPIO) readme for Swift installation instructions.

Once your board runs Swift, if your version support the Swift Package Manager, you can simply add this library as a dependency of your project and compile with `swift build`:

```swift
  let package = Package(
      name: "MyProject",
      dependencies: [
    .Package(url: "https://github.com/uraimo/MCP3008.swift.git", majorVersion: 1),
    ...
      ]
      ...
  ) 
```

The directory `Examples` contains sample projects that uses SPM, compile it and run the sample with `./.build/debug/TestMCP`.

If SPM is not supported, you'll need to manually download the library and its dependencies: 

    wget https://raw.githubusercontent.com/uraimo/MCP3008.swift/master/Sources/MCP3008.swift https://raw.githubusercontent.com/uraimo/SwiftyGPIO/master/Sources/SwiftyGPIO.swift https://raw.githubusercontent.com/uraimo/SwiftyGPIO/master/Sources/Presets.swift https://raw.githubusercontent.com/uraimo/SwiftyGPIO/master/Sources/SPI.swift https://raw.githubusercontent.com/uraimo/SwiftyGPIO/master/Sources/SunXi.swift  

And once all the files have been downloaded, create an additional file that will contain the code of your application (e.g. main.swift). When your code is ready, compile it with:

    swiftc *.swift

The compiler will create a **main** executable.

