//
//  UIColor + Extension.swift
//  Valetudo
//
//  Created by David Klopp on 03.06.25.
//
import UIKit

extension UIColor {
    func darker(by percentage: CGFloat) -> UIColor {
        UIColor(cgColor: cgColor.darker(by: percentage))
    }

    func lighter(by percentage: CGFloat) -> UIColor {
        UIColor(cgColor: cgColor.lighter(by: percentage))
    }

    func inverted() -> UIColor {
        UIColor(cgColor: cgColor.inverted())
    }

    static let vtGreen: UIColor = .init(red: 149 / 255.0, green: 189 / 255.0, blue: 94 / 255.0, alpha: 1.00)
    static let vtTurquoise: UIColor = .init(red: 97 / 255.0, green: 157 / 255.0, blue: 159 / 255.0, alpha: 1.00)
    static let vtRed: UIColor = .init(red: 193 / 255.0, green: 101 / 255.0, blue: 59 / 255.0, alpha: 1.00)
    static let vtPurple: UIColor = .init(red: 140 / 255.0, green: 106 / 255.0, blue: 192 / 255.0, alpha: 1.00)
    static let vtBlue: UIColor = .init(red: 179 / 255.0, green: 200 / 255.0, blue: 231 / 255.0, alpha: 1.00)
}
