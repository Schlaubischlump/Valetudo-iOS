//
//  VTSliderCellContentView.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//

import UIKit

final class VTSliderCellContentView: UIView, VTContentView {
    var currentConfiguration: VTSliderCellContentConfiguration!

    var configuration: UIContentConfiguration {
        get { currentConfiguration }
        set {
            guard let config = newValue as? VTSliderCellContentConfiguration else { return }
            apply(configuration: config)
        }
    }

    private let leftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .secondaryLabel
        return imageView
    }()

    private let slider: UISlider = {
        let slider = UISlider()
        slider.isContinuous = false
        return slider
    }()

    private let rightImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .secondaryLabel
        return imageView
    }()

    let minCellHeight: CGFloat = 50.0

    init(configuration: VTSliderCellContentConfiguration) {
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
        withHorizontalFittingPriority _: UILayoutPriority,
        verticalFittingPriority _: UILayoutPriority
    ) -> CGSize {
        let height = max(
            minCellHeight,
            slider.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
                + directionalLayoutMargins.top
                + directionalLayoutMargins.bottom
        )

        return CGSize(width: targetSize.width, height: height)
    }

    func setupViews() {
        let stackView = UIStackView(arrangedSubviews: [
            leftImageView,
            slider,
            rightImageView,
        ])

        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 12

        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),

            leftImageView.widthAnchor.constraint(equalToConstant: 24),
            leftImageView.heightAnchor.constraint(equalToConstant: 24),

            rightImageView.widthAnchor.constraint(equalToConstant: 24),
            rightImageView.heightAnchor.constraint(equalToConstant: 24),
        ])

        slider.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    }

    func apply(configuration: VTSliderCellContentConfiguration) {
        guard currentConfiguration != configuration else { return }
        currentConfiguration = configuration

        leftImageView.image = configuration.leftImage
        rightImageView.image = configuration.rightImage

        leftImageView.isHidden = configuration.leftImage == nil
        rightImageView.isHidden = configuration.rightImage == nil

        slider.minimumValue = configuration.minValue ?? 0
        slider.maximumValue = configuration.maxValue ?? 1
        slider.value = configuration.value
        slider.isEnabled = configuration.isEnabled
    }

    @objc private func valueChanged() {
        guard var config = currentConfiguration else { return }

        config.value = slider.value

        let isEnabled = !config.disableSelectionAfterAction
        config.isEnabled = isEnabled
        slider.isEnabled = isEnabled

        currentConfiguration = config
        currentConfiguration?.onChange?(slider.value)
    }
}
