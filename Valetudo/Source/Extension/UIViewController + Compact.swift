//
//  UISplitViewController + Compact.swift
//  Valetudo
//
//  Created by David Klopp on 19.05.25.
//
import UIKit

extension UIViewController {
    var isCompact: Bool { traitCollection.horizontalSizeClass == .compact }
}
