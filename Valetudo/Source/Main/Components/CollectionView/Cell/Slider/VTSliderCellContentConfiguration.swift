//
//  VTSliderCellContentConfiguration.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//
import UIKit

struct VTSliderCellContentConfiguration: UIContentConfiguration, Hashable {
    let id: String
    let leftImage: UIImage?
    let rightImage: UIImage?
    let minValue: Float?
    let maxValue: Float?
    var value: Float
    var disableSelectionAfterAction: Bool = true
    let onChange: ((Float) -> Void)?

    var isEnabled: Bool = true

    init(
        id: String,
        leftImage: UIImage? = nil,
        rightImage: UIImage? = nil,
        minValue: Float? = nil,
        maxValue: Float? = nil,
        value: Float,
        disableSelectionAfterAction: Bool = true,
        onChange: ((Float) -> Void)? = nil
    ) {
        self.id = id
        self.leftImage = leftImage
        self.rightImage = rightImage
        self.minValue = minValue
        self.maxValue = maxValue
        self.value = value
        self.disableSelectionAfterAction = disableSelectionAfterAction
        self.onChange = onChange
    }

    func makeContentView() -> UIView & UIContentView {
        VTSliderCellContentView(configuration: self)
    }

    func updated(for _: UIConfigurationState) -> Self {
        self
    }

    static func == (lhs: VTSliderCellContentConfiguration, rhs: VTSliderCellContentConfiguration) -> Bool {
        lhs.id == rhs.id &&
            lhs.leftImage == rhs.leftImage &&
            lhs.rightImage == rhs.rightImage &&
            lhs.value == rhs.value &&
            lhs.disableSelectionAfterAction == rhs.disableSelectionAfterAction &&
            lhs.isEnabled == rhs.isEnabled
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(leftImage)
        hasher.combine(rightImage)
        hasher.combine(minValue)
        hasher.combine(maxValue)
        hasher.combine(value)
        hasher.combine(disableSelectionAfterAction)
        hasher.combine(isEnabled)
    }
}
