//
//  VTTimerDetailViewController.swift
//  Valetudo
//
//  Created by David Klopp on 18.03.25.
//
//

import UIKit

private let kEnabled = "ENABLED"
private let kLabel = "LABEL"
private let kDow = "DOW"
private let kTime = "TIME"
private let kSetFan = "SET_FAN"
private let kFan = "FAN"
private let kSetWater = "SET_WATER"
private let kWater = "WATER"
private let kSetMode = "SET_MODE"
private let kMode = "MODE"
private let kAction = "ACTION"
private let kIterations = "ITERATIONS"
private let kCustomOrder = "CUSTOM_ORDER"
private let kSegments = "SEGMENTS"

final class VTTimerDetailViewController: VTCollectionViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<VTTimersDetailSection, VTAnyItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<VTTimersDetailSection, VTAnyItem>

    private let client: VTAPIClientProtocol
    private var dataSource: DataSource!

    private var timer: VTTimer

    var onDone: ((VTTimer) -> Void)?

    // MARK: - Init

    init(timer: VTTimer, client: VTAPIClientProtocol) {
        self.client = client
        self.timer = timer

        super.init(collectionViewLayout: UICollectionViewLayout())
        setupAndApplyListLayout()
    }

    @available(*, unavailable)
    @MainActor required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(didTapDone)
        )

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(didTapClose)
        )

        configureCollectionView()
        configureDataSource()
    }

    func showLoading() {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: spinner)
    }

    @objc private func didTapDone() {
        showLoading()
        collectionView.isUserInteractionEnabled = false
        onDone?(timer)
        dismiss(animated: true)
    }

    @objc private func didTapClose() {
        dismiss(animated: true)
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

    // MARK: - DataSource

    private func togglePreAction(_ preActionType: VTTimer.PreAction.PreActionType, enabled: Bool) {
        let filteredPreActions = timer.preActions.filter { $0.type != preActionType }
        if !enabled {
            timer = timer.copy(preActions: filteredPreActions)
        } else {
            // Create a fresh preaction with a dummy value, it will be replaced on applying the snapshot
            let freshPreAction: VTTimer.PreAction = .init(type: preActionType, params: .init(value: nil))
            timer = timer.copy(preActions: filteredPreActions + [freshPreAction])
        }

        // enable corresponding selection item
        Task {
            await applySnapshotAfterAnimationDelay()
        }
    }

    private func configureDataSource() {
        let checkboxCell = VTCellRegistration { [weak self] cell, _, wrappedItem in
            guard let item = wrappedItem.base as? VTCheckboxItem else {
                fatalError("Unsupported checkbox item: \(wrappedItem.base)")
            }

            let disabledToggleOnAction = (item.id != kEnabled) && (item.id != kCustomOrder)

            cell.contentConfiguration = VTCheckboxCellContentConfiguration(
                id: item.id,
                title: item.title,
                isOn: item.enabled,
                disableSelectionAfterAction: disabledToggleOnAction
            ) { [weak self] new in
                guard let self else { return }

                switch item.id {
                case kEnabled:
                    timer = timer.copy(enabled: new)
                case kFan:
                    togglePreAction(.fanSpeedControl, enabled: new)
                case kWater:
                    togglePreAction(.waterUsageControl, enabled: new)
                case kMode:
                    togglePreAction(.operationModeControl, enabled: new)
                case kCustomOrder:
                    // If the action type is not 'segmentCleanup' we should never be able to reach this code path, since
                    // the toggle is not visible.
                    if timer.action.type == .segmentCleanup {
                        let params = timer.action.params
                        timer = timer.copy(action: .init(type: .segmentCleanup, params: params.copy(customOrder: new)))

                        // Update UI to allow or disallow reordering
                        Task {
                            await applySnapshotAfterAnimationDelay()
                        }
                    }
                default:
                    fatalError("Unexpected id: \(item.id)")
                }
            }
        }

        let textFieldCell = VTCellRegistration { [weak self] cell, _, wrappedItem in
            guard let item = wrappedItem.base as? VTTextFieldItem else {
                fatalError("Unsupported textField item: \(wrappedItem.base)")
            }

            cell.contentConfiguration = VTTextFieldCellContentConfiguration(
                id: item.id,
                label: "CUSTOM_LABEL".localized(),
                placeholder: "TIMER".localized(),
                text: item.text
            ) { [weak self] newText in
                guard let self else { return }

                switch item.id {
                case kLabel:
                    timer = timer.copy(label: newText)
                default:
                    fatalError("Unexpected id: \(item.id)")
                }
            }
        }

        let timePickerCell = VTCellRegistration { [weak self] cell, _, wrappedItem in
            guard let item = wrappedItem.base as? VTTimePickerItem else {
                fatalError("Unsupported time picker item: \(wrappedItem.base)")
            }

            cell.contentConfiguration = VTTimePickerCellContentConfiguration(
                id: item.id,
                label: "TIME".localized(),
                hours: item.hours,
                minutes: item.minutes
            ) { [weak self] localHour, localMin in
                guard let self else { return }

                switch item.id {
                case kTime:
                    guard let date = Date.fromLocal(hour: localHour, minute: localMin) else { return }
                    let (hour, minute) = date.toUTCHourMinute()
                    timer = timer.copy(hour: hour, minute: minute)
                default:
                    fatalError("Unexpected id: \(item.id)")
                }
            }
        }

        let segmentCell = VTCellRegistration { [weak self] cell, _, wrappedItem in
            guard let item = wrappedItem.base as? VTSegmentItem<VTWeekday> else {
                fatalError("Unsupported segment item: \(wrappedItem.base)")
            }

            cell.contentConfiguration = VTSegmentCellContentConfiguration(
                id: item.id,
                options: item.options,
                active: item.active
            ) { [weak self] newActive in
                guard let self else { return }

                timer = switch item.id {
                case kDow:
                    timer.copy(dow: newActive.map(\.index))
                default:
                    fatalError("Unexpected id: \(item.id)")
                }
            }
        }

        let dropdownCell = VTCellRegistration { [weak self] cell, _, wrappedItem in
            switch wrappedItem.base {
            case let item as VTDropDownItem<VTTimer.Action.ActionType>:
                cell.contentConfiguration = VTDropDownCellContentConfiguration(
                    id: item.id,
                    title: item.id.localized(),
                    options: item.options,
                    selection: item.active,
                    disableSelectionAfterAction: false
                ) { [weak self] newActionType in
                    guard let self else { return }

                    switch item.id {
                    case kAction:
                        timer = timer.copy(action: .init(type: newActionType, params: .empty))
                        Task {
                            await applySnapshotAfterAnimationDelay()
                        }
                    default:
                        fatalError("Unexpected id: \(item.id)")
                    }
                }
            case let item as VTDropDownItem<Int>:
                cell.contentConfiguration = VTDropDownCellContentConfiguration(
                    id: item.id,
                    title: item.id.localized(),
                    options: item.options,
                    selection: item.active,
                    disableSelectionAfterAction: false
                ) { [weak self] new in
                    guard let self else { return }

                    switch item.id {
                    case kIterations:
                        if timer.action.type == .segmentCleanup {
                            let params = timer.action.params
                            timer = timer.copy(action: .init(type: .segmentCleanup, params: params.copy(iterations: new)))
                        }
                    default:
                        fatalError("Unexpected id: \(item.id)")
                    }
                }
            case let item as VTDropDownItem<VTPresetValue>:
                cell.contentConfiguration = VTDropDownCellContentConfiguration(
                    id: item.id,
                    title: item.id.localized(),
                    options: item.options,
                    selection: item.active,
                    disableSelectionAfterAction: false
                ) { [weak self] newValue in
                    guard let self else { return }

                    switch item.id {
                    case kSetFan:
                        let filtered = timer.preActions.filter { $0.type != .fanSpeedControl }
                        timer = timer.copy(preActions: filtered + [
                            .init(type: .fanSpeedControl, params: .init(value: newValue)),
                        ])
                    case kSetWater:
                        let filtered = timer.preActions.filter { $0.type != .waterUsageControl }
                        timer = timer.copy(preActions: filtered + [
                            .init(type: .waterUsageControl, params: .init(value: newValue)),
                        ])
                    case kSetMode:
                        let filtered = timer.preActions.filter { $0.type != .operationModeControl }
                        timer = timer.copy(preActions: filtered + [
                            .init(type: .operationModeControl, params: .init(value: newValue)),
                        ])
                    default:
                        fatalError("Unexpected id: \(item.id)")
                    }
                }
            default:
                fatalError("Unsupported item: \(wrappedItem.base)")
            }
        }

        let layerListCell = VTCellRegistration { [weak self] cell, _, wrappedItem in
            guard let item = wrappedItem.base as? VTListSelectionItem<VTLayer> else {
                fatalError("Unsupported segment item: \(wrappedItem.base)")
            }

            let customOrder = self?.timer.action.params.customOrder ?? true

            cell.contentConfiguration = VTListSelectionCellContentConfiguration(
                id: item.id,
                enabledTitle: "SELECTED_SEGMENTS".localized(),
                disabledTitle: "AVAILABLE_SEGMENTS".localized(),
                allowReordering: customOrder,
                options: item.options,
                active: item.active
            ) { [weak self] newLayer in
                guard let self else { return }

                switch item.id {
                case kSegments:
                    if timer.action.type == .segmentCleanup {
                        let params = timer.action.params
                        let newSegementIDs = newLayer.compactMap(\.segmentId)
                        let newParams = params.copy(segmentIDs: newSegementIDs)
                        timer = timer.copy(action: .init(type: .segmentCleanup, params: newParams))
                    }
                default:
                    fatalError("Unexpected id: \(item.id)")
                }
            }
        }

        dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, wrappedItem in
            let registration = switch wrappedItem.base {
            case _ as VTCheckboxItem: checkboxCell
            case _ as VTTextFieldItem: textFieldCell
            case _ as VTSegmentItem<VTWeekday>: segmentCell
            case _ as VTTimePickerItem: timePickerCell
            case _ as VTDropDownItem<VTPresetValue>,
                 _ as VTDropDownItem<VTTimer.Action.ActionType>,
                 _ as VTDropDownItem<Int>: dropdownCell
            case _ as VTListSelectionItem<VTLayer>: layerListCell
            default: fatalError("Unsupported item type: \(type(of: wrappedItem.base))")
            }

            return collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: wrappedItem)
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

                let section = self.dataSource.sectionIdentifier(for: indexPath.section)
                header?.configure(text: section?.title ?? "")
                return header

            default:
                return nil
            }
        }
    }

    // MARK: - CollectionView

    override func collectionView(_: UICollectionView, shouldSelectItemAt _: IndexPath) -> Bool {
        false
    }

    override func collectionView(_: UICollectionView, shouldHighlightItemAt _: IndexPath) -> Bool {
        false
    }

    // MARK: - Actions

    @MainActor
    private func applySnapshotAfterAnimationDelay() async {
        try? await Task.sleep(nanoseconds: 250_000_000)
        await applySnapshot(animated: true)
    }

    private func applySnapshot(animated: Bool = true) async {
        // Helper to generate fresh groups
        var lastGroupID = 0
        func freshGroup() -> VTTimersDetailSection {
            .group(id: lastGroupID++)
        }

        var snapshot = Snapshot()

        // general
        snapshot.appendSections([.general])
        snapshot.appendItems([
            .checkbox(kEnabled, title: "ENABLED".localized(), enabled: timer.enabled),
            .textField(kLabel, text: timer.label),
        ], toSection: .general)

        // schedule
        snapshot.appendSections([.schedule])
        let activeWeekdays = Set(timer.dow.map { VTWeekday(rawValue: $0)! })
        let weekdays = VTWeekday.allNormalizedCases

        // Convert to local time
        var hour = timer.hour
        var minute = timer.minute
        if let date = Date.fromUTC(hour: timer.hour, minute: timer.minute) {
            (hour, minute) = date.toLocalHourMinute()
        }

        snapshot.appendItems([
            .segment(kDow, active: activeWeekdays, options: weekdays),
            .timePicker(kTime, hours: hour, minutes: minute),
        ], toSection: .schedule)

        // pre-actions
        var possibleGroups: [VTTimersDetailSection] = [.preActions, freshGroup(), freshGroup()]
        let preActionTypes: [(String, String, String, VTTimer.PreAction.PreActionType, VTPresetType)] = [
            (kFan, kSetFan, "FAN_SPEED", .fanSpeedControl, .fanSpeed),
            (kWater, kSetWater, "WATER_GRADE", .waterUsageControl, .waterGrade),
            (kMode, kSetMode, "OPERATION_MODE", .operationModeControl, .operationMode),
        ]

        for (toggleID, dropDownID, title, preActionTy, presetTy) in preActionTypes {
            let preAction = timer.preActions.first(where: { $0.type == preActionTy })
            let presets = await (try? client.getPresets(forType: presetTy)) ?? []
            if let activePreset = preAction?.params.value ?? presets.first {
                let section = possibleGroups.removeFirst()
                let isEnabled = preAction != nil

                // Add 'enable' toggle item
                var items: [VTAnyItem] = [
                    .checkbox(toggleID, title: title.localized(), enabled: isEnabled),
                ]
                // Add drop down menu only if enabled
                if isEnabled {
                    items.append(.dropDown(dropDownID, active: activePreset, options: presets))
                }

                snapshot.appendSections([section])
                snapshot.appendItems(items, toSection: section)
            }
        }

        // action
        snapshot.appendSections([.action])
        let allActions = VTTimer.Action.ActionType.allCases
        let isFullCleanup = timer.action.type == .fullCleanup

        if isFullCleanup {
            snapshot.appendItems([
                .dropDown(kAction, active: .fullCleanup, options: allActions),
            ], toSection: .action)
        } else {
            let params = timer.action.params

            let maxIter = 4
            let minIter = 1
            let allIters = Array(minIter ... maxIter)
            let currentIter = max(min(params.iterations ?? minIter, maxIter), minIter)

            let customOrder = params.customOrder ?? false

            // Add base actions
            snapshot.appendItems([
                .dropDown(kAction, active: .segmentCleanup, options: allActions),
                .dropDown(kIterations, active: currentIter, options: allIters),
                .checkbox(kCustomOrder, title: "USE_CUSTOM_ORDER".localized(), enabled: customOrder),
            ], toSection: .action)

            // Add segments actions to their own separate group
            let allSegments = await (try? client.getMap().segmentLayer) ?? []
            let segmentsMap = Dictionary(uniqueKeysWithValues: allSegments.compactMap { seg in
                seg.segmentId.map { ($0, seg) }
            })
            let activeSegments = params.segmentIds?.compactMap { segmentsMap[$0] } ?? []

            let segmentActions: [VTAnyItem] = [
                .listSelection(kSegments, active: activeSegments, options: allSegments),
            ]
            let segmentSection = freshGroup()
            snapshot.appendSections([segmentSection])
            snapshot.appendItems(segmentActions, toSection: segmentSection)
            // reconfigure to force a UI update to allow or disallow reordering
            snapshot.reconfigureItems(segmentActions)
        }

        await dataSource.apply(snapshot, animatingDifferences: animated)
    }

    // MARK: - Data Loading

    private func reloadData(animated: Bool) async {
        Task {
            await self.applySnapshot(animated: animated)
        }
    }

    // MARK: - VTViewController

    @MainActor
    override func reconnectAndRefresh() async {
        await reloadData(animated: false)
    }
}
