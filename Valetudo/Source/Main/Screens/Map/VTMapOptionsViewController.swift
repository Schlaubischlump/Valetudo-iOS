//
//  VTMap.swift
//  Valetudo
//
//  Created by David Klopp on 26.04.26.
//
import UIKit

final class VTMapOptionsViewController: VTCollectionViewController {
    private typealias DataSource = UICollectionViewDiffableDataSource<VTMapOptionsSection, VTMapOptionsItem>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<VTMapOptionsSection, VTMapOptionsItem>

    private let client: VTAPIClientProtocol
    private var dataSource: DataSource!

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
    
    @MainActor
    required init?(coder: NSCoder) {
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
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, VTMapOptionsItem> { _, _, _ in
        }

        dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }

        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionFooter else { return nil }
            let footer = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: VTFooterView.reuseIdentifier,
                for: indexPath
            ) as? VTFooterView
            footer?.configure(attributedText: "MAP_OPTIONS_FOOTER_DESCRIPTION".localizedMarkdown())
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
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        await dataSource.apply(snapshot, animatingDifferences: animated)

        #if !targetEnvironment(macCatalyst)
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
        #endif
    }
}
