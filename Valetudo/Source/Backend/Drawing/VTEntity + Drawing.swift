//
//  VTEntity + Drawing.swift
//  Valetudo
//
//  Created by David Klopp on 17.05.25.
//
import CoreGraphics
import Foundation

extension VTEntity {
    var centerPoint: CGPoint? {
        guard points.count == 2 else { return nil }
        return CGPoint(x: Double(points[0]), y: Double(points[1]))
    }

    var angleInDegree: CGFloat {
        CGFloat(metaData["angle"]?.intValue ?? 0)
    }
}

extension VTEntity: Comparable {
    public static func < (lhs: VTEntity, rhs: VTEntity) -> Bool {
        lhs.type.order < rhs.type.order
    }

    public static func == (lhs: VTEntity, rhs: VTEntity) -> Bool {
        lhs.type == rhs.type
    }
}
