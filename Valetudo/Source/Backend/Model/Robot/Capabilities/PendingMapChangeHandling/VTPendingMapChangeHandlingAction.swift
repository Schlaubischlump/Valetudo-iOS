//
//  VTPendingMapChangeHandlingAction.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//

enum VTPendingMapChangeHandlingActionType: String, Encodable, Hashable {
    case accept
    case reject
}

struct VTPendingMapChangeHandlingAction: Encodable, Hashable {
    let action: VTPendingMapChangeHandlingActionType
}
