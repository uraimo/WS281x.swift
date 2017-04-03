import SwiftyGPIO
import WS281x
import Glibc
import Foundation


///////////////////////////////////////////////////////////////////////////////////////////////////
///
/// Swift Xoroshiro random generator by @cocoawithlove
/// From: https://github.com/mattgallagher/CwlUtils/blob/master/Sources/CwlUtils/CwlRandom.swift

public struct DevRandom {
    class FileDescriptor {
        let value: CInt
        init() {
            value = open("/dev/urandom", O_RDONLY)
            precondition(value >= 0)
        }
        deinit {
            close(value)
        }
    }
    
    let fd: FileDescriptor
    public init() {
        fd = FileDescriptor()
    }
    
    public mutating func randomize(buffer: UnsafeMutableRawPointer, size: Int) {
        let result = read(fd.value, buffer, size)
        precondition(result == size)
    }
    
    public static func randomize(buffer: UnsafeMutableRawPointer, size: Int) {
        var r = DevRandom()
        r.randomize(buffer: buffer, size: size)
    }
}

public struct Xoroshiro {
    public typealias WordType = UInt64
    public typealias StateType = (UInt64, UInt64)

    var state: StateType = (0, 0)

    public init() {
        DevRandom.randomize(buffer: &state, size: MemoryLayout<StateType>.size)
    }
    
    public init(seed: StateType) {
        self.state = seed
    }
    
    public mutating func random64() -> UInt64 {
        return randomWord()
    }

    public mutating func randomWord() -> UInt64 {
        // Directly inspired by public domain implementation here:
        // http://xoroshiro.di.unimi.it
        // by David Blackman and Sebastiano Vigna
        let (l, k0, k1, k2): (UInt64, UInt64, UInt64, UInt64) = (64, 55, 14, 36)
        
        let result = state.0 &+ state.1
        let x = state.0 ^ state.1
        state.0 = ((state.0 << k0) | (state.0 >> (l - k0))) ^ x ^ (x << k1)
        state.1 = (x << k2) | (x >> (l - k2))
        return result
    }
}

var xoro = Xoroshiro()

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
////
////                                     Matrix effects
////

func ledsRandom(_ values: [UInt32]) -> [UInt32] {
    var values = values
    for i in 0..<values.count {
        let r = UInt32(xoro.random64() % 254 + 1)
        let g = UInt32(xoro.random64() % 254 + 1)
        let b = UInt32(xoro.random64() % 254 + 1)
        values[i] = (r<<16) + (g<<8) + b // R-G-B
    }
    return values
}

func ledsSnake(_ values: [UInt32]) -> [UInt32] {
    var values = values
    values[0] = 0x006060
    values[1] = 0x004040
    values[2] = 0x002020
    values[3] = 0x000020
    values[4] = 0x000020
    values[5] = 0x000020
    return values
}

func scroll(_ values: [UInt32]) -> [UInt32] {
    var arr = Array(values[1..<values.count])
    arr.append(values[0])
    return arr
}

func ledsCosine(_ values: [UInt32], width: Int, time: Int) -> [UInt32] {
    var values = values
    for i in 0..<values.count {
        let center = Double(width/2) * 0.9
        let scale = 1.0 // Bigger = smaller period
        var ix = Double(i%width) - center
        ix *= scale
        var iy = Double(i/width) - center
        iy *= scale
        let cosarg = (sqrt(ix*ix+iy*iy) - Double(time))
        values[i] = UInt32( (cos(cosarg) + 1) * 100 + 10)
    }
    return values
}

func ledsRipple(_ values: [UInt32], width: Int, time: Int) -> [UInt32] {
    var values = values
    let time = time % 50 // Repeat every 50 frames
    for i in 0..<values.count {
        let center = Double(width/2) * 0.9
        let scale = 3.5 //Bigger = smaller initial drop and thinner ripple
        var ix = Double(i%width) - center
        ix *= scale
        var iy = Double(i/width) - center
        iy *= scale
        let timeDiv = 0.7 //Smaller = slower
        let cosarg = (sqrt(ix*ix+iy*iy) - Double(time)*timeDiv)
        // Use the cardinal sine function sinc(x) -> sin(x)/x [0.2,1]
        values[i] = UInt32( sin(cosarg)/cosarg * 180 + 50)
    }
    return values
}


func ledsRainbow(_ values: [UInt32], width: Int, time: Int) -> [UInt32] {
    let colors:[UInt32] = [0x200000,0x201000,0x202000,0x002000,0x002020,0x000020,0x100010,0x200010]
    var values = values
    for i in 0..<values.count {
        values[i] = colors[(i%width + time)%colors.count]
    }
    return values
}

///
///
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

// Example that uses a 8x8 matrix with the data pin connected to P18
// If you have a strip you can still use this example, just

let pwms = SwiftyGPIO.hardwarePWMs(for:.RaspberryPi2)!
let pwm = (pwms[0]?[.P18])!

let numberOfLeds = 64
let matrixWidth = 8

let w = WS281x(pwm, 
               type: .WS2812B,
               numElements: numberOfLeds)

var initial = [UInt32](repeating:0x0, count: numberOfLeds)

// Clear
w.setLeds(initial)
w.start()
w.wait()

// Set the 10th led in the sequence (even if it's a matrix will be considered as a strip)
w.setLed(10, r: 0xF0, g: 0, b: 0)

// Let's set pixels with matrix coordinates now, your matrix could be connected differently from these two, do some test setting
// individual pixels with setLed() to understand how the leds are connected or use the snake effect that scrolls through the sequence
// from the beginning to the last element.

// Set the led at (4,4) for matrices where each row starts with the (row-1)*width element in the sequence (Nulsom Rainbow Matrix)
// Es.
//  0  1  2  3
//  4  5  6  7
//  8  9  10 11
//  12 13 14 15
w.setLedAsMatrix(x: 4, y: 4, width: matrixWidth, r: 0, g: 0, b: 0xF0)

// Set the led at (4,4) for matrices where each row is connetted to the last element of the preceding row (Pimoroni UnicornHat)
// Es.
//  3  2  1  0
//  4  5  6  7
//  11 10 9  8
//  12 13 14 15
w.setLedAsSequentialMatrix(x: 5, y: 2, width: matrixWidth, r: 0, g: 0, b: 0xF0)

// Start the transmission that will program the matrix and wait
w.start()
w.wait()
sleep(2)

// Random colors
var leds: [UInt32] = ledsRandom(initial)
for i in 0...100 {
    leds = ledsRandom(leds)
    w.setLeds(leds)
    w.start()
}

// Scrolling rainbow
leds = ledsRainbow(initial, width: matrixWidth, time: 0)
for i in 0...100 {
    w.setLeds(leds)
    w.start()
    leds = ledsRainbow(leds, width: matrixWidth, time: i)
    usleep(50_000)
}

// Snake
leds = ledsSnake(initial)
for i in 0...200 {
    w.setLeds(leds)
    w.start()
    leds = scroll(leds)
}

// 2D Cosine
leds = ledsCosine(initial, width: matrixWidth, time: 0)
for i in 0...200 {
    w.setLeds(leds)
    w.start()
    leds = ledsCosine(leds, width: matrixWidth, time: i)
    usleep(50_000)
}

// 2D ripple effect with sinc function
leds = ledsRipple(initial, width: matrixWidth, time: 0)
for i in 0...200 {
    w.setLeds(leds)
    w.start()
    leds = ledsRipple(leds, width: matrixWidth, time: i)
}

// Clear
w.setLeds(initial)
w.start()
w.wait()

// Final cleanup
w.cleanup()