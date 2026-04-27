//
//  CGColor+Extension.swift
//  Valetudo
//
//  Created by David Klopp on 14.05.25.
//
import CoreGraphics

private let scatterPrime: Int = 41

private extension String {
    func stableHashValue() -> UInt64 {
        var hash: UInt64 = 0x6A09_E667_F3BC_C908 // FNV offset basis
        let prime: UInt64 = 0x100_0000_01B3 // FNV prime
        for byte in utf8 {
            hash ^= UInt64(byte)
            hash = hash &* prime
        }
        return hash
    }
}

extension CGColor {
    static var black: CGColor {
        CGColor(red: 0, green: 0, blue: 0, alpha: 1.0)
    }

    static var lightGray: CGColor {
        CGColor(gray: 0.3, alpha: 1.0)
    }

    static var white: CGColor {
        CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }

    static var blue: CGColor {
        CGColor(red: 0, green: 122.0 / 255.0, blue: 1.0, alpha: 1.0)
    }

    static var yellow: CGColor {
        CGColor(red: 1.0, green: 0.58, blue: 0.0, alpha: 1.0)
    }

    /* static func from(hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) -> CGColor {
         let i = Int(hue * 6)
         let f = hue * 6 - CGFloat(i)
         let p = brightness * (1 - saturation)
         let q = brightness * (1 - f * saturation)
         let t = brightness * (1 - (1 - f) * saturation)
         let (r, g, b) = switch i % 6 {
         case 0: (brightness, t, p)
         case 1: (q, brightness, p)
         case 2: (p, brightness, t)
         case 3: (p, q, brightness)
         case 4: (t, p, brightness)
         case 5: (brightness, p, q)
         default: (brightness, brightness, brightness)
         }
         return CGColor(red: r, green: g, blue: b, alpha: alpha)
     }

     static func from(text: String) -> CGColor {
         let hashValue = text.stableHashValue()
         return from(number: Int(hashValue % 360))
     }

     static func from(number: Int) -> CGColor {
         let hue = CGFloat(((number % 360) * scatterPrime) % 360) / 360.0
         let saturation: CGFloat = 0.7
         let brightness: CGFloat = 0.9
         return CGColor.from(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
     } */

    func inverted() -> CGColor {
        guard let rgbColor = converted(to: CGColorSpace(name: CGColorSpace.sRGB)!,
                                       intent: .defaultIntent,
                                       options: nil),
            let components = rgbColor.components,
            components.count >= 3
        else {
            return self
        }

        let r = 1.0 - components[0]
        let g = 1.0 - components[1]
        let b = 1.0 - components[2]
        let a = components.count >= 4 ? components[3] : 1.0

        return CGColor(red: r, green: g, blue: b, alpha: a)
    }

    func lighter(by percentage: CGFloat) -> CGColor {
        adjustBrightness(percentage: abs(percentage), towardWhite: true)
    }

    func darker(by percentage: CGFloat) -> CGColor {
        adjustBrightness(percentage: abs(percentage), towardWhite: false)
    }

    private func adjustBrightness(percentage: CGFloat, towardWhite: Bool) -> CGColor {
        guard let rgbColor = converted(to: CGColorSpace(name: CGColorSpace.sRGB)!,
                                       intent: .defaultIntent,
                                       options: nil),
            let components = rgbColor.components,
            components.count >= 3
        else {
            return self
        }

        let r = interpolate(components[0], toward: towardWhite ? 1.0 : 0.0, by: percentage)
        let g = interpolate(components[1], toward: towardWhite ? 1.0 : 0.0, by: percentage)
        let b = interpolate(components[2], toward: towardWhite ? 1.0 : 0.0, by: percentage)
        let a = components.count >= 4 ? components[3] : 1.0

        return CGColor(red: r, green: g, blue: b, alpha: a)
    }

    private func interpolate(_ value: CGFloat, toward target: CGFloat, by percentage: CGFloat) -> CGFloat {
        value + (target - value) * clamp(percentage)
    }

    private func clamp(_ value: CGFloat) -> CGFloat {
        max(0.0, min(1.0, value))
    }
}
