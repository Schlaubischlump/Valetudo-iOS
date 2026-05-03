//
//  VTDoNotDisturbTime.swift
//  Valetudo
//

import Foundation

struct VTDoNotDisturbTime: Codable, Hashable {
    let hour: Int
    let minute: Int
}

extension VTDoNotDisturbTime {
    var formattedValue: String {
        String(format: "%02d:%02d", hour, minute)
    }
}
