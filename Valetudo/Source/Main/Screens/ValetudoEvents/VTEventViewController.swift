//
//  VTEventViewController.swift
//  Valetudo
//
//  Created by David Klopp on 19.04.26.
//
import UIKit

final class VTValetudoEventsViewController: VTCollectionViewController {
    private var dataSource: UICollectionViewDiffableDataSource<Int, VTValetudoEventItem>!

    private let refreshControl = UIRefreshControl()
    
    private var client: any VTAPIClientProtocol
    private var events: [any VTValetudoEvent] = []
    
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
            if item.processed {
                return nil
            } else {
                let actions = item.createContextualAction { interaction in
                    do {
                        try await self?.client.interactWithValetudoEvent(id: item.id, interaction: interaction)
                        await self?.reloadData(animated: true)
                        return true
                    } catch {
                        log(message: error.localizedDescription, forSubsystem: .event, level: .error)
                        return false
                    }
                }
                return UISwipeActionsConfiguration(actions: actions)
            }
        }
        config.showsSeparators = true

        let layout = UICollectionViewCompositionalLayout.list(using: config)
        collectionView.collectionViewLayout = layout
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)

        view.addSubview(collectionView)
    }
    
    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, VTValetudoEventItem> { cell, _, item in
            
            var content = cell.defaultContentConfiguration()
            
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short

            content.text = item.title
            content.secondaryText = formatter.string(from: item.timestamp)
            
            if item.processed {
                content.text = nil
                content.textProperties.color = .label
                let attributedTitle = NSAttributedString(
                    string: item.title,
                    attributes: [
                        .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                        .foregroundColor: UIColor.label
                    ]
                )
                content.attributedText = attributedTitle
            } else {
                content.attributedText = nil
                content.text = item.title
                content.textProperties.color = .systemRed
            }

            cell.contentConfiguration = content
        }

        dataSource = UICollectionViewDiffableDataSource<Int, VTValetudoEventItem>(
            collectionView: collectionView
        ) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: item
            )
        }
    }
    
    // MARK: - Selection
    
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    // MARK: - Reload
    
    @objc private func didPullToRefresh() {
        Task { await self.reloadData(animated: true) }
    }
    
    @MainActor func reloadData(animated: Bool) async {
        do {
            events = try await client.getValetudoEvents()
        } catch {
            events = []
            log(message: error.localizedDescription, forSubsystem: .event, level: .error)
        }
        await applySnapshot(animated: animated)
    }
    
    private func applySnapshot(animated: Bool) async {
        var snapshot = NSDiffableDataSourceSnapshot<Int, VTValetudoEventItem>()
        snapshot.appendSections([0])

        let items = events.map { VTValetudoEventItem(event: $0) }
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

extension VTValetudoEventsViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        .none
    }
}
