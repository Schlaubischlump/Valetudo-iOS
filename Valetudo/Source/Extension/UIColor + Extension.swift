//
//  UIColor + Extension.swift
//  Valetudo
//
//  Created by David Klopp on 03.06.25.
//
import UIKit

extension UIColor {
    static let vtGreen: UIColor = .init(red: 149 / 255.0, green: 189 / 255.0, blue: 94 / 255.0, alpha: 1.00)
    static let vtTurquoise: UIColor = .init(red: 97 / 255.0, green: 157 / 255.0, blue: 159 / 255.0, alpha: 1.00)
    static let vtRed: UIColor = .init(red: 193 / 255.0, green: 101 / 255.0, blue: 59 / 255.0, alpha: 1.00)
    static let vtPurple: UIColor = .init(red: 140 / 255.0, green: 106 / 255.0, blue: 192 / 255.0, alpha: 1.00)
    static let vtBlue: UIColor = .init(red: 179 / 255.0, green: 200 / 255.0, blue: 231 / 255.0, alpha: 1.00)
    
    func darker(by percentage: CGFloat) -> UIColor {
        UIColor(cgColor: cgColor.darker(by: percentage))
    }

    func lighter(by percentage: CGFloat) -> UIColor {
        UIColor(cgColor: cgColor.lighter(by: percentage))
    }

    func inverted() -> UIColor {
        UIColor(cgColor: cgColor.inverted())
    }
        
    static let macOSCellBackground: UIColor = UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 37.0/255.0, green: 38.0/255.0, blue: 42.0/255.0, alpha: 1.0)
            : UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
    }
    
    static let macOSGroupedBackground: UIColor = UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 30.0/255.0, green: 31.0/255.0, blue: 36.0/255.0, alpha: 1.0)
            : .systemBackground
    }
    
    static var adaptiveGroupedBackground: UIColor {
        #if targetEnvironment(macCatalyst)
        .macOSGroupedBackground
        #else
        .systemGroupedBackground
        #endif
    }
}
