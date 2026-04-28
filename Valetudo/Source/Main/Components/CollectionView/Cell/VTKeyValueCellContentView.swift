//
//  VTKeyValueCellContentView.swift
//  Valetudo
//
//  Created by David Klopp on 27.09.25.
//

import UIKit

final class VTKeyValueCellContentView: UIView, UIContentView {
    private var currentConfiguration: VTKeyValueCellContentConfiguration!

    private let rootStack = UIStackView()
    private let textStack = UIStackView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private lazy var titleWidthConstraint = titleLabel.widthAnchor.constraint(equalToConstant: 170)
    private lazy var minimumHeightConstraint = heightAnchor.constraint(greaterThanOrEqualToConstant: 50)

    var configuration: UIContentConfiguration {
        get { currentConfiguration }
        set {
            guard let newConfiguration = newValue as? VTKeyValueCellContentConfiguration else { return }
            apply(configuration: newConfiguration)
        }
    }

    init(configuration: VTKeyValueCellContentConfiguration) {
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
        let contentSize = rootStack.systemLayoutSizeFitting(
            CGSize(width: availableWidth, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: horizontalFittingPriority,
            verticalFittingPriority: .fittingSizeLevel
        )

        let minCellHeight = 44.0
        let height = max(minCellHeight, contentSize.height + directionalLayoutMargins.top + directionalLayoutMargins.bottom)
        return CGSize(width: targetSize.width, height: height)
    }

    private func setupViews() {
        preservesSuperviewLayoutMargins = true
        directionalLayoutMargins = .init(top: 10, leading: 0, bottom: 10, trailing: 0)

        rootStack.alignment = .center
        rootStack.axis = .horizontal
        rootStack.spacing = 12
        rootStack.translatesAutoresizingMaskIntoConstraints = false

        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .label
        iconImageView.setContentHuggingPriority(.required, for: .horizontal)
        iconImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false

        textStack.alignment = .top
        textStack.axis = .vertical
        textStack.spacing = 6
        textStack.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = .preferredFont(forTextStyle: .body)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)

        valueLabel.font = .preferredFont(forTextStyle: .body)
        valueLabel.textColor = .secondaryLabel
        valueLabel.numberOfLines = 0
        valueLabel.textAlignment = .right
        valueLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        addSubview(rootStack)
        rootStack.addArrangedSubview(iconImageView)
        rootStack.addArrangedSubview(textStack)
        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(valueLabel)

        NSLayoutConstraint.activate([
            minimumHeightConstraint,
            rootStack.topAnchor.constraint(greaterThanOrEqualTo: layoutMarginsGuide.topAnchor),
            rootStack.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            rootStack.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            rootStack.bottomAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.bottomAnchor),
            rootStack.centerYAnchor.constraint(equalTo: layoutMarginsGuide.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 28),
            iconImageView.heightAnchor.constraint(equalToConstant: 28),
        ])
    }

    private func apply(configuration: VTKeyValueCellContentConfiguration) {
        guard currentConfiguration != configuration else { return }
        currentConfiguration = configuration

        let hasValue = !(configuration.value?.isEmpty ?? true)
        let hasImage = configuration.image != nil
        titleLabel.text = configuration.title
        valueLabel.text = configuration.value
        valueLabel.isHidden = !hasValue
        iconImageView.image = configuration.image?.withRenderingMode(.alwaysTemplate)
        iconImageView.isHidden = !hasImage

        let usesHorizontalLayout = configuration.usesHorizontalLayout && hasValue
        textStack.axis = usesHorizontalLayout ? .horizontal : .vertical
        textStack.spacing = hasValue ? (usesHorizontalLayout ? 20 : 6) : 0
        valueLabel.textAlignment = usesHorizontalLayout ? .right : .left
        titleWidthConstraint.isActive = usesHorizontalLayout
    }
}
