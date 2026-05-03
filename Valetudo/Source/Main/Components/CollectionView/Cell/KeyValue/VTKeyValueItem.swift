//
//  VTKeyValueItem.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//
import Foundation
import UIKit

/// A title/value row that can optionally include a leading image.
struct VTKeyValueItem: VTItem {
    let id: String
    let title: String
    let value: String?
    let image: UIImage?
}

extension VTAnyItem {
    static func keyValue(
        _ id: String,
        title: String,
        value: String?,
        image: UIImage? = nil
    ) -> VTAnyItem {
        VTAnyItem(
            VTKeyValueItem(
                id: id,
                title: title,
                value: value,
                image: image
            )
        )
    }
}
