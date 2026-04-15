//
//  VTCheckboxCell.swift
//  Valetudo
//
//  Created by David Klopp on 14.04.26.
//
import UIKit

final class VTCheckboxCellContentView: UIView, UIContentView {

    private let label: UILabel = {
        let label = UILabel()
        //label.textColor = .secondaryLabel
        return label
    }()
    
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

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        let stack = UIStackView(arrangedSubviews: [label, toggle])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)

        let vPad = 16.0
        let hPad = 16.0
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: vPad),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -vPad),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: hPad),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -hPad),
        ])

        toggle.addTarget(self, action: #selector(changed), for: .valueChanged)
    }

    private func apply(_ config: VTCheckboxCellContentConfiguration) {
        currentConfiguration = config
        label.text = config.title
        toggle.isEnabled = true
        toggle.isOn = config.isOn
    }

    @objc private func changed() {
        guard let config = currentConfiguration else { return }
        toggle.isEnabled = !config.disableSelectionAfterAction
        currentConfiguration.onChange?(toggle.isOn)
    }
}
