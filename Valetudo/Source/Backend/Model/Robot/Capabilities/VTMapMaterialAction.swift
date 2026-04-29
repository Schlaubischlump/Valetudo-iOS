///
///  VTMapMaterialAction.swift
///  Valetudo
///
///  Created by David Klopp on 29.04.26.
///
enum VTMapMaterialActionType: String, Encodable, Hashable {
    case setMaterial = "set_material"
}

struct VTMapMaterialAction: Encodable, Hashable {
    let action: VTMapMaterialActionType
    let segmentID: String
    let material: VTMaterial

    init(action: VTMapMaterialActionType = .setMaterial, segmentID: String, material: VTMaterial) {
        self.segmentID = segmentID
        self.material = material
        self.action = action
    }

    enum CodingKeys: String, CodingKey {
        case action
        case segmentID = "segment_id"
        case material
    }
}
