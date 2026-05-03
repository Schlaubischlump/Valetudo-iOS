//
//  VTStackedCellContentView.swift
//  Valetudo
//
//  Created by David Klopp on 02.05.26.
//
import UIKit

class VTStackedCellContentView<Configuration: VTStackedCellContentConfiguration>: UIView, VTContentView {
    var currentConfiguration: Configuration!

    let rootStack = UIStackView()
    let textStack = UIStackView()
    let iconImageView = UIImageView()
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()

    let rootSpacing: CGFloat = 8.0
    let textSpacing: CGFloat = 4.0
    let minCellHeight: CGFloat = 50.0

    // private lazy var titleWidthConstraint = titleLabel.widthAnchor.constraint(equalToConstant: 170)

    var configuration: UIContentConfiguration {
        get { currentConfiguration }
        set {
            guard let newConfiguration = newValue as? Configuration else { return }
            apply(configuration: newConfiguration)
        }
    }

    required init(configuration: Configuration) {
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

        let minCellHeight = minCellHeight
        let height = max(minCellHeight, contentSize.height + directionalLayoutMargins.top + directionalLayoutMargins.bottom)
        return CGSize(width: targetSize.width, height: height)
    }

    func setupViews() {
        preservesSuperviewLayoutMargins = true
        // directionalLayoutMargins = .init(top: 10, leading: 0, bottom: 10, trailing: 0)

        rootStack.alignment = .center
        rootStack.axis = .horizontal
        rootStack.spacing = rootSpacing
        rootStack.translatesAutoresizingMaskIntoConstraints = false

        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .label
        iconImageView.setContentHuggingPriority(.required, for: .horizontal)
        iconImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false

        textStack.alignment = .top
        textStack.axis = .vertical
        textStack.spacing = textSpacing
        textStack.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textStack.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textStack.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = .preferredFont(forTextStyle: .body)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 2
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

        subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 2
        subtitleLabel.textAlignment = .left
        subtitleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        addSubview(rootStack)
        rootStack.addArrangedSubview(iconImageView)
        rootStack.addArrangedSubview(textStack)
        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            rootStack.topAnchor.constraint(greaterThanOrEqualTo: layoutMarginsGuide.topAnchor),
            rootStack.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            rootStack.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            rootStack.bottomAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.bottomAnchor),
            rootStack.centerYAnchor.constraint(equalTo: layoutMarginsGuide.centerYAnchor),
            iconImageView.heightAnchor.constraint(equalToConstant: minCellHeight - 10),
            iconImageView.widthAnchor.constraint(equalTo: iconImageView.heightAnchor),
        ])
    }

    func apply(configuration: Configuration) {
        guard currentConfiguration != configuration else { return }
        currentConfiguration = configuration

        let hasValue = !(configuration.subtitle?.isEmpty ?? true)
        let hasImage = configuration.image != nil
        titleLabel.text = configuration.title
        subtitleLabel.text = configuration.subtitle
        subtitleLabel.isHidden = !hasValue
        iconImageView.image = configuration.image?.withRenderingMode(.alwaysTemplate)
        iconImageView.isHidden = !hasImage

        // titleWidthConstraint.isActive = usesHorizontalLayout
    }
}
