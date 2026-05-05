//
//  VTTextCalloutView.swift
//  Valetudo
//
//  Created by David Klopp on 27.04.26.
//
import UIKit

private let textCalloutPadX = 12.0
private let textCalloutPadY = 8.0
private let textCalloutSpacing = 4.0

/// Compact callout view that displays only title and subtitle text.
final class VTTextCalloutView: VTCalloutView {
    private let contentStack = UIStackView()

    // MARK: - Init

    /// Creates a text callout with the provided title and subtitle.
    override init(title: String, subtitle: String) {
        super.init(title: title, subtitle: subtitle)
        setupViews()
    }

    /// Creates a text callout from an archive.
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    // MARK: - Setup

    /// Builds the vertical text-only callout layout.
    private func setupViews() {
        contentStack.axis = .vertical
        contentStack.spacing = textCalloutSpacing
        contentStack.alignment = .leading
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(subtitleLabel)

        addSubview(contentStack)

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: textCalloutPadY),
            contentStack.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -textCalloutPadY),
            contentStack.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: textCalloutPadX),
            contentStack.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -textCalloutPadX),
        ])
    }
}
