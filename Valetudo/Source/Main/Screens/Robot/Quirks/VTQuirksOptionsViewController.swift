//
//  VTQuirksOptionsViewController.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//

import UIKit

final class VTQuirksOptionsViewController: VTCollectionViewController {
    private typealias DataSource = UICollectionViewDiffableDataSource<VTQuirksOptionsSection, VTAnyItem>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<VTQuirksOptionsSection, VTAnyItem>

    private let client: any VTAPIClientProtocol

    private var dataSource: DataSource!

    init(client: any VTAPIClientProtocol) {
        self.client = client

        super.init(collectionViewLayout: UICollectionViewLayout())
        setupAndApplyListLayout()

        title = "ROBOT_SYSTEM_OPTIONS".localized()
    }

    @available(*, unavailable)
    @MainActor required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View life cycle

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

    // MARK: - Setup CollectionView

    private func setupAndApplyListLayout() {
        var listConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        listConfig.showsSeparators = true
        listConfig.headerMode = .supplementary
        listConfig.backgroundColor = .adaptiveGroupedBackground

        let layout = UICollectionViewCompositionalLayout.list(using: listConfig)
        collectionView.setCollectionViewLayout(layout, animated: false)
    }

    private func configureCollectionView() {
        collectionView.register(
            VTHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: VTHeaderView.reuseIdentifier
        )
    }

    private func configureDataSource() {
        let dropDownCell = VTCellRegistration { [weak self] cell, _, wrappedItem in
            guard let item = wrappedItem.base as? VTDropDownItem<String> else {
                fatalError("Unsupported checkbox item: \(wrappedItem.base)")
            }

            cell.contentConfiguration = VTDropDownCellContentConfiguration(
                id: item.id,
                title: item.title,
                subtitle: item.subtitle,
                options: item.options,
                selection: item.active,
                disableSelectionAfterAction: true
            ) { [weak self] newActive in
                guard let self else { return }
                performUpdate(operationName: "Update Quirk \(item.title)", itemID: item.id) { [client] in
                    try await client.setQuirk(id: item.id, value: newActive)
                }
            }
            cell.backgroundConfiguration = .adaptiveListCell()
            cell.accessories = []
        }

        dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, wrappedItem in
            let registration = switch wrappedItem.base {
            case _ as VTDropDownItem<String>: dropDownCell
            default: fatalError("Unsupported item type: \(type(of: wrappedItem.base))")
            }

            return collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: wrappedItem)
        }

        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader else { return nil }
            guard
                let self,
                let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: VTHeaderView.reuseIdentifier,
                    for: indexPath
                ) as? VTHeaderView,
                let section = dataSource.sectionIdentifier(for: indexPath.section)
            else {
                return nil
            }

            header.configure(text: section.title)
            return header
        }
    }

    // MARK: - Setup UI

    @MainActor
    private func reloadData(animated: Bool, reconfigureItemWithIDs itemIDs: [String] = []) async {
        let quirks = await (try? client.getQuirks()) ?? []
        let items: [VTAnyItem] = quirks.map { quirk in
            .dropDown(
                quirk.id,
                title: quirk.title,
                subtitle: quirk.description,
                active: quirk.value,
                options: quirk.options
            )
        }

        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        let refreshItems = items.filter { itemIDs.contains($0.id) }
        snapshot.reconfigureItems(refreshItems)
        await dataSource.apply(snapshot, animatingDifferences: animated)
    }

    // MARK: - Callbacks

    private func performUpdate(
        operationName: String,
        itemID: String,
        operation: @escaping @Sendable () async throws -> Void,
        onSuccess: (@MainActor () -> Void)? = nil
    ) {
        Task { [weak self] in
            guard let self else { return }

            do {
                try await operation()
                await MainActor.run {
                    onSuccess?()
                }
                await reloadData(animated: false, reconfigureItemWithIDs: [itemID])
            } catch {
                log(message: "\(operationName) failed: \(error.localizedDescription)", forSubsystem: .robotControl, level: .error)
                await reconfigureItem(withID: itemID)
            }
        }
    }
    
    @MainActor
    private func reconfigureItem(withID id: String) async {
        var snapshot = dataSource.snapshot()
        guard let item = snapshot.itemIdentifiers.first(where: { $0.id == id }) else { return }
        snapshot.reconfigureItems([item])
        // Wait a little to make the rollback interaction smoother
        try? await Task.sleep(nanoseconds: 250_000_000)
        await dataSource.apply(snapshot, animatingDifferences: false)
    }

    @MainActor
    override func reconnectAndRefresh() async {
        await reloadData(animated: false)
    }
}
