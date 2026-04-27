//
//  Untitled.swift
//  Valetudo
//
//  Created by David Klopp on 24.05.25.
//
import Foundation

enum VTMapSegmentationActionType: String, Encodable, Hashable, Sendable {
    case startSegmentAction = "start_segment_action"
}

public struct VTMapSegmentationAction: Encodable, Hashable, Sendable {
    let action: VTMapSegmentationActionType = .startSegmentAction
    let segmentIDs: [String]
    let iterations: Int
    let customOrder: Bool

    enum CodingKeys: String, CodingKey {
        case action
        case segmentIDs = "segment_ids"
        case iterations
        case customOrder
    }

    public init(segmentIDs: [String],
                iterations: Int,
                customOrder: Bool) {
        self.segmentIDs = segmentIDs
        self.iterations = iterations
        self.customOrder = customOrder
    }
}
