//
//  Untitled.swift
//  Valetudo
//
//  Created by David Klopp on 24.05.25.
//
import Foundation

public struct VTMapSegmentationCapability: Encodable {
    let action: String
    let segmentIDs: [String]
    let iterations: Int
    let customOrder: Bool

    enum CodingKeys: String, CodingKey {
        case action
        case segmentIDs = "segment_ids"
        case iterations
        case customOrder
    }

    public init(action: String = "start_segment_action",
                segmentIDs: [String],
                iterations: Int,
                customOrder: Bool) {
        self.action = action
        self.segmentIDs = segmentIDs
        self.iterations = iterations
        self.customOrder = customOrder
    }
}
