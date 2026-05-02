//
//  Untitled.swift
//  Valetudo
//
//  Created by David Klopp on 15.04.26.
//
import UIKit

final class VTListSelectionCellContentView<T: Hashable & Equatable & Sendable & Describable>: UIView, UIContentView, UICollectionViewDelegate, UICollectionViewDropDelegate, UICollectionViewDragDelegate {
    private enum Section: Int, CaseIterable {
        case enabled
        case disabled
    }

    private let collectionView: UICollectionView
    private var dataSource: UICollectionViewDiffableDataSource<Section, T>!

    private var currentConfiguration: VTListSelectionCellContentConfiguration<T>!

    var configuration: UIContentConfiguration {
        get { currentConfiguration }
        set {
            guard let config = newValue as? VTListSelectionCellContentConfiguration<T> else { return }
            apply(config)
        }
    }

    // MARK: - Init

    init(configuration: VTListSelectionCellContentConfiguration<T>) {
        var layoutConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        layoutConfig.headerMode = .supplementary
        layoutConfig.backgroundColor = .adaptiveGroupedBackground

        // let compositionalLayout = UICollectionViewCompositionalLayout.list(using: layoutConfig)
        let compositionalLayout = UICollectionViewCompositionalLayout { _, env in
            let section = NSCollectionLayoutSection.list(using: layoutConfig, layoutEnvironment: env)
            section.contentInsets.top = 0
            section.contentInsets.trailing = 0
            section.contentInsets.leading = 0
            section.contentInsetsReference = .none
            section.supplementaryContentInsetsReference = .none
            return section
        }

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: compositionalLayout)

        super.init(frame: .zero)

        setup()
        configureDataSource()
        apply(configuration)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    // MARK: - Self Sizing

    override func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority _: UILayoutPriority,
        verticalFittingPriority _: UILayoutPriority
    ) -> CGSize {
        collectionView.layoutIfNeeded()
        let height = collectionView.collectionViewLayout.collectionViewContentSize.height
        return CGSize(width: targetSize.width, height: height + 20)
    }

    // MARK: - Setup

    private func setup() {
        collectionView.register(
            VTHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: VTHeaderView.reuseIdentifier
        )
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isScrollEnabled = false
        collectionView.delegate = self
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self

        addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    // MARK: - DataSource

    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, T> { [weak self] cell, indexPath, item in
            guard let allowReordering = self?.currentConfiguration.allowReordering else { return }

            var content = UIListContentConfiguration.cell()
            content.text = item.description
            content.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)
            cell.contentConfiguration = content
            cell.backgroundConfiguration = .adaptiveListCell()
            let section = Section(rawValue: indexPath.section)
            cell.accessories = section == .enabled ?
                (allowReordering ? [.reorder(displayed: .always)] : [])
                : [.plus()]
        }

        dataSource = UICollectionViewDiffableDataSource<Section, T>(
            collectionView: collectionView
        ) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }

        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader else { return nil }

            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: VTHeaderView.reuseIdentifier,
                for: indexPath
            ) as? VTHeaderView

            if let config = self?.currentConfiguration {
                let section = Section(rawValue: indexPath.section)
                header?.configure(text: section == .enabled ? config.enabledTitle : config.disabledTitle)
            }

            return header
        }
    }

    // MARK: - Apply Snapshot

    private func apply(_ config: VTListSelectionCellContentConfiguration<T>) {
        currentConfiguration = config

        var snapshot = NSDiffableDataSourceSnapshot<Section, T>()
        snapshot.appendSections([.enabled, .disabled])

        let enabled = config.active
        let disabled = config.options.filter { !config.active.contains($0) }

        snapshot.appendItems(enabled, toSection: .enabled)
        snapshot.appendItems(disabled, toSection: .disabled)

        // reconfigure to refresh cell accessories
        snapshot.reconfigureItems(enabled + disabled)

        dataSource.apply(snapshot, animatingDifferences: false)
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(_: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource.itemIdentifier(for: indexPath),
              let section = Section(rawValue: indexPath.section)
        else { return false }

        // Update the UI to move the cell
        var snapshot = dataSource.snapshot()
        snapshot.deleteItems([item])
        let targetSection: Section = (section == .enabled) ? .disabled : .enabled
        snapshot.appendItems([item], toSection: targetSection)
        snapshot.reconfigureItems([item])

        let enabledItems = snapshot.itemIdentifiers(inSection: .enabled)

        dataSource.apply(snapshot, animatingDifferences: true)

        // Perform callback to inform observer about the change
        currentConfiguration.onChange?(enabledItems)

        return false
    }

    // MARK: - UICollectionViewDragDelegate

    func collectionView(_: UICollectionView,
                        itemsForBeginning _: UIDragSession,
                        at indexPath: IndexPath)
        -> [UIDragItem]
    {
        guard currentConfiguration.allowReordering else { return [] }

        let section = Section(rawValue: indexPath.section)
        guard section == .enabled else { return [] }

        let itemProvider = NSItemProvider(object: indexPath.description as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = indexPath
        return [dragItem]
    }

    // MARK: - UICollectionViewDropDelegate

    func collectionView(_: UICollectionView,
                        dropSessionDidUpdate session: UIDropSession,
                        withDestinationIndexPath destinationIndexPath: IndexPath?)
        -> UICollectionViewDropProposal
    {
        guard currentConfiguration.allowReordering else { return UICollectionViewDropProposal(operation: .forbidden) }

        guard let destinationIndexPath else { return UICollectionViewDropProposal(operation: .cancel) }
        guard let sourceIndexPath = session.localDragSession?
            .items.first?
            .localObject as? IndexPath
        else {
            return UICollectionViewDropProposal(operation: .cancel)
        }

        let destSection = Section(rawValue: destinationIndexPath.section)
        let sourceSection = Section(rawValue: sourceIndexPath.section)

        // Only allow drag & drop in enabled section
        guard sourceSection == .enabled, sourceSection == destSection else {
            return UICollectionViewDropProposal(operation: .forbidden)
        }

        return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }

    func collectionView(_: UICollectionView,
                        performDropWith coordinator: UICollectionViewDropCoordinator)
    {
        guard currentConfiguration.allowReordering else { return }

        guard let destinationIndexPath = coordinator.destinationIndexPath else { return }
        guard let item = coordinator.items.first, let sourceIndexPath = item.sourceIndexPath else { return }

        let destSection = Section(rawValue: destinationIndexPath.section)!
        let sourceSection = Section(rawValue: sourceIndexPath.section)!

        guard sourceSection == .enabled, sourceSection == destSection else { return }

        var snapshot = dataSource.snapshot()

        // Remove from old position
        let movingItem = dataSource.itemIdentifier(for: sourceIndexPath)!
        snapshot.deleteItems([movingItem])

        // Compute insertion index safely
        let itemsInSection = snapshot.itemIdentifiers(inSection: destSection)
        let insertIndex = min(destinationIndexPath.item, itemsInSection.count)

        if itemsInSection.isEmpty {
            snapshot.appendItems([movingItem], toSection: destSection)
        } else {
            let referenceItem = itemsInSection[insertIndex == itemsInSection.count
                ? insertIndex - 1
                : insertIndex]

            if insertIndex >= itemsInSection.count {
                snapshot.appendItems([movingItem], toSection: destSection)
            } else {
                snapshot.insertItems([movingItem], beforeItem: referenceItem)
            }
        }

        dataSource.apply(snapshot, animatingDifferences: true)

        let enabledItems = snapshot.itemIdentifiers(inSection: .enabled)
        currentConfiguration.onChange?(enabledItems)

        coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
    }
}
