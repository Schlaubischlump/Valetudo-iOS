//
//  VTActionCellContentView.swift
//  Valetudo
//
//  Created by David Klopp on 27.09.25.
//
import UIKit

final class VTActionCellContentView: UIView, UIContentView {
    private var currentConfiguration: VTActionCellContentConfiguration!

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UIFont.smallSystemFontSize, weight: .semibold)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()

    private lazy var actionButton = VTOutlineButton(title: "", tintColor: tintColor)

    var configuration: UIContentConfiguration {
        get { currentConfiguration }
        set {
            guard let newConfiguration = newValue as? VTActionCellContentConfiguration else { return }
            apply(configuration: newConfiguration)
        }
    }

    init(configuration: VTActionCellContentConfiguration) {
        super.init(frame: .zero)
        setupViews()
        apply(configuration: configuration)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        backgroundColor = .clear

        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 4

        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        textStack.translatesAutoresizingMaskIntoConstraints = false
        actionButton.translatesAutoresizingMaskIntoConstraints = false

        let container = UIStackView(arrangedSubviews: [iconImageView, textStack, actionButton])
        container.axis = .horizontal
        container.alignment = .center
        container.spacing = 12
        container.translatesAutoresizingMaskIntoConstraints = false

        addSubview(container)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            container.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 28),
            iconImageView.heightAnchor.constraint(equalToConstant: 28)
        ])

        textStack.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textStack.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        actionButton.setContentHuggingPriority(.required, for: .horizontal)
        actionButton.setContentCompressionResistancePriority(.required, for: .horizontal)

        actionButton.addTarget(self, action: #selector(didTapAction), for: .touchUpInside)
    }

    private func apply(configuration: VTActionCellContentConfiguration) {
        guard currentConfiguration != configuration else { return }
        currentConfiguration = configuration

        titleLabel.text = configuration.title
        subtitleLabel.text = configuration.subtitle
        iconImageView.image = configuration.image
        iconImageView.tintColor = configuration.imageTintColor
        iconImageView.isHidden = configuration.image == nil
        actionButton.configuration?.title = configuration.buttonTitle
        actionButton.isHidden = !configuration.showsButton
    }

    @objc private func didTapAction() {
        currentConfiguration.onAction?()
    }
}
