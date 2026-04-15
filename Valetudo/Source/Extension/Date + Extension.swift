//
//  Date + Extension.swift
//  Valetudo
//
//  Created by David Klopp on 15.04.26.
//
import Foundation

extension Date {
        
    /// Extract (hour, minute) in local time
    func toLocalHourMinute() -> (Int, Int) {
        return extract(in: .current)
    }
    
    /// Extract (hour, minute) in UTC
    func toUTCHourMinute() -> (Int, Int) {
        return extract(in: .utc)
    }
    
    private func extract(in timeZone: TimeZone) -> (Int, Int) {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        
        let comps = calendar.dateComponents([.hour, .minute], from: self)
        return (comps.hour ?? 0, comps.minute ?? 0)
    }
    
    
    // MARK: - Create
    
    /// Create Date from local (hour, minute)
    static func fromLocal(hour: Int, minute: Int) -> Date? {
        return build(hour: hour, minute: minute, timeZone: .current)
    }
    
    /// Create Date from UTC (hour, minute)
    static func fromUTC(hour: Int, minute: Int) -> Date? {
        return build(hour: hour, minute: minute, timeZone: .utc)
    }
    
    private static func build(hour: Int, minute: Int, timeZone: TimeZone) -> Date? {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        
        let now = Date()
        var comps = calendar.dateComponents([.year, .month, .day], from: now)
        comps.hour = hour
        comps.minute = minute
        
        return calendar.date(from: comps)
    }
}
