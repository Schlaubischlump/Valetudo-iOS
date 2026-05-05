//
//  VTSystemInformationSection.swift
//  Valetudo
//
//  Created by David Klopp on 16.09.25.
//
import Foundation

enum VTSystemInformationSection: Int, CaseIterable {
    case robot
    case valetudo
    case host
    case runtime

    // detailed sections
    case main
    case keys
    case dependencies

    var title: String? {
        switch self {
        case .robot: "ROBOT".localized()
        case .valetudo: "VALETUDO".localized()
        case .host: "HOST".localized()
        case .runtime: "RUNTIME".localized()
        case .main: nil
        case .keys: "KEYS".localized()
        case .dependencies: "DEPENDENCIES".localized()
        }
    }
}
