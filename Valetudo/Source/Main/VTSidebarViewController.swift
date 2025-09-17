//
//  VTSidebarViewController.swift
//  Valetudo
//
//  Created by David Klopp on 15.05.25.
//
import Foundation
import UIKit

enum VTSidebarSection: Int, CaseIterable {
    case main = 0
    case robot = 1
    case options = 2
    case misc = 3
    
    var title: String? {
        switch (self) {
        case .main:     return nil
        case .robot:    return "ROBOT".localizedCapitalized()
        case .options:  return "OPTIONS".localizedCapitalized()
        case .misc:     return "MISC".localizedCapitalized()
        }
    }
}

enum VTSidebarItem: Hashable {
    case home
    case map
    case consumables
    case robot
    case timers
    case log
    case systemInformation
    case updater
    case manualControl

    var title: String {
        switch self {
        case .home:                 return "HOME".localizedCapitalized()
        case .map:                  return "MAP".localizedCapitalized()
        case .consumables:          return "CONSUMABLES".localizedCapitalized()
        case .robot:                return "ROBOT".localizedCapitalized()
        case .timers:               return "TIMERS".localizedCapitalized()
        case .log:                  return "LOG".localizedCapitalized()
        case .systemInformation:    return "SYSTEM_INFORMATION".localizedCapitalized()
        case .updater:              return "UPDATER".localizedCapitalized()
        case .manualControl:        return "MANUAL_CONTROL".localizedCapitalized()
        }
    }

    var icon: UIImage? {
        switch self {
        case .home:              return UIImage(systemName: "house.fill")
        case .map:               return UIImage(systemName: "map.fill")
        case .consumables:       return UIImage(systemName: "chart.line.text.clipboard.fill")
        case .robot:             return UIImage(systemName: "robotic.vacuum.fill")
        case .timers:            return UIImage(systemName: "clock.fill")
        case .log:               return UIImage(systemName: "text.page.fill")
        case .systemInformation: return UIImage(systemName: "info.circle.fill")
        case .updater:           return UIImage(systemName: "square.and.arrow.down.fill")
        case .manualControl:     return UIImage(systemName: "arrow.up.and.down.and.arrow.left.and.right")
        }
    }
}


class VTSidebarViewController: UICollectionViewController {
    typealias VTSidebarDataSource = UICollectionViewDiffableDataSource<VTSidebarSection, VTSidebarItem>
    typealias VTSidebarDatasourceSnapshot = NSDiffableDataSourceSnapshot<VTSidebarSection, VTSidebarItem>
    
    private var dataSource: VTSidebarDataSource!
    private let items: [VTSidebarSection: [VTSidebarItem]] = [
        .main:      [.home],
        .robot:     [.consumables, .manualControl],
        .options:   [.map, .robot],
        .misc:      [.timers, .log, .updater, .systemInformation]
    ]
    
    var didSelectItem: ((VTSidebarItem) -> Void)?


    init() {
        var listConfig = UICollectionLayoutListConfiguration(appearance: .sidebar)
        listConfig.headerMode = .supplementary
        let layout = UICollectionViewCompositionalLayout.list(using: listConfig)
        super.init(collectionViewLayout: layout)
        self.clearsSelectionOnViewWillAppear = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureDataSource()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        selectFirstItemIfNeeded()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        selectFirstItemIfNeeded()
    }
    
    private func selectFirstItemIfNeeded() {
        guard viewIfLoaded != nil, let isCompact = splitViewController?.isCompact else { return }
        
        if !isCompact, (collectionView.indexPathsForSelectedItems?.isEmpty ?? false) {
            collectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .top)
        }
    }

    private func configureCollectionView() {
        //collectionView.backgroundColor = .systemGroupedBackground
        collectionView.register(
            VTSidebarHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: VTSidebarHeaderView.reuseIdentifier
        )
    }

    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, VTSidebarItem> { cell, _, item in
            var content = cell.defaultContentConfiguration()
            content.text = item.title
            content.image = item.icon
            cell.contentConfiguration = content
        }

        dataSource = VTSidebarDataSource(collectionView: collectionView) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }

        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader else { return nil }
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: VTSidebarHeaderView.reuseIdentifier,
                for: indexPath
            ) as? VTSidebarHeaderView
            header?.configure(text: VTSidebarSection(rawValue: indexPath.section)?.title ?? "")
            return header
        }
        
        var snapshot = VTSidebarDatasourceSnapshot()
        VTSidebarSection.allCases.forEach { section in
            snapshot.appendSections([section])
            snapshot.appendItems(items[section] ?? [], toSection: section)
        }
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    // MARK: - UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let identifier = dataSource.itemIdentifier(for: indexPath) else { return }
        didSelectItem?(identifier)
    }
}
