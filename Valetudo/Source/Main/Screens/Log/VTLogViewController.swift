//
//  VTUpdaterViewController.swift
//  Valetudo
//
//  Created by David Klopp on 20.09.25.
//
import UIKit
import MarkdownKit

// TODO: Test: After successfull install the check for update spins forever

fileprivate let unknownString = "UNKNOWN".localizedUppercase()

class VTUpdaterViewController: UICollectionViewController {
    typealias VTUpdaterDataSource = UICollectionViewDiffableDataSource<VTUpdaterSection, VTUpdaterItem>
    typealias VTUpdaterSnapshot = NSDiffableDataSourceSnapshot<VTUpdaterSection, VTUpdaterItem>
    
    let client: VTAPIClientProtocol
    var dataSource: VTUpdaterDataSource!
    
    private let refreshControl = UIRefreshControl()
    
    private var sections: [VTUpdaterSection] = [.main, .update]
    
    private var selectedProvider: VTUpdaterProvider?
    private var needsVersionCheck: Bool = true
    
    init(client: VTAPIClientProtocol) {
        self.client = client
        var listConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        listConfig.showsSeparators = true
        listConfig.headerMode = .supplementary
        listConfig.footerMode = .supplementary
        let layout = UICollectionViewCompositionalLayout.list(using: listConfig)
        super.init(collectionViewLayout: layout)
        
        navigationItem.title = "UPDATER".localizedCapitalized()
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
        
    private func configureCollectionView() {
        //collectionView.backgroundColor = .systemGroupedBackground
        collectionView.delaysContentTouches = false
        
        collectionView.register(
            VTHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: VTHeaderView.reuseIdentifier
        )
        
        collectionView.register(
            VTFooterView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: VTFooterView.reuseIdentifier
        )
        
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
    }
    
    @objc private func didPullToRefresh() {
        Task {
            await self.reloadData(animated: true)
        }
    }
    
    private func configureDataSource() {
        let currentVersionRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, VTUpdaterItem> { cell, _, item in
            switch (item) {
            case .currentVersion(let version):
                var listContent = cell.defaultContentConfiguration()
                listContent.text = "VERSION".localizedCapitalized()
                listContent.secondaryText = version
                cell.contentConfiguration = listContent
            case .currentCommit(let commit):
                var listContent = cell.defaultContentConfiguration()
                listContent.text = "COMMIT".localizedCapitalized()
                listContent.secondaryText = commit
                cell.contentConfiguration = listContent
            default:
                break
            }
        }
        
        let updateProviderRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, VTUpdaterItem> { [weak self] cell, _, item in
            switch (item) {
            case .updaterProvider(let provider):
                let config = VTProviderSelectionCellContentConfiguration(
                    title: "UPDATE_CHANNEL".localizedCapitalized(),
                    provider: provider,
                    selectedProvider: (self?.selectedProvider ?? provider.last!),
                ) { newProvider in
                    Task {
                        do {
                            try await self?.client.setUpdaterConfiguration(VTUpdaterConfig(updateProvider: newProvider))
                            self?.selectedProvider = newProvider
                            
                            let updaterState = try? await self?.client.getUpdaterState()
                            self?.needsVersionCheck = true
                            await self?.checkForUpdateIfNeeded(updaterState)
                        } catch {
                            /* nothing */
                        }
                        
                        var snapshot = self?.dataSource.snapshot()
                        snapshot?.reconfigureItems([item])
                        if let snapshot {
                            await self?.dataSource.apply(snapshot, animatingDifferences: false)
                        }
                    }
                }
                cell.contentConfiguration = config
            default:
                break
            }
        }
        
        let loadingUpdateCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, VTUpdaterItem> { cell, _, item in
            switch (item) {
            case .loading(let title):
                cell.contentConfiguration = VTLoadingCellContentConfiguration(message: title)
            default:
                break
            }
        }
        
        let updateStateCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, VTUpdaterItem> { cell, _, item in
            switch (item) {
            case .updateState(let title, let image, let color):
                cell.contentConfiguration = VTUpdateStateCellContentConfiguration(
                    message: title,
                    image: image,
                    tintColor: color
                )
            default:
                break
            }
        }
        
        let updateProgressCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, VTUpdaterItem> { cell, _, item in
            switch (item) {
            case .progress(let title, let progress):
                cell.contentConfiguration = VTProgressCellContentConfiguration(
                    message: title,
                    progress: progress
                )
            default:
                break
            }
        }
        
        let updateDetailCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, VTUpdaterItem> { cell, _, item in
            switch (item) {
            case .updateAvailable(let title, let image, let version, let changelog):
                let markdownString = if let range = changelog.range(of: "</div>") {
                    String(changelog[range.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
                } else {
                    changelog
                }
                let markdownParser = MarkdownParser(
                    font: .systemFont(ofSize: UIFont.labelFontSize),
                    color: .label
                )
                let attributedText = markdownParser.parse(markdownString)
                cell.contentConfiguration = VTUpdateDetailCellContentConfiguration(
                    title: title,
                    subtitle: version,
                    image: image,
                    attributedMessage: attributedText,
                    baseTextColor: .label,
                    buttonTitle: "DOWNLOAD".localizedCapitalized(),
                    buttonAction: { [weak self] button in
                        button.isEnabled = false
                        Task {
                            let updaterState = try? await self?.client.getUpdaterState()
                            await self?.downloadUpdateIfNeeded(updaterState)
                        }
                    }
                )
            case .installUpdate(let title, let image, let version):
                cell.contentConfiguration = VTUpdateDetailCellContentConfiguration(
                    title: title,
                    subtitle: version,
                    image: image,
                    attributedMessage: NSAttributedString(
                        string: "INSTALL_WARNING".localized(),
                        attributes: [.foregroundColor: UIColor.systemRed]
                    ),
                    baseTextColor: .systemRed,
                    buttonTitle: "INSTALL".localizedCapitalized(),
                    buttonAction: { [weak self] button in
                        button.isEnabled = false
                        Task {
                            let updaterState = try? await self?.client.getUpdaterState()
                            await self?.installUpdateIfNeeded(updaterState)
                        }
                    }
                )
            default:
                break
            }
        }
        
        dataSource = VTUpdaterDataSource(collectionView: collectionView) { collectionView, indexPath, item in
            switch (item) {
            case .currentVersion(_), .currentCommit(_):
                collectionView.dequeueConfiguredReusableCell(using: currentVersionRegistration, for: indexPath, item: item)
            case .updaterProvider(_):
                collectionView.dequeueConfiguredReusableCell(using: updateProviderRegistration, for: indexPath, item: item)
            case .loading(_):
                collectionView.dequeueConfiguredReusableCell(using: loadingUpdateCellRegistration, for: indexPath, item: item)
            case .updateState(_, _, _):
                collectionView.dequeueConfiguredReusableCell(using: updateStateCellRegistration, for: indexPath, item: item)
            case .progress(_, _):
                collectionView.dequeueConfiguredReusableCell(using: updateProgressCellRegistration, for: indexPath, item: item)
            case .updateAvailable(_, _, _, _), .installUpdate(_, _, _):
                collectionView.dequeueConfiguredReusableCell(using: updateDetailCellRegistration, for: indexPath, item: item)
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
            case (UICollectionView.elementKindSectionFooter, .update):
                let footer = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: VTFooterView.reuseIdentifier,
                    for: indexPath
                ) as? VTFooterView
                footer?.isHidden = false
                footer?.configure(attributedText: "UPDATER_FOOTER_DESCRIPTION".localizedMarkdown())
                return footer
            case (UICollectionView.elementKindSectionFooter, _):
                let footer = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: VTFooterView.reuseIdentifier,
                    for: indexPath
                ) as? VTFooterView
                //footer?.configure(attributedText: NSAttributedString(string: ""))
                footer?.isHidden = true
                return footer
            default:
                fatalError("Unexpected element kind: \(kind)!")
            }
        }
    }
    
    func section(for indexPath: IndexPath) -> VTUpdaterSection {
        sections[indexPath.section] 
    }
    
    private func item(forState state: (any VTUpdaterState)?) -> VTUpdaterItem {
        let unknownState: VTUpdaterItem = .updateState(
            title: "UPDATE_UNKNOWN".localizedCapitalized(),
            image: UIImage(systemName: "questionmark.circle.fill"),
            tintColor: .secondaryLabel
        )
        guard let state else { return unknownState }        
        switch (state) {
        case _ as VTUpdaterNoUpdateRequiredState:
            return .updateState(
                title: "UP_TO_DATE".localizedCapitalized(),
                image: UIImage(systemName: "checkmark.circle.fill"),
                tintColor: .systemGreen
            )
        case _ as VTUpdaterIdleState:
            return .loading(title: "CHECKING_FOR_UPDATES".localizedCapitalized())
        case _ as VTUpdaterErrorState:
            return .updateState(
                title: "UPDATE_ERROR".localizedCapitalized(),
                image: UIImage(systemName: "xmark.circle.fill"),
                tintColor: .systemRed
            )
        case let downloadingState as VTUpdaterDownloadingState:
            if let progress = downloadingState.progress {
                let formattedProgress = String(format: "%.0f", progress)
                return .progress(
                    title: "\(formattedProgress)% " + "DOWNLOADING_UPDATE".localizedCapitalized(),
                    progress: progress
                )
            } else {
                return .loading(title: "DOWNLOADING_UPDATE".localizedCapitalized())
            }
        case _ as VTUpdaterDisabledState:
            return .updateState(
                title: "UPDATE_DISABLED".localizedCapitalized(),
                image: UIImage(systemName: "circle.slash.fill"),
                tintColor: .secondaryLabel
            )
        case let approvalPendingState as VTUpdaterApprovalPendingState:
            return .updateAvailable(
                title: "VALETUDO".localizedCapitalized(),
                image: UIImage(named: "Logo"),
                version: approvalPendingState.version,
                changelog: approvalPendingState.changelog
            )
        case let applyPendingState as VTUpdaterApplyPendingState:
            if applyPendingState.busy {
                return .loading(title: "APPLY_UPDATE".localizedCapitalized())
            } else {
                return .installUpdate(
                    title: "INSTALL".localizedCapitalized(),
                    image: UIImage(systemName: "arrow.trianglehead.2.counterclockwise"),
                    version: applyPendingState.version
                )
            }
        default:
            return unknownState
        }
    }
    
    private func checkForUpdateIfNeeded(_ state: (any VTUpdaterState)?) async {
        guard needsVersionCheck, let state, let _ = state as? VTUpdaterIdleState else { return }
        let client = self.client
        do {
            try await client.checkForUpdate()
            needsVersionCheck = false
            await scheduleRefresh(continuous: true)
        } catch {
            /* nothing, handeled by state change */
        }
    }
    
    private func downloadUpdateIfNeeded(_ state: (any VTUpdaterState)?) async {
        guard let state, let _ = state as? VTUpdaterApprovalPendingState else { return }
        do {
            try await client.downloadUpdate()
            await scheduleRefresh(continuous: true)
        } catch { /* nothing, handeled by state change */}
    }
    
    private func installUpdateIfNeeded(_ state: (any VTUpdaterState)?) async {
        guard let state, let _ = state as? VTUpdaterApplyPendingState else { return }
        do {
            try await client.applyUpdate()
            needsVersionCheck = true
            await scheduleRefresh(continuous: true)
        } catch { /* nothing, handeled by state change */}
    }
    
    /**
     * As long as the state is busy, we busy wait and fetch the state again.
     * Only if the state is not busy anymore we refresh the UI.
     * Set continuous to true to update the UI every single time we make a request.
     */
    @MainActor
    private func scheduleRefresh(continuous: Bool = false, retries: Int = 120) async {
        var state: (any VTUpdaterState)? = nil
        var isBusy = true
        var i = 0
        while (isBusy && i < retries) {
            state = try? await client.getUpdaterState()
            // after a successfull install, we need to check for new updates
            await checkForUpdateIfNeeded(state)
            
            if let state, continuous {
                await refreshUpdateCell(state, animated: true)
            } else {
                i += 1
            }
            
            // true as default to continue in case of an error
            isBusy = state?.busy ?? true
            if (!isBusy) { break }
            
            try? await Task.sleep(nanoseconds: 1_000_000_000) // wait 1 second
        }
        guard let state, !continuous else { return }
        await refreshUpdateCell(state, animated: true)
    }
    
    @MainActor
    private func refreshUpdateCell(_ state: any VTUpdaterState, animated: Bool) async {
        var snapshot = dataSource.snapshot()
        let identifiers = snapshot.itemIdentifiers(inSection: .update)
        snapshot.deleteItems(identifiers)
        snapshot.appendItems([item(forState: state)], toSection: .update)
        await dataSource.apply(snapshot, animatingDifferences: animated)
    }
    
    @MainActor
    func reloadData(animated: Bool) async {
        let valetudoVersion = try? await client.getValetudoVersionInfo()
        let updaterConfig = try? await client.getUpdaterConfiguration()
        let updaterState = try? await client.getUpdaterState()
                
        selectedProvider = updaterConfig?.updateProvider
        
        var snapshot = VTUpdaterSnapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems([
            .currentVersion(valetudoVersion?.release ?? unknownString),
            .currentCommit(valetudoVersion?.commit ?? unknownString),
            .updaterProvider(VTUpdaterProvider.allCases),
        ], toSection: .main)
        snapshot.appendSections([.update])
        snapshot.appendItems([
            item(forState: updaterState)
        ], toSection: .update)

        await dataSource.apply(snapshot, animatingDifferences: animated)
        
        if self.refreshControl.isRefreshing {
            self.refreshControl.endRefreshing()
        }
        
        needsVersionCheck = true
        await checkForUpdateIfNeeded(updaterState)
    }

    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }
        return switch (item) {
        case _: false
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        
        switch item {
        default:
            break
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }
        return switch (item) {
        case _: false
        }
    }
}
