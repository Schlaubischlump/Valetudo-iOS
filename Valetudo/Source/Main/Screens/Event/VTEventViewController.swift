//
//  VTEventViewController.swift
//  Valetudo
//
//  Created by David Klopp on 19.04.26.
//
import UIKit

final class VTEventsViewController: VTCollectionViewController {
    private var dataSource: UICollectionViewDiffableDataSource<Int, VTEventItem>!

    private let refreshControl = UIRefreshControl()
    
    private var client: any VTAPIClientProtocol
    private var events: [any VTEvent] = []
    
    init(client: any VTAPIClientProtocol) {
        self.client = client
        super.init(collectionViewLayout: UICollectionViewLayout())
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        configureCollectionView()
        configureDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Task { await reloadData(animated: false) }
    }
    
    override func reconnectAndRefresh() async {
        await reloadData(animated: false)
    }
    
    // MARK: - Setup
    
    private func configureCollectionView() {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let item = self?.dataSource.itemIdentifier(for: indexPath) else { return nil }

            let delete = UIContextualAction(style: .destructive, title: "DELETE".localizedCapitalized()) {
                [weak self] _, _, completion in

                Task {
                    var success = false
                    do {
                        try await self?.client.interactWithEvent(id: item.id, interaction: .ok)
                        await self?.applySnapshot(animated: true)
                        success = true
                    } catch {
                        success = false
                    }
                    DispatchQueue.main.async {
                        completion(success)
                    }
                }
            }

            return UISwipeActionsConfiguration(actions: [delete])
        }
        config.showsSeparators = true

        let layout = UICollectionViewCompositionalLayout.list(using: config)
        collectionView.collectionViewLayout = layout
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)

        view.addSubview(collectionView)
    }
    
    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, VTEventItem> { cell, _, item in
            
            var content = cell.defaultContentConfiguration()
            
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short

            content.text = item.title
            content.secondaryText = formatter.string(from: item.timestamp)
            content.textProperties.color = .systemRed

            cell.contentConfiguration = content
        }

        dataSource = UICollectionViewDiffableDataSource<Int, VTEventItem>(
            collectionView: collectionView
        ) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: item
            )
        }
    }
    

    // MARK: - Reload
    
    @objc private func didPullToRefresh() {
        Task { await self.reloadData(animated: true) }
    }
    
    @MainActor func reloadData(animated: Bool) async {
        do {
            events = try await client.getEvents()
        } catch {
            events = []
            log(message: error.localizedDescription, forSubsystem: .event, level: .error)
        }
        await applySnapshot(animated: animated)
    }
    
    private func applySnapshot(animated: Bool) async {
        var snapshot = NSDiffableDataSourceSnapshot<Int, VTEventItem>()
        snapshot.appendSections([0])

        let items = events.map { VTEventItem(id: $0.id, title: $0.description, timestamp: $0.timestamp) }
        snapshot.appendItems(items)

        if self.refreshControl.isRefreshing {
            self.refreshControl.endRefreshing()
        }
        
        await dataSource.apply(snapshot, animatingDifferences: animated)
    }
    
    // MARK: - Self sizing
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let contentHeight = collectionView.contentSize.height

        let maxHeight: CGFloat = 400
        let minHeight: CGFloat = 100

        let height = min(max(contentHeight, minHeight), maxHeight)

        preferredContentSize = CGSize(width: 320, height: height)
    }
}

extension VTEventsViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        .none
    }
}
