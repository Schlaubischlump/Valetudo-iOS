//
//  VTLoadingItem.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//
import Foundation
import UIKit

/// A non-interactive loading state row with a status message.
struct VTLoadingItem: VTItem {
    let id: String
    let message: String
}

extension VTAnyItem {
    static func loading(_ id: String, message: String) -> VTAnyItem {
        VTAnyItem(VTLoadingItem(id: id, message: message))
    }
}
