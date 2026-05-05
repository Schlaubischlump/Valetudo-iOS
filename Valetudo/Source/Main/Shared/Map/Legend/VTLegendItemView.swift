//
//  VTLegendItemView.swift
//  Valetudo
//
//  Created by David Klopp on 20.05.25.
//
import UIKit

/// Pill-shaped legend row that shows a color swatch, label, and selection state.
class VTLegendItemView: UIView {
    private let colorView = UIView()
    private let legendLabel = UILabel()
    private let checkmarkImageView = UIImageView()

    var isSelected: Bool = false {
        didSet {
            updateCheckmark()
        }
    }

    // MARK: - Init

    /// Creates a legend item view for the provided legend item.
    init(item: VTLegendItem) {
        super.init(frame: .zero)
        setup(item: item)
    }

    /// Creates a legend item view from an archive.
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    /// Applies the shared shadow styling used by the legend chip.
    private func setupShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 2
        layer.masksToBounds = false
    }

    /// Builds the legend chip content for the supplied item.
    private func setup(item: VTLegendItem) {
        backgroundColor = .systemGray6

        setupShadow()

        // Keep the color swatch a fixed circle so legend colors remain easy to scan.
        colorView.backgroundColor = item.color
        colorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            colorView.widthAnchor.constraint(equalToConstant: 24),
            colorView.heightAnchor.constraint(equalToConstant: 24),
        ])

        legendLabel.text = item.text
        legendLabel.font = .systemFont(ofSize: 14)
        legendLabel.textColor = .label

        checkmarkImageView.tintColor = .tintColor
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        checkmarkImageView.setContentHuggingPriority(.required, for: .horizontal)
        NSLayoutConstraint.activate([
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 20),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 20),
        ])

        updateCheckmark()

        let stack = UIStackView(arrangedSubviews: [colorView, legendLabel, checkmarkImageView])
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)

        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    // MARK: - Layout

    /// Rounds the chip and color swatch after Auto Layout has resolved their final sizes.
    override func layoutSubviews() {
        super.layoutSubviews()

        colorView.layoutIfNeeded()
        colorView.layer.cornerRadius = colorView.bounds.height / 2
        layer.cornerRadius = bounds.height / 2
    }

    // MARK: - Appearance

    /// Updates the trailing checkmark symbol to match the current selection state.
    private func updateCheckmark() {
        let imageName = isSelected ? "checkmark.circle.fill" : "circle"
        let symbolImage = UIImage(systemName: imageName)

        // Crossfade the symbol so selection changes feel deliberate instead of abrupt.
        UIView.transition(with: checkmarkImageView,
                          duration: 0.3,
                          options: [.transitionCrossDissolve],
                          animations: { [weak self] in
                              self?.checkmarkImageView.image = symbolImage
                          },
                          completion: nil)
    }
}
