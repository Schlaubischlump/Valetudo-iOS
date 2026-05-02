//
//  VTTextFieldCell.swift
//  Valetudo
//
//  Created by David Klopp on 14.04.26.
//
import UIKit

final class VTTextFieldCellContentView: VTStackedCellContentView<VTTextFieldCellContentConfiguration> {
    private let textField: UITextField = {
        let textField = UITextField()
        textField.clearButtonMode = .never
        textField.textAlignment = .right
        textField.borderStyle = .none
        textField.returnKeyType = .done
        return textField
    }()

    override init(configuration: VTTextFieldCellContentConfiguration) {
        super.init(configuration: configuration)
    }

    override func setupViews() {
        super.setupViews()

        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false

        rootStack.addArrangedSubview(textField)

        textField.addTarget(self, action: #selector(changed), for: .editingChanged)
    }

    override func apply(configuration: VTTextFieldCellContentConfiguration) {
        guard currentConfiguration != configuration else { return }
        super.apply(configuration: configuration)

        textField.placeholder = configuration.placeholder
        textField.text = configuration.text
    }

    @objc private func changed() {
        currentConfiguration.onChange?(textField.text ?? "")
    }
}

extension VTTextFieldCellContentView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
