//
//  VTRobotsListViewController.swift
//  Valetudo
//
//  Created by David Klopp on 22.04.26.
//
import Foundation
import UIKit

final class VTRobotsListViewController: VTCollectionViewController {
    private typealias DataSource = UICollectionViewDiffableDataSource<VTRobotsListViewSection, VTRobotsListViewItem>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<VTRobotsListViewSection, VTRobotsListViewItem>
    private static let scanRetryDelay: Duration = .milliseconds(750)

    var onSelectRobot: ((VTMDNSRobot) -> Void)?

    private let mdnsClient = VTMDNSClient()
    private var dataSource: DataSource!
    private var scanTask: Task<Void, Never>?

    /// We track the current generation of a scan for two reasons:
    /// - stale robot results should not be publishd into the new scan’s UI
    /// - prevent running the retry path and restart scanning even though a newer scan is already active
    private var scanGeneration = 0
    private var isScanning = false
    private var robots: [VTMDNSRobot] = []

    init() {
        var listConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        listConfig.showsSeparators = true
        listConfig.backgroundColor = .adaptiveGroupedBackground

        let layout = UICollectionViewCompositionalLayout.list(using: listConfig)
        super.init(collectionViewLayout: layout)

        title = "ROBOTS".localized()
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.subtitle = "SEARCHING_FOR_ROBOTS".localized()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureDataSource()
        applySnapshot(animated: false)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startScanning()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopScanning()
    }

    @MainActor
    override func reconnectAndRefresh() async {
        startScanning()
    }

    private func configureCollectionView() {
        collectionView.backgroundColor = .systemBackground
        collectionView.delaysContentTouches = false
    }

    private func configureDataSource() {
        let robotCell = UICollectionView.CellRegistration<UICollectionViewListCell, VTMDNSRobot> { cell, _, robot in
            cell.contentConfiguration = VTRobotCellContentConfiguration(robot: robot)
            cell.accessories = [.disclosureIndicator(displayed: .always)]
            cell.backgroundConfiguration = .adaptiveListCell()
        }

        dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case let .robot(robot):
                collectionView.dequeueConfiguredReusableCell(using: robotCell, for: indexPath, item: robot)
            }
        }
    }

    @MainActor
    private func startScanning(resetRobots: Bool = true) {
        stopScanning(preservesScanningState: !resetRobots)
        scanGeneration += 1
        let currentScanGeneration = scanGeneration

        if resetRobots {
            robots = []
        }

        isScanning = true
        applySnapshot(animated: false)

        scanTask = Task { @MainActor [weak self] in
            guard let self else { return }

            for await robots in mdnsClient.scanForRobotsStream() {
                guard scanGeneration == currentScanGeneration else { return }
                self.robots = robots
                applySnapshot(animated: true)
            }

            await retryScanningIfNeeded(scanGeneration: currentScanGeneration)
        }
    }

    @MainActor
    private func stopScanning(preservesScanningState: Bool = false) {
        scanGeneration += 1
        scanTask?.cancel()
        scanTask = nil

        if !preservesScanningState {
            isScanning = false
        }

        mdnsClient.stopScanning()
        setNeedsUpdateContentUnavailableConfiguration()
    }

    @MainActor
    private func retryScanningIfNeeded(scanGeneration: Int) async {
        guard self.scanGeneration == scanGeneration, !Task.isCancelled else { return }

        scanTask = nil

        try? await Task.sleep(for: Self.scanRetryDelay)
        guard self.scanGeneration == scanGeneration, !Task.isCancelled else { return }
        startScanning(resetRobots: false)
    }

    @MainActor
    private func applySnapshot(animated: Bool) {
        var snapshot = Snapshot()

        snapshot.appendSections([.robots])
        snapshot.appendItems(robots.map(VTRobotsListViewItem.robot), toSection: .robots)
        setNeedsUpdateContentUnavailableConfiguration()

        dataSource.apply(snapshot, animatingDifferences: animated)
    }

    override func updateContentUnavailableConfiguration(using _: UIContentUnavailableConfigurationState) {
        guard robots.isEmpty else {
            applyContentUnavailableConfiguration(nil)
            return
        }

        if isScanning {
            var config = UIContentUnavailableConfiguration.loading()
            config.text = "SCANNING".localized()
            config.secondaryText = "SEARCHING_FOR_ROBOTS".localized()
            applyContentUnavailableConfiguration(config)
        } else {
            // Mostly a safeguard. You should never see this screen.
            var config = UIContentUnavailableConfiguration.empty()
            config.image = .wifiSlash
            config.text = "NO_ROBOTS_FOUND".localized()
            config.secondaryText = "MAKE_SURE_ROBOT_IS_ONLINE".localized()
            config.imageProperties.preferredSymbolConfiguration = .init(pointSize: 36, weight: .regular)
            applyContentUnavailableConfiguration(config)
        }
    }

    /// Mac catalyst has a problem with setting contentUnavailableConfiguration.
    private func applyContentUnavailableConfiguration(_ configuration: UIContentUnavailableConfiguration?) {
        #if targetEnvironment(macCatalyst)
            collectionView.backgroundView = configuration.map(UIContentUnavailableView.init(configuration:))
        #else
            contentUnavailableConfiguration = configuration
        #endif
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        guard let item = dataSource.itemIdentifier(for: indexPath),
              case let .robot(robot) = item else { return }

        Task { @MainActor [weak self] in
            self?.onSelectRobot?(robot)
        }
    }
}
