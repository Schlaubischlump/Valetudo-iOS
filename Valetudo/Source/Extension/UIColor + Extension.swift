//
//  UIColor + Extension.swift
//  Valetudo
//
//  Created by David Klopp on 03.06.25.
//
import UIKit

extension UIColor {
    func darker(by percentage: CGFloat) -> UIColor {
        UIColor(cgColor: self.cgColor.darker(by: percentage))
    }
    
    func lighter(by percentage: CGFloat) -> UIColor {
        UIColor(cgColor: self.cgColor.lighter(by: percentage))
    }
    
    func inverted() -> UIColor {
        UIColor(cgColor: self.cgColor.inverted())
    }
}
