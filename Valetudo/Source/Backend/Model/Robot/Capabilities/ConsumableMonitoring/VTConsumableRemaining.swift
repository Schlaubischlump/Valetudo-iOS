//
//  VTConsumableRemaining.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//
import Foundation

public struct VTConsumableRemaining: Codable, Hashable, Sendable, Describable {
    public let value: Double
    public let unit: VTConsumableUnit

    public var description: String {
        switch unit {
        case .percent:
            return "\(Int(value)) %"
        case .minutes:
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.day, .hour, .minute]
            formatter.unitsStyle = .abbreviated
            formatter.zeroFormattingBehavior = [.pad]
            return formatter.string(from: DateComponents(minute: Int(value))) ?? ""
        }
    }
}

extension VTConsumableRemaining: Equatable {}
