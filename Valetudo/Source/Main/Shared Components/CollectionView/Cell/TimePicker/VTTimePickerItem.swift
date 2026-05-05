//
//  VTTimePickerItem.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//
import Foundation
import UIKit

/// A row for editing an hour/minute time value.
struct VTTimePickerItem: VTItem {
    let id: String
    let title: String
    let subtitle: String?
    let image: UIImage?
    let hours: Int
    let minutes: Int
}

extension VTAnyItem {
    static func timePicker(
        _ id: String,
        title: String,
        subtitle: String? = nil,
        image: UIImage? = nil,
        hours: Int,
        minutes: Int
    ) -> VTAnyItem {
        VTAnyItem(
            VTTimePickerItem(id: id, title: title, subtitle: subtitle, image: image, hours: hours, minutes: minutes)
        )
    }
}
