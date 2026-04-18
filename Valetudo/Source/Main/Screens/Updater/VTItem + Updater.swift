//
//  VTSystemInformationItem.swift
//  Valetudo
//
//  Created by David Klopp on 16.09.25.
//
import Foundation
import UIKit


struct VTCurrentVersionItem: VTItem {
    let id: String
    let versionString: String
}

struct VTCurrentCommitItem: VTItem {
    let id: String
    let commitString: String
}

typealias VTUpdaterProviderItem = VTDropDownItem<VTUpdaterProvider>

struct VTUpdateStateItem: VTItem {
    let id: String
    let title: String
    let image: UIImage?
    let tintColor: UIColor
}

struct VTUpdateAvailableItem: VTItem {
    let id: String
    let title: String
    let image: UIImage?
    let version: String
    let changelog: String
}

struct VTInstallUpdateItem: VTItem {
    let id: String
    let title: String
    let image: UIImage?
    let version: String
}

extension VTAnyItem {
    /// Version information
    static func currentVersion(_ id: String, versionString: String) -> VTAnyItem {
        VTAnyItem(VTCurrentVersionItem(id: id, versionString: versionString))
    }
    
    /// Commit information
    static func currentCommit(_ id: String, commitString: String) -> VTAnyItem {
        VTAnyItem(VTCurrentCommitItem(id: id, commitString: commitString))
    }
    
    /// Update provider selection information
    static func updaterProvider(_ id: String, provider: VTUpdaterProvider) -> VTAnyItem {
        VTAnyItem(VTUpdaterProviderItem(id: id, active: provider, options: VTUpdaterProvider.allCases))
    }
    
    /// Generic Update state with title and icon
    static func updateState(_ id: String, title: String, image: UIImage?, tintColor: UIColor) -> VTAnyItem {
        VTAnyItem(VTUpdateStateItem(id: id, title: title, image: image, tintColor: tintColor))
    }
    
    /// Update available screen with a changelog
    static func updateAvailable(_ id: String, title: String, image: UIImage?, version: String, changelog: String) -> VTAnyItem {
        VTAnyItem(VTUpdateAvailableItem(id: id, title: title, image: image, version: version, changelog: changelog))
    }
    
    static func installUpdate(_ id: String, title: String, image: UIImage?, version: String) -> VTAnyItem {
        VTAnyItem(VTInstallUpdateItem(id: id, title: title, image: image, version: version))
    }
}
