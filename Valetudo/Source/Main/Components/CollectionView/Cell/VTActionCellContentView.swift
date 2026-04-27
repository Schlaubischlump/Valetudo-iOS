//
//  VTActionCellContentView.swift
//  Valetudo
//
//  Created by David Klopp on 27.09.25.
//
import UIKit

final class VTActionCellContentView: UIView, UIContentView {
    private var currentConfiguration: VTActionCellContentConfiguration!
    private var actionButton = VTOutlineButton(title: "", tintColor: .tintColor)

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
    
    private lazy var textStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }()
    
    private lazy var container: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [iconImageView, textStack, actionButton])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

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

        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        textStack.translatesAutoresizingMaskIntoConstraints = false
        actionButton.translatesAutoresizingMaskIntoConstraints = false

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
        iconImageView.image = configuration.image?.withRenderingMode(.alwaysTemplate)
        iconImageView.tintColor = .label
        iconImageView.isHidden = configuration.image == nil
        replaceActionButton(
            title: configuration.buttonTitle,
            style: configuration.buttonStyle ?? .normal
        )
    }
    
    private func replaceActionButton(title: String, style: VTButtonStyle) {
        container.removeArrangedSubview(actionButton)
        actionButton.removeFromSuperview()

        actionButton = VTOutlineButton(title: title, tintColor: tintColor, style: style)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.setContentHuggingPriority(.required, for: .horizontal)
        actionButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        actionButton.addTarget(self, action: #selector(didTapAction), for: .touchUpInside)
        container.addArrangedSubview(actionButton)
    }

    @objc private func didTapAction() {
        currentConfiguration.onAction?()
    }
}
