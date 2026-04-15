//
//  VTStackedProgressBarCellContentConfiguration.swift
//  Valetudo
//
//  Created by David Klopp on 16.09.25.
//
import Foundation
import UIKit

struct VTSelectionCellContentConfiguration<S: Describable &  Hashable & Equatable>: UIContentConfiguration, Hashable {
    let id: String
    let title: String?
    let options: [S]
    let selection: S
    var disableSelectionAfterAction: Bool = true
    let onChange: ((S) -> Void)?
    
    func makeContentView() -> UIView & UIContentView {
        VTSelectionCellContentView<S>(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> VTSelectionCellContentConfiguration<S> {
        self
    }
    
    static func == (lhs: VTSelectionCellContentConfiguration<S>, rhs: VTSelectionCellContentConfiguration<S>) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.options == rhs.options &&
        lhs.selection == rhs.selection
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(options)
        hasher.combine(selection)
    }
}
