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
    private var eventObservationTask: Task<Void, Never>?
    private var observerToken: VTListenerToken?

    init(client: any VTAPIClientProtocol) {
        self.client = client
        super.init(collectionViewLayout: UICollectionViewLayout())
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        eventObservationTask?.cancel()

        if let observerToken {
            let client = self.client
            Task { await client.removeEventObserver(token: observerToken, for: .valetudoEvent) }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        configureCollectionView()
        configureDataSource()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        startEventObservation()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        stopEventObservation()
    }

    override func reconnectAndRefresh() async {
        stopEventObservation()
        startEventObservation()
    }

    // MARK: - Setup

    private func configureCollectionView() {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.backgroundColor = .adaptiveGroupedBackground
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
                        log(message: error.localizedDescription, forSubsystem: .valetudoEvent, level: .error)
                        return false
                    }
                }
                return UISwipeActionsConfiguration(actions: actions)
            }
        }
        config.showsSeparators = true

        let layout = UICollectionViewCompositionalLayout.list(using: config)
        collectionView.collectionViewLayout = layout
        configureRefreshControlIfSupported(refreshControl, action: #selector(didPullToRefresh))

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
                        .foregroundColor: UIColor.label,
                    ]
                )
                content.attributedText = attributedTitle
            } else {
                content.attributedText = nil
                content.text = item.title
                content.textProperties.color = .systemRed
            }

            cell.contentConfiguration = content
            cell.backgroundConfiguration = .adaptiveListCell()
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

    override func collectionView(_: UICollectionView, shouldHighlightItemAt _: IndexPath) -> Bool {
        false
    }

    // MARK: - Event Observation

    private func startEventObservation() {
        guard eventObservationTask == nil else { return }

        eventObservationTask = Task { [weak self] in
            guard let self else { return }

            await reloadData(animated: false)

            let (token, stream) = await client.registerEventObserver(for: .valetudoEvent)
            observerToken = token

            for await event in stream {
                guard !Task.isCancelled else { break }

                switch event {
                case let .didReceiveData(events):
                    await updateEvents(events, animated: true)
                case let .didReceiveError(message):
                    log(message: message, forSubsystem: .valetudoEvent, level: .error)
                default:
                    break
                }
            }
        }
    }

    private func stopEventObservation() {
        eventObservationTask?.cancel()
        eventObservationTask = nil

        if let observerToken {
            let client = client
            Task { await client.removeEventObserver(token: observerToken, for: .valetudoEvent) }
            self.observerToken = nil
        }
    }

    @MainActor
    private func updateEvents(_ events: [any VTValetudoEvent], animated: Bool) async {
        self.events = events
        await applySnapshot(animated: animated)
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
            log(message: error.localizedDescription, forSubsystem: .valetudoEvent, level: .error)
        }
        await applySnapshot(animated: animated)
    }

    private func applySnapshot(animated: Bool) async {
        var snapshot = NSDiffableDataSourceSnapshot<Int, VTValetudoEventItem>()
        snapshot.appendSections([0])

        let items = events.map { VTValetudoEventItem(event: $0) }
        snapshot.appendItems(items)
        updateChromeVisibility(animated: animated)
        setNeedsUpdateContentUnavailableConfiguration()

        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }

        await dataSource.apply(snapshot, animatingDifferences: animated)
    }

    private func updateChromeVisibility(animated: Bool) {
        navigationController?.setNavigationBarHidden(events.isEmpty, animated: animated)
        view.setNeedsLayout()
    }

    override func updateContentUnavailableConfiguration(using _: UIContentUnavailableConfigurationState) {
        guard events.isEmpty else {
            contentUnavailableConfiguration = nil
            return
        }

        var config = UIContentUnavailableConfiguration.empty()
        config.text = "NO_EVENTS".localized()
        config.image = .bellFill
        config.imageProperties.preferredSymbolConfiguration = .init(pointSize: 36, weight: .regular)
        contentUnavailableConfiguration = config
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
    func adaptivePresentationStyle(for _: UIPresentationController) -> UIModalPresentationStyle {
        .none
    }
}
