//
//  VTRuntimeInfo.swift
//  Valetudo
//
//  Created by David Klopp on 15.09.25.
//
import Foundation

public struct VTRuntimeInfo: Codable, Sendable {
    let uptime: Int
    let argv: [String]
    let execArgv: [String]
    let execPath: String
    let uid: Int
    let gid: Int
    let pid: Int
    let versions: [String: String]
    let env: [String: String]
}
