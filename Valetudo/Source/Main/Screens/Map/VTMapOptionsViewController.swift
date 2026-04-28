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

final class VTMapOptionsViewController: VTCollectionViewController {
    private typealias DataSource = UICollectionViewDiffableDataSource<VTMapOptionsSection, VTAnyItem>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<VTMapOptionsSection, VTAnyItem>

    private let client: VTAPIClientProtocol
    private var dataSource: DataSource!
    private var availableCapabilities = Set<VTCapability>()

    #if !targetEnvironment(macCatalyst)
        private let refreshControl = UIRefreshControl()
    #endif

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

    override func viewDidLoad() {
        super.viewDidLoad()

        configureCollectionView()
        configureDataSource()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Task {
            await reloadData(animated: false)
        }
    }

    private func setupAndApplyListLayout() {
        var listConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        listConfig.showsSeparators = true
        listConfig.footerMode = .supplementary
        listConfig.backgroundColor = .adaptiveGroupedBackground

        let layout = UICollectionViewCompositionalLayout.list(using: listConfig)
        collectionView.setCollectionViewLayout(layout, animated: false)
    }

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

    private func configureDataSource() {
        let actionCellRegistration = VTCellRegistration { [weak self] cell, _, wrappedItem in
            guard let self else { return }
            guard let item = wrappedItem.base as? VTActionItem else {
                fatalError("Unsupported map options item: \(wrappedItem.base)")
            }

            cell.contentConfiguration = VTActionCellContentConfiguration(
                id: item.id,
                title: item.title,
                subtitle: item.subtitle,
                image: item.image,
                buttonTitle: item.buttonTitle,
                buttonStyle: item.buttonStyle,
                onAction: { [weak self] in
                    switch item.id {
                    case kMappingPass:
                        self?.didTapMappingPass()
                    case kMapReset:
                        self?.didTapMapReset()
                    default:
                        break
                    }
                }
            )
            cell.backgroundConfiguration = .adaptiveListCell()
        }

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
            cell.accessories = [.disclosureIndicator()]
        }

        dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, item in
            switch item.base {
            case is VTActionItem:
                collectionView.dequeueConfiguredReusableCell(using: actionCellRegistration, for: indexPath, item: item)
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

    @objc private func didPullToRefresh() {
        Task {
            await reloadData(animated: true)
        }
    }

    @MainActor
    override func reconnectAndRefresh() async {
        await reloadData(animated: false)
    }

    @MainActor
    private func reloadData(animated: Bool) async {
        availableCapabilities = await Set((try? client.getCapabilities()) ?? [])

        var snapshot = Snapshot()
        snapshot.appendSections([.mapping, .segmentationManagement])
        if availableCapabilities.contains(.mappingPass) {
            snapshot.appendItems([
                .action(
                    kMappingPass,
                    title: "MAP_OPTIONS_MAPPING_PASS_TITLE".localized(),
                    subtitle: "MAP_OPTIONS_MAPPING_PASS_SUBTITLE".localized(),
                    image: .mapFill,
                    buttonTitle: "MAP_OPTIONS_MAPPING_PASS_BUTTON".localized()
                ),
            ], toSection: .mapping)
        }
        if availableCapabilities.contains(.mapReset) {
            snapshot.appendItems([
                .action(
                    kMapReset,
                    title: "MAP_OPTIONS_RESET_TITLE".localized(),
                    subtitle: "MAP_OPTIONS_RESET_SUBTITLE".localized(),
                    image: .mapSlash,
                    buttonTitle: "MAP_OPTIONS_MAPPING_PASS_BUTTON".localized(),
                    buttonStyle: .destructive
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
            ], toSection: .segmentationManagement)
        }
        if availableCapabilities.contains(.combinedVirtualRestrictions) {
            snapshot.appendItems([
                .keyValue(
                    kVirtualRestrictionManagement,
                    title: "MAP_OPTIONS_VIRTUAL_RESTRICTION_MANAGEMENT_TITLE".localized(),
                    value: "MAP_OPTIONS_VIRTUAL_RESTRICTION_MANAGEMENT_SUBTITLE".localized(),
                    image: .nosign
                ),
            ], toSection: .segmentationManagement)
        }
        await dataSource.apply(snapshot, animatingDifferences: animated)

        #if !targetEnvironment(macCatalyst)
            if refreshControl.isRefreshing {
                refreshControl.endRefreshing()
            }
        #endif
    }

    private func didTapMappingPass() {
        Task {
            do {
                try await client.startMappingPass()
            } catch {
                log(message: "MappingPassCapability start failed: \(error.localizedDescription)", forSubsystem: .mapOptions, level: .error)
            }
        }
    }

    private func didTapMapReset() {
        Task {
            do {
                try await client.resetMap()
            } catch {
                log(message: "MapResetCapability trigger failed: \(error.localizedDescription)", forSubsystem: .mapOptions, level: .error)
            }
        }
    }
}
