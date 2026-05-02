//
//  V.swift
//  Valetudo
//
//  Created by David Klopp on 20.09.25.
//
import UIKit

final class VTDropDownCellContentView<S: Describable & Hashable & Equatable>: VTStackedCellContentView<VTDropDownCellContentConfiguration<S>> {
    private let selectionButton = UIButton(type: .system)

    private var options: [S] = []
    private var selection: S?
    private lazy var minimumHeightConstraint = heightAnchor.constraint(greaterThanOrEqualToConstant: 50)

    override init(configuration: VTDropDownCellContentConfiguration<S>) {
        super.init(configuration: configuration)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setupViews() {
        super.setupViews()

        selectionButton.translatesAutoresizingMaskIntoConstraints = false
        selectionButton.showsMenuAsPrimaryAction = true
        selectionButton.changesSelectionAsPrimaryAction = true
        selectionButton.setContentHuggingPriority(.required, for: .horizontal)
        selectionButton.setContentCompressionResistancePriority(.required, for: .horizontal)

        rootStack.addArrangedSubview(selectionButton)
    }

    override func apply(configuration: VTDropDownCellContentConfiguration<S>) {
        guard currentConfiguration != configuration else { return }
        super.apply(configuration: configuration)

        let config = configuration
        options = config.options
        selection = config.selection
        selectionButton.isEnabled = true

        // Build menu
        selectionButton.menu = UIMenu(children: options.map { sel in
            UIAction(title: sel.description, state: sel == selection ? .on : .off) { [weak self] _ in
                self?.selectionButton.isEnabled = !config.disableSelectionAfterAction
                self?.selection = sel
                config.onChange?(sel)
            }
        })

        selectionButton.setTitle(selection?.description ?? "", for: .normal)
    }
}
