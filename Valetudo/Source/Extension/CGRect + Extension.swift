//
//  CGSize + Extension.swift
//  Valetudo
//
//  Created by David Klopp on 15.05.25.
//
import CoreGraphics

extension CGRect {
    var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
}
