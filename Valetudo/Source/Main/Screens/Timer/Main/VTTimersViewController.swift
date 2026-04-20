//
//  VTMainViewController.swift
//  Valetudo
//
//  Created by David Klopp on 18.03.25.
//  
//

import UIKit

final class VTTimersViewController: VTCollectionViewController {

    typealias DataSource = UICollectionViewDiffableDataSource<VTTimersSection, VTTimersItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<VTTimersSection, VTTimersItem>

    private let client: VTAPIClientProtocol
    private var dataSource: DataSource!

    private let refreshControl = UIRefreshControl()

    private var timers: [String: VTTimer] = [:]

    // MARK: - Init

    init(client: VTAPIClientProtocol) {
        self.client = client
        
        super.init(collectionViewLayout: UICollectionViewLayout())
        setupAndApplyListLayout()
        
        title = "TIMER".localized()
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItems = [
            VTValetudoEventBarButton(client: client),
            UIBarButtonItem(
                barButtonSystemItem: .add,
                target: self,
                action: #selector(didTapAdd)
            ),
        ]
        
        configureCollectionView()
        configureDataSource()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Task {
            await reloadData(animated: false)
        }
    }
    
    // MARK: - Layout

    private func setupAndApplyListLayout() {
        var listConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        listConfig.showsSeparators = true
        listConfig.headerMode = .supplementary
        listConfig.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let item = self?.dataSource.itemIdentifier(for: indexPath),
                  case .timer(let timer) = item else { return nil }
            
            let delete = UIContextualAction(style: .destructive, title: "DELETE".localizedCapitalized()) { [weak self] _, _, completion in
                Task {
                    await self?.deleteTimer(timer)
                    completion(true)
                }
            }
            
            delete.image = UIImage(systemName: "trash")
            
            return UISwipeActionsConfiguration(actions: [delete])
        }
        let layout = UICollectionViewCompositionalLayout.list(using: listConfig)
        collectionView.setCollectionViewLayout(layout, animated: false)
    }
    
    private func configureCollectionView() {
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)

        collectionView.register(
            VTHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: VTHeaderView.reuseIdentifier
        )
    }

    // MARK: - DataSource
    
    @MainActor
    private func enableUserInteraction() async {
        self.collectionView.isUserInteractionEnabled = true
    }
    
    @MainActor
    private func disableUserInteraction() async {
        self.collectionView.isUserInteractionEnabled = false
    }

    private func configureDataSource() {

        let timerCell = UICollectionView.CellRegistration<UICollectionViewListCell, VTTimersItem> { [weak self] cell, _, item in
            guard case .timer(let timer) = item else { return }

            var config = timer.toCellConfiguration()

            config.onToggle = { isOn in
                Task {
                    await self?.disableUserInteraction()
                    let updatedTimer = timer.copy(enabled: isOn)
                    await self?.update(timer: timer, with: updatedTimer)
                    await self?.enableUserInteraction()
                }
            }
            config.onSelect = { weekday in
                Task {
                    await self?.disableUserInteraction()
                    let isActive = timer.isActiveWeekday(weekday)
                    let updatedTimer = timer.update(weekday: weekday, enabled: !isActive)
                    await self?.update(timer: timer, with: updatedTimer)
                    await self?.enableUserInteraction()
                }
            }
            config.onRun = {
                guard let timerID = timer.id else { return }
                
                Task {
                    await self?.disableUserInteraction()
                    do {
                        try await self?.client.executeTimer(id: timerID)
                    } catch {
                        print(error)
                        // TODO: Handle error and display it to the user
                    }
                    await self?.enableUserInteraction()
                }
            }

            cell.contentConfiguration = config
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
        }

        dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: timerCell, for: indexPath, item: item)
        }

        // Header
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            switch kind {
            case UICollectionView.elementKindSectionHeader:
                let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: VTHeaderView.reuseIdentifier,
                    for: indexPath
                ) as? VTHeaderView

                header?.configure(text: "")
                return header

            default:
                return nil
            }
        }
    }

    // MARK: - Actions

    @objc private func didTapAdd() {
        let client = self.client
        let vc = VTTimerDetailViewController(timer: VTTimer(), client: client)
        vc.title = "ADD_TIMER".localizedCapitalized()
        vc.onDone = { [weak self] timer in
            Task {
                do {
                    try await client.addTimer(timer)
                    await self?.reloadData(animated: true)
                } catch {
                    print(error)
                    // TODO: Handle error
                }
            }
        }
        present(UINavigationController(rootViewController: vc), animated: true)
    }
    
    @objc private func didPullToRefresh() {
        Task {
            await reloadData(animated: true)
        }
    }

    private func update(timer: VTTimer, with updated: VTTimer) async {
        guard timer.id == updated.id else {
            fatalError("ID mismatch between timer and updated timer!")
        }
        guard let id = timer.id else { return }
                
        // try to update timer, on failure revert
        let newTimer = ((try? await client.updateTimer(updated)) != nil) ? updated : timer
        
        await MainActor.run {
            self.timers[id] = newTimer
            self.applySnapshot(animated: true)
        }
    }
    
    private func deleteTimer(_ timer: VTTimer) async {
        guard let id = timer.id else { return }

        await disableUserInteraction()

        do {
            try await client.deleteTimer(id: id)
            await MainActor.run {
                timers.removeValue(forKey: id)
                self.applySnapshot(animated: true)
            }
        } catch {
            print(error)
            // TODO: show error UI
        }

        await enableUserInteraction()
    }
    
    @MainActor
    private func applySnapshot(animated: Bool = true) {
        var snapshot = Snapshot()

        let sortedTimers = timers.values.sorted {
            ($0.hour, $0.minute) < ($1.hour, $1.minute)
        }

        for timer in sortedTimers {
            guard let id = timer.id else { continue }

            let section = VTTimersSection.timer(id: id)
            snapshot.appendSections([section])
            snapshot.appendItems([.timer(timer)], toSection: section)
        }

        dataSource.apply(snapshot, animatingDifferences: animated)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath),
              case .timer(let timer) = item else { return }

        let vc = VTTimerDetailViewController(timer: timer, client: client)
        vc.title = "EDIT_TIMER".localizedCapitalized()
        let client = self.client
        vc.onDone = { [weak self] timer in
            Task {
                do {
                    try await client.updateTimer(timer)
                    await self?.reloadData(animated: true)
                } catch {
                    print(error)
                    // TODO: Handle error
                }
            }
        }
        present(UINavigationController(rootViewController: vc), animated: true)
    }

    // MARK: - Data Loading

    @MainActor
    private func reloadData(animated: Bool) async {
        do {
            timers = try await client.getTimers()
        } catch {
            print(error)
            // TODO: Handle error
            timers = [:]
        }

        self.applySnapshot(animated: animated)

        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }

    // MARK: - VTViewController

    @MainActor
    override func reconnectAndRefresh() async {
        await reloadData(animated: false)
    }
}

// MARK: - Context Menu

extension VTTimersViewController {

    override func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {

        guard let item = dataSource.itemIdentifier(for: indexPath),
              case .timer(let timer) = item,
              let id = timer.id else { return nil }

        return UIContextMenuConfiguration(identifier: id as NSString, previewProvider: nil) { _ in
            let delete = UIAction(title: "DELETE".localizedCapitalized(), image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
                Task {
                    await self?.deleteTimer(timer)
                }
            }
            return UIMenu(title: "", children: [delete])
        }
    }
}
