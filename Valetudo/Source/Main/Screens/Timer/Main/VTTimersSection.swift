//
//  VTSystemInformationSection.swift
//  Valetudo
//
//  Created by David Klopp on 16.09.25.
//
import Foundation

enum VTTimersSection: Hashable {
    case timer(id: String)

    var id: String {
        switch self {
        case let .timer(id): id
        }
    }

    var title: String? {
        "TIMER".localized()
    }
}
