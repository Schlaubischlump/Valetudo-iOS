//
//  VTMapSegmentEditAction.swift
//  Valetudo
//
//  Created by David Klopp on 17.07.26.
//

import CoreGraphics
import Foundation

enum VTMapSegmentEditActionType: String, Encodable, Hashable {
    case joinSegments = "join_segments"
    case splitSegment = "split_segment"
}

public struct VTMapCoordinate: Codable, Hashable, Sendable {
    let x: Int
    let y: Int
}

struct VTMapSegmentJoinAction: Encodable, Hashable {
    let action: VTMapSegmentEditActionType = .joinSegments
    let segmentAID: String
    let segmentBID: String

    enum CodingKeys: String, CodingKey {
        case action
        case segmentAID = "segment_a_id"
        case segmentBID = "segment_b_id"
    }
}

struct VTMapSegmentSplitAction: Encodable, Hashable {
    let action: VTMapSegmentEditActionType = .splitSegment
    let segmentID: String
    let pointA: VTMapCoordinate
    let pointB: VTMapCoordinate

    enum CodingKeys: String, CodingKey {
        case action
        case segmentID = "segment_id"
        case pointA = "pA"
        case pointB = "pB"
    }
}
