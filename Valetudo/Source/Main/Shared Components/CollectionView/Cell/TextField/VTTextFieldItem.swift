//
//  VTTextFieldItem.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//
import Foundation
import UIKit

/// A free-form text input row.
struct VTTextFieldItem: VTItem {
    let id: String
    let title: String
    let text: String
}

extension VTAnyItem {
    static func textField(_ id: String, title: String, text: String) -> VTAnyItem {
        VTAnyItem(VTTextFieldItem(id: id, title: title, text: text))
    }
}
