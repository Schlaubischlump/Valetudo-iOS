//
//  VTTextFieldCell.swift
//  Valetudo
//
//  Created by David Klopp on 14.04.26.
//
import UIKit

final class VTTextFieldCellContentView: UIView, UIContentView {

    private let textField: UITextField = {
        let textField = UITextField()
        textField.clearButtonMode = .never
        textField.textAlignment = .right
        textField.borderStyle = .none
        textField.returnKeyType = .done
        return textField
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        //label.textColor = .secondaryLabel
        return label
    }()
    
    private var currentConfiguration: VTTextFieldCellContentConfiguration!

    var configuration: UIContentConfiguration {
        get { currentConfiguration }
        set {
            guard let config = newValue as? VTTextFieldCellContentConfiguration else { return }
            apply(config)
        }
    }

    init(configuration: VTTextFieldCellContentConfiguration) {
        super.init(frame: .zero)
        setup()
        apply(configuration)
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textField)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)

        let hPad = 16.0
        let vPad = 16.0
        let spacing = 16.0
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: hPad),
            label.topAnchor.constraint(equalTo: topAnchor, constant: vPad),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -vPad),
            //label.widthAnchor.constraint(equalToConstant: 250),
            textField.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: spacing),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -hPad),
            textField.topAnchor.constraint(equalTo: topAnchor, constant: vPad),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -vPad),
        ])

        textField.addTarget(self, action: #selector(changed), for: .editingChanged)
    }

    private func apply(_ config: VTTextFieldCellContentConfiguration) {
        currentConfiguration = config
        textField.placeholder = config.placeholder
        textField.text = config.text
        label.text = config.label
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
