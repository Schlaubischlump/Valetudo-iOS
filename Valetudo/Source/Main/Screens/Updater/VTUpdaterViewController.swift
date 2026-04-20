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

fileprivate let kUpdate = "UPDATE_CHANNEL"
fileprivate let kUpdateUnknown = "UPDATE_UNKNOWN"
fileprivate let kUpToDate = "UP_TO_DATE"
fileprivate let kCheckingForUpdates = "CHECKING_FOR_UPDATES"
fileprivate let kUpdatError = "UPDATE_ERROR"
fileprivate let kProgress = "PROGRESS"
fileprivate let kLoading = "LOADING"
fileprivate let kUpdateDisabled = "UPDATE_DISABLED"
fileprivate let kUpdateAvailable = "UPDATE_AVAILABLE"
fileprivate let kApplyUpdate = "APPLY_UPDATE"
fileprivate let kInstallUpdate = "INSTALL_UPDATE"
fileprivate let kCurrentVersion = "CURRENT_VERSION"
fileprivate let kCurrentCommit = "CURRENT_COMMIT"
fileprivate let kUpdateProvider = "UPDATE_PROVIDER"

class VTUpdaterViewController: VTCollectionViewController {
    typealias VTUpdaterDataSource = UICollectionViewDiffableDataSource<VTUpdaterSection, VTAnyItem>
    typealias VTUpdaterSnapshot = NSDiffableDataSourceSnapshot<VTUpdaterSection, VTAnyItem>
    
    let client: VTAPIClientProtocol
    var dataSource: VTUpdaterDataSource!
    
    private let refreshControl = UIRefreshControl()
    
    private var sections: [VTUpdaterSection] = [.main, .update]
    
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
        navigationItem.rightBarButtonItem = VTValetudoEventBarButton(client: client)
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
    
