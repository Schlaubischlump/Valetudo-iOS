//
//  VTStackedProgressBarCellContentConfiguration.swift
//  Valetudo
//
//  Created by David Klopp on 16.09.25.
//
import Foundation
import UIKit

struct VTSelectionCellContentConfiguration<S>: UIContentConfiguration, Hashable {
    var title: String?
    var provider: [S]
    var selectedProvider: S
    var onChange: ((S) -> Void)?
    
    func makeContentView() -> UIView & UIContentView {
        VTProviderSelectionCellView(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> VTProviderSelectionCellContentConfiguration {
        self
    }
    
    static func == (lhs: VTProviderSelectionCellContentConfiguration, rhs: VTProviderSelectionCellContentConfiguration) -> Bool {
        lhs.title == rhs.title &&
        lhs.provider == rhs.provider &&
        lhs.selectedProvider == rhs.selectedProvider
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(provider)
        hasher.combine(selectedProvider)
    }
}
