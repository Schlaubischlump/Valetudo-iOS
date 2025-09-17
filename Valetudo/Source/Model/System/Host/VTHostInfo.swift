//
//  VTHostInfo.swift
//  Valetudo
//
//  Created by David Klopp on 15.09.25.
//
import Foundation

struct VTMemory: Codable, Sendable {
    let total: Double
    let free: Double
    let valetudo_current: Double
    let valetudo_max: Double
    
    var system: Double {
        total - free - valetudo_current
    }
    
    var real_valetudo_max: Double {
        valetudo_max - valetudo_current
    }
    
    var real_free: Double {
        free - real_valetudo_max
    }
    
    static var zero: VTMemory {
        VTMemory(total: 1.0, free: 0.0, valetudo_current: 0.0, valetudo_max: 0.0)
    }
}

struct VTLoad: Codable, Sendable {
    let one: Double
    let five: Double
    let fifteen: Double

    private enum CodingKeys: String, CodingKey, Sendable {
        case one = "1"
        case five = "5"
        case fifteen = "15"
    }
}

struct VTUsage: Codable, Sendable {
    let user: Double
    let nice: Double
    let sys: Double
    let idle: Double
    let irq: Double
}

struct VTCPU: Codable, Sendable {
    let usage: VTUsage
}

struct VTHostInfo: Codable, Sendable {
    let hostname: String
    let arch: String
    let mem: VTMemory
    let uptime: Int
    let load: VTLoad
    let cpus: [VTCPU]
}
