//
//  VTRobotControlMode.swift
//  Valetudo
//
//  Created by David Klopp on 09.10.25.
//

enum VTRobotControlMode: CaseIterable {
    case segment
    case zone
    case goTo

    var menuTitle: String {
        switch self {
        case .segment: "SEGMENT".localized()
        case .zone: "ZONE".localized()
        case .goTo: "GO_TO".localized()
        }
    }
}
