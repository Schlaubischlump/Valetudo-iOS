//
//  VTUpdateProgressCellView.swift
//  Valetudo
//
//  Created by David Klopp on 20.09.25.
//
import UIKit

final class VTProgressCellView: UIView, VTContentView {
    private let progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .bar)
        progressView.trackTintColor = .secondarySystemFill
        progressView.layer.cornerRadius = 4
        progressView.layer.masksToBounds = true
        return progressView
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()

    private lazy var minimumHeightConstraint = heightAnchor.constraint(greaterThanOrEqualToConstant: 50)

    var currentConfiguration: VTProgressCellContentConfiguration!

    var configuration: UIContentConfiguration {
        get { currentConfiguration }
        set {
            guard let config = newValue as? VTProgressCellContentConfiguration else { return }
            apply(configuration: config)
        }
    }

    init(configuration: VTProgressCellContentConfiguration) {
        super.init(frame: .zero)

        setupViews()
        apply(configuration: configuration)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupViews() {
        let stack = UIStackView(arrangedSubviews: [messageLabel, progressView])
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

            progressView.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: stack.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 8),
        ])
    }

    func apply(configuration: VTProgressCellContentConfiguration) {
        guard currentConfiguration != configuration else { return }
        currentConfiguration = configuration

        messageLabel.text = configuration.message
        progressView.progress = Float(configuration.progress / 100.0)
    }
}
