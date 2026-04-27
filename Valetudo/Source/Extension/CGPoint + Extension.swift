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

    func insetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
        CGPoint(x: x - dx, y: y - dy)
    }
}
