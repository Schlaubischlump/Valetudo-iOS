//
//  VTValetudoDataPoint.swift
//  Valetudo
//
//  Created by David Klopp on 22.05.25.
//
import Foundation

public enum VTValetudoDataPointType: String, Decodable, Sendable, Hashable, Describable {
    case time
    case area
    case count
    
    public var description: String {
        switch (self) {
        case .time:  "TIME".localized()
        case .area:  "AREA".localized()
        case .count: "COUNT".localized()
        }
    }
}

public struct VTValetudoDataPoint: Decodable, Sendable, Hashable, Describable {
    let __class: String
    let metaData: [String: VTAnyCodable]
    let timestamp: Date
    let type: VTValetudoDataPointType
    let value: Int
    
    var areaInM2: Float? {
        guard type == .area else { return nil }
        return Float(value) / 10000
    }
    
    var timeString: String? {
        guard type == .time else { return nil }
        let hours = value / 3600
        let minutes = (value % 3600) / 60
        let seconds = value % 60
        let hString = String(format: "%02dh", hours)
        let mString = String(format: "%02dm", minutes)
        let sString = String(format: "%02ds", seconds)
        return "\(hString) \(mString) \(sString)"
    }
    
    public var description: String {
        switch (self.type) {
        case .time:  timeString ?? ""
        case .area:  areaInM2.map({ String(format: "%06.2f m\u{00B2}", $0) }) ?? ""
        case .count: String(value)
        }
    }
            
}
