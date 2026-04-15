//
//  VTWeekday.swift
//  Valetudo
//
//  Created by David Klopp on 13.04.26.
//
import Foundation

enum VTWeekday: Int, CaseIterable, Codable, Hashable, Sendable, Describable {
    case sunday = 0
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    
    static var allNormalizedCases: [VTWeekday] {
        VTWeekday.allCases.shiftedLeft()
    }
    
    /// Normalized index when the week starts at Monday instead of Sunday
    var normalizedIndex: Int {
        (rawValue + 6) % 7
    }
    
    var index: Int {
        return rawValue
    }
    
    var description: String {
        Calendar.current.shortWeekdaySymbols[index]
    }
    
    init?(normalizedIndex: Int) {
        guard let day = VTWeekday(rawValue: (normalizedIndex + 1) % 7) else {
            return nil
        }
        self = day
    }
}
