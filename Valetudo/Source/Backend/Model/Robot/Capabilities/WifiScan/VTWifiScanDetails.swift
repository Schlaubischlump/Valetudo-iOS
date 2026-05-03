//
//  VTWifiScanDetails.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//

struct VTWifiScanDetails: Decodable, Hashable {
    let ssid: String
    let signal: Int
}
