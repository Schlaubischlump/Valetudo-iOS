//
//  VTShapeLayer.swift
//  Valetudo
//
//  Created by David Klopp on 17.05.25.
//
import CoreGraphics
import Foundation
import QuartzCore

protocol VTShapeLayerProtocol: CAShapeLayer {
    associatedtype T
    var data: T! { get }
    var center: CGPoint { get }
    func contains(_ point: CGPoint) -> Bool
}

class VTShapeLayer<T>: CAShapeLayer, VTShapeLayerProtocol {
    var center: CGPoint {
        path?.boundingBox.center ?? .zero
    }

    var data: T!

    init(data: T!) {
        self.data = data
        super.init()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(layer: Any) {
        super.init(layer: layer)
        if let other = layer as? VTShapeLayer {
            data = other.data
        }
    }

    override func contains(_: CGPoint) -> Bool {
        false
    }
}

class VTEntityShapeLayer: VTShapeLayer<VTEntity> {
    override func contains(_ point: CGPoint) -> Bool {
        // clicks inside the path are okay
        path?.boundingBox.contains(point) ?? false
    }
}

class VTLayerShapeLayer: VTShapeLayer<VTLayer> {
    override func contains(_ point: CGPoint) -> Bool {
        path?.contains(point) ?? false
    }
}
