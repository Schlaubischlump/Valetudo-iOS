//
//  VTImageCalloutView.swift
//  Valetudo
//
//  Created by David Klopp on 27.04.26.
//
import UIKit

private let textCalloutSpacing = 4.0
private let imageCalloutPadX = 14.0
private let imageCalloutPadY = 14.0
private let imageCalloutSpacing = 10.0
private let calloutImageLength = 220.0

/// Callout view that displays title and subtitle text above an optional square image.
final class VTImageCalloutView: VTCalloutView {
    private let closeButton = UIButton(type: .system)
    private let imageContainerView = UIView()
    private let imageView = UIImageView()
    private let activityIndicatorView = UIActivityIndicatorView(style: .medium)
    private let textStack = UIStackView()
    private let headerStack = UIStackView()
    private let contentStack = UIStackView()

    override var preferredContentWidth: CGFloat? {
        calloutImageLength + imageCalloutPadX * 2
    }

    // MARK: - Init

    /// Creates an image callout with optional image and loading state.
    init(title: String, subtitle: String, image: UIImage? = nil, isLoadingImage: Bool = false) {
        super.init(title: title, subtitle: subtitle)
        setupViews()
        configureImage(image: image, isLoadingImage: isLoadingImage)
    }

    /// Creates an image callout from an archive.
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    // MARK: - Setup

    /// Builds the stacked image callout layout and close affordance.
    private func setupViews() {
        backgroundColor = .clear

        var configuration = UIButton.Configuration.filled()
        configuration.image = .xmark
        configuration.buttonSize = .small
        configuration.cornerStyle = .capsule
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        closeButton.configuration = configuration
        closeButton.tintColor = .secondaryLabel
        closeButton.addAction(
            UIAction { [weak self] _ in
                self?.onClose?()
            },
            for: .touchUpInside
        )

        imageContainerView.backgroundColor = .clear
        imageContainerView.layer.cornerRadius = 14
        imageContainerView.clipsToBounds = true
        imageContainerView.translatesAutoresizingMaskIntoConstraints = false

        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .clear
        imageView.translatesAutoresizingMaskIntoConstraints = false

        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false

        textStack.axis = .vertical
        textStack.spacing = textCalloutSpacing
        textStack.alignment = .leading
        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(subtitleLabel)

        headerStack.axis = .horizontal
        headerStack.spacing = imageCalloutSpacing
        headerStack.alignment = .center
        headerStack.addArrangedSubview(textStack)
        headerStack.addArrangedSubview(closeButton)

        contentStack.axis = .vertical
        contentStack.spacing = imageCalloutSpacing
        contentStack.alignment = .fill
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(headerStack)
        contentStack.addArrangedSubview(imageContainerView)

        addSubview(contentStack)
        imageContainerView.addSubview(imageView)
        imageContainerView.addSubview(activityIndicatorView)

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: imageCalloutPadY),
            contentStack.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -imageCalloutPadY),
            contentStack.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: imageCalloutPadX),
            contentStack.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -imageCalloutPadX),
            imageContainerView.widthAnchor.constraint(equalToConstant: calloutImageLength),
            imageContainerView.heightAnchor.constraint(equalToConstant: calloutImageLength),
            imageView.topAnchor.constraint(equalTo: imageContainerView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: imageContainerView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: imageContainerView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: imageContainerView.trailingAnchor),
            activityIndicatorView.centerXAnchor.constraint(equalTo: imageContainerView.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: imageContainerView.centerYAnchor),
        ])
    }

    // MARK: - Content

    /// Updates the displayed image and loading indicator state.
    func configureImage(image: UIImage? = nil, isLoadingImage: Bool = false) {
        imageView.image = image
        imageView.isHidden = image == nil

        if isLoadingImage {
            activityIndicatorView.startAnimating()
        } else {
            activityIndicatorView.stopAnimating()
        }
    }
}
