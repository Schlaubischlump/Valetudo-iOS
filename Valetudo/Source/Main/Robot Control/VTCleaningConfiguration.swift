//
//  VTCleaningConfiguration.swift
//  Valetudo
//
//  Created by David Klopp on 05.05.26.
//

import UIKit

enum VTCleaningConfiguration {
    case full
    case segments(ids: [String], customOrder: Bool, iterations: Int)
    case zones([VTZoneCleaningZone], iterations: Int)
    case goTo(VTMapCoordinate)

    var canChangeIterations: Bool {
        switch self {
        case .full, .goTo: false
        case .segments(ids: _, customOrder: _, iterations: _), .zones(_, iterations: _): true
        }
    }

    var iterations: Int {
        switch self {
        case .full, .goTo: 1
        case .segments(ids: _, customOrder: _, iterations: let iter), let .zones(_, iterations: iter): iter
        }
    }

    func appending(segmentId: String) -> VTCleaningConfiguration {
        switch self {
        case .full:
            .segments(ids: [segmentId], customOrder: false, iterations: 1)
        case let .segments(ids: ids, customOrder: order, iterations: iters):
            .segments(ids: ids + [segmentId], customOrder: order, iterations: iters)
        case .zones, .goTo:
            .segments(ids: [segmentId], customOrder: false, iterations: 1)
        }
    }

    func updated(iterations: Int) -> VTCleaningConfiguration {
        switch self {
        case .full:
            .full
        case .segments(ids: let ids, customOrder: let order, iterations: _):
            .segments(ids: ids, customOrder: order, iterations: iterations)
        case .zones(let zones, iterations: _):
            .zones(zones, iterations: iterations)
        case let .goTo(coordinate):
            .goTo(coordinate)
        }
    }

    func removing(segmentId: String) -> VTCleaningConfiguration {
        switch self {
        case .full:
            return .full
        case .segments(ids: var ids, customOrder: let order, iterations: let iters):
            let idx = ids.firstIndex(of: segmentId)!
            ids.remove(at: idx)
            if ids.isEmpty {
                return .full
            } else {
                return .segments(ids: ids, customOrder: order, iterations: iters)
            }
        case .zones, .goTo:
            return .full
        }
    }

    var controlMode: VTRobotControlMode {
        switch self {
        case .full, .segments: .segment
        case .zones: .zone
        case .goTo: .goTo
        }
    }
}
