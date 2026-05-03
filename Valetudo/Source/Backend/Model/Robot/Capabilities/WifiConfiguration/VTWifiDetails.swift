//
//  VTWifiDetails.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//

struct VTWifiDetails: Codable, Hashable {
    enum Frequency: String, Codable, Hashable {
        case twoPointFourGHz = "2.4ghz"
        case fiveGHz = "5ghz"
    }

    let ssid: String
    let bssid: String?
    let downspeed: Int?
    let upspeed: Int?
    let signal: Int?
    let ips: [String]?
    let frequency: Frequency?
}
