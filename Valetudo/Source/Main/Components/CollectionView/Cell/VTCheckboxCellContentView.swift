//
//  VTCheckboxCell.swift
//  Valetudo
//
//  Created by David Klopp on 14.04.26.
//
import UIKit

final class VTCheckboxCellContentView: VTStackedCellContentView<VTCheckboxCellContentConfiguration> {
    private let toggle: UISwitch = {
        let toggle = UISwitch()
        toggle.preferredStyle = .sliding
        return toggle
    }()

    override init(configuration: VTCheckboxCellContentConfiguration) {
        super.init(configuration: configuration)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    override func setupViews() {
        super.setupViews()

        toggle.setContentCompressionResistancePriority(.required, for: .horizontal)
        toggle.setContentHuggingPriority(.required, for: .horizontal)

        rootStack.addArrangedSubview(toggle)
        toggle.addTarget(self, action: #selector(changed), for: .valueChanged)
    }

    override func apply(configuration: VTCheckboxCellContentConfiguration) {
        guard currentConfiguration != configuration else { return }
        super.apply(configuration: configuration)

        toggle.isEnabled = true
        toggle.isOn = configuration.isOn
    }

    @objc private func changed() {
        guard let config = currentConfiguration else { return }
        toggle.isEnabled = !config.disableSelectionAfterAction
        currentConfiguration.onChange?(toggle.isOn)
    }
}
