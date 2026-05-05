//
//  VTItem + SystemInformation.swift
//  Valetudo
//
//  Created by David Klopp on 16.09.25.
//

import UIKit

struct VTSystemInformationSegmentedBarItem: VTItem {
    let id: String
    let config: VTStackedProgressBarCellContentConfiguration
}

struct VTSystemInformationLinkItem: VTItem {
    let id: String
    let title: String
    let children: [VTSystemInformationSection: [VTAnyItem]]
}

extension VTAnyItem {
    static func systemInformationSegmentedBar(_ id: String, config: VTStackedProgressBarCellContentConfiguration) -> VTAnyItem {
        VTAnyItem(VTSystemInformationSegmentedBarItem(id: id, config: config))
    }

    static func systemInformationLink(_ id: String, title: String, children: [VTSystemInformationSection: [VTAnyItem]]) -> VTAnyItem {
        VTAnyItem(VTSystemInformationLinkItem(id: id, title: title, children: children))
    }
}
