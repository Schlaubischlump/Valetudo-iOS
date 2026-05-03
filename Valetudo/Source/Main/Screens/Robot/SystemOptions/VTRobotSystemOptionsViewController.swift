//
//  VTRobotSystemOptionsViewController.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//

import UIKit

private let kSpeakerVolumeID = "SPEAKER_VOLUME"
private let kSpeakerTestID = "SPEAKER_TEST"
// private let kVoicePacksUrlID = "VOICE_PACKS_URL"
// private let kVoicePacksLanguageCodeID = "VOICE_PACKS_LANGUAGE_CODE"
// private let kVoicePacksHashID = "VOICE_PACKS_HASH"
// private let kSetVoicePack = "VOICE_PACKS_SET"
private let kDoNotDisturbEnabledID = "DO_NOT_DISTURB_ENABLED"
private let kDoNotDisturbStartID = "DO_NOT_DISTURB_START"
private let kDoNotDisturbEndID = "DO_NOT_DISTURB_END"

private enum VTRobotSystemOptionsError: Error, LocalizedError {
    case dndCreationFailed

    var errorDescription: String? {
        switch self {
        case .dndCreationFailed: "Failed to create VTDoNotDisturbConfiguration."
        }
    }
}

// TODO: Support Voice Packs

final class VTRobotSystemOptionsViewController: VTCollectionViewController {
    private struct DoNotDisturbState {
        var enabled: Bool = false
        var localStartTime: (hour: Int, minute: Int) = (0, 0)
        var localEndTime: (hour: Int, minute: Int) = (0, 0)

        func toDndConfiguration(
            enabled: Bool? = nil,
            localStartTime: (hour: Int, minute: Int)? = nil,
            localEndTime: (hour: Int, minute: Int)? = nil
        ) throws -> VTDoNotDisturbConfiguration {
            let newEnabled = enabled ?? self.enabled
            let newLocalStartTime = localStartTime ?? self.localStartTime
            let newLocalEndTime = localEndTime ?? self.localEndTime
            guard let startDate = Date.fromLocal(hour: newLocalStartTime.hour, minute: newLocalStartTime.minute),
                  let endDate = Date.fromLocal(hour: newLocalEndTime.hour, minute: newLocalEndTime.minute)
            else {
                throw VTRobotSystemOptionsError.dndCreationFailed
            }
            let (startHour, startMinute) = startDate.toUTCHourMinute()
            let (endHour, endMinute) = endDate.toUTCHourMinute()
            return VTDoNotDisturbConfiguration(
                enabled: newEnabled,
                start: VTDoNotDisturbTime(hour: startHour, minute: startMinute),
                end: VTDoNotDisturbTime(hour: endHour, minute: endMinute),
                metaData: [:]
            )
        }
    }

    /* private struct VoicePackState {
         var url: URL? = nil
         var languageCode: String? = nil
         var hash: String? = nil
     } */

    private struct State {
        var currentVolume: Int = 0
        /// var voicePack = VoicePackState()
        var doNotDisturb = DoNotDisturbState()
    }

    private typealias DataSource = UICollectionViewDiffableDataSource<VTRobotSystemOptionsSection, VTAnyItem>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<VTRobotSystemOptionsSection, VTAnyItem>

    private let client: any VTAPIClientProtocol
    private let availableCapabilities: Set<VTCapability>

    private var dataSource: DataSource!
    private var state = State()

    init(client: any VTAPIClientProtocol, capabilities: Set<VTCapability>) {
        self.client = client
        availableCapabilities = capabilities

        super.init(collectionViewLayout: UICollectionViewLayout())
        setupAndApplyListLayout()

        title = "ROBOT_SYSTEM_OPTIONS".localized()
    }

    @available(*, unavailable)
    @MainActor required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View life cycle

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

    // MARK: - Setup CollectionView

    private func setupAndApplyListLayout() {
        var listConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        listConfig.showsSeparators = true
        listConfig.headerMode = .supplementary
        listConfig.backgroundColor = .adaptiveGroupedBackground

        let layout = UICollectionViewCompositionalLayout.list(using: listConfig)
        collectionView.setCollectionViewLayout(layout, animated: false)
    }

    private func configureCollectionView() {
        collectionView.register(
            VTHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: VTHeaderView.reuseIdentifier
        )
    }

