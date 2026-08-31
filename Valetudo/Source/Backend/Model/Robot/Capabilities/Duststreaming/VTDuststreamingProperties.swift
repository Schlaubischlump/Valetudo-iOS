//
//  VTDuststreamingProperties.swift
//  Valetudo
//
//  Created by David Klopp on 06.05.26.
//

import Foundation

public struct VTDuststreamingProperties: Codable, Sendable, Hashable {
    public let width: Int
    public let height: Int
    public let duststreamerInstalled: Bool
}