    @MainActor
    override func reconnectAndRefresh() async {
        Task { await self.reloadData(animated: false) }
    }
    
    
    private func configureDataSource() {
        let currentVersionRegistration = VTCellRegistration { cell, _, wrappedItem in
            switch (wrappedItem.base) {
            case let item as VTCurrentVersionItem:
                var listContent = cell.defaultContentConfiguration()
                listContent.text = "VERSION".localizedCapitalized()
                listContent.secondaryText = item.versionString
                cell.contentConfiguration = listContent
            case let item as VTCurrentCommitItem:
                var listContent = cell.defaultContentConfiguration()
                listContent.text = "COMMIT".localizedCapitalized()
                listContent.secondaryText = item.commitString
                cell.contentConfiguration = listContent
            default:
                break
            }
        }
        
        let updateProviderRegistration = VTCellRegistration { [weak self] cell, _, wrappedItem in
            switch (wrappedItem.base) {
            case let item as VTUpdaterProviderItem:
                let config = VTDropDownCellContentConfiguration(
                    id: item.id,
                    title: "UPDATE_CHANNEL".localizedCapitalized(),
                    options: item.options,
                    selection: item.active,
                    disableSelectionAfterAction: true
                ) { newProvider in
                    Task {
                        do {
                            guard let self else { return }
                            
                            try await self.client.setUpdaterConfiguration(VTUpdaterConfig(updateProvider: newProvider))
                            
                            let updaterState = try? await self.client.getUpdaterState()
                            
                            self.needsVersionCheck = true
                            await self.checkForUpdateIfNeeded(updaterState)
                            
                            await self.refreshUpdaterProviderCell(newProvider, animated: false)
                        } catch {
                            /* nothing */
                        }
                    }
                }
                cell.contentConfiguration = config
            default:
                break
            }
        }
        
        let loadingUpdateCellRegistration = VTCellRegistration { cell, _, wrappedItem in
            switch (wrappedItem.base) {
            case let item as VTLoadingItem:
                cell.contentConfiguration = VTLoadingCellContentConfiguration(id: item.id, message: item.message)
            default:
                break
            }
        }
        
        let updateStateCellRegistration = VTCellRegistration { cell, _, wrappedItem in
            switch (wrappedItem.base) {
            case let item as VTUpdateStateItem:
                cell.contentConfiguration = VTUpdateStateCellContentConfiguration(
                    id: item.id,
                    message: item.title,
                    image: item.image,
                    tintColor: item.tintColor
                )
            default:
                break
            }
        }
        
        let updateProgressCellRegistration = VTCellRegistration { cell, _, wrappedItem in
            switch (wrappedItem.base) {
            case let item as VTProgressItem:
                cell.contentConfiguration = VTProgressCellContentConfiguration(
                    id: item.id,
                    message: item.message,
                    progress: item.progress
                )
            default:
                break
            }
        }
        
        let updateDetailCellRegistration = VTCellRegistration { cell, _, wrappedItem in
            switch (wrappedItem.base) {
            case let item as VTUpdateAvailableItem:
                let markdownString = if let range = item.changelog.range(of: "</div>") {
                    String(item.changelog[range.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
                } else {
                    item.changelog
                }
                let markdownParser = MarkdownParser(
                    font: .systemFont(ofSize: UIFont.labelFontSize),
                    color: .label
                )
                let attributedText = markdownParser.parse(markdownString)
                cell.contentConfiguration = VTUpdateDetailCellContentConfiguration(
                    id: item.id,
                    title: item.title,
                    subtitle: item.version,
                    image: item.image,
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
            case let item as VTInstallUpdateItem:
                cell.contentConfiguration = VTUpdateDetailCellContentConfiguration(
                    id: item.id,
                    title: item.title,
                    subtitle: item.version,
                    image: item.image,
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
        
        dataSource = VTUpdaterDataSource(collectionView: collectionView) { collectionView, indexPath, wrappedItem in
            let registration = switch (wrappedItem.base) {
            case _ as VTCurrentVersionItem, _ as VTCurrentCommitItem:   currentVersionRegistration
            case _ as VTUpdaterProviderItem:                            updateProviderRegistration
            case _ as VTLoadingItem:                                    loadingUpdateCellRegistration
            case _ as VTUpdateStateItem:                                updateStateCellRegistration
            case _ as VTProgressItem:                                   updateProgressCellRegistration
            case _ as VTUpdateAvailableItem, _ as VTInstallUpdateItem:  updateDetailCellRegistration
            default: fatalError("Unsupported item type: \(type(of: wrappedItem.base))")
            }
            
            return collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: wrappedItem)
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
    
    private func item(forState state: (any VTUpdaterState)?) -> VTAnyItem {
        let unknownState: VTAnyItem = .updateState(
            kUpdateUnknown,
            title: "UPDATE_UNKNOWN".localizedCapitalized(),
            image: UIImage(systemName: "questionmark.circle.fill"),
            tintColor: .secondaryLabel
        )
        guard let state else { return unknownState }        
        switch (state) {
        case _ as VTUpdaterNoUpdateRequiredState:
            return .updateState(
                kUpToDate,
                title: "UP_TO_DATE".localizedCapitalized(),
                image: UIImage(systemName: "checkmark.circle.fill"),
                tintColor: .systemGreen
            )
        case _ as VTUpdaterIdleState:
            return .loading(kCheckingForUpdates, message: "CHECKING_FOR_UPDATES".localizedCapitalized())
        case _ as VTUpdaterErrorState:
            return .updateState(
                kUpdatError,
                title: "UPDATE_ERROR".localizedCapitalized(),
                image: UIImage(systemName: "xmark.circle.fill"),
                tintColor: .systemRed
            )
        case let downloadingState as VTUpdaterDownloadingState:
            if let progress = downloadingState.progress {
                let formattedProgress = String(format: "%.0f", progress)
                return .progress(
                    kProgress,
                    message: "\(formattedProgress)% " + "DOWNLOADING_UPDATE".localizedCapitalized(),
                    progress: progress
                )
            } else {
                return .loading(kLoading, message: "DOWNLOADING_UPDATE".localizedCapitalized())
            }
        case _ as VTUpdaterDisabledState:
            return .updateState(
                kUpdateDisabled,
                title: "UPDATE_DISABLED".localizedCapitalized(),
                image: UIImage(systemName: "circle.slash.fill"),
                tintColor: .secondaryLabel
            )
        case let approvalPendingState as VTUpdaterApprovalPendingState:
            return .updateAvailable(
                kUpdateAvailable,
                title: "VALETUDO".localizedCapitalized(),
                image: UIImage(named: "Logo"),
                version: approvalPendingState.version,
                changelog: approvalPendingState.changelog
            )
        case let applyPendingState as VTUpdaterApplyPendingState:
            if applyPendingState.busy {
                return .loading(kApplyUpdate, message: "APPLY_UPDATE".localizedCapitalized())
            } else {
                return .installUpdate(
                    kInstallUpdate,
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
    private func refreshUpdaterProviderCell(_ provider: VTUpdaterProvider, animated: Bool) async {
        var snapshot = dataSource.snapshot()
        let identifier = snapshot.itemIdentifiers(inSection: .main).last!
        snapshot.deleteItems([identifier])
        snapshot.appendItems([.updaterProvider(kUpdateProvider, provider: provider)], toSection: .main)
        await dataSource.apply(snapshot, animatingDifferences: animated)
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
                
        let selectedProvider = updaterConfig?.updateProvider ?? VTUpdaterProvider.allCases.last!
        
        var snapshot = VTUpdaterSnapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems([
            .currentVersion(kCurrentVersion, versionString: valetudoVersion?.release ?? unknownString),
            .currentCommit(kCurrentCommit, commitString: valetudoVersion?.commit ?? unknownString),
            .updaterProvider(kUpdateProvider, provider: selectedProvider)
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
