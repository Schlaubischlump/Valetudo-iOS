//
//  VTViewController.swift
//  Valetudo
//
//  Created by David Klopp on 28.03.26.
//
import UIKit

class VTCollectionViewController: UICollectionViewController {
    
    @objc
    private func sceneWillEnterForeground(_ notification: Notification) {
        Task {
            guard self.viewIfLoaded?.window != nil else { return }
            await self.reconnectAndRefresh()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // We don't need any cleanup, since we are using target / action pattern
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sceneWillEnterForeground(_:)),
            name: .scene​Did​Request​Refresh​After​Background,
            object: nil
        )
    }
    
    @MainActor
    func reconnectAndRefresh() async {
        // Override me
    }
}
