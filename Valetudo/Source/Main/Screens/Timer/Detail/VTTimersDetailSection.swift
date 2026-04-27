//
//  VTSystemInformationSection.swift
//  Valetudo
//
//  Created by David Klopp on 16.09.25.
//
import Foundation

enum VTTimersDetailSection: RawRepresentable, Hashable {
    typealias RawValue = Int

    case general
    case schedule
    case preActions
    case group(id: Int)
    case action

    init?(rawValue: Int) {
        self = switch rawValue {
        case -1: .general
        case -2: .schedule
        case -3: .preActions
        case -4: .action
        default: .group(id: rawValue)
        }
    }

    var rawValue: Int {
        switch self {
        case .general: -1
        case .schedule: -2
        case .preActions: -3
        case .action: -4
        case let .group(id): id
        }
    }

    var title: String? {
        switch self {
        case .general: "GENERAL".localized()
        case .schedule: "SCHEDULE".localized()
        case .preActions: "PRE_ACTIONS".localized()
        case .action: "ACTION".localized()
        case .group: ""
        }
    }
}

extension VTTimersDetailSection {
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.general, .general), (.schedule, .schedule), (.preActions, .preActions), (.action, .action): true
        case let (.group(a), .group(b)): a == b
        default: false
        }
    }
}

extension VTTimersDetailSection {
    func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}
