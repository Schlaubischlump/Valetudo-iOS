//
//  VTDockControlView.swift
//  Valetudo
//
//  Created by David Klopp on 21.05.25.
//
import UIKit

final class VTStackedControlRow<T: VTControlItem>: VTControlRow<UIStackView> {
    var items: [T] = [] {
        didSet {
            content.arrangedSubviews.forEach { $0.removeFromSuperview() }
            items.forEach { content.addArrangedSubview($0) }
        }
    }

    var axis: NSLayoutConstraint.Axis {
        get { content.axis }
        set { content.axis = newValue }
    }

    init(title: String, titleIcon: UIImage?) {
        super.init(title: title, titleIcon: titleIcon, content: UIStackView())
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setup() {
        super.setup()
        // Horizontal stack for buttons
        content.translatesAutoresizingMaskIntoConstraints = false
        content.axis = .horizontal
        content.spacing = 8
        content.distribution = .fillEqually
    }
}

extension VTStackedControlRow where T == VTControlButton {
    var isEnabled: Bool {
        get { items.allSatisfy(\.isEnabled) }
        set { items.forEach { $0.isEnabled = newValue } }
    }
}
