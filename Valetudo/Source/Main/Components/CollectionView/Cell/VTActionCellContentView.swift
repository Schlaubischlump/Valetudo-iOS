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
    private lazy var minimumHeightConstraint = heightAnchor.constraint(greaterThanOrEqualToConstant: 50)

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .label
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()

    private lazy var textStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.alignment = .top
        stack.axis = .vertical
        stack.spacing = 6
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

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority _: UILayoutPriority
    ) -> CGSize {
        let availableWidth = max(0, targetSize.width - directionalLayoutMargins.leading - directionalLayoutMargins.trailing)
        let contentSize = container.systemLayoutSizeFitting(
            CGSize(width: availableWidth, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: horizontalFittingPriority,
            verticalFittingPriority: .fittingSizeLevel
        )

        let minCellHeight = 44.0
        let height = max(minCellHeight, contentSize.height + directionalLayoutMargins.top + directionalLayoutMargins.bottom)
        return CGSize(width: targetSize.width, height: height)
    }

    private func setupViews() {
        backgroundColor = .clear
        preservesSuperviewLayoutMargins = true
        directionalLayoutMargins = .init(top: 10, leading: 0, bottom: 10, trailing: 0)

        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        textStack.translatesAutoresizingMaskIntoConstraints = false
        actionButton.translatesAutoresizingMaskIntoConstraints = false

        addSubview(container)

        NSLayoutConstraint.activate([
            minimumHeightConstraint,
            container.topAnchor.constraint(greaterThanOrEqualTo: layoutMarginsGuide.topAnchor),
            container.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            container.bottomAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.bottomAnchor),
            container.centerYAnchor.constraint(equalTo: layoutMarginsGuide.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 28),
            iconImageView.heightAnchor.constraint(equalToConstant: 28),
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
