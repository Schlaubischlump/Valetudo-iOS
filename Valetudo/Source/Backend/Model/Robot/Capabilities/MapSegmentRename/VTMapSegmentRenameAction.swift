//
//  VTMapSegmentRenameAction.swift
//  Valetudo
//
//  Created by David Klopp on 17.07.26.
//

import Foundation

enum VTMapSegmentRenameActionType: String, Encodable, Hashable {
    case renameSegment = "rename_segment"
}

struct VTMapSegmentRenameAction: Encodable, Hashable {
    let action: VTMapSegmentRenameActionType = .renameSegment
    let segmentID: String
    let name: String

    enum CodingKeys: String, CodingKey {
        case action
        case segmentID = "segment_id"
        case name
    }
}
