//
//  VTQuirksOptionsSection.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//

enum VTQuirksOptionsSection: Int, CaseIterable {
    case main

    var title: String {
        switch self {
        case .main: ""
        }
    }
}
