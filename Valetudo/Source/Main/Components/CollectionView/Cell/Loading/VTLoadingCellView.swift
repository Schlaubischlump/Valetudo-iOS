//
//  VTLoadingCellContentView.swift
//  Valetudo
//
//  Created by David Klopp on 20.09.25.
//
import UIKit

final class VTLoadingCellView: UIView, VTContentView {
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()

    private lazy var minimumHeightConstraint = heightAnchor.constraint(greaterThanOrEqualToConstant: 50)

    var currentConfiguration: VTLoadingCellContentConfiguration!

    var configuration: UIContentConfiguration {
        get { currentConfiguration }
        set {
            guard let config = newValue as? VTLoadingCellContentConfiguration else { return }
            apply(configuration: config)
        }
    }

    init(configuration: VTLoadingCellContentConfiguration) {
        super.init(frame: .zero)

        setupViews()
        apply(configuration: configuration)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupViews() {
        let stack = UIStackView(arrangedSubviews: [activityIndicator, messageLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)

        NSLayoutConstraint.activate([
            minimumHeightConstraint,
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
        ])
    }

    func apply(configuration: VTLoadingCellContentConfiguration) {
        if currentConfiguration != configuration {
            currentConfiguration = configuration
            messageLabel.text = configuration.message
        }
        activityIndicator.startAnimating()
    }

    /*override func didMoveToWindow() {
        super.didMoveToWindow()

        guard window != nil else { return }
        activityIndicator.startAnimating()
    }*/
}
