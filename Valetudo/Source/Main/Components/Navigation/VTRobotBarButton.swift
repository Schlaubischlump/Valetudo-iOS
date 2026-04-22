//
//  VTRobotBarButton.swift
//  Valetudo
//
//  Created by David Klopp on 22.04.26.
//
import UIKit

class VTRobotBarButton: UIBarButtonItem {
    private weak var parentViewController: UIViewController?
    
    init(parentViewController: UIViewController) {
        self.parentViewController = parentViewController
        super.init()
        self.image = UIImage(systemName: "robotic.vacuum.fill")
        self.target = self
        self.action = #selector(goBackToRobotsListScreen(_:))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func goBackToRobotsListScreen(_ sender: Any) {
        guard let sceneDelegate = parentViewController?.view.window?.windowScene?.delegate as? VTSceneDelegate else {
            return
        }
        
        sceneDelegate.showRobotsListScreen(animated: true)
    }
}
