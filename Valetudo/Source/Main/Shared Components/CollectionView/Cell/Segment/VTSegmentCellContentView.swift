//
//  VTSegmentCellContentView.swift
//  Valetudo
//
//  Created by David Klopp on 14.04.26.
//
import UIKit

private final class ToggleButton<S: Describable & Hashable & Equatable>: UILabel {
    var insets = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)

    var value: S

    var onTap: ((_ isSelected: Bool) -> Void)?

    init(value: S) {
        self.value = value

        super.init(frame: .zero)

        text = value.description
        textAlignment = .center
        font = .systemFont(ofSize: 13)
        isUserInteractionEnabled = true

        layer.masksToBounds = true
        layer.cornerRadius = 8

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        tapGestureRecognizer.addTarget(self, action: #selector(tapped(_:)))
        addGestureRecognizer(tapGestureRecognizer)

        updateSelectionState()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateSelectionState() {
        textColor = isSelected ? .white : .label
        backgroundColor = isSelected ? .tintColor : .systemFill
    }

    var isSelected: Bool = false {
        didSet { updateSelectionState() }
    }

    @objc private func tapped(_: UIGestureRecognizer) {
        isSelected = !isSelected
        onTap?(isSelected)
    }

    // MARK: - Insets

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + insets.left + insets.right,
                      height: size.height + insets.top + insets.bottom)
    }

    override var bounds: CGRect {
        didSet {
            preferredMaxLayoutWidth = bounds.width - (insets.left + insets.right)
        }
    }
}

final class VTSegmentCellContentView<S: Describable & Hashable & Equatable>: UIView, VTContentView {
    private let stack = UIStackView()
    private var buttons: [ToggleButton<S>] = []

    var currentConfiguration: VTSegmentCellContentConfiguration<S>!

    var configuration: UIContentConfiguration {
        get { currentConfiguration }
        set {
            guard let config = newValue as? VTSegmentCellContentConfiguration<S> else { return }
            apply(configuration: config)
        }
    }

    init(configuration: VTSegmentCellContentConfiguration<S>) {
        super.init(frame: .zero)
        setupViews()
        apply(configuration: configuration)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    func setupViews() {
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)

        let hPad = 16.0
        let vPad = 16.0

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: vPad),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -vPad),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: hPad),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -hPad),
        ])
    }

    func apply(configuration: VTSegmentCellContentConfiguration<S>) {
        guard currentConfiguration != configuration else { return }
        currentConfiguration = configuration

        // Rebuild buttons (simple + safe for diffable)
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        buttons.removeAll()

        for value in configuration.options {
            let button = ToggleButton(value: value)
            let isSelected = configuration.active.contains(value)
            button.isSelected = isSelected
            button.onTap = { [weak self] _ in
                guard let self else { return }

                let (_, newSelection) = zip(buttons, currentConfiguration.options).filter(\.0.isSelected).unzip()

                currentConfiguration.active = Set(newSelection)
                currentConfiguration.onChange?(Set(newSelection))
            }

            buttons.append(button)
            stack.addArrangedSubview(button)
        }
    }
}
