//
//  VTSystemInformationViewControllerBase.swift
//  Valetudo
//
//  Created by David Klopp on 16.09.25.
//
import UIKit

class VTSystemInformationViewControllerBase: VTCollectionViewController {
    typealias VTSystemInformationDataSource = UICollectionViewDiffableDataSource<VTSystemInformationSection, VTSystemInformationItem>
    typealias VTSystemInformationSnapshot = NSDiffableDataSourceSnapshot<VTSystemInformationSection, VTSystemInformationItem>

    let client: VTAPIClientProtocol
    var dataSource: VTSystemInformationDataSource!

    init(client: VTAPIClientProtocol) {
        self.client = client
        var listConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        listConfig.showsSeparators = true
        listConfig.headerMode = .supplementary
        let layout = UICollectionViewCompositionalLayout.list(using: listConfig)
        super.init(collectionViewLayout: layout)

        navigationItem.title = "SYSTEM_INFORMATION".localized()
        navigationItem.rightBarButtonItem = VTValetudoEventBarButtonItem(client: client, parentViewController: self)
    }

    @available(*, unavailable)
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
        // collectionView.backgroundColor = .systemGroupedBackground
        collectionView.register(
            VTHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: VTHeaderView.reuseIdentifier
        )
    }

    func configureDataSource() {
        let linkCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, VTSystemInformationItem> { cell, _, item in
            switch item {
            case let .link(title, _):
                var listContent = cell.defaultContentConfiguration()
                listContent.text = title
                cell.contentConfiguration = listContent
                cell.accessories = [.disclosureIndicator()]
            default:
                break
            }
        }

        let keyValueCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, VTSystemInformationItem> { cell, _, item in
            switch item {
            case let .keyValuePair(title, subtitle):
                var listContent = cell.defaultContentConfiguration()
                listContent.text = title
                listContent.secondaryText = subtitle
                cell.contentConfiguration = listContent
            default:
                break
            }
        }

        let segmentedBarRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, VTSystemInformationItem> { cell, _, item in
            switch item {
            case var .segmentedBar(config):
                config.availableWidth = cell.contentView.frame.width
                cell.contentConfiguration = config
                cell.accessories = []
            default:
                break
            }
        }

        dataSource = VTSystemInformationDataSource(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case .keyValuePair:
                collectionView.dequeueConfiguredReusableCell(using: keyValueCellRegistration, for: indexPath, item: item)
            case .link:
                collectionView.dequeueConfiguredReusableCell(using: linkCellRegistration, for: indexPath, item: item)
            case .segmentedBar:
                collectionView.dequeueConfiguredReusableCell(using: segmentedBarRegistration, for: indexPath, item: item)
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

    @MainActor
    override func reconnectAndRefresh() async {
        Task { await self.reloadData(animated: false) }
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }
        return switch item {
        case .link: true
        case _: false
        }
    }

    override func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }

        switch item {
        case let .link(title, children):
            let vc = VTSystemInformationDetailedViewController(client: client, data: children)
            vc.navigationItem.title = title
            navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }

    override func collectionView(_: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }
        return switch item {
        case .link: true
        case _: false
        }
    }
}
