//
//  VTNoGoAreaMapOverlay.swift
//  Valetudo
//
//  Created by David Klopp on 01.05.26.
//
import UIKit

@MainActor
final class VTNoGoAreaMapOverlay: VTResizableRectangularMapOverlay {
    init(rect: CGRect) {
        super.init(
            rect: rect,
            strokeColor: .systemRed,
            fillColor: UIColor.systemRed.withAlphaComponent(0.16)
        )
    }
}
