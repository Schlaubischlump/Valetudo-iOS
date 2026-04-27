//
//  VTSystemInformationItem.swift
//  Valetudo
//
//  Created by David Klopp on 16.09.25.
//
import Foundation
import UIKit

enum VTLogItem: Hashable {
    case updateLogLevel(presets: [String])
    case logLine(date: Date, level: String, message: String)
}
