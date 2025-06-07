//
//  VTShapeLayer.swift
//  Valetudo
//
//  Created by David Klopp on 17.05.25.
//
import Foundation
import CoreGraphics
import QuartzCore

protocol VTShapeLayerProtocol: CAShapeLayer {
    associatedtype T
    var data: T! { get }
    var center: CGPoint { get }
    func contains(_ point: CGPoint) -> Bool
}

class VTShapeLayer<T>: CAShapeLayer, VTShapeLayerProtocol {
    var center: CGPoint { path?.boundingBox.center ?? .zero }
    
    var data: T!
    
    init(data: T!) {
        self.data = data
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
        if let other = layer as? VTShapeLayer {
            self.data = other.data
        }
    }

    override func contains(_ point: CGPoint) -> Bool { return false }
}

class VTEntityShapeLayer: VTShapeLayer<VTEntity> {
    override func contains(_ point: CGPoint) -> Bool {
        // clicks inside the path are okay
        self.path?.boundingBox.contains(point) ?? false
    }
}

class VTLayerShapeLayer: VTShapeLayer<VTLayer> {
    override func contains(_ point: CGPoint) -> Bool {
        self.path?.contains(point) ?? false
    }
}
