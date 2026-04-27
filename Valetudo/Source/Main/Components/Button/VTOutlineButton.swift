//
//  VTOutlineButton.swift
//  Valetudo
//
//  Created by David Klopp on 27.09.25.
//
import UIKit

@MainActor
final class VTOutlineButton: UIButton {
    init(title: String, tintColor: UIColor) {
        var config = UIButton.Configuration.bordered()
        config.title = title
        config.baseForegroundColor = tintColor
        config.baseBackgroundColor = .clear
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: UIFont.systemFontSize, weight: .bold)
            return outgoing
        }
        config.contentInsets = .init(top: 6, leading: 12, bottom: 6, trailing: 12)

        super.init(frame: .zero)

        configuration = config

        layer.borderColor = tintColor.cgColor
        layer.borderWidth = 2.0
        layer.cornerRadius = 4
        configurationUpdateHandler = { button in
            var config = button.configuration

            if button.isHighlighted {
                config?.baseForegroundColor = .white
                config?.baseBackgroundColor = tintColor
            } else {
                config?.baseForegroundColor = tintColor
                config?.baseBackgroundColor = .clear
            }

            button.configuration = config
        }

        self.tintColor = tintColor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
