//
//  VTSidebarViewController.swift
//  Valetudo
//
//  Created by David Klopp on 15.05.25.
//
import UIKit

class VTSidebarViewController: UICollectionViewController {
    enum Section {
        case main
    }

    enum Item: Hashable {
        case map
        case settings

        var title: String {
            switch self {
            case .map:      return "Map"
            case .settings: return "Settings"
            }
        }

        var icon: UIImage? {
            switch self {
            case .map:      return UIImage(systemName: "map.fill")
            case .settings: return UIImage(systemName: "gearshape.fill")
            }
        }
    }

    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!

    var didSelectItem: ((Int) -> Void)?

    let items: [Item] = [.map, .settings]

    init() {
        let layout = UICollectionViewCompositionalLayout.list(using: UICollectionLayoutListConfiguration(appearance: .sidebar))
        super.init(collectionViewLayout: layout)
        self.clearsSelectionOnViewWillAppear = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureDataSource()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        selectFirstItemIfNeeded()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        selectFirstItemIfNeeded()
    }
    
    private func selectFirstItemIfNeeded() {
        guard viewIfLoaded != nil, let isCompact = splitViewController?.isCompact else { return }
        
        if !isCompact, (collectionView.indexPathsForSelectedItems?.isEmpty ?? false) {
            collectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .top)
        }
    }

    private func configureCollectionView() {
        collectionView.backgroundColor = .systemGroupedBackground
    }

    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Item> { cell, _, item in
            var content = cell.defaultContentConfiguration()
            content.text = item.title
            content.image = item.icon
            cell.contentConfiguration = content
        }

        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }

        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    // MARK: - UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectItem?(indexPath.item)
    }
}
