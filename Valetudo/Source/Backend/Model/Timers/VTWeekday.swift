//
//  VTWeekday.swift
//  Valetudo
//
//  Created by David Klopp on 13.04.26.
//
import Foundation

public enum VTWeekday: Int, CaseIterable, Codable, Hashable, Sendable, Describable {
    case sunday = 0
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday

    public static var allNormalizedCases: [VTWeekday] {
        VTWeekday.allCases.shiftedLeft()
    }

    /// Normalized index when the week starts at Monday instead of Sunday
    public var normalizedIndex: Int {
        (rawValue + 6) % 7
    }

    public var index: Int {
        rawValue
    }

    public var description: String {
        Calendar.current.shortWeekdaySymbols[index]
    }

    public init?(normalizedIndex: Int) {
        guard let day = VTWeekday(rawValue: (normalizedIndex + 1) % 7) else {
            return nil
        }
        self = day
    }
}
