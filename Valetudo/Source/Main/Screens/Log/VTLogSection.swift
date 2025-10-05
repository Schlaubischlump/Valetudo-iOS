//
//  VTSystemInformationSection.swift
//  Valetudo
//
//  Created by David Klopp on 16.09.25.
//
import Foundation

enum VTLogSection: Int, CaseIterable {
    case main
    case log
    
    var title: String? {
        switch (self) {
        case .main:    nil
        case .log:  "LOG".localizedCapitalized()
        }
    }
}
