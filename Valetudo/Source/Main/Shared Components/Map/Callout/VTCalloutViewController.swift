//
//  VTCalloutViewController.swift
//  Valetudo
//
//  Created by David Klopp on 17.05.25.
//

import UIKit

/// Popover view controller that hosts either a text or image-based map callout view.
class VTCalloutViewController: UIViewController {
    private let calloutView: VTCalloutView

    // private var popoverObserver: NSObjectProtocol?

    // MARK: - Init

    /// Creates a text-only map callout.
    init(title: String, subtitle: String) {
        calloutView = VTTextCalloutView(title: title, subtitle: subtitle)
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .popover
    }

    /// Creates an image-backed map callout with optional loading state.
    init(title: String, subtitle: String, image: UIImage? = nil, isLoadingImage: Bool = false) {
        calloutView = VTImageCalloutView(
            title: title,
            subtitle: subtitle,
            image: image,
            isLoadingImage: isLoadingImage
        )
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .popover
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Life Cycle

    /// Installs the configured callout view as the controller's root view.
    override func loadView() {
        view = calloutView
    }

    /// Wires the close action and computes the initial popover size.
    override func viewDidLoad() {
        super.viewDidLoad()
        calloutView.onClose = { [weak self] in
            self?.dismiss(animated: true)
        }
        updatePreferredContentSize()
        /* popoverObserver = observe(\.popoverPresentationController) { _, change in
             guard let popover = change.newValue else { return }
             Task { @MainActor [popover] in
                 print("Changed....")
                 popover?.delegate = self
             }
         } */
    }

    // MARK: - Content Updates

    /// Updates the content of a text-only callout and recomputes its preferred popover size.
    func update(title: String, subtitle: String) {
        calloutView.configure(title: title, subtitle: subtitle)
        updatePreferredContentSize()
    }

    /// Updates the content of an image callout and recomputes its preferred popover size.
    func update(title: String, subtitle: String, image: UIImage? = nil, isLoadingImage: Bool = false) {
        calloutView.configure(title: title, subtitle: subtitle)
        (calloutView as? VTImageCalloutView)?.configureImage(image: image, isLoadingImage: isLoadingImage)
        updatePreferredContentSize()
    }

    /// Measures the hosted callout view and publishes the resulting preferred popover size.
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

// MARK: - UIPopoverPresentationControllerDelegate

extension VTCalloutViewController: UIPopoverPresentationControllerDelegate {
    /// Keeps callouts presented as popovers instead of adapting to another presentation style.
    func adaptivePresentationStyle(for _: UIPresentationController) -> UIModalPresentationStyle {
        .none
    }
}
