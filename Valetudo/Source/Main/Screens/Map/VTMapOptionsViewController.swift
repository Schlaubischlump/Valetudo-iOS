//
//  VTMap.swift
//  Valetudo
//
//  Created by David Klopp on 26.04.26.
//
import UIKit

private let kMappingPass = "MAPPING_PASS"
private let kMapReset = "MAP_RESET"
private let kSegmentManagement = "SEGMENT_MANAGEMENT"
private let kVirtualRestrictionManagement = "VIRTUAL_RESTRICTION_MANAGEMENT"

/// Displays the available map-related actions supported by the connected robot.
final class VTMapOptionsViewController: VTCollectionViewController {
    private typealias DataSource = UICollectionViewDiffableDataSource<VTMapOptionsSection, VTAnyItem>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<VTMapOptionsSection, VTAnyItem>

    private let client: VTAPIClientProtocol
    private var dataSource: DataSource!
    private var availableCapabilities = Set<VTCapability>()

    #if !targetEnvironment(macCatalyst)
        private let refreshControl = UIRefreshControl()
    #endif

    /// Creates the map options screen for a specific API client.
    init(client: VTAPIClientProtocol) {
        self.client = client

        super.init(collectionViewLayout: UICollectionViewLayout())
        setupAndApplyListLayout()

        title = "MAP".localized()
        navigationItem.subtitle = "MAP_OPTIONS_SUBTITLE".localized()
        navigationItem.rightBarButtonItem = VTValetudoEventBarButtonItem(client: client, parentViewController: self)
    }

    @available(*, unavailable)
    @MainActor
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View life cycle

    /// Configures the collection view and its diffable data source.
    override func viewDidLoad() {
        super.viewDidLoad()

        configureCollectionView()
        configureDataSource()
    }

