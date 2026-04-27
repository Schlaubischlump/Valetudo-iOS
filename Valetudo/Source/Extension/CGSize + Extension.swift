//
//  CGSize + Extension.swift
//  Valetudo
//
//  Created by David Klopp on 15.05.25.
//
import CoreGraphics

extension CGSize {
    static var one: CGSize {
        CGSize(width: 1, height: 1)
    }

    func scaleBy(x: CGFloat, y: CGFloat) -> CGSize {
        CGSize(width: width * x, height: height * y)
    }

    func insetBy(dx: CGFloat, dy: CGFloat) -> CGSize {
        CGSize(width: width - dx, height: height - dy)
    }
}
