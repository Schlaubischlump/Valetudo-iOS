//
//  VTSliderItem.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//

import Foundation
import UIKit

struct VTSliderItem: VTItem {
    let id: String
    let leftImage: UIImage?
    let rightImage: UIImage?
    let minValue: Float?
    let maxValue: Float?
    let value: Float
}

extension VTAnyItem {
    static func slider(
        _ id: String,
        leftImage: UIImage? = nil,
        rightImage: UIImage? = nil,
        minValue: Float = 0,
        maxValue: Float = 1,
        value: Float
    ) -> VTAnyItem {
        VTAnyItem(
            VTSliderItem(
                id: id,
                leftImage: leftImage,
                rightImage: rightImage,
                minValue: minValue,
                maxValue: maxValue,
                value: value
            )
        )
    }
}
