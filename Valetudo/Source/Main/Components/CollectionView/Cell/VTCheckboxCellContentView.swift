//
//  VTCheckboxCell.swift
//  Valetudo
//
//  Created by David Klopp on 14.04.26.
//
import UIKit

final class VTCheckboxCellContentView: UIView, UIContentView {
    private let iconImageView = UIImageView()
    private let label: UILabel = .init()

    private let toggle = UISwitch()

    private var currentConfiguration: VTCheckboxCellContentConfiguration!

    var configuration: UIContentConfiguration {
        get { currentConfiguration }
        set {
            guard let config = newValue as? VTCheckboxCellContentConfiguration else { return }
            apply(config)
        }
    }

    init(configuration: VTCheckboxCellContentConfiguration) {
        super.init(frame: .zero)
        setup()
        apply(configuration)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    private func setup() {
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .label
        iconImageView.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [iconImageView, label, toggle])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)

        let vPad = 16.0
        let hPad = 16.0
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: vPad),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -vPad),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: hPad),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -hPad),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
        ])

        toggle.addTarget(self, action: #selector(changed), for: .valueChanged)
    }

    private func apply(_ config: VTCheckboxCellContentConfiguration) {
        currentConfiguration = config
        label.text = config.title
        iconImageView.image = config.image?.withRenderingMode(.alwaysTemplate)
        iconImageView.isHidden = config.image == nil
        toggle.isEnabled = true
        toggle.isOn = config.isOn
    }

    @objc private func changed() {
        guard let config = currentConfiguration else { return }
        toggle.isEnabled = !config.disableSelectionAfterAction
        currentConfiguration.onChange?(toggle.isOn)
    }
}
