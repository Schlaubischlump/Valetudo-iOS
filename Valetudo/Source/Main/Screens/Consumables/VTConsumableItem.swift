//
//  VTConsumableItem.swift
//  Valetudo
//
//  Created by David Klopp on 16.09.25.
//
import UIKit

struct VTConsumableItem: Hashable {
    let type: VTConsumableType
    let subType: VTConsumableSubType
    let remaining: VTConsumableRemaining
    let maxValue: VTConsumableRemaining?

    var title: String {
        "\(subType.description.capitalized) \(type.description.capitalized)"
    }

    var subtitle: String {
        remaining.description
    }

    var icon: UIImage? {
        nil
    }

    var progress: Double {
        switch (maxValue?.unit, remaining.unit) {
        case (_, .percent):
            return remaining.value / 100.0
        case (.minutes, .minutes):
            guard let value = maxValue?.value else {
                log(message: "Could not get progress for \(self).", forSubsystem: .consumable, level: .error)
                return 0.0
            }
            return 1.0 - (remaining.value / value)
        default:
            log(message: "Could not get progress for \(self).", forSubsystem: .consumable, level: .error)
            return 0.0
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        hasher.combine(subType)
        hasher.combine(remaining.value)
        hasher.combine(remaining.unit)
    }
}
