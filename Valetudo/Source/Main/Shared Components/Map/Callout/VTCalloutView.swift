//
//  VTCalloutView.swift
//  Valetudo
//
//  Created by David Klopp on 17.05.25.
//

import UIKit

/// Base view for map callouts that provides shared title and subtitle labels.
class VTCalloutView: UIView {
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()

    var onClose: (() -> Void)?
    var preferredContentWidth: CGFloat? {
        nil
    }

    // MARK: - Init

    /// Creates a callout view with the provided text content.
    init(title: String, subtitle: String) {
        super.init(frame: .zero)
        setupLabels()
        configure(title: title, subtitle: subtitle)
    }

    /// Creates a callout view from an archive.
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLabels()
    }

    // MARK: - Setup

    /// Configures the shared typography used by all callout variants.
    private func setupLabels() {
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0

        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0
    }

    // MARK: - Content

    /// Applies the provided text content to the shared title and subtitle labels.
    func configure(title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
}
