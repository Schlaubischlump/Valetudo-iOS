//
//  CGSize + Extension.swift
//  Valetudo
//
//  Created by David Klopp on 15.05.25.
//
import CoreGraphics

extension CGPoint {
    func scaleBy(x: CGFloat, y: CGFloat) -> CGPoint {
        CGPoint(x: self.x * x, y: self.y * y)
    }

    func downScaledBy(x: CGFloat, y: CGFloat) -> CGPoint {
        CGPoint(x: self.x / x, y: self.y / y)
    }

    func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
        CGPoint(x: x + dx, y: y + dy)
    }

    func distance(to other: CGPoint) -> CGFloat {
        hypot(x - other.x, y - other.y)
    }

    func clamped(to bounds: CGRect?) -> CGPoint {
        guard let bounds else { return self }

        return CGPoint(
            x: min(max(x, bounds.minX), bounds.maxX),
            y: min(max(y, bounds.minY), bounds.maxY)
        )
    }

    func clampedForResize(from origin: CGPoint, minimumSideLength: CGFloat, to bounds: CGRect?) -> CGPoint {
        guard let bounds else { return self }

        return CGPoint(
            x: min(max(x, origin.x + minimumSideLength), bounds.maxX),
            y: min(max(y, origin.y + minimumSideLength), bounds.maxY)
        )
    }

    static func translationToFit(start: CGPoint, end: CGPoint, within bounds: CGRect?) -> CGPoint {
        guard let bounds else { return .zero }

        let minX = min(start.x, end.x)
        let maxX = max(start.x, end.x)
        let minY = min(start.y, end.y)
        let maxY = max(start.y, end.y)

        let dx: CGFloat = if minX < bounds.minX {
            bounds.minX - minX
        } else if maxX > bounds.maxX {
            bounds.maxX - maxX
        } else {
            0
        }

        let dy: CGFloat = if minY < bounds.minY {
            bounds.minY - minY
        } else if maxY > bounds.maxY {
            bounds.maxY - maxY
        } else {
            0
        }

        return CGPoint(x: dx, y: dy)
    }
}
