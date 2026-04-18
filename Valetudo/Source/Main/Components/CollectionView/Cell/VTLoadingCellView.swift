//
//  VTLoadingCellContentView.swift
//  Valetudo
//
//  Created by David Klopp on 20.09.25.
//
import UIKit

final class VTLoadingCellView: UIView, UIContentView {
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()

    var configuration: UIContentConfiguration {
        didSet { apply(configuration: configuration) }
    }

    init(configuration: VTLoadingCellContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        setupViews()
        apply(configuration: configuration)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        let stack = UIStackView(arrangedSubviews: [activityIndicator, messageLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }

    private func apply(configuration: UIContentConfiguration) {
        guard let config = configuration as? VTLoadingCellContentConfiguration else { return }
        messageLabel.text = config.message
        activityIndicator.startAnimating()
    }
}
