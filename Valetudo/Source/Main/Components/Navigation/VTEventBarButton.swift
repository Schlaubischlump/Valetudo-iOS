//
//  VTNotificationButton.swift
//  Valetudo
//
//  Created by David Klopp on 18.04.26.
//
import Foundation
import UIKit

class VTEventBarButton: UIBarButtonItem {
    let client: any VTAPIClientProtocol
    
    init(client: any VTAPIClientProtocol) {
        self.client = client
        super.init()
        self.image = UIImage(systemName: "bell.fill")
        self.target = self
        self.action = #selector(showEventsPopup(_:))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func showEventsPopup(_ sender: UIBarButtonItem) {
        let vc = VTEventsViewController(client: client)
        vc.title = "EVENTS".localizedCapitalized()
        
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .popover

        guard let popover = nav.popoverPresentationController else { return }
        popover.barButtonItem = sender
        popover.permittedArrowDirections = .any
        popover.delegate = vc
    
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root = scene.windows.first?.rootViewController else { return }
        
        let topViewController = root.presentedViewController ?? root
        topViewController.present(nav, animated: true)
    }
}
