//
//  VTLineMapOverlay.swift
//  Valetudo
//
//  Created by David Klopp on 29.04.26.
//
import Foundation
import UIKit

/// Transient line overlay used for split guides.
@MainActor
final class VTSplitLineMapOverlay: VTLineMapOverlay {
    override var allowsDeselection: Bool {
        false
    }

    init(
        center: CGPoint,
        angle: CGFloat = 0.0,
        length: CGFloat,
        thickness: CGFloat,
        bodyColor: UIColor = .white,
        strokeColor: UIColor = .black,
        strokeWidth: CGFloat = 1.5
    ) {
        let startPoint = CGPoint(
            x: center.x - cos(angle) * length / 2,
            y: center.y - sin(angle) * length / 2
        )
        let endPoint = CGPoint(
            x: center.x + cos(angle) * length / 2,
            y: center.y + sin(angle) * length / 2
        )

        super.init(
            startPoint: startPoint,
            endPoint: endPoint,
            minimumLength: 28.0,
            style: .init(
                bodyColor: bodyColor.cgColor,
                strokeColor: strokeColor.cgColor,
                thickness: thickness,
                strokeWidth: strokeWidth,
                insertionBehavior: .keepCurrentCenter
            )
        )
    }
}
