//
//  VTStackedProgressBarCellContentConfiguration.swift
//  Valetudo
//
//  Created by David Klopp on 16.09.25.
//
import Foundation
import UIKit

struct VTSelectionCellContentConfiguration<S: Describable &  Hashable & Equatable>: UIContentConfiguration, Hashable {
    var title: String?
    var options: [S]
    var selection: S
    var onChange: ((S) -> Void)?
    
    func makeContentView() -> UIView & UIContentView {
        VTSelectionCellView<S>(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> VTSelectionCellContentConfiguration<S> {
        self
    }
    
    static func == (lhs: VTSelectionCellContentConfiguration, rhs: VTSelectionCellContentConfiguration) -> Bool {
        lhs.title == rhs.title &&
        lhs.options == rhs.options &&
        lhs.selection == rhs.selection
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(options)
        hasher.combine(selection)
    }
}
