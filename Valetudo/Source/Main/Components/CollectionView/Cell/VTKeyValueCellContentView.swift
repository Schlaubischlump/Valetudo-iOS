//
//  VTKeyValueCellContentView.swift
//  Valetudo
//
//  Created by David Klopp on 27.09.25.
//

import UIKit

final class VTKeyValueCellContentView: VTStackedCellContentView<VTKeyValueCellContentConfiguration> {
    let textSpacingVertical: CGFloat = 20

    override func apply(configuration: VTKeyValueCellContentConfiguration) {
        guard currentConfiguration != configuration else { return }
        super.apply(configuration: configuration)

        let hasValue = !(configuration.subtitle?.isEmpty ?? true)

        let usesHorizontalLayout = configuration.usesHorizontalLayout && hasValue
        textStack.axis = usesHorizontalLayout ? .horizontal : .vertical
        textStack.spacing = hasValue ? (usesHorizontalLayout ? textSpacingVertical : textSpacing) : 0
        subtitleLabel.textAlignment = usesHorizontalLayout ? .right : .left
        // titleWidthConstraint.isActive = usesHorizontalLayout
    }
}
