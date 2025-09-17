//
//  Untitled.swift
//  Valetudo
//
//  Created by David Klopp on 14.09.25.
//
import UIKit


class VTConsumablesViewController: UICollectionViewController {
    fileprivate typealias VTConsumablesDataSource = UICollectionViewDiffableDataSource<VTConsumablesSection, VTConsumableItem>
    fileprivate typealias VTConsumablesDatasourceSnapshot = NSDiffableDataSourceSnapshot<VTConsumablesSection, VTConsumableItem>
    
    // You can remove this once tuples support hashability in swift
    private struct VTConsumableID: Hashable {
        let type: VTConsumableType
        let subType: VTConsumableSubType
    }
    // optional meta data, in particular the max value, for items
    private var itemProperties: [VTConsumableID: VTConsumableStateAttributeProperties] = [:]
    
    private var dataSource: VTConsumablesDataSource!
    private var items: [VTConsumableItem] = []
    
    private let client: VTAPIClientProtocol
    private var observerToken: VTListenerToken?
    
    init(client: VTAPIClientProtocol) {
        self.client = client
        var listConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        listConfig.showsSeparators = true
        listConfig.footerMode = .supplementary
        listConfig.backgroundColor = .clear
        let layout = UICollectionViewCompositionalLayout.list(using: listConfig)
        super.init(collectionViewLayout: layout)
        
        collectionView.delaysContentTouches = false
        navigationItem.subtitle = "MONITORE_AND_RESET_CONSUMABLE_STATES".localized()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureDataSource()
    }

    private func configureCollectionView() {
        collectionView.register(
            VTFooterView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: VTFooterView.reuseIdentifier
        )
        collectionView.backgroundColor = .systemBackground
    }
    
    private func configureDataSource() {
        let client = self.client
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, VTConsumableItem> { cell, _, item in
            cell.contentConfiguration = VTConsumablesCellContentConfiguration(
                title: item.title,
                remaining: item.subtitle,
                progress: Float(item.progress),
                showsReset: true
            ) {
                Task {
                    do {
                        try await client.resetConsumable(type: item.type, subtype: item.subType)
                    } catch {
                        // TODO: Show error
                        print("Received error: \(error)")
                    }
                }
            }
            cell.backgroundConfiguration = .clear()
        }
        
        dataSource = VTConsumablesDataSource(collectionView: collectionView) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionFooter else { return nil }
            let footer = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: VTFooterView.reuseIdentifier,
                for: indexPath
            ) as? VTFooterView
            footer?.configure(attributedText: "CONSUMABLE_FOOTER_DESCRIPTION".localizedMarkdown())
            return footer
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Task {
            do {
                try await loadInitialData()
                
                let (token, stream) = await client.registerEventObserver(for: .stateAttributes)
                observerToken = token
                
                for await event in stream {
                    switch event {
                    case .didReceiveData(let stateAttributes):
                        updateItems(with: stateAttributes.consumableStateAttributes, animated: true)
                    case .didReceiveError(let msg):
                        print("Received error message: \(msg)")
                        // TODO: Show error
                    default:
                        break
                    }
                }
            } catch {
                // TODO: Show error
                print("Failed to load map data: \(error)")
            }
        }
    }

    func loadInitialData() async throws {
        let metaData = (try? await client.getPropertiesForConsumables()) ?? []
        itemProperties = Dictionary(uniqueKeysWithValues: metaData.compactMap { prop in
            if prop.maxValue != nil {
                (VTConsumableID(type: prop.type, subType: prop.subType), prop)
            } else {
                nil
            }
        })
        let attrs = try? await client.getConsumables()
        updateItems(with: attrs ?? [], animated: false)
    }
    
    private func updateItems(with attributes: [VTConsumableStateAttribute], animated: Bool) {
        items = attributes.map { attr in
            let id = VTConsumableID(type: attr.type, subType: attr.subType)
            let prop = itemProperties[id]
            let maxValue: VTConsumableRemaining? = if let prop, let maxVal = prop.maxValue {
                VTConsumableRemaining(value: maxVal, unit: prop.unit)
            } else {
                nil
            }
            return VTConsumableItem(
                type: attr.type,
                subType: attr.subType,
                remaining: attr.remaining,
                maxValue:maxValue
            )
        }
        applySnapshot(animated: animated)
    }
    
    @MainActor
    private func applySnapshot(animated: Bool) {
        var snapshot = VTConsumablesDatasourceSnapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let token = observerToken {
            // capture a strong reference, since we know the client will outlive self
            let client = self.client
            Task { await client.removeEventObserver(token: token, for: .map) }
        }
    }
}

