//
//  UICellAccessory + Extension.swift
//  Valetudo
//
//  Created by David Klopp on 16.04.26.
//
import UIKit

extension UICellAccessory {

    @MainActor
    static func plus(
        action: UIAction? = nil,
        pointSize: CGFloat = 18,
        color: UIColor = .tintColor
    ) -> UICellAccessory {

        let imageView = UIImageView(image: UIImage(systemName: "plus.circle.fill"))

        imageView.tintColor = color
        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(
            pointSize: pointSize,
            weight: .semibold
        )

        if let action {
            let button = UIButton(type: .system)
            button.setImage(imageView.image, for: .normal)
            button.tintColor = color
            button.addAction(action, for: .touchUpInside)

            return .customView(
                configuration: .init(
                    customView: button,
                    placement: .trailing()
                )
            )
        }

        return .customView(
            configuration: .init(
                customView: imageView,
                placement: .trailing()
            )
        )
    }
}
