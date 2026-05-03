//
//  VTDropDownItem.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//
import Foundation
import UIKit

/// A single-selection row backed by a dropdown menu.
struct VTDropDownItem<T: Hashable & Sendable>: VTItem {
    let id: String
    let title: String
    let subtitle: String?
    let active: T
    let options: [T]
    let image: UIImage?

    init(id: String, title: String, subtitle: String? = nil, active: T, options: [T], image: UIImage? = nil) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.active = active
        self.options = options
        self.image = image
    }
}

extension VTAnyItem {
    static func dropDown<T: Hashable & Sendable>(
        _ id: String,
        title: String,
        subtitle: String? = nil,
        active: T,
        options: [T],
        image: UIImage? = nil
    ) -> VTAnyItem {
        VTAnyItem(VTDropDownItem(id: id, title: title, subtitle: subtitle, active: active, options: options, image: image))
    }
}
