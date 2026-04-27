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
        case .robot:    return "ROBOT".localized()
        case .options:  return "OPTIONS".localized()
        case .misc:     return "MISC".localized()
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
    case highResolutionManualControl

    var title: String {
        switch self {
        case .home:                                        return "HOME".localized()
        case .map:                                         return "MAP".localized()
        case .consumables:                                 return "CONSUMABLES".localized()
        case .robot:                                       return "ROBOT".localized()
        case .timers:                                      return "TIMERS".localized()
        case .log:                                         return "LOG".localized()
        case .systemInformation:                           return "SYSTEM_INFORMATION".localized()
        case .updater:                                     return "UPDATER".localized()
        case .manualControl, .highResolutionManualControl: return "MANUAL_CONTROL".localized()
        }
    }

    var icon: UIImage? {
        switch self {
        case .home:                                        return .houseFill
        case .map:                                         return .mapFill
        case .consumables:                                 return .chartLineTextClipboardFill
        case .robot:                                       return .roboticVacuumFill
        case .timers:                                      return .clockFill
        case .log:                                         return .textPageFill
        case .systemInformation:                           return .infoCircleFill
        case .updater:                                     return .squareAndArrowDownFill
        case .manualControl, .highResolutionManualControl: return .arrowUpAndDownAndArrowLeftAndRight
        }
    }
}

fileprivate typealias VTSidebarData = [(VTSidebarSection, [VTSidebarItem])]

fileprivate extension VTSidebarData {
    func section(at: Int) -> VTSidebarSection? { self[safe: at]?.0 }
}

class VTSidebarViewController: VTCollectionViewController {
    typealias VTSidebarDataSource = UICollectionViewDiffableDataSource<VTSidebarSection, VTSidebarItem>
    typealias VTSidebarDatasourceSnapshot = NSDiffableDataSourceSnapshot<VTSidebarSection, VTSidebarItem>
    
    private var dataSource: VTSidebarDataSource!
    private var data: VTSidebarData = [
        .main    => [.home],
        .robot   => [.consumables, .manualControl, .highResolutionManualControl],
        .options => [.map, .robot],
        .misc    => [.timers, .log, .updater, .systemInformation]
    ]
    
    var didSelectItem: ((VTSidebarItem) -> Void)?

    private var client: VTAPIClientProtocol

    init(client: VTAPIClientProtocol) {
        self.client = client
        var listConfig = UICollectionLayoutListConfiguration(appearance: .sidebar)
        listConfig.headerMode = .supplementary
        let layout = UICollectionViewCompositionalLayout.list(using: listConfig)
        super.init(collectionViewLayout: layout)
        self.clearsSelectionOnViewWillAppear = true
        
        self.navigationItem.rightBarButtonItem = VTValetudoEventBarButtonItem(client: client, parentViewController: self)
        self.navigationItem.leftBarButtonItem = VTRobotBarButtonItem(parentViewController: self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        configureDataSource()
        
        Task { await loadInitialData() }
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
        guard !isCompact else { return }
        guard collectionView.indexPathsForSelectedItems?.isEmpty ?? true else { return }
        
        let snapshot = dataSource.snapshot()
        guard let firstSection = snapshot.sectionIdentifiers.first,
              let firstItem = snapshot.itemIdentifiers(inSection: firstSection).first,
              let indexPath = dataSource.indexPath(for: firstItem) else { return }

        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
    }

    private func configureCollectionView() {
        //collectionView.backgroundColor = .systemGroupedBackground
        collectionView.register(
            VTSidebarHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: VTSidebarHeaderView.reuseIdentifier
        )
    }
    
    @MainActor
    private func loadInitialData() async {
        let capabilities = Set((try? await client.getCapabilities()) ?? [])
        let supportsHighResolutionManualControl = capabilities.contains(.highResolutionManualControl)
        // filter the data, such that all unavailable features are remove
        data = data.compactMap { (sec, its) in
            let tmpItems = its.filter { item in
                switch (item) {
                case .home, .log, .robot, .map, .systemInformation, .timers, .updater: true
                case .consumables:   capabilities.contains(.consumableMonitoring)
                case .manualControl: capabilities.contains(.manualControl) && !supportsHighResolutionManualControl
                case .highResolutionManualControl: supportsHighResolutionManualControl
                }
            }
            return tmpItems.isEmpty ? nil : (sec, tmpItems)
        }
        
        var snapshot = VTSidebarDatasourceSnapshot()
        for (section, items) in data {
            snapshot.appendSections([section])
            snapshot.appendItems(items, toSection: section)
        }
        await dataSource.apply(snapshot, animatingDifferences: false)
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

        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader else { return nil }
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: VTSidebarHeaderView.reuseIdentifier,
                for: indexPath
            ) as? VTSidebarHeaderView
            header?.configure(text: self?.data.section(at: indexPath.section)?.title ?? "")
            return header
        }
    }

    // MARK: - UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let identifier = dataSource.itemIdentifier(for: indexPath) else { return }
        didSelectItem?(identifier)
    }
}
