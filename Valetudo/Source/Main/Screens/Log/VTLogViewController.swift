//
//  VTLogViewController.swift
//  Valetudo
//
//  Created by David Klopp on 20.09.25.
//
import MarkdownKit
import UIKit

// TODO: We could add sse events in the future

final class VTLogViewController: VTCollectionViewController, UISearchResultsUpdating {
    typealias VTLogDataSource = UICollectionViewDiffableDataSource<VTLogSection, VTLogItem>
    typealias VTLogSnapshot = NSDiffableDataSourceSnapshot<VTLogSection, VTLogItem>

    let client: VTAPIClientProtocol
    var dataSource: VTLogDataSource!

    private let refreshControl = UIRefreshControl()

    private let sections: [VTLogSection] = [.main, .log]
    // cached data
    private var currentLogLevel: String?
    private var allLogLineItems: [VTLogItem] = []

    init(client: VTAPIClientProtocol) {
        self.client = client
        var listConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        listConfig.showsSeparators = true
        listConfig.headerMode = .supplementary
        listConfig.backgroundColor = .adaptiveGroupedBackground
        let layout = UICollectionViewCompositionalLayout.list(using: listConfig)
        super.init(collectionViewLayout: layout)

        navigationItem.title = "LOG".localized()
        navigationItem.rightBarButtonItems = [
            VTValetudoEventBarButtonItem(client: client, parentViewController: self),
            /* UIBarButtonItem(
                    barButtonSystemItem: .refresh,
                    target: self,
                    action: #selector(animatePullToRefresh)
                ), */
            UIBarButtonItem(
                barButtonSystemItem: .action,
                target: self,
                action: #selector(shareLogFile)
            ),
        ]

        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        definesPresentationContext = true
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

    private func configureCollectionView() {
        // collectionView.backgroundColor = .systemGroupedBackground
        collectionView.delaysContentTouches = false

        collectionView.register(
            VTHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: VTHeaderView.reuseIdentifier
        )

        configureRefreshControlIfSupported(refreshControl, action: #selector(didPullToRefresh))
    }

    @objc private func shareLogFile() {
        // Convert all log lines to a single string
        let isoFormatter = DateFormatter()
        isoFormatter.locale = Locale(identifier: "en_US_POSIX")
        isoFormatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC
        isoFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"

        let logText = allLogLineItems.compactMap { item -> String? in
            switch item {
            case let .logLine(date, level, message):
                return "[\(isoFormatter.string(from: date))] [\(level)] \(message)"
            default:
                return nil
            }
        }.joined(separator: "\n")

        // Save the log to a temporary file
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("logs.txt")

        do {
            try logText.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            // TODO: Show error
            log(message: "Failed to write log file: \(error.localizedDescription)", forSubsystem: .valetudoLog, level: .error)
            return
        }

        // Present the share sheet
        let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        activityVC.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItems?.last
        present(activityVC, animated: true)
    }

    @objc private func animatePullToRefresh() {
        #if targetEnvironment(macCatalyst)
            didPullToRefresh()
        #else
            guard !refreshControl.isRefreshing else { return }
            refreshControl.beginRefreshing()

            // Make sure the refresh control is visible
            collectionView.setContentOffset(
                CGPoint(x: 0, y: -collectionView.adjustedContentInset.top - refreshControl.frame.size.height),
                animated: true
            )
            // Give it some time to do a proper animation of the refresh control
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.didPullToRefresh()
            }
        #endif
    }

    @MainActor
    override func reconnectAndRefresh() async {
        await reloadData(animated: true)
    }

    @objc private func didPullToRefresh() {
        Task {
            await self.reloadData(animated: true)
        }
    }

    private func configureDataSource() {
        let updateLogLevel = UICollectionView.CellRegistration<UICollectionViewListCell, VTLogItem> { [weak self] cell, _, item in
            switch item {
            case let .updateLogLevel(presets):
                let config = VTDropDownCellContentConfiguration<String>(
                    id: "log_level",
                    title: "LEVEL".localized(),
                    options: presets.map(\.capitalized),
                    selection: self?.currentLogLevel ?? presets.last ?? ""
                ) { newLevel in
                    Task {
                        do {
                            try await self?.client.setLogLevel(newLevel.lowercased())
                            self?.currentLogLevel = newLevel
                        } catch { /* nothing */ }

                        var snapshot = self?.dataSource.snapshot()
                        snapshot?.reconfigureItems([item])
                        if let snapshot {
                            await self?.dataSource.apply(snapshot, animatingDifferences: false)
                        }
                    }
                }
                cell.contentConfiguration = config
                cell.backgroundConfiguration = .adaptiveListCell()

            default:
                break
            }
        }

        let logContent = UICollectionView.CellRegistration<UICollectionViewListCell, VTLogItem> { cell, _, item in
            switch item {
            case let .logLine(date, level, message):
                let config = VTLogLineCellContentConfiguration(timestamp: date, level: level, message: message)
                cell.contentConfiguration = config
                cell.backgroundConfiguration = .adaptiveListCell()
            default:
                break
            }
        }

        dataSource = VTLogDataSource(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case .updateLogLevel:
                collectionView.dequeueConfiguredReusableCell(using: updateLogLevel, for: indexPath, item: item)
            case .logLine:
                collectionView.dequeueConfiguredReusableCell(using: logContent, for: indexPath, item: item)
            }
        }

        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            let section = self.section(for: indexPath)
            switch (kind, section) {
            case (UICollectionView.elementKindSectionHeader, _):
                let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: VTHeaderView.reuseIdentifier,
                    for: indexPath
                ) as? VTHeaderView
                header?.configure(text: self.section(for: indexPath).title ?? "")
                return header
            default:
                fatalError("Unexpected element kind: \(kind)!")
            }
        }
    }

    func section(for indexPath: IndexPath) -> VTLogSection {
        sections[indexPath.section]
    }

    @MainActor
    func reloadData(animated: Bool) async {
        let logProperties = try? await client.getLogProperties()
        let logEntries = await (try? client.getLog()) ?? []
        allLogLineItems = logEntries.map { VTLogItem.logLine(date: $0.timestamp, level: $0.level, message: $0.message) }

        currentLogLevel = logProperties?.current.capitalized

        var snapshot = VTLogSnapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems([
            .updateLogLevel(presets: logProperties?.presets ?? []),
        ], toSection: .main)
        snapshot.appendSections([.log])
        snapshot.appendItems(allLogLineItems, toSection: .log)

        await dataSource.apply(snapshot, animatingDifferences: animated)

        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }

    // MARK: - UISearchResultsUpdating

    private var searchTask: Task<Void, Never>?

    func updateSearchResults(for searchController: UISearchController) {
        searchTask?.cancel()
        searchTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 200_000_000) // 0.2s debounce, might help for large logs
            await MainActor.run {
                self?.applySearch(query: searchController.searchBar.text)
            }
        }
    }

    private func applySearch(query: String?) {
        let lowerQuery = query?.lowercased() ?? ""
        let filteredLogs: [VTLogItem] = lowerQuery.isEmpty ? allLogLineItems : allLogLineItems.filter {
            switch $0 {
            case let .logLine(_, level, message):
                level.lowercased().contains(lowerQuery) || message.lowercased().contains(lowerQuery)
            default:
                false
            }
        }

        var snapshot = dataSource.snapshot()
        if snapshot.sectionIdentifiers.contains(.log) {
            snapshot.deleteItems(snapshot.itemIdentifiers(inSection: .log))
            snapshot.appendItems(filteredLogs, toSection: .log)
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    // MARK: - UICollectionViewDelegate

    override func collectionView(_: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }
        return switch item {
        case _: false
        }
    }

    override func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        switch item {
        default: break
        }
    }

    override func collectionView(_: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }
        return switch item {
        case _: false
        }
    }
}
