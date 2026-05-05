//
//  VTButtonCellContentView.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//
import UIKit

final class VTButtonCellContentView: UIView, VTContentView {
    var currentConfiguration: VTButtonCellContentConfiguration!

    var configuration: UIContentConfiguration {
        get { currentConfiguration }
        set {
            guard let config = newValue as? VTButtonCellContentConfiguration else { return }
            apply(configuration: config)
        }
    }

    private let button: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.contentInsets = .zero
        configuration.baseForegroundColor = .tintColor

        let button = UIButton(configuration: configuration)
        button.titleLabel?.font = .preferredFont(forTextStyle: .body)
        button.titleLabel?.textAlignment = .center
        button.configurationUpdateHandler = { button in
            var config = button.configuration
            let isActive = (button.isEnabled && !button.isSelected && !button.isHighlighted)
            config?.baseForegroundColor = isActive ? .tintColor : .tertiaryLabel
            button.configuration = config
        }

        return button
    }()

    let minCellHeight: CGFloat = 50.0

    init(configuration: VTButtonCellContentConfiguration) {
        super.init(frame: .zero)

        setupViews()
        apply(configuration: configuration)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    override func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority _: UILayoutPriority
    ) -> CGSize {
        let availableWidth = max(0, targetSize.width - directionalLayoutMargins.leading - directionalLayoutMargins.trailing)
        let contentSize = button.systemLayoutSizeFitting(
            CGSize(width: availableWidth, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: horizontalFittingPriority,
            verticalFittingPriority: .fittingSizeLevel
        )

        let minCellHeight = minCellHeight
        let height = max(minCellHeight, contentSize.height + directionalLayoutMargins.top + directionalLayoutMargins.bottom)
        return CGSize(width: targetSize.width, height: height)
    }

    func setupViews() {
        addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false

        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.setContentHuggingPriority(.required, for: .horizontal)

        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            button.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            button.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
        ])

        button.addTarget(self, action: #selector(tapped), for: .touchUpInside)
    }

    func apply(configuration: VTButtonCellContentConfiguration) {
        guard currentConfiguration != configuration else { return }
        currentConfiguration = configuration

        button.isEnabled = configuration.isEnabled
        button.setTitle(configuration.title, for: .normal)
    }

    @objc private func tapped() {
        guard var config = currentConfiguration else { return }

        let isEnabled = !config.disableSelectionAfterAction
        config.isEnabled = isEnabled
        button.isEnabled = isEnabled

        currentConfiguration = config
        currentConfiguration?.action?()
    }
}
