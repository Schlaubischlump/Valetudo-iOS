//
//  VTUpdateAvailableCellView.swift
//  Valetudo
//
//  Created by David Klopp on 20.09.25.
//
import UIKit

final class VTUpdateDetailCellView: UIView, UIContentView {
    private var currentConfiguration: VTUpdateDetailCellContentConfiguration!

    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .label
        iv.setContentHuggingPriority(.required, for: .horizontal)
        iv.setContentCompressionResistancePriority(.required, for: .horizontal)
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()

    private let textView = VTReadMoreTextView(maxLength: 250)

    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = UIButton.Configuration.filled()
        button.configuration?.baseBackgroundColor = .systemBlue
        button.configuration?.baseForegroundColor = .white
        button.configuration?.contentInsets = .init(top: 10, leading: 16, bottom: 10, trailing: 16)
        return button
    }()

    var configuration: UIContentConfiguration {
        get { currentConfiguration }
        set {
            guard let newConfig = newValue as? VTUpdateDetailCellContentConfiguration else { return }
            apply(configuration: newConfig)
        }
    }

    init(configuration: VTUpdateDetailCellContentConfiguration) {
        currentConfiguration = configuration
        super.init(frame: .zero)
        setupViews()
        apply(configuration: configuration)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        actionButton.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)

        let labelsStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        labelsStack.axis = .vertical
        labelsStack.spacing = 2
        labelsStack.alignment = .leading

        let headerStack = UIStackView(arrangedSubviews: [iconImageView, labelsStack])
        headerStack.axis = .horizontal
        headerStack.spacing = 12
        headerStack.alignment = .center

        let stack = UIStackView(arrangedSubviews: [headerStack, textView, actionButton])
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),
        ])
    }

    @objc private func didTapButton(_ sender: UIButton) {
        currentConfiguration.buttonAction(sender)
    }

    private func apply(configuration: UIContentConfiguration) {
        guard let config = configuration as? VTUpdateDetailCellContentConfiguration else { return }

        currentConfiguration = config
        titleLabel.text = config.title
        subtitleLabel.text = config.subtitle
        iconImageView.image = config.image

        textView.configure(with: config.attributedMessage)
        textView.baseFont = config.baseFont
        textView.baseTextColor = config.baseTextColor
        textView.reloadHandler = { [weak self] in
            let collectionView = self?.enclosingCollectionView as? UICollectionView
            let layout = collectionView?.collectionViewLayout
            layout?.invalidateLayout()
        }

        actionButton.setTitle(config.buttonTitle, for: .normal)
        actionButton.isEnabled = true
    }
}
