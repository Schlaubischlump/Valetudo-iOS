//
//  CGSize + Extension.swift
//  Valetudo
//
//  Created by David Klopp on 15.05.25.
//
import CoreGraphics

extension CGSize {
    static var one : CGSize {
        return CGSize(width: 1, height: 1)
    }
    
    func scaleBy(x: CGFloat, y: CGFloat) -> CGSize {
        return CGSize(width: self.width * x, height: self.height * y)
    }

    func insetBy(dx: CGFloat, dy: CGFloat) -> CGSize {
        return CGSize(width: self.width - dx, height: self.height - dy)
    }
}
