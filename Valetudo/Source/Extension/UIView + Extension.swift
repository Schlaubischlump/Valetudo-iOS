//
//  UIView + Extension.swift
//  Valetudo
//
//  Created by David Klopp on 05.09.25.
//
import UIKit

extension UIView {
    func updateBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        let supportedEdges: [(UIRectEdge, String)] = [
            (.top, "topBorder"),
            (.bottom, "bottomBorder"),
            (.left, "leftBorder"),
            (.right, "rightBorder"),
        ]

        for (supportedEdge, borderName) in supportedEdges {
            guard edge.contains(supportedEdge) else { continue }

            let existingBorder = layer.sublayers?.first(where: { $0.name == borderName })

            let frame: CGRect = switch supportedEdge {
            case .top: CGRect(x: 0, y: 0, width: bounds.width, height: thickness)
            case .bottom: CGRect(x: 0, y: bounds.height - thickness, width: bounds.width, height: thickness)
            case .left: CGRect(x: 0, y: 0, width: thickness, height: bounds.height)
            case .right: CGRect(x: bounds.width - thickness, y: 0, width: thickness, height: bounds.height)
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

    /// Recursively searches the superview hierarchy for a UICollectionView
    var enclosingCollectionView: UICollectionView? {
        var view: UIView? = self
        while let current = view {
            if let collectionView = current as? UICollectionView {
                return collectionView
            }
            view = current.superview
        }
        return nil
    }
}
