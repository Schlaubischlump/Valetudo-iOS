//
//  VTUpdateProgressCellView.swift
//  Valetudo
//
//  Created by David Klopp on 20.09.25.
//
import UIKit

final class VTProgressCellView: UIView, UIContentView {
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

    var configuration: UIContentConfiguration {
        didSet { apply(configuration: configuration) }
    }

    init(configuration: VTProgressCellContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        setupViews()
        apply(configuration: configuration)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        let stack = UIStackView(arrangedSubviews: [messageLabel, progressView])
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

            progressView.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: stack.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 8),
        ])
    }

    private func apply(configuration: UIContentConfiguration) {
        guard let config = configuration as? VTProgressCellContentConfiguration else { return }
        messageLabel.text = config.message
        progressView.progress = Float(config.progress / 100.0)
    }
}