    private func configureDataSource() {
        let buttonCell = VTCellRegistration { cell, _, wrappedItem in
            guard let item = wrappedItem.base as? VTButtonItem else {
                fatalError("Unsupported key value item: \(wrappedItem.base)")
            }
            cell.contentConfiguration = VTButtonCellContentConfiguration(
                id: item.id,
                title: item.title,
                disableSelectionAfterAction: true
            ) { [weak self] in
                guard let self, item.id == kSpeakerTestID else { return }
                performUpdate(operationName: "Test Speaker Volume", itemID: item.id) { [client] in
                    try await client.playSpeakerTestSound()
                } onSuccess: {
                    
                }
            }
            cell.backgroundConfiguration = .adaptiveListCell()
            cell.accessories = []
        }

        let sliderCell = VTCellRegistration { [weak self] cell, _, wrappedItem in
            guard let item = wrappedItem.base as? VTSliderItem else {
                fatalError("Unsupported key value item: \(wrappedItem.base)")
            }

            cell.contentConfiguration = VTSliderCellContentConfiguration(
                id: item.id,
                leftImage: item.leftImage,
                rightImage: item.rightImage,
                minValue: item.minValue,
                maxValue: item.maxValue,
                value: item.value,
                disableSelectionAfterAction: true
            ) { [weak self] newValue in
                guard let self, item.id == kSpeakerVolumeID else { return }
                performUpdate(operationName: "Change Speaker Volume", itemID: item.id) { [client] in
                    try await client.setSpeakerVolume(Int(newValue))
                } onSuccess: { [weak self] in
                    self?.state.currentVolume = Int(newValue)
                }
            }
            cell.backgroundConfiguration = .adaptiveListCell()
            cell.accessories = []
        }

        let checkboxCell = VTCellRegistration { [weak self] cell, _, wrappedItem in
            guard let item = wrappedItem.base as? VTCheckboxItem else {
                fatalError("Unsupported checkbox item: \(wrappedItem.base)")
            }

            cell.contentConfiguration = VTCheckboxCellContentConfiguration(
                id: item.id,
                title: item.title,
                subtitle: item.subtitle,
                isOn: item.isOn,
                image: item.image,
                disableSelectionAfterAction: true
            ) { [weak self] isOn in
                guard let self, item.id == kDoNotDisturbEnabledID else { return }
                performUpdate(operationName: "Toggle Do Not Disturb", itemID: item.id) { [weak self, client] in
                    guard let self else { return }
                    let newDndConfig = try await state.doNotDisturb.toDndConfiguration(enabled: isOn)
                    try await client.setDoNotDisturbConfiguration(newDndConfig)
                } onSuccess: { [weak self] in
                    self?.state.doNotDisturb.enabled = isOn
                }
            }
            cell.backgroundConfiguration = .adaptiveListCell()
            cell.accessories = []
        }

        let timePickerCell = VTCellRegistration { [weak self] cell, _, wrappedItem in
            guard let item = wrappedItem.base as? VTTimePickerItem else {
                fatalError("Unsupported checkbox item: \(wrappedItem.base)")
            }

            cell.contentConfiguration = VTTimePickerCellContentConfiguration(
                id: item.id,
                title: item.title,
                subtitle: item.subtitle,
                image: item.image,
                hours: item.hours,
                minutes: item.minutes,
                disableSelectionAfterAction: true
            ) { [weak self] localHour, localMin in
                guard let self, item.id == kDoNotDisturbStartID || item.id == kDoNotDisturbEndID else { return }
                performUpdate(operationName: "Change Do Not Disturb Time", itemID: item.id) { [weak self, client] in
                    guard let self else { return }
                    let newDndConfig = if item.id == kDoNotDisturbStartID {
                        try await state.doNotDisturb.toDndConfiguration(localStartTime: (localHour, localMin))
                    } else {
                        try await state.doNotDisturb.toDndConfiguration(localEndTime: (localHour, localMin))
                    }
                    try await client.setDoNotDisturbConfiguration(newDndConfig)
                } onSuccess: { [weak self] in
                    if item.id == kDoNotDisturbStartID {
                        self?.state.doNotDisturb.localStartTime = (localHour, localMin)
                    }
                    if item.id == kDoNotDisturbEndID {
                        self?.state.doNotDisturb.localEndTime = (localHour, localMin)
                    }
                }
            }
            cell.backgroundConfiguration = .adaptiveListCell()
            cell.accessories = []
        }

        dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, wrappedItem in
            let registration = switch wrappedItem.base {
            case _ as VTButtonItem: buttonCell
            case _ as VTSliderItem: sliderCell
            case _ as VTCheckboxItem: checkboxCell
            case _ as VTTimePickerItem: timePickerCell
            default: fatalError("Unsupported item type: \(type(of: wrappedItem.base))")
            }

            return collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: wrappedItem)
        }

        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader else { return nil }
            guard
                let self,
                let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: VTHeaderView.reuseIdentifier,
                    for: indexPath
                ) as? VTHeaderView,
                let section = dataSource.sectionIdentifier(for: indexPath.section)
            else {
                return nil
            }

            header.configure(text: section.title)
            return header
        }
    }

    // MARK: - Setup UI
    
    @MainActor
    private func applySnapshot(animated: Bool, reconfigureItemWithIDs itemIDs: [String]) {
        let sectionAndItems: [(VTRobotSystemOptionsSection, [VTAnyItem])] = [
            .speaker => makeSpeakerItems(),
            // .voicePacks => makeVoicePackItems(),
            .doNotDisturb => makeDoNotDisturbItems(),
        ]

        var snapshot = Snapshot()
        for (sec, items) in sectionAndItems where !items.isEmpty {
            snapshot.appendSections([sec])
            snapshot.appendItems(items, toSection: sec)
            // Force a reload to rollback incorrect items.
            let refreshItems = items.filter { itemIDs.contains($0.id) }
            snapshot.reconfigureItems(refreshItems)
        }
        

        dataSource.apply(snapshot, animatingDifferences: animated)
    }

    private func makeSpeakerItems() -> [VTAnyItem] {
        var items: [VTAnyItem] = []

        if availableCapabilities.contains(.speakerVolumeControl) {
            items.append(.slider(
                kSpeakerVolumeID,
                leftImage: .speakerQuite,
                rightImage: .speakerLoud,
                minValue: 0,
                maxValue: 100,
                value: Float(state.currentVolume)
            ))
        }
        if availableCapabilities.contains(.speakerTest) {
            items.append(.button(
                kSpeakerTestID,
                title: "TEST_SPEAKER".localized()
            ))
        }

        return items
    }

    /* private func makeVoicePackItems() -> [VTAnyItem] {
         var items: [VTAnyItem] = []

         guard availableCapabilities.contains(.voicePackManagement) else {
             return items
         }

         return items
     } */

    private func makeDoNotDisturbItems() -> [VTAnyItem] {
        guard availableCapabilities.contains(.doNotDisturb) else {
            return []
        }

        return [
            .checkbox(
                kDoNotDisturbEnabledID,
                title: "ENABLED".localized(),
                enabled: state.doNotDisturb.enabled
            ),
            .timePicker(
                kDoNotDisturbStartID,
                title: "START_TIME".localized(),
                hours: state.doNotDisturb.localStartTime.hour,
                minutes: state.doNotDisturb.localStartTime.minute
            ),
            .timePicker(
                kDoNotDisturbEndID,
                title: "END_TIME".localized(),
                hours: state.doNotDisturb.localEndTime.hour,
                minutes: state.doNotDisturb.localEndTime.minute
            ),
        ]
    }

    @MainActor
    private func reloadData(animated: Bool, reconfigureItemWithIDs itemIDs: [String] = []) async {
        var nextState = state

        if availableCapabilities.contains(.speakerVolumeControl) {
            nextState.currentVolume = await (try? client.getSpeakerVolume()) ?? nextState.currentVolume
        }

        /* if availableCapabilities.contains(.voicePackManagement),
             let status = await (try? client.getVoicePackManagementStatus())
         {

         } */

        if availableCapabilities.contains(.doNotDisturb),
           let dndConfig = await (try? client.getDoNotDisturbConfiguration()),
           let startDate = Date.fromUTC(hour: dndConfig.start.hour, minute: dndConfig.start.minute),
           let endDate = Date.fromUTC(hour: dndConfig.end.hour, minute: dndConfig.end.minute)
        {
            nextState.doNotDisturb.enabled = dndConfig.enabled
            nextState.doNotDisturb.localStartTime = startDate.toLocalHourMinute()
            nextState.doNotDisturb.localEndTime = endDate.toLocalHourMinute()
        }

        state = nextState
        applySnapshot(animated: animated, reconfigureItemWithIDs: itemIDs)
    }

    // MARK: - Callbacks

    private func performUpdate(
        operationName: String,
        itemID: String,
        operation: @escaping @Sendable () async throws -> Void,
        onSuccess: (@MainActor () -> Void)? = nil
    ) {
        Task { [weak self] in
            guard let self else { return }

            do {
                try await operation()
                await MainActor.run {
                    onSuccess?()
                }
                await reloadData(animated: false, reconfigureItemWithIDs: [itemID])
            } catch {
                log(message: "\(operationName) failed: \(error.localizedDescription)", forSubsystem: .robotControl, level: .error)
                await reconfigureItem(withID: itemID)
            }
        }
    }
    
    @MainActor
    private func reconfigureItem(withID id: String) async {
        var snapshot = dataSource.snapshot()
        guard let item = snapshot.itemIdentifiers.first(where: { $0.id == id }) else { return }
        snapshot.reconfigureItems([item])
        // Wait a little to make the rollback interaction smoother
        try? await Task.sleep(nanoseconds: 250_000_000)
        await dataSource.apply(snapshot, animatingDifferences: false)
    }

    override func collectionView(_: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }
        return item.base is VTKeyValueItem
    }

    
    @MainActor
    override func reconnectAndRefresh() async {
        await reloadData(animated: false)
    }
}
