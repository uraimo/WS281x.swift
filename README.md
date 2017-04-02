![WS281x](https://github.com/uraimo/WS281x.swift/raw/master/logo.png)

*A Swift library for WS2812x (WS2811,WS2812,WS2812B) RGB led strips, rings, sticks, matrixes, etc...*

<p>
<img src="https://img.shields.io/badge/os-linux-green.svg?style=flat" alt="Linux-only" />
<a href="https://developer.apple.com/swift"><img src="https://img.shields.io/badge/swift3-compatible-4BC51D.svg?style=flat" alt="Swift 3 compatible" /></a>
<a href="https://raw.githubusercontent.com/uraimo/5110lcd_pcd8544.swift/master/LICENSE"><img src="http://img.shields.io/badge/license-BSD-blue.svg?style=flat" alt="License: BSD" /></a>
</p>

**Not yet ready, come back in a few days**

<p>
<img src="https://github.com/uraimo/SwiftyGPIO/raw/master/images/led1.gif" />
<img src="https://github.com/uraimo/SwiftyGPIO/raw/master/images/led2.gif" />
<img src="https://github.com/uraimo/SwiftyGPIO/raw/master/images/led3.gif" />
</p>

# Summary

...

## Usage

The first thing we need to do is to obtain an instance of `PWMOutput` from SwiftyGPIO and use it to initialize the `WS281x` object:

```swift
import SwiftyGPIO
import WS281x
```

...

## Supported Boards

Every board supported by [SwiftyGPIO](https://github.com/uraimo/SwiftyGPIO) with pattern-based PWM signal generator, at the moment only RaspberryPis.

To use this library, you'll need Swift 3.x.

The example below will use a RaspberryPi 2 board but you can easily modify the example to use one the the other supported boards, a full working demo projects for the RaspberryPi2 is available in the `Examples` directory.

## Installation

Please refer to the [SwiftyGPIO](https://github.com/uraimo/SwiftyGPIO) readme for Swift installation instructions.

Once your board runs Swift, if your version support the Swift Package Manager, you can simply add this library as a dependency of your project and compile with `swift build`:

```swift
  let package = Package(
      name: "MyProject",
      dependencies: [
    .Package(url: "https://github.com/uraimo/WS281x.swift.git", majorVersion: 1),
    ...
      ]
      ...
  ) 
```

The directory `Examples` contains sample projects that uses SPM, compile it and run the sample with `./.build/debug/TestWS2812B`.

If SPM is not supported, you'll need to manually download the library and its dependencies: 

    wget https://raw.githubusercontent.com/uraimo/WS281x.swift/master/Sources/WS281x.swift https://raw.githubusercontent.com/uraimo/SwiftyGPIO/master/Sources/SwiftyGPIO.swift https://raw.githubusercontent.com/uraimo/SwiftyGPIO/master/Sources/Presets.swift https://raw.githubusercontent.com/uraimo/SwiftyGPIO/master/Sources/PWM.swift https://raw.githubusercontent.com/uraimo/SwiftyGPIO/master/Sources/SunXi.swift  

And once all the files have been downloaded, create an additional file that will contain the code of your application (e.g. main.swift). When your code is ready, compile it with:

    swiftc *.swift

The compiler will create a **main** executable.

