//
//  VTConsumablesCellContentConfiguration.swift
//  Valetudo
//
//  Created by David Klopp on 16.09.25.
//
import UIKit

struct VTConsumablesCellContentConfiguration: UIContentConfiguration, Hashable, Equatable {
    static func == (lhs: VTConsumablesCellContentConfiguration, rhs: VTConsumablesCellContentConfiguration) -> Bool {
        lhs.title == rhs.title &&
        lhs.remaining == rhs.remaining &&
        lhs.progress == rhs.progress &&
        lhs.showsReset == rhs.showsReset
    }
    
    var title: String
    var remaining: String
    var progress: Float
    var showsReset: Bool
    var onReset: (() -> Void)? = nil
    
    func makeContentView() -> UIView & UIContentView {
        return VTConsumablesContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> VTConsumablesCellContentConfiguration {
        return self
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(remaining)
        hasher.combine(progress)
        hasher.combine(showsReset)
    }
}
