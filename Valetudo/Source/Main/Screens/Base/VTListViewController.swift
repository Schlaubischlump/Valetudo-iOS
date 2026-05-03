//
//  VTListViewController.swift
//  Valetudo
//
//  Created by David Klopp on 04.05.26.
//
import UIKit

class VTListViewController<SectionType: Hashable & Sendable>: VTCollectionViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<SectionType, VTAnyItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<SectionType, VTAnyItem>

    var dataSource: DataSource!

    init() {
        super.init(collectionViewLayout: UICollectionViewLayout())
        setupAndApplyListLayout()
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

    // MARK: - Subclass methods

    var supportedCellTypes: [any VTItem.Type] {
        []
    }

    func cellRegistration(forType _: any VTItem.Type) -> VTCellRegistration {
        fatalError("Not implemented!")
    }

    func title(forSection _: SectionType) -> String {
        fatalError("Not implemented!")
    }

    func sections() -> [SectionType] {
        fatalError("Not implemented!")
    }

    func items(forSection _: SectionType) -> [VTAnyItem] {
        fatalError("Not implemented!")
    }

    func updateState() async {}

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

    private func identifier(forItemType: any VTItem.Type) -> String {
        String(describing: forItemType)
    }

    private func configureDataSource() {
        let cellRegistrations = Dictionary(uniqueKeysWithValues: supportedCellTypes.map { ty in
            String(describing: ty) => self.cellRegistration(forType: ty)
        })

        dataSource = DataSource(collectionView: collectionView) { [weak self] collectionView, indexPath, wrappedItem in
            guard let self,
                  let item = wrappedItem.base as? (any VTItem),
                  let registration = cellRegistrations[identifier(forItemType: type(of: item))]
            else {
                fatalError("Expected VTItem")
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

            header.configure(text: title(forSection: section))
            return header
        }
    }

    // MARK: - Update UI

    @MainActor
    private func applySnapshot(animated: Bool, reconfigureItemWithIDs itemIDs: [String]) {
        let sectionAndItems = sections().map { sec in sec => items(forSection: sec) }

        var snapshot = Snapshot()
        for (sec, items) in sectionAndItems where !items.isEmpty {
            snapshot.appendSections([sec])
            snapshot.appendItems(items, toSection: sec)
            // Force a reload to rollback incorrect items.
            let refreshItems = items.filter { itemIDs.contains($0.id) }
            snapshot.reconfigureItems(refreshItems)
        }

        dataSource.apply(snapshot, animatingDifferences: animated)
    }

    @MainActor
    private func reloadData(animated: Bool, reconfigureItemWithIDs itemIDs: [String] = []) async {
        await updateState()
        applySnapshot(animated: animated, reconfigureItemWithIDs: itemIDs)
    }

    func performUpdate(
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

    override func collectionView(_: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }
        return item.base is VTKeyValueItem
    }

    override func collectionView(_: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }
        return item.base is VTKeyValueItem
    }

    @MainActor
    override func reconnectAndRefresh() async {
        await reloadData(animated: false)
    }
}
