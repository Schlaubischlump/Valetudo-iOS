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
        self.calloutView = VTTextCalloutView(title: title, subtitle: subtitle)
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .popover
    }
    
    init(title: String, subtitle: String, image: UIImage? = nil, isLoadingImage: Bool = false) {
        self.calloutView = VTImageCalloutView(
            title: title,
            subtitle: subtitle,
            image: image,
            isLoadingImage: isLoadingImage
        )
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
        calloutView.onClose = { [weak self] in
            self?.dismiss(animated: true)
        }
        updatePreferredContentSize()
    }
    
    func update(title: String, subtitle: String) {
        calloutView.configure(title: title, subtitle: subtitle)
        updatePreferredContentSize()
    }
    
    func update(title: String, subtitle: String, image: UIImage? = nil, isLoadingImage: Bool = false) {
        calloutView.configure(title: title, subtitle: subtitle)
        (calloutView as? VTImageCalloutView)?.configureImage(image: image, isLoadingImage: isLoadingImage)
        updatePreferredContentSize()
    }
    
    private func updatePreferredContentSize() {
        let targetWidth = calloutView.preferredContentWidth ?? UIView.layoutFittingCompressedSize.width
        let horizontalPriority: UILayoutPriority = calloutView.preferredContentWidth == nil ? .fittingSizeLevel : .required
        
        preferredContentSize = calloutView.systemLayoutSizeFitting(
            CGSize(width: targetWidth, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: horizontalPriority,
            verticalFittingPriority: .fittingSizeLevel
        )
    }
}
