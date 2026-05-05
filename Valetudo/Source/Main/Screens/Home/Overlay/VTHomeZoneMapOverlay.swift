//
//  VTHomeZoneMapOverlay.swift
//  Valetudo
//
//  Created by David Klopp on 04.05.26.
//
import UIKit

/// Simple white rectangular overlay used to represent a zone-cleaning area on the home map.
@MainActor
final class VTHomeZoneMapOverlay: VTResizableRectangularMapOverlay {
    init(rect: CGRect) {
        super.init(
            rect: rect,
            strokeColor: .white,
            fillColor: UIColor.white.withAlphaComponent(0.18)
        )
    }
}
