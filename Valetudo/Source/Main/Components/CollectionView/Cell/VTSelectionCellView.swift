//
//  V.swift
//  Valetudo
//
//  Created by David Klopp on 20.09.25.
//
import UIKit

final class VTSelectionCellView<S: Describable & Hashable & Equatable>: UIView, UIContentView {

    private let titleLabel = UILabel()
    private let selectionButton = UIButton(type: .system)

    private var options: [S] = []
    private var selection: S?

    var configuration: UIContentConfiguration {
        didSet {
            apply(configuration: configuration)
        }
    }

    init(configuration: VTSelectionCellContentConfiguration<S>) {
        self.configuration = configuration
        super.init(frame: .zero)

        setupViews()
        apply(configuration: configuration)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        selectionButton.translatesAutoresizingMaskIntoConstraints = false
        selectionButton.showsMenuAsPrimaryAction = true
        selectionButton.changesSelectionAsPrimaryAction = true

        let stack = UIStackView(arrangedSubviews: [titleLabel, selectionButton])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
        ])
    }

    private func apply(configuration: UIContentConfiguration) {
        guard let config = configuration as? VTSelectionCellContentConfiguration<S> else { return }
        titleLabel.text = config.title
        options = config.options
        selection = config.selection
        selectionButton.isEnabled = true

        // Build menu
        selectionButton.menu = UIMenu(children: options.map { sel in
            UIAction(title: sel.description, state: sel == selection ? .on : .off) { [weak self] _ in
                self?.selectionButton.isEnabled = false
                self?.selection = sel
                config.onChange?(sel)
            }
        })

        selectionButton.setTitle(selection?.description ?? "", for: .normal)
    }
}
