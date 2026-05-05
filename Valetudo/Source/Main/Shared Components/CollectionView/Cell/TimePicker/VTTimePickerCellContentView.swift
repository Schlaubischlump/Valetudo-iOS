//
//  VTTimePickerCellContentView.swift
//  Valetudo
//
//  Created by David Klopp on 14.04.26.
//
import UIKit

final class VTTimePickerCellContentView: VTStackedCellContentView<VTTimePickerCellContentConfiguration> {
    private let picker = UIDatePicker()

    required init(configuration: VTTimePickerCellContentConfiguration) {
        super.init(configuration: configuration)
    }

    override func setupViews() {
        super.setupViews()

        rootStack.addArrangedSubview(picker)

        // Picker
        picker.datePickerMode = .time
        picker.preferredDatePickerStyle = .compact
        picker.setContentHuggingPriority(.required, for: .horizontal)
        picker.setContentCompressionResistancePriority(.required, for: .horizontal)

        picker.addTarget(self, action: #selector(changed), for: .valueChanged)
    }

    override func apply(configuration: VTTimePickerCellContentConfiguration) {
        guard currentConfiguration != configuration else { return }
        super.apply(configuration: configuration)

        let calendar = Calendar.current
        var components = DateComponents()
        components.hour = configuration.hours
        components.minute = configuration.minutes

        picker.isEnabled = configuration.isEnabled

        if let date = calendar.date(from: components), picker.date != date {
            picker.date = date
        }
    }

    @objc private func changed() {
        guard var config = currentConfiguration else { return }

        let components = Calendar.current.dateComponents([.hour, .minute], from: picker.date)

        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0

        let isEnabled = !config.disableSelectionAfterAction
        config.isEnabled = isEnabled
        picker.isEnabled = isEnabled

        currentConfiguration = config
        currentConfiguration.onChange?(hours, minutes)
    }
}
