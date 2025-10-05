//
//  VTSystemInformationItem.swift
//  Valetudo
//
//  Created by David Klopp on 16.09.25.
//
import Foundation
import UIKit


enum VTUpdaterItem: Sendable, Hashable {
    // Detailed information
    case currentVersion(_ versionString: String)
    case currentCommit(_ commitString: String)
    case updaterProvider(_ provider: [VTUpdaterProvider])
    
    // Show a progress spinner
    case loading(title: String)
    // Show a progress bar
    case progress(title: String, progress: CGFloat)
    // Generic Update state with title and icon
    case updateState(title: String, image: UIImage?, tintColor: UIColor)
    // Update available screen with a changelog
    case updateAvailable(title: String, image: UIImage?, version: String, changelog: String)
    // Start the install process
    case installUpdate(title: String, image: UIImage?, version: String)
}
