//
//  VTSystemInformationDetailedViewController.swift
//  Valetudo
//
//  Created by David Klopp on 16.09.25.
//
import UIKit

/**
 * Detailed view controller for dependencies and environment.
 */
final class VTSystemInformationDetailedViewController: VTSystemInformationViewControllerBase {
    private let data: [VTSystemInformationSection: [VTSystemInformationItem]]
    
    private lazy var sortedSections: [VTSystemInformationSection] = {
        data.keys.sorted(by: {
            switch ($0, $1) {
            case (.main, _): true
            case (_, .main): false
            case (let first, let second): first.rawValue < second.rawValue
            }
        })
    }()
    
    init(client: VTAPIClientProtocol, data: [VTSystemInformationSection: [VTSystemInformationItem]]) {
        self.data = data
        super.init(client: client)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func section(for indexPath: IndexPath) -> VTSystemInformationSection {
        sortedSections[indexPath.section]
    }
    
    override func reloadData(animated: Bool) async {
        var snapshot = VTSystemInformationSnapshot()
        snapshot.appendSections(sortedSections)
        for sec in sortedSections {
            snapshot.appendItems(data[sec] ?? [], toSection: sec)
        }
        await dataSource.apply(snapshot, animatingDifferences: animated)
    }
}
