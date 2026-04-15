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
        
        navigationItem.title = "SYSTEM_INFORMATION".localizedCapitalized()
    }
    
    required init?(coder: NSCoder) {
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
        //collectionView.backgroundColor = .systemGroupedBackground
        collectionView.register(
            VTHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: VTHeaderView.reuseIdentifier
        )
    }
    
    func configureDataSource() {
        let linkCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, VTSystemInformationItem> { cell, _, item in
            switch (item) {
            case .link(let title, _):
                var listContent = cell.defaultContentConfiguration()
                listContent.text = title
                cell.contentConfiguration = listContent
                cell.accessories = [.disclosureIndicator()]
            default:
                break
            }
        }
        
        let keyValueCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, VTSystemInformationItem> { cell, _, item in
            switch (item) {
            case .keyValuePair(let title, let subtitle):
                var listContent = cell.defaultContentConfiguration()
                listContent.text = title
                listContent.secondaryText = subtitle
                cell.contentConfiguration = listContent
            default:
                break
            }
            
        }
        
        let segmentedBarRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, VTSystemInformationItem> { cell, _, item in
            switch (item) {
            case .segmentedBar(var config):
                config.availableWidth = cell.contentView.frame.width
                cell.contentConfiguration = config
                cell.accessories = []
            default:
                break
            }
        }
        
        dataSource = VTSystemInformationDataSource(collectionView: collectionView) { collectionView, indexPath, item in
            switch (item) {
            case .keyValuePair(_, _):
                collectionView.dequeueConfiguredReusableCell(using: keyValueCellRegistration, for: indexPath, item: item)
            case .link(_, _):
                collectionView.dequeueConfiguredReusableCell(using: linkCellRegistration, for: indexPath, item: item)
            case .segmentedBar(_):
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
    
    func section(for indexPath: IndexPath) -> VTSystemInformationSection {
        fatalError("Not implemented!")
    }
    
    func reloadData(animated: Bool) async {
        fatalError("Not implemented!")
    }

    @MainActor
    override func reconnectAndRefresh() async {
        Task { await self.reloadData(animated: false) }
    }
    
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }
        return switch (item) {
        case .link(_, _): true
        case _: false
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        
        switch item {
        case .link(let title, let children):
            let vc = VTSystemInformationDetailedViewController(client: client, data: children)
            vc.navigationItem.title = title
            navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }
        return switch (item) {
        case .link(_, _): true
        case _: false
        }
    }
}
