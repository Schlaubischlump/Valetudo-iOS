//
//  VTCleanRouteControlProperties.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//

public struct VTCleanRouteControlProperties: Decodable, Sendable, Hashable {
    let supportedRoutes: [VTCleanRoute]
    let mopOnly: [VTCleanRoute]
    let oneTime: [VTCleanRoute]
}
