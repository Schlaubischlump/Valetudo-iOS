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

    required init(configuration: VTDropDownCellContentConfiguration<S>) {
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

        var config = configuration
        options = config.options
        selection = config.selection
        selectionButton.isEnabled = configuration.isEnabled

        // Build menu
        selectionButton.menu = UIMenu(children: options.map { sel in
            UIAction(title: sel.description, state: sel == selection ? .on : .off) { [weak self] _ in
                let isEnabled = !config.disableSelectionAfterAction
                config.isEnabled = isEnabled
                self?.selectionButton.isEnabled = isEnabled
                self?.selection = sel
                config.onChange?(sel)
                self?.currentConfiguration = config
            }
        })

        selectionButton.setTitle(selection?.description ?? "", for: .normal)
    }
}
