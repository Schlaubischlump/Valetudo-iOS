//
//  VTStackedProgressBarCellContentConfiguration.swift
//  Valetudo
//
//  Created by David Klopp on 16.09.25.
//
import Foundation
import UIKit

struct VTDropDownCellContentConfiguration<S: Describable & Hashable & Equatable>: VTStackedCellContentConfiguration {
    let id: String
    let title: String
    let subtitle: String?
    let options: [S]
    let selection: S
    let image: UIImage?
    var disableSelectionAfterAction: Bool = true
    let onChange: ((S) -> Void)?

    init(
        id: String,
        title: String,
        subtitle: String? = nil,
        options: [S],
        selection: S,
        image: UIImage? = nil,
        disableSelectionAfterAction: Bool = true,
        onChange: ((S) -> Void)? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.options = options
        self.selection = selection
        self.image = image
        self.disableSelectionAfterAction = disableSelectionAfterAction
        self.onChange = onChange
    }

    func makeContentView() -> UIView & UIContentView {
        VTDropDownCellContentView<S>(configuration: self)
    }

    func updated(for _: UIConfigurationState) -> VTDropDownCellContentConfiguration<S> {
        self
    }

    static func == (lhs: VTDropDownCellContentConfiguration<S>, rhs: VTDropDownCellContentConfiguration<S>) -> Bool {
        lhs.id == rhs.id &&
            lhs.title == rhs.title &&
            lhs.subtitle == rhs.subtitle &&
            lhs.options == rhs.options &&
            lhs.selection == rhs.selection &&
            lhs.image == rhs.image
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(subtitle)
        hasher.combine(options)
        hasher.combine(selection)
        hasher.combine(image)
    }
}
