//
//  UIApplication + Extension.swift
//  Valetudo
//
//  Created by David Klopp on 22.04.26.
//
import UIKit

extension UIApplication {
    var displayName: String {
        let infoDictionary = Bundle.main.localizedInfoDictionary ?? Bundle.main.infoDictionary
        return infoDictionary?["CFBundleDisplayName"] as? String
            ?? infoDictionary?["CFBundleName"] as? String
            ?? ProcessInfo.processInfo.processName
    }
}