    /// Refreshes the visible options whenever the screen becomes active again.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Task {
            await reloadData(animated: false)
        }
    }

    // MARK: - Layout

    /// Applies the inset-grouped list layout used by the options menu.
    private func setupAndApplyListLayout() {
        var listConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        listConfig.showsSeparators = true
        listConfig.footerMode = .supplementary
        listConfig.backgroundColor = .adaptiveGroupedBackground

        let layout = UICollectionViewCompositionalLayout.list(using: listConfig)
        collectionView.setCollectionViewLayout(layout, animated: false)
    }

    // MARK: - Collection View Configuration

    /// Registers reusable views and wires up pull-to-refresh support where available.
    private func configureCollectionView() {
        collectionView.delaysContentTouches = false
        collectionView.register(
            VTFooterView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: VTFooterView.reuseIdentifier
        )
        #if !targetEnvironment(macCatalyst)
            configureRefreshControlIfSupported(refreshControl, action: #selector(didPullToRefresh))
        #endif
    }

    /// Builds the diffable data source used to render the current capability-driven options.
    private func configureDataSource() {
        let linkCellRegistration = VTCellRegistration { cell, _, wrappedItem in
            guard let item = wrappedItem.base as? VTKeyValueItem else {
                fatalError("Unsupported map options item: \(wrappedItem.base)")
            }

            cell.contentConfiguration = VTKeyValueCellContentConfiguration(
                id: item.id,
                title: item.title,
                value: item.value,
                usesHorizontalLayout: false,
                image: item.image
            )
            cell.backgroundConfiguration = .adaptiveListCell()
            cell.accessories = switch item.id {
            case kSegmentManagement, kVirtualRestrictionManagement:
                [.disclosureIndicator()]
            default:
                []
            }
        }

        dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, item in
            switch item.base {
            case is VTKeyValueItem:
                collectionView.dequeueConfiguredReusableCell(using: linkCellRegistration, for: indexPath, item: item)
            default:
                fatalError("Unsupported map options item: \(item.base)")
            }
        }

        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionFooter else { return nil }
            let footer = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: VTFooterView.reuseIdentifier,
                for: indexPath
            ) as? VTFooterView
            if indexPath.section == VTMapOptionsSection.allCases.indices.last {
                footer?.configure(attributedText: "MAP_OPTIONS_FOOTER_DESCRIPTION".localizedMarkdown())
            } else {
                footer?.configure(attributedText: NSAttributedString(string: ""))
            }
            return footer
        }
    }

    // MARK: - Refreshing

    /// Reloads the options after a user-initiated pull-to-refresh gesture.
    @objc private func didPullToRefresh() {
        Task {
            await reloadData(animated: true)
        }
    }

    /// Re-fetches map capabilities after the shared reconnect flow completes.
    @MainActor
    override func reconnectAndRefresh() async {
        await reloadData(animated: false)
    }

    /// Rebuilds the collection view snapshot from the robot's currently available map capabilities.
    @MainActor
    private func reloadData(animated: Bool) async {
        availableCapabilities = await Set((try? client.getCapabilities()) ?? [])

        var snapshot = Snapshot()
        snapshot.appendSections([.mapping, .management])
        if availableCapabilities.contains(.mappingPass) {
            snapshot.appendItems([
                .keyValue(
                    kMappingPass,
                    title: "MAP_OPTIONS_MAPPING_PASS_TITLE".localized(),
                    value: "MAP_OPTIONS_MAPPING_PASS_SUBTITLE".localized(),
                    image: .mapFill
                ),
            ], toSection: .mapping)
        }
        if availableCapabilities.contains(.mapReset) {
            snapshot.appendItems([
                .keyValue(
                    kMapReset,
                    title: "MAP_OPTIONS_RESET_TITLE".localized(),
                    value: "MAP_OPTIONS_RESET_SUBTITLE".localized(),
                    image: .mapSlash
                ),
            ], toSection: .mapping)
        }
        if availableCapabilities.contains(.mapSegmentation) {
            snapshot.appendItems([
                .keyValue(
                    kSegmentManagement,
                    title: "MAP_OPTIONS_SEGMENT_MANAGEMENT_TITLE".localized(),
                    value: "MAP_OPTIONS_SEGMENT_MANAGEMENT_SUBTITLE".localized(),
                    image: .rectangle3GroupFill
                ),
            ], toSection: .management)
        }
        if availableCapabilities.contains(.combinedVirtualRestrictions) {
            snapshot.appendItems([
                .keyValue(
                    kVirtualRestrictionManagement,
                    title: "MAP_OPTIONS_VIRTUAL_RESTRICTION_MANAGEMENT_TITLE".localized(),
                    value: "MAP_OPTIONS_VIRTUAL_RESTRICTION_MANAGEMENT_SUBTITLE".localized(),
                    image: .nosign
                ),
            ], toSection: .management)
        }
        await dataSource.apply(snapshot, animatingDifferences: animated)

        #if !targetEnvironment(macCatalyst)
            if refreshControl.isRefreshing {
                refreshControl.endRefreshing()
            }
        #endif
    }

    // MARK: - Collection View Delegate

    /// Routes taps on option rows to the corresponding capability action or detail screen.
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        defer { collectionView.deselectItem(at: indexPath, animated: true) }
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }

        switch item.id {
        case kMappingPass:
            didTapMappingPass()
        case kMapReset:
            presentMapResetConfirmation()
        case kSegmentManagement:
            let vc = VTSegmentManagementViewController(client: client, capabilities: availableCapabilities)
            navigationController?.pushViewController(vc, animated: true)
        case kVirtualRestrictionManagement:
            let vc = VTVirtualRestrictionManagementViewController(client: client, capabilities: availableCapabilities)
            navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }

    // MARK: - Actions

    /// Starts a mapping pass on robots that expose the corresponding capability.
    private func didTapMappingPass() {
        Task {
            do {
                try await client.startMappingPass()
            } catch {
                log(message: "MappingPassCapability start failed: \(error.localizedDescription)", forSubsystem: .mapOptions, level: .error)
            }
        }
    }

    /// Triggers a full map reset on the robot.
    private func didTapMapReset() {
        Task {
            do {
                try await client.resetMap()
            } catch {
                log(message: "MapResetCapability trigger failed: \(error.localizedDescription)", forSubsystem: .mapOptions, level: .error)
            }
        }
    }

    // MARK: - Alerts

    /// Presents a destructive confirmation before resetting the robot's stored map.
    private func presentMapResetConfirmation() {
        let alert = UIAlertController(
            title: "MAP_OPTIONS_RESET_CONFIRMATION_TITLE".localized(),
            message: "MAP_OPTIONS_RESET_CONFIRMATION_MESSAGE".localized(),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "CANCEL".localized(), style: .cancel))
        alert.addAction(UIAlertAction(title: "MAP_OPTIONS_RESET_CONFIRMATION_ACTION".localized(), style: .destructive) { [weak self] _ in
            self?.didTapMapReset()
        })

        present(alert, animated: true)
    }
}
