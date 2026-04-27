//
//  VTSystemInformationViewControllerBase.swift
//  Valetudo
//
//  Created by David Klopp on 16.09.25.
//
import UIKit

class VTSystemInformationViewControllerBase: VTCollectionViewController {
    typealias VTSystemInformationDataSource = UICollectionViewDiffableDataSource<VTSystemInformationSection, VTAnyItem>
    typealias VTSystemInformationSnapshot = NSDiffableDataSourceSnapshot<VTSystemInformationSection, VTAnyItem>

    let client: VTAPIClientProtocol
    var dataSource: VTSystemInformationDataSource!

    init(client: VTAPIClientProtocol) {
        self.client = client
        var listConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        listConfig.showsSeparators = true
        listConfig.headerMode = .supplementary
        listConfig.backgroundColor = .adaptiveGroupedBackground
        let layout = UICollectionViewCompositionalLayout.list(using: listConfig)
        super.init(collectionViewLayout: layout)

        navigationItem.title = "SYSTEM_INFORMATION".localized()
        navigationItem.rightBarButtonItem = VTValetudoEventBarButtonItem(client: client, parentViewController: self)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) not implemented")
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

    func configureCollectionView() {
        collectionView.register(
            VTHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: VTHeaderView.reuseIdentifier
        )
    }

    func configureDataSource() {
        let linkCellRegistration = VTCellRegistration { cell, _, wrappedItem in
            switch wrappedItem.base {
            case let item as VTSystemInformationLinkItem:
                cell.contentConfiguration = VTKeyValueCellContentConfiguration(
                    id: item.id,
                    title: item.title,
                    value: nil,
                    usesHorizontalLayout: false
                )
                cell.backgroundConfiguration = .adaptiveListCell()
                cell.accessories = [.disclosureIndicator()]
            default:
                break
            }
        }

        let keyValueCellRegistration = VTCellRegistration { cell, _, wrappedItem in
            switch wrappedItem.base {
            case let item as VTKeyValueItem:
                cell.contentConfiguration = VTKeyValueCellContentConfiguration(
                    id: item.id,
                    title: item.title,
                    value: item.value,
                    usesHorizontalLayout: self.currentViewDesign == .regular
                )
                cell.backgroundConfiguration = .adaptiveListCell()
                cell.accessories = []
            default:
                break
            }
        }

        let segmentedBarRegistration = VTCellRegistration { cell, _, wrappedItem in
            switch wrappedItem.base {
            case let item as VTSystemInformationSegmentedBarItem:
                var config = item.config
                config.availableWidth = cell.contentView.frame.width
                cell.contentConfiguration = config
                cell.backgroundConfiguration = .adaptiveListCell()
                cell.accessories = []
            default:
                break
            }
        }

        dataSource = VTSystemInformationDataSource(collectionView: collectionView) { collectionView, indexPath, item in
            switch item.base {
            case is VTKeyValueItem:
                collectionView.dequeueConfiguredReusableCell(using: keyValueCellRegistration, for: indexPath, item: item)
            case is VTSystemInformationLinkItem:
                collectionView.dequeueConfiguredReusableCell(using: linkCellRegistration, for: indexPath, item: item)
            case is VTSystemInformationSegmentedBarItem:
                collectionView.dequeueConfiguredReusableCell(using: segmentedBarRegistration, for: indexPath, item: item)
            default:
                fatalError("Unsupported system information item: \(item.base)")
            }
        }

        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader else { return nil }
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: VTHeaderView.reuseIdentifier,
                for: indexPath
            ) as? VTHeaderView
            header?.configure(text: self.section(for: indexPath).title ?? "")
            return header
        }
    }

    func section(for _: IndexPath) -> VTSystemInformationSection {
        fatalError("Not implemented!")
    }

    func reloadData(animated _: Bool) async {
        fatalError("Not implemented!")
    }

    override func viewDesignDidChange(to _: VTViewDesign) {
        var snapshot = dataSource.snapshot()
        let identifiers = snapshot.itemIdentifiers
        guard !identifiers.isEmpty else { return }

        snapshot.reconfigureItems(identifiers)
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    @MainActor
    override func reconnectAndRefresh() async {
        Task { await self.reloadData(animated: false) }
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }
        return item.base is VTSystemInformationLinkItem
    }

    override func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }

        switch item.base {
        case let linkItem as VTSystemInformationLinkItem:
            let vc = VTSystemInformationDetailedViewController(client: client, data: linkItem.children)
            vc.navigationItem.title = linkItem.title
            navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }

    override func collectionView(_: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }
        return item.base is VTSystemInformationLinkItem
    }
}
