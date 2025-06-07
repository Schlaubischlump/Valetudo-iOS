//
//  VTCalloutViewController.swift
//  Valetudo
//
//  Created by David Klopp on 17.05.25.
//
import UIKit

class VTCalloutViewController: UIViewController {
    
    private let calloutView: VTCalloutView
    
    init(title: String, subtitle: String) {
        self.calloutView = VTCalloutView(title: title, subtitle: subtitle)
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .popover
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = calloutView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preferredContentSize = calloutView.intrinsicContentSize
    }
    
    // Optional: update title/subtitle later
    func update(title: String, subtitle: String) {
        calloutView.configure(title: title, subtitle: subtitle)
    }
}
