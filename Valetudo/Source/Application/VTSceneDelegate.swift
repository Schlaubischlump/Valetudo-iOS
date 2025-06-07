//
//  VTSceneDelegate.swift
//  Valetudo
//
//  Created by David Klopp on 18.03.25.
//  
//

import UIKit

class VTSceneDelegate: UIResponder, UIWindowSceneDelegate {
	var window: UIWindow?
	
	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let windowScene = scene as? UIWindowScene else {
			fatalError("Expected scene of type UIWindowScene but got an unexpected type")
		}
		window = UIWindow(windowScene: windowScene)

        // TODO: Remove the mock client once you are done
        // TODO: Show MDNS selection to find robots
        let apiClient = VTAPIClient.shared
        guard let apiClient else {
            // TODO: Show error
            return
        }
        
		if let window = window {
            window.rootViewController = VTSplitViewController(client: apiClient, style: .doubleColumn)

#if targetEnvironment(macCatalyst)
			
			let toolbar = NSToolbar(identifier: NSToolbar.Identifier("VTSceneDelegate.Toolbar"))
			toolbar.delegate = self
			toolbar.displayMode = .iconOnly
			toolbar.allowsUserCustomization = false
			
			windowScene.titlebar?.toolbar = toolbar
			windowScene.titlebar?.toolbarStyle = .unified
			
#endif
			
			window.makeKeyAndVisible()
		}
	}
}
