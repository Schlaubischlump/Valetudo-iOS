//
//  VTProgressItem.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//
import Foundation
import UIKit

/// A progress row with a message and numeric completion value.
struct VTProgressItem: VTItem {
    let id: String
    let message: String
    let progress: CGFloat
}

extension VTAnyItem {
    static func progress(_ id: String, message: String, progress: CGFloat) -> VTAnyItem {
        VTAnyItem(VTProgressItem(id: id, message: message, progress: progress))
    }
}
