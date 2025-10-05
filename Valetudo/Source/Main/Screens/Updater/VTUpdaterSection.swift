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
        switch (self) {
        case .robot:        "ROBOT".localizedCapitalized()
        case .valetudo:     "VALETUDO".localizedCapitalized()
        case .host:         "HOST".localizedCapitalized()
        case .runtime:      "RUNTIME".localizedCapitalized()
            
        case .main:         nil
        case .keys:         "KEYS".localizedCapitalized()
        case .dependencies: "DEPENDENCIES".localizedCapitalized()
        }
    }
}
