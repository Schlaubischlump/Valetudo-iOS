//
//  VTCheckboxItem.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//
import Foundation
import UIKit

/// A boolean on/off row rendered as a checkbox-style control.
struct VTButtonItem: VTItem {
    let id: String
    let title: String
}

extension VTAnyItem {
    static func button(_ id: String, title: String) -> VTAnyItem {
        VTAnyItem(VTButtonItem(id: id, title: title))
    }
}
