//
//  VTConsumableItem.swift
//  Valetudo
//
//  Created by David Klopp on 16.09.25.
//
import UIKit

struct VTConsumableItem: Sendable, Hashable {
    let type: VTConsumableType
    let subType: VTConsumableSubType
    let remaining: VTConsumableRemaining
    let maxValue: VTConsumableRemaining?
    
    var title: String {
        "\(self.subType.description.capitalized) \(self.type.description.capitalized)"
    }
    
    var subtitle: String {
        return remaining.description
    }
    
    var icon: UIImage? {
        return nil
    }
    
    var progress: Double {
        switch(maxValue?.unit, remaining.unit) {
        case (_, .percent):
            return remaining.value / 100.0
        case (.minutes, .minutes):
            guard let value = maxValue?.value else {
                // TODO: log error
                return 0.0
            }
            return 1.0 - (remaining.value / value)
        default:
            // TODO: log error
            return 0.0
        }
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        hasher.combine(subType)
        hasher.combine(remaining.value)
        hasher.combine(remaining.unit)
    }
}
