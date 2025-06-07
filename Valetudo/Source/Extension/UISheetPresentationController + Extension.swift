//
//  UIPresentationController + Detent.swift
//  Valetudo
//
//  Created by David Klopp on 21.05.25.
//
import UIKit

extension UISheetPresentationController.Detent.Identifier {
    static var bottom: UISheetPresentationController.Detent.Identifier {
        UISheetPresentationController.Detent.Identifier("Detent.Bottom")
    }
    
    static var middle: UISheetPresentationController.Detent.Identifier {
        UISheetPresentationController.Detent.Identifier("Detent.Middle")
    }
    
    static var top: UISheetPresentationController.Detent.Identifier = .large
}

extension UISheetPresentationController.Detent {
    static var bottomHeight: CGFloat = 80
    static var middleHeight: CGFloat = 200
        
    static func bottom() -> UISheetPresentationController.Detent {
        .custom(identifier: .bottom) { _ in bottomHeight }
    }
    
    static func middle() -> UISheetPresentationController.Detent {
        .custom(identifier: .middle) { _ in middleHeight }
    }
    
    static func top() -> UISheetPresentationController.Detent {
        .large()
    }
}
