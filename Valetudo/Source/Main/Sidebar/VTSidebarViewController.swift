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
    case app = 4

    var title: String? {
        switch self {
        case .main: nil
        case .robot: "ROBOT".localized()
        case .options: "OPTIONS".localized()
        case .misc: "MISC".localized()
        case .app: "APP".localized()
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
    case appSettings

    var title: String {
        switch self {
        case .home: "HOME".localized()
        case .map: "MAP".localized()
        case .consumables: "CONSUMABLES".localized()
        case .robot: "ROBOT".localized()
        case .timers: "TIMERS".localized()
        case .log: "LOG".localized()
        case .systemInformation: "SYSTEM_INFORMATION".localized()
        case .updater: "UPDATER".localized()
        case .manualControl, .highResolutionManualControl: "MANUAL_CONTROL".localized()
        case .appSettings: "APP_SETTINGS".localized()
        }
    }

    var icon: UIImage? {
        switch self {
        case .home: .sidebarHome
        case .map: .sidebarMap
        case .consumables: .sidebarConsumables
        case .robot: .sidebarRobot
        case .timers: .sidebarTimers
        case .log: .sidebarLog
        case .systemInformation: .sidebarSystemInformation
        case .updater: .sidebarUpdater
        case .manualControl, .highResolutionManualControl: .sidebarManualControl
        case .appSettings: .sidebarAppSettings
        }
    }
}

private typealias VTSidebarData = [(VTSidebarSection, [VTSidebarItem])]

private extension VTSidebarData {
    func section(at: Int) -> VTSidebarSection? {
        self[safe: at]?.0
    }
}

class VTSidebarViewController: VTCollectionViewController {
    typealias VTSidebarDataSource = UICollectionViewDiffableDataSource<VTSidebarSection, VTSidebarItem>
    typealias VTSidebarDatasourceSnapshot = NSDiffableDataSourceSnapshot<VTSidebarSection, VTSidebarItem>

    private var dataSource: VTSidebarDataSource!
    private var data: VTSidebarData = [
        .main => [.home],
        .robot => [.consumables, .manualControl, .highResolutionManualControl],
        .options => [.map, .robot],
        .misc => [.timers, .log, .updater, .systemInformation],
        .app => [.appSettings],
    ]

    var didSelectItem: ((VTSidebarItem) -> Void)?
    private var selectedItem: VTSidebarItem?

    private var client: VTAPIClientProtocol
    private lazy var valetudoEventBarButtonItem = VTValetudoEventBarButtonItem(client: client, parentViewController: self)

    init(client: VTAPIClientProtocol) {
        self.client = client
        var listConfig = UICollectionLayoutListConfiguration(appearance: .sidebar)
        listConfig.headerMode = .supplementary
        let layout = UICollectionViewCompositionalLayout.list(using: listConfig)
        super.init(collectionViewLayout: layout)
        clearsSelectionOnViewWillAppear = false

        // navigationItem.leftBarButtonItem = VTRobotBarButtonItem(parentViewController: self)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
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

        if applySelectedItemIfPossible() {
            return
        }

        guard collectionView.indexPathsForSelectedItems?.isEmpty ?? true else { return }

        let snapshot = dataSource.snapshot()
        guard let firstSection = snapshot.sectionIdentifiers.first,
              let firstItem = snapshot.itemIdentifiers(inSection: firstSection).first,
              let indexPath = dataSource.indexPath(for: firstItem) else { return }

        selectedItem = firstItem
        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
    }

    private func configureCollectionView() {
        // collectionView.backgroundColor = .systemGroupedBackground
        collectionView.register(
            VTSidebarHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: VTSidebarHeaderView.reuseIdentifier
        )
    }

    func setShowsEventButton(_ showsEventButton: Bool) {
        navigationItem.rightBarButtonItem = showsEventButton ? valetudoEventBarButtonItem : nil
    }

    func setSelectedItem(_ item: VTSidebarItem?) {
        selectedItem = item
        _ = applySelectedItemIfPossible()
    }

    @MainActor
    private func loadInitialData() async {
        let capabilities = await Set((try? client.getCapabilities()) ?? [])
        let supportsHighResolutionManualControl = capabilities.contains(.highResolutionManualControl)
        // filter the data, such that all unavailable features are remove
        data = data.compactMap { sec, its in
            let tmpItems = its.filter { item in
                switch item {
                case .home, .log, .robot, .map, .systemInformation, .timers, .updater: true
                case .consumables: capabilities.contains(.consumableMonitoring)
                case .manualControl: capabilities.contains(.manualControl) && !supportsHighResolutionManualControl
                case .highResolutionManualControl: supportsHighResolutionManualControl
                case .appSettings: true
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
        applySelectedItemIfPossible()
    }

    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, VTSidebarItem> { cell, _, item in
            cell.configurationUpdateHandler = { cell, state in
                var content = UIListContentConfiguration.cell().updated(for: state)
                content.text = item.title
                content.image = item.icon
                content.imageProperties.tintColor = content.textProperties.color
                cell.contentConfiguration = content
            }

            cell.setNeedsUpdateConfiguration()
        }

        dataSource = VTSidebarDataSource(collectionView: collectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
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

    override func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let identifier = dataSource.itemIdentifier(for: indexPath) else { return }
        selectedItem = identifier
        didSelectItem?(identifier)
    }

    @discardableResult
    private func applySelectedItemIfPossible() -> Bool {
        guard viewIfLoaded != nil, let selectedItem, let indexPath = dataSource?.indexPath(for: selectedItem) else {
            return false
        }

        guard collectionView.indexPathsForSelectedItems != [indexPath] else { return true }
        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        return true
    }
}
