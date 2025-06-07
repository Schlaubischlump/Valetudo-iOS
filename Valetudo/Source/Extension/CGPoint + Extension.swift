//
//  CGSize + Extension.swift
//  Valetudo
//
//  Created by David Klopp on 15.05.25.
//
import CoreGraphics

extension CGPoint {    
    func scaleBy(x: CGFloat, y: CGFloat) -> CGPoint {
        return CGPoint(x: self.x * x, y: self.y * y)
    }
    
    func downScaledBy(x: CGFloat, y: CGFloat) -> CGPoint {
        return CGPoint(x: self.x / x, y: self.y / y)
    }
    
    func insetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: self.x - dx, y: self.y - dy)
    }
}
