//
//  VTSegmentItem.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//
import Foundation
import UIKit

/// A segmented control row with one or more active options.
struct VTSegmentItem<T: Hashable & Sendable>: VTItem {
    let id: String
    let active: Set<T>
    let options: [T]
}

extension VTAnyItem {
    static func segment<T: Hashable & Sendable>(_ id: String, active: Set<T>, options: [T]) -> VTAnyItem {
        VTAnyItem(VTSegmentItem(id: id, active: active, options: options))
    }
}
