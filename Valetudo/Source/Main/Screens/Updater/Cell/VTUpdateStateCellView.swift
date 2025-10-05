//
//  VTNoUpdateAvailableCellView.swift
//  Valetudo
//
//  Created by David Klopp on 20.09.25.
//
import UIKit

final class VTUpdateStateCellView: UIView, UIContentView {
    private let checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()

    var configuration: UIContentConfiguration {
        didSet { apply(configuration: configuration) }
    }

    init(configuration: VTUpdateStateCellContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        setupViews()
        apply(configuration: configuration)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        let stack = UIStackView(arrangedSubviews: [checkmarkImageView, messageLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 40),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    private func apply(configuration: UIContentConfiguration) {
        guard let config = configuration as? VTUpdateStateCellContentConfiguration else { return }
        messageLabel.text = config.message
        checkmarkImageView.image = config.image
        checkmarkImageView.tintColor = config.tintColor
    }
}
