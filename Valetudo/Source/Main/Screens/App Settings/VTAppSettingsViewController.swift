//
//  VTAppSettingsViewController.swift
//  Valetudo
//
//  Created by David Klopp on 06.05.26.
//
import UIKit

let kRobotDiscovery = "ROBOT_DISCOVERY"
let kHideNoGoAreas = "HIDE_NO_GO_AREAS"
let kShareLogFile = "SHARE_LOG_FILE"

/// Displays app-scoped settings such as robot discovery, map rendering preferences, and log export.
final class VTAppSettingsViewController: VTCollectionViewController {
    private typealias DataSource = UICollectionViewDiffableDataSource<VTAppSettingsSection, VTAnyItem>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<VTAppSettingsSection, VTAnyItem>

    private let settings = VTAppSettingsStore.shared
    private var dataSource: DataSource!

    /// Creates the settings screen for the current app session.
    init(client: VTAPIClientProtocol) {
        var listConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        listConfig.showsSeparators = true
        listConfig.headerMode = .supplementary
        listConfig.backgroundColor = .adaptiveGroupedBackground
        let layout = UICollectionViewCompositionalLayout.list(using: listConfig)
        super.init(collectionViewLayout: layout)

        title = "APP_SETTINGS".localized()
        navigationItem.rightBarButtonItem = VTValetudoEventBarButtonItem(client: client, parentViewController: self)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Configures the collection view and builds the initial snapshot.
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureDataSource()
        applySnapshot(animated: false)
    }

    /// Registers reusable supplementary views used by the inset-grouped list.
    private func configureCollectionView() {
        collectionView.delaysContentTouches = false
        collectionView.register(
            VTHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: VTHeaderView.reuseIdentifier
        )
    }

    /// Builds the diffable data source and reusable cell registrations for each settings row.
    private func configureDataSource() {
        let linkCellRegistration = VTCellRegistration { cell, _, wrappedItem in
            guard let item = wrappedItem.base as? VTKeyValueItem else {
                fatalError("Unsupported link item: \(wrappedItem.base)")
            }

            cell.contentConfiguration = VTKeyValueCellContentConfiguration(
                id: item.id,
                title: item.title,
                subtitle: item.value,
                usesHorizontalLayout: false,
                image: item.image
            )
            cell.backgroundConfiguration = .adaptiveListCell()
            cell.accessories = item.id == kRobotDiscovery ? [.disclosureIndicator()] : []
        }

        let checkboxCellRegistration = VTCellRegistration { [weak self] cell, _, wrappedItem in
            guard let item = wrappedItem.base as? VTCheckboxItem else {
                fatalError("Unsupported toggle item: \(wrappedItem.base)")
            }

            cell.contentConfiguration = VTCheckboxCellContentConfiguration(
                id: item.id,
                title: item.title,
                subtitle: item.subtitle,
                isOn: self?.settings.hideNoGoAreas ?? false,
                image: item.image,
                disableSelectionAfterAction: false
            ) { [weak self] isOn in
                self?.settings.hideNoGoAreas = isOn
            }
            cell.backgroundConfiguration = .adaptiveListCell()
        }

        dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, item in
            switch item.base {
            case is VTKeyValueItem:
                collectionView.dequeueConfiguredReusableCell(using: linkCellRegistration, for: indexPath, item: item)
            case is VTCheckboxItem:
                collectionView.dequeueConfiguredReusableCell(using: checkboxCellRegistration, for: indexPath, item: item)
            default:
                fatalError("Unsupported settings item: \(item.base)")
            }
        }

        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader else { return nil }
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: VTHeaderView.reuseIdentifier,
                for: indexPath
            ) as? VTHeaderView
            header?.configure(text: self?.section(for: indexPath).title ?? "")
            return header
        }
    }

    /// Rebuilds the static settings snapshot from the latest persisted state.
    private func applySnapshot(animated: Bool) {
        var snapshot = Snapshot()
        snapshot.appendSections(VTAppSettingsSection.allCases)
        snapshot.appendItems([
            .keyValue(
                kRobotDiscovery,
                title: "APP_SETTINGS_ROBOT_DISCOVERY_TITLE".localized(),
                value: "APP_SETTINGS_ROBOT_DISCOVERY_SUBTITLE".localized(),
                image: .robotNavigationItem
            ),
        ], toSection: .robot)
        snapshot.appendItems([
            .checkbox(
                kHideNoGoAreas,
                title: "APP_SETTINGS_HIDE_NO_GO_AREAS_TITLE".localized(),
                subtitle: "APP_SETTINGS_HIDE_NO_GO_AREAS_SUBTITLE".localized(),
                enabled: settings.hideNoGoAreas,
                image: .noGo
            ),
        ], toSection: .map)
        snapshot.appendItems([
            .keyValue(
                kShareLogFile,
                title: "APP_SETTINGS_SHARE_LOG_FILE_TITLE".localized(),
                value: "APP_SETTINGS_SHARE_LOG_FILE_SUBTITLE".localized(),
                image: .share
            ),
        ], toSection: .log)
        dataSource.apply(snapshot, animatingDifferences: animated)
    }

    /// Returns the settings section displayed at the provided index path.
    private func section(for indexPath: IndexPath) -> VTAppSettingsSection {
        VTAppSettingsSection.allCases[indexPath.section]
    }

    /// Pushes the robot discovery flow using the scene delegate that owns the current window.
    private func showRobotDiscovery() {
        guard let sceneDelegate = view.window?.windowScene?.delegate as? VTSceneDelegate else { return }
        sceneDelegate.showRobotDiscoveryScreen(from: self)
    }

    /// Presents the native share sheet for the persisted app log file.
    private func shareLogFile(from sourceView: UIView?) {
        do {
            let fileURL = try VTLogFileStore.shared.shareableFileURL()
            let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = sourceView ?? view
            activityVC.popoverPresentationController?.sourceRect = sourceView?.bounds ?? view.bounds
            present(activityVC, animated: true)
        } catch {
            log(message: "Failed to prepare shared log file: \(error.localizedDescription)", forSubsystem: .valetudoLog, level: .error)
            showError(
                title: "ERROR".localized(),
                message: String(format: "LOG_EXPORT_FAILED_MESSAGE".localized(), error.localizedDescription)
            )
        }
    }

    /// Routes taps on selectable rows to the appropriate settings action.
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        defer { collectionView.deselectItem(at: indexPath, animated: true) }
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }

        switch item.id {
        case kRobotDiscovery:
            showRobotDiscovery()
        case kShareLogFile:
            shareLogFile(from: collectionView.cellForItem(at: indexPath))
        case kHideNoGoAreas:
            break
        default:
            break
        }
    }

    /// Limits list-style selection highlighting to rows that perform a navigation or share action.
    override func collectionView(_: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }

        return switch item.id {
        case kRobotDiscovery, kShareLogFile: true
        case kHideNoGoAreas: false
        default: false
        }
    }

    /// Matches highlight behavior to the selection rules for settings rows.
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        self.collectionView(collectionView, shouldSelectItemAt: indexPath)
    }
}
