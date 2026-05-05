//
//  UIViewController + Callout.swift
//  Valetudo
//
//  Created by David Klopp on 05.05.26.
//
import UIKit

extension UIViewController {
    func presentCallout(_ callout: VTCalloutViewController, in view: UIView, at point: CGPoint) {
        guard let popover = callout.popoverPresentationController else { return }
        popover.sourceView = view
        popover.sourceRect = CGRect(origin: point, size: .one)
        popover.permittedArrowDirections = .any
        popover.delegate = callout

        if let presentedCallout = presentedViewController as? VTCalloutViewController {
            presentedCallout.dismiss(animated: false) { [weak self] in
                self?.present(callout, animated: true)
            }
        } else {
            present(callout, animated: true)
        }
    }
}
