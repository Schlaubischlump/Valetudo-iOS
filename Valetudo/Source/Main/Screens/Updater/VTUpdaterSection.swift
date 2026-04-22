//
//  VTSystemInformationSection.swift
//  Valetudo
//
//  Created by David Klopp on 16.09.25.
//
import Foundation

enum VTUpdaterSection: Int, CaseIterable {
    case main
    case update
    
    var title: String? {
        switch (self) {
        case .main:    nil
        case .update:  "UPDATE".localized()
        }
    }
}
