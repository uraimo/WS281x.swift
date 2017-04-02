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
    for i in 0..<NUM_ELEMENTS {
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
    for i in 0..<NUM_ELEMENTS {
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
    for i in 0..<NUM_ELEMENTS {
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
    for i in 0..<NUM_ELEMENTS {
        values[i] = colors[(i%width + time)%colors.count]
    }
    return values
}

///
///
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////


let pwms = SwiftyGPIO.hardwarePWMs(for:.RaspberryPi2)!
let pwm = (pwms[0]?[.P18])!


let w = WS281x(pwm: pwm, 
               type: .WS2812B
               numElements: 64,
               frequency: 800_000,
               resetDelay: 55)

var initial = [UInt32](repeating:0x0, count: 64)

//Clear
w.setLeds(initial)
w.start()
w.wait()


var leds: [UInt32] = ledsRandom(initial)
for i in 0...100 {
    leds = ledsRandom(leds)
    w.setLeds(leds)
    w.start()
}

leds = ledsRainbow(initial, width: 8, time: 0)
for i in 0...100 {
    w.setLeds(leds)
    w.start()
    leds = ledsRainbow(leds, width: 8, time: i)
    usleep(50_000)
}

leds = ledsSnake(initial)
for i in 0...200 {
    w.setLeds(leds)
    w.start()
    leds = scroll(leds)
}

leds = ledsCosine(initial, width: 8, time: 0)
for i in 0...200 {
    w.setLeds(leds)
    w.start()
    leds = ledsCosine(leds, width: 8, time: i)
    usleep(50_000)
}

leds = ledsRipple(initial, width: 8, time: 0)
for i in 0...200 {
    w.setLeds(leds)
    w.start()
    leds = ledsRipple(leds, width: 8, time: i)
}

//Clear
w.setLeds(initial)
w.start()
w.wait()


w.cleanup()