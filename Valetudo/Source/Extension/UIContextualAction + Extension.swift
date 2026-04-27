//
//  UIContextualAction + Extension.swift
//  Valetudo
//
//  Created by David Klopp on 19.04.26.
//
import UIKit

extension UIContextualAction {
    convenience init(style: UIContextualAction.Style, title: String, color: UIColor, handler: @escaping UIContextualAction.Handler) {
        self.init(style: style, title: title, handler: handler)
        backgroundColor = color
    }
}
