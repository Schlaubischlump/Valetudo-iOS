//
//  VTNoMopAreaMapOverlay.swift
//  Valetudo
//
//  Created by David Klopp on 01.05.26.
//
import UIKit

@MainActor
final class VTNoMopAreaMapOverlay: VTRectangularVirtualRestrictionMapOverlay {
    init(rect: CGRect) {
        super.init(
            rect: rect,
            strokeColor: .systemBlue,
            fillColor: UIColor.systemBlue.withAlphaComponent(0.16)
        )
    }
}
