//
//  VTViewController.swift
//  Valetudo
//
//  Created by David Klopp on 28.03.26.
//
import UIKit

class VTViewController: UIViewController, VTAppEventObserver {
    var observer: (any NSObjectProtocol)?
    
    func subscribe(_ handler: @escaping @Sendable (Notification) -> Void) {
        observer = NotificationCenter.default.addObserver(
            forName: .sceneWillEnterForeground,
            object: nil,
            queue: .main,
            using: handler)
    }
    
    func unsubscribe() {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    deinit {
        DispatchQueue.main.sync {
            unsubscribe()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subscribe { [weak self] _ in
            DispatchQueue.main.async {
                guard let self, self.viewIfLoaded?.window != nil else { return }
                self.reconnectAndRefresh()
            }
        }
    }
    
    func reconnectAndRefresh() {
        // Override me
    }
}
