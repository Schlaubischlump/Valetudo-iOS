//
//  CGColor+Extension.swift
//  Valetudo
//
//  Created by David Klopp on 14.05.25.
//
import CoreGraphics

private let scatterPrime: Int = 41

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
