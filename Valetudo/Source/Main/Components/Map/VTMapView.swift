//
//  VTMapView.swift
//  Valetudo
//
//  Created by David Klopp on 15.05.25.
//
import UIKit

fileprivate let pad = 10.0

@MainActor
class VTMapView: UIView {
    private(set) var data: VTMapData
    private var mapLayer: CALayer
    private(set) var selectedLayers: Set<VTLayer> = []
    
    var onLayerSelectionChange: ((VTLayer, Bool) async -> Bool)?
    var onEntityClicked: ((VTEntity, CGPoint) async -> Bool)?

    init(frame: CGRect, data: VTMapData) {
        self.data = data
        
        let scale = UIScreen.main.scale
        mapLayer = data.toLayer(fitting: frame.size.insetBy(dx: pad, dy: pad), screenScale: scale)

        // use the size of the mapLayer to get a fitting size for the parent
        let size = mapLayer.frame.size

        super.init(frame: CGRect(origin: frame.origin, size: size.insetBy(dx: -pad, dy: -pad)))

        mapLayer.position = CGPoint(x: pad/2.0, y: pad/2.0)
        layer.addSublayer(mapLayer)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapGesture)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func clearSelection() async {
        for layer in selectedLayers {
            await toggleLayerSelection(for: layer, in: shapeLayerForVTLayer(vtLayer: layer)!, triggerCallback: false)
        }
    }
    
    @MainActor
    public func updateData(data: VTMapData) async {
        let scale = UIScreen.main.scale
        let newMapLayer = data.toLayer(fitting: frame.size.insetBy(dx: pad, dy: pad), screenScale: scale)
        newMapLayer.position = mapLayer.position
        let transform = mapLayer.transform
        mapLayer.removeFromSuperlayer()
        mapLayer = newMapLayer
        mapLayer.transform = transform
        layer.addSublayer(mapLayer)
    }
    
    public func select(layer: VTLayer) async {
        guard !selectedLayers.contains(layer), let shapeLayer = shapeLayerForVTLayer(vtLayer: layer) else { return }
        await toggleLayerSelection(for: layer, in: shapeLayer, triggerCallback: false)
    }

    public func deselect(layer: VTLayer) async {
        guard selectedLayers.contains(layer), let shapeLayer = shapeLayerForVTLayer(vtLayer: layer) else { return }
        await toggleLayerSelection(for: layer, in: shapeLayer, triggerCallback: false)
    }
    
    private func shapeLayerForVTLayer(vtLayer: VTLayer) -> VTLayerShapeLayer? {
        return mapLayer.sublayers?
            .compactMap({ $0 as? VTLayerShapeLayer })
            .first(where: { vtLayer == $0.data })
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: self)
        Task { [weak self] in
            await self?.handleTapAsync(atLocation: point)
        }
    }

    private func handleTapAsync(atLocation point: CGPoint) async {
        let mapPoint = self.layer.convert(point, to: mapLayer)

        guard let shapeLayers = mapLayer.sublayers?
            .compactMap({ $0 as? (any VTShapeLayerProtocol) })
            .reversed() // reverse to make sure we iterate the topmost layer first
        else { return }
                        
        // figure out which layer was selected
        for shapeLayer in shapeLayers {
            let pathPoint = mapLayer.convert(mapPoint, to: shapeLayer)
            let pointInPath = shapeLayer.contains(pathPoint)
            guard pointInPath else { continue }
            
            if let vtEntity = shapeLayer.data as? VTEntity {
                let position = mapLayer.convert(shapeLayer.center, to: layer)
                if await (onEntityClicked?(vtEntity, position) ?? false) {
                    break
                }
            }
            
            if let vtLayer = shapeLayer.data as? VTLayer {
                if await (toggleLayerSelection(for: vtLayer, in: shapeLayer, triggerCallback: true)) {
                    break
                }
            }
        }
    }

    @discardableResult private func toggleLayerSelection(
        for vtLayer: VTLayer,
        in shapeLayer: any VTShapeLayerProtocol,
        triggerCallback: Bool
    ) async -> Bool {
        guard vtLayer.type == .segment else { return false }
        
        let isSelected: Bool = selectedLayers.contains(vtLayer)
        var updateSelectionColor: Bool = false
        
        if (triggerCallback) {
            if await (onLayerSelectionChange?(vtLayer, isSelected) ?? true) {
                updateSelectionColor = true
            }
        } else {
            updateSelectionColor = true
        }
        
        guard updateSelectionColor else { return false }
        
        if isSelected {
            selectedLayers.remove(vtLayer)
            shapeLayer.fillColor = vtLayer.color
        } else {
            selectedLayers.insert(vtLayer)
            shapeLayer.fillColor = vtLayer.color.darker(by: 0.5)
        }
        return true
    }
}
