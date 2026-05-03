//
//  VTCheckboxItem.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//
import Foundation
import UIKit

/// A boolean on/off row rendered as a checkbox-style control.
struct VTCheckboxItem: VTItem {
    let id: String
    let title: String
    let subtitle: String?
    let isOn: Bool
    let image: UIImage?

    init(id: String, title: String, subtitle: String? = nil, enabled: Bool, image: UIImage? = nil) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        isOn = enabled
        self.image = image
    }
}

extension VTAnyItem {
    static func checkbox(_ id: String, title: String, subtitle: String? = nil, enabled: Bool, image: UIImage? = nil) -> VTAnyItem {
        VTAnyItem(VTCheckboxItem(id: id, title: title, subtitle: subtitle, enabled: enabled, image: image))
    }
}
