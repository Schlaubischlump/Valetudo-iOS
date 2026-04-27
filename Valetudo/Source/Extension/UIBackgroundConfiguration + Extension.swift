//
//  UIBackgroundConfiguration + Extension.swift
//  Valetudo
//
//  Created by David Klopp on 27.04.26.
//
import UIKit

extension UIBackgroundConfiguration {
    static func adaptiveListCell() -> UIBackgroundConfiguration {
        var config = UIBackgroundConfiguration.listCell()
        #if targetEnvironment(macCatalyst)
        config.backgroundColor = .macOSCellBackground
        #endif
        return config
    }
}
