//
//  VTSceneDelegate + NSToolbar.swift
//  Valetudo
//
//  Created by David Klopp on 18.03.25.
//
//

import UIKit

#if targetEnvironment(macCatalyst)
    import AppKit

    extension VTSceneDelegate: NSToolbarDelegate {
        func toolbarItems() -> [NSToolbarItem.Identifier] {
            [.toggleSidebar]
        }

        func toolbarAllowedItemIdentifiers(_: NSToolbar) -> [NSToolbarItem.Identifier] {
            toolbarItems()
        }

        func toolbarDefaultItemIdentifiers(_: NSToolbar) -> [NSToolbarItem.Identifier] {
            toolbarItems()
        }

        func toolbar(_: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar _: Bool) -> NSToolbarItem? {
            NSToolbarItem(itemIdentifier: itemIdentifier)
        }
    }
#endif
