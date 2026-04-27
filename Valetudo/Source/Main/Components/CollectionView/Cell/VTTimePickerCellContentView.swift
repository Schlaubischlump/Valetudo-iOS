//
//  VTTimePickerCellContentView.swift
//  Valetudo
//
//  Created by David Klopp on 14.04.26.
//
import UIKit

final class VTTimePickerCellContentView: UIView, UIContentView {
    private let label = UILabel()
    private let picker = UIDatePicker()
    private let stackView = UIStackView()
    private let spacer = UIView()

    private var currentConfiguration: VTTimePickerCellContentConfiguration!

    var configuration: UIContentConfiguration {
        get { currentConfiguration }
        set {
            guard let config = newValue as? VTTimePickerCellContentConfiguration else { return }
            apply(config)
        }
    }

    init(configuration: VTTimePickerCellContentConfiguration) {
        super.init(frame: .zero)
        setup()
        apply(configuration)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    private func setup() {
        // Label
        label.numberOfLines = 1
        label.setContentHuggingPriority(.required, for: .horizontal)

        // Picker
        picker.datePickerMode = .time
        picker.preferredDatePickerStyle = .compact
        picker.setContentHuggingPriority(.required, for: .horizontal)
        picker.setContentCompressionResistancePriority(.required, for: .horizontal)

        picker.addTarget(self, action: #selector(changed), for: .valueChanged)

        // Spacer expands
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        // Stack
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false

        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(spacer) // 👈 key
        stackView.addArrangedSubview(picker)

        addSubview(stackView)

        let vPad = 16.0
        let hPad = 16.0

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: vPad),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -vPad),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: hPad),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -hPad),
        ])
    }

    private func apply(_ config: VTTimePickerCellContentConfiguration) {
        currentConfiguration = config

        label.text = config.label

        let calendar = Calendar.current
        var components = DateComponents()
        components.hour = config.hours
        components.minute = config.minutes

        if let date = calendar.date(from: components), picker.date != date {
            picker.date = date
        }
    }

    @objc private func changed() {
        let components = Calendar.current.dateComponents([.hour, .minute], from: picker.date)

        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0

        currentConfiguration.onChange?(hours, minutes)
    }
}
