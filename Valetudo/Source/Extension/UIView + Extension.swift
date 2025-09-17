//
//  UIView + Extension.swift
//  Valetudo
//
//  Created by David Klopp on 05.09.25.
//
import UIKit

extension UIView {
    func updateBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        let borderName: String
        switch edge {
        case .top:    borderName = "topBorder"
        case .bottom: borderName = "bottomBorder"
        case .left:   borderName = "leftBorder"
        case .right:  borderName = "rightBorder"
        default:      return
        }
        
        let existingBorder = layer.sublayers?.first(where: { $0.name == borderName })
        
        let frame: CGRect = switch edge {
            case .top:      CGRect(x: 0, y: 0, width: bounds.width, height: thickness)
            case .bottom:   CGRect(x: 0, y: bounds.height - thickness, width: bounds.width, height: thickness)
            case .left:     CGRect(x: 0, y: 0, width: thickness, height: bounds.height)
            case .right:    CGRect(x: bounds.width - thickness, y: 0, width: thickness, height: bounds.height)
            default: .zero
            }
        
        if let border = existingBorder {
            border.frame = frame
            border.backgroundColor = color.cgColor
        } else {
            let border = CALayer()
            border.name = borderName
            border.backgroundColor = color.cgColor
            border.frame = frame
            layer.addSublayer(border)
        }
    }
}
