//
//  VTListSelectionItem.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//
import Foundation
import UIKit

/// A row that presents and edits an ordered multi-selection list.
struct VTListSelectionItem<T: Hashable & Sendable>: VTItem {
    let id: String
    let enabledTitle: String
    let disabledTitle: String
    let active: [T]
    let options: [T]
}

extension VTAnyItem {
    static func listSelection<T: Hashable & Sendable>(
        _ id: String,
        enabledTitle: String,
        disabledTitle: String,
        active: [T],
        options: [T]
    ) -> VTAnyItem {
        VTAnyItem(
            VTListSelectionItem(
                id: id,
                enabledTitle: enabledTitle,
                disabledTitle: disabledTitle,
                active: active,
                options: options
            )
        )
    }
}
