//
//  VTRobotOptionsViewController.swift
//  Valetudo
//
//  Created by David Klopp on 02.05.26.
//

import UIKit

private enum VTRobotOptionsSection: Int, CaseIterable {
    case general
    case behavior
    case perception
    case dock
    case misc

    var title: String {
        switch self {
        case .general:
            "GENERAL".localized()
        case .behavior:
            "BEHAVIOR".localized()
        case .perception:
            "PERCEPTION".localized()
        case .dock:
            "DOCK".localized()
        case .misc:
            "MISC".localized()
        }
    }
}

private enum VTCleanRouteOption: String, CaseIterable {
    case fast = "Fast"
    case balanced = "Balanced"
    case deep = "Deep"
}

private enum VTCarpetSensorOption: String, CaseIterable {
    case ignore = "Ignore"
    case avoid = "Avoid"
    case liftMop = "Lift Mop"
}

private enum VTDockAutoEmptyOption: String, CaseIterable {
    case off = "Off"
    case afterEveryCleanup = "After Every Cleanup"
    case everyTwoCleanups = "Every 2 Cleanups"
}

private enum VTMopDryingTimeOption: String, CaseIterable {
    case twoHours = "2 Hours"
    case threeHours = "3 Hours"
    case fourHours = "4 Hours"
}

extension VTCleanRouteOption: Describable {
    var description: String {
        rawValue
    }
}

extension VTCarpetSensorOption: Describable {
    var description: String {
        rawValue
    }
}

extension VTDockAutoEmptyOption: Describable {
    var description: String {
        rawValue
    }
}

extension VTMopDryingTimeOption: Describable {
    var description: String {
        rawValue
    }
}

final class VTRobotOptionsViewController: VTCollectionViewController {
    private struct State {
        var lockKeysEnabled = false
        var collisionAvoidantNavigationEnabled = true
        var materialAlignedNavigationEnabled = false
        var cleanRoute: VTCleanRouteOption = .balanced
        var carpetModeEnabled = true
        var carpetSensor: VTCarpetSensorOption = .liftMop
        var mopTwistEnabled = true
        var obstacleAvoidanceEnabled = true
        var petObstacleAvoidanceEnabled = false
        var obstacleImagesEnabled = true
        var dockAutoEmpty: VTDockAutoEmptyOption = .afterEveryCleanup
        var mopAutoDryingEnabled = true
        var mopDryingTime: VTMopDryingTimeOption = .threeHours
    }

    private typealias DataSource = UICollectionViewDiffableDataSource<VTRobotOptionsSection, VTAnyItem>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<VTRobotOptionsSection, VTAnyItem>

    private static let locateRobotID = "locateRobot"
    private static let lockKeysID = "lockKeys"
    private static let collisionAvoidantNavigationID = "collisionAvoidantNavigation"
    private static let materialAlignedNavigationID = "materialAlignedNavigation"
    private static let cleanRouteID = "cleanRoute"
    private static let carpetModeID = "carpetMode"
    private static let carpetSensorID = "carpetSensor"
    private static let mopTwistID = "mopTwist"
    private static let obstacleAvoidanceID = "obstacleAvoidance"
    private static let petObstacleAvoidanceID = "petObstacleAvoidance"
    private static let obstacleImagesID = "obstacleImages"
    private static let dockAutoEmptyID = "dockAutoEmpty"
    private static let mopAutoDryingID = "mopAutoDrying"
    private static let mopDryingTimeID = "mopDryingTime"
    private static let systemOptionsID = "systemOptions"
    private static let quirksID = "quirks"

    private let client: any VTAPIClientProtocol
    private var dataSource: DataSource!
    private var availableCapabilities = Set<VTCapability>()
    private var state = State()

    init(client: any VTAPIClientProtocol) {
        self.client = client

        super.init(collectionViewLayout: UICollectionViewLayout())
        setupAndApplyListLayout()

        title = "ROBOT_OPTIONS".localized()
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
        let linkCell = VTCellRegistration { [weak self] cell, _, wrappedItem in
            guard let item = wrappedItem.base as? VTKeyValueItem else {
                fatalError("Unsupported key value item: \(wrappedItem.base)")
            }

            cell.contentConfiguration = VTKeyValueCellContentConfiguration(
                id: item.id,
                title: item.title,
                subtitle: item.value,
                usesHorizontalLayout: false,
                image: item.image
            )
            cell.backgroundConfiguration = .adaptiveListCell()
            cell.accessories = self?.accessories(for: item.id) ?? []
        }

        let checkboxCell = VTCellRegistration { [weak self] cell, _, wrappedItem in
            guard let item = wrappedItem.base as? VTCheckboxItem else {
                fatalError("Unsupported checkbox item: \(wrappedItem.base)")
            }

            cell.contentConfiguration = VTCheckboxCellContentConfiguration(
                id: item.id,
                title: item.title,
                subtitle: item.subtitle,
                isOn: item.enabled,
                image: item.image
            ) { [weak self] isOn in
                self?.updateToggle(id: item.id, isOn: isOn)
            }
            cell.backgroundConfiguration = .adaptiveListCell()
            cell.accessories = []
        }

        let cleanRouteDropdownCell = VTCellRegistration { [weak self] cell, _, wrappedItem in
            guard let item = wrappedItem.base as? VTDropDownItem<VTCleanRouteOption> else {
                fatalError("Unsupported clean route item: \(wrappedItem.base)")
            }

            cell.contentConfiguration = VTDropDownCellContentConfiguration(
                id: item.id,
                title: item.title,
                subtitle: item.subtitle,
                options: item.options,
                selection: item.active,
                image: item.image,
                disableSelectionAfterAction: false
            ) { [weak self] selection in
                self?.state.cleanRoute = selection
            }
            cell.backgroundConfiguration = .adaptiveListCell()
            cell.accessories = []
        }

        let carpetSensorDropdownCell = VTCellRegistration { [weak self] cell, _, wrappedItem in
            guard let item = wrappedItem.base as? VTDropDownItem<VTCarpetSensorOption> else {
                fatalError("Unsupported carpet sensor item: \(wrappedItem.base)")
            }

            cell.contentConfiguration = VTDropDownCellContentConfiguration(
                id: item.id,
                title: item.title,
                subtitle: item.subtitle,
                options: item.options,
                selection: item.active,
                image: item.image,
                disableSelectionAfterAction: false
            ) { [weak self] selection in
                self?.state.carpetSensor = selection
            }
            cell.backgroundConfiguration = .adaptiveListCell()
            cell.accessories = []
        }

        let dockAutoEmptyDropdownCell = VTCellRegistration { [weak self] cell, _, wrappedItem in
            guard let item = wrappedItem.base as? VTDropDownItem<VTDockAutoEmptyOption> else {
                fatalError("Unsupported dock auto-empty item: \(wrappedItem.base)")
            }

            cell.contentConfiguration = VTDropDownCellContentConfiguration(
                id: item.id,
                title: item.title,
                subtitle: item.subtitle,
                options: item.options,
                selection: item.active,
                image: item.image,
                disableSelectionAfterAction: false
            ) { [weak self] selection in
                self?.state.dockAutoEmpty = selection
            }
            cell.backgroundConfiguration = .adaptiveListCell()
            cell.accessories = []
        }

        let mopDryingTimeDropdownCell = VTCellRegistration { [weak self] cell, _, wrappedItem in
            guard let item = wrappedItem.base as? VTDropDownItem<VTMopDryingTimeOption> else {
                fatalError("Unsupported mop drying time item: \(wrappedItem.base)")
            }

            cell.contentConfiguration = VTDropDownCellContentConfiguration(
                id: item.id,
                title: item.title,
                subtitle: item.subtitle,
                options: item.options,
                selection: item.active,
                image: item.image,
                disableSelectionAfterAction: false
            ) { [weak self] selection in
                self?.state.mopDryingTime = selection
            }
            cell.backgroundConfiguration = .adaptiveListCell()
            cell.accessories = []
        }

        dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, wrappedItem in
            let registration = switch wrappedItem.base {
            case _ as VTKeyValueItem:
                linkCell
            case _ as VTCheckboxItem:
                checkboxCell
            case _ as VTDropDownItem<VTCleanRouteOption>:
                cleanRouteDropdownCell
            case _ as VTDropDownItem<VTCarpetSensorOption>:
                carpetSensorDropdownCell
            case _ as VTDropDownItem<VTDockAutoEmptyOption>:
                dockAutoEmptyDropdownCell
            case _ as VTDropDownItem<VTMopDryingTimeOption>:
                mopDryingTimeDropdownCell
            default:
                fatalError("Unsupported item type: \(type(of: wrappedItem.base))")
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
    private func applySnapshot(animated: Bool) {
        var snapshot = Snapshot()

        let generalItems = makeGeneralItems()
        if !generalItems.isEmpty {
            snapshot.appendSections([.general])
            snapshot.appendItems(generalItems, toSection: .general)
        }

        let behaviorItems = makeBehaviorItems()
        if !behaviorItems.isEmpty {
            snapshot.appendSections([.behavior])
            snapshot.appendItems(behaviorItems, toSection: .behavior)
        }

        let perceptionItems = makePerceptionItems()
        if !perceptionItems.isEmpty {
            snapshot.appendSections([.perception])
            snapshot.appendItems(perceptionItems, toSection: .perception)
        }

        let dockItems = makeDockItems()
        if !dockItems.isEmpty {
            snapshot.appendSections([.dock])
            snapshot.appendItems(dockItems, toSection: .dock)
        }

        let miscItems = makeMiscItems()
        if !miscItems.isEmpty {
            snapshot.appendSections([.misc])
            snapshot.appendItems(miscItems, toSection: .misc)
        }

        dataSource.apply(snapshot, animatingDifferences: animated)
    }

    private func makeGeneralItems() -> [VTAnyItem] {
        var items: [VTAnyItem] = []

        if availableCapabilities.contains(.locate) {
            items.append(.keyValue(
                Self.locateRobotID,
                title: "LOCATE_ROBOT".localized(),
                value: "LOCATE_ROBOT_DESCRIPTION".localized(),
                image: .locateRobot
            ))
        }
        if availableCapabilities.contains(.keyLock) {
            items.append(.checkbox(
                Self.lockKeysID,
                title: "LOCK_KEYS".localized(),
                subtitle: "LOCK_KEYS_DESCRIPTION".localized(),
                enabled: state.lockKeysEnabled,
                image: .keyLock
            ))
        }

        return items
    }

    private func makeBehaviorItems() -> [VTAnyItem] {
        var items: [VTAnyItem] = []

        if availableCapabilities.contains(.collisionAvoidantNavigationControl) {
            items.append(.checkbox(
                Self.collisionAvoidantNavigationID,
                title: "COLLISION_AVOIDANT_NAVIGATION".localized(),
                subtitle: "COLLISION_AVOIDANT_NAVIGATION_DESCRIPTION".localized(),
                enabled: state.collisionAvoidantNavigationEnabled,
                image: .collisionAvoidantNavigation
            ))
        }
        if availableCapabilities.contains(.floorMaterialDirectionAwareNavigationControl) {
            items.append(.checkbox(
                Self.materialAlignedNavigationID,
                title: "MATERIAL_ALIGNED_NAVIGATION".localized(),
                subtitle: "MATERIAL_ALIGNED_NAVIGATION_DESCRIPTION".localized(),
                enabled: state.materialAlignedNavigationEnabled,
                image: .materialAlignedNavigation
            ))
        }
        if availableCapabilities.contains(.cleanRouteControl) {
            items.append(.dropDown(
                Self.cleanRouteID,
                title: "CLEAN_ROUTE".localized(),
                subtitle: "CLEAN_ROUTE_DESCRIPTION".localized(),
                active: state.cleanRoute,
                options: VTCleanRouteOption.allCases,
                image: .cleanRoute
            ))
        }
        if availableCapabilities.contains(.carpetModeControl) {
            items.append(.checkbox(
                Self.carpetModeID,
                title: "CARPET_MODE".localized(),
                subtitle: "CARPET_MODE_DESCRIPTION".localized(),
                enabled: state.carpetModeEnabled,
                image: .carpetMode
            ))
        }
        if availableCapabilities.contains(.carpetSensorModeControl) {
            items.append(.dropDown(
                Self.carpetSensorID,
                title: "CARPET_SENSOR".localized(),
                subtitle: "CARPET_SENSOR_DESCRIPTION".localized(),
                active: state.carpetSensor,
                options: VTCarpetSensorOption.allCases,
                image: .carpetSensor
            ))
        }
        if availableCapabilities.contains(.mopTwistControl) {
            items.append(.checkbox(
                Self.mopTwistID,
                title: "MOP_TWIST".localized(),
                subtitle: "MOP_TWIST_DESCRIPTION".localized(),
                enabled: state.mopTwistEnabled,
                image: .mopTwist
            ))
        }

        return items
    }

    private func makePerceptionItems() -> [VTAnyItem] {
        var items: [VTAnyItem] = []

        if availableCapabilities.contains(.obstacleAvoidanceControl) {
            items.append(.checkbox(
                Self.obstacleAvoidanceID,
                title: "OBSTACLE_AVOIDANCE".localized(),
                subtitle: "OBSTACLE_AVOIDANCE_DESCRIPTION".localized(),
                enabled: state.obstacleAvoidanceEnabled,
                image: .obstacleAvoidance
            ))
        }
        if availableCapabilities.contains(.petObstacleAvoidanceControl) {
            items.append(.checkbox(
                Self.petObstacleAvoidanceID,
                title: "PET_OBSTACLE_AVOIDANCE".localized(),
                subtitle: "PET_OBSTACLE_AVOIDANCE_DESCRIPTION".localized(),
                enabled: state.petObstacleAvoidanceEnabled,
                image: .petObstacleAvoidance
            ))
        }
        if availableCapabilities.contains(.obstacleImages) {
            items.append(.checkbox(
                Self.obstacleImagesID,
                title: "OBSTACLE_IMAGES".localized(),
                subtitle: "OBSTACLE_IMAGES_DESCRIPTION".localized(),
                enabled: state.obstacleImagesEnabled,
                image: .obstacleImages
            ))
        }

        return items
    }

    private func makeDockItems() -> [VTAnyItem] {
        var items: [VTAnyItem] = []

        if availableCapabilities.contains(.autoEmptyDockAutoEmptyIntervalControl) {
            items.append(.dropDown(
                Self.dockAutoEmptyID,
                title: "DOCK_AUTO_EMPTY".localized(),
                subtitle: "DOCK_AUTO_EMPTY_DESCRIPTION".localized(),
                active: state.dockAutoEmpty,
                options: VTDockAutoEmptyOption.allCases,
                image: .dockAutoEmpty
            ))
        }
        if availableCapabilities.contains(.mopDockMopAutoDryingControl) {
            items.append(.checkbox(
                Self.mopAutoDryingID,
                title: "MOP_AUTO_DRYING".localized(),
                subtitle: "MOP_AUTO_DRYING_DESCRIPTION".localized(),
                enabled: state.mopAutoDryingEnabled,
                image: .mopAutoDrying
            ))
        }
        if availableCapabilities.contains(.mopDockMopDryingTimeControl) {
            items.append(.dropDown(
                Self.mopDryingTimeID,
                title: "MOP_DRYING_TIME".localized(),
                subtitle: "MOP_DRYING_TIME_DESCRIPTION".localized(),
                active: state.mopDryingTime,
                options: VTMopDryingTimeOption.allCases,
                image: .mopDryingTime
            ))
        }

        return items
    }

    private func makeMiscItems() -> [VTAnyItem] {
        var items: [VTAnyItem] = []

        if supportsSystemOptions {
            items.append(.keyValue(
                Self.systemOptionsID,
                title: "SYSTEM_OPTIONS".localized(),
                value: "SYSTEM_OPTIONS_DESCRIPTION".localized(),
                image: .systemOptions
            ))
        }
        if availableCapabilities.contains(.quirks) {
            items.append(.keyValue(
                Self.quirksID,
                title: "QUIRKS".localized(),
                value: "QUIRKS_DESCRIPTION".localized(),
                image: .quirks
            ))
        }

        return items
    }

    private var supportsSystemOptions: Bool {
        availableCapabilities.contains(.voicePackManagement) ||
            availableCapabilities.contains(.doNotDisturb) ||
            availableCapabilities.contains(.speakerVolumeControl) ||
            availableCapabilities.contains(.speakerTest)
    }

    @MainActor
    private func reloadData(animated: Bool) async {
        availableCapabilities = await Set((try? client.getCapabilities()) ?? [])
        if availableCapabilities.contains(.keyLock) {
            state.lockKeysEnabled = await (try? client.getKeyLockIsEnabled()) ?? false
        }
        applySnapshot(animated: animated)
    }

    private func accessories(for itemID: String) -> [UICellAccessory] {
        switch itemID {
        case Self.systemOptionsID, Self.quirksID:
            [.disclosureIndicator()]
        default:
            []
        }
    }

    // MARK: - Callbacks

    private func updateToggle(id: String, isOn: Bool) {
        switch id {
        case Self.lockKeysID:
            Task { [weak self] in
                guard let self else { return }
                do {
                    if isOn {
                        try await client.enableKeyLock()
                    } else {
                        try await client.disableKeyLock()
                    }

                    await MainActor.run {
                        state.lockKeysEnabled = isOn
                        applySnapshot(animated: false)
                    }
                } catch {
                    await reloadData(animated: false)
                }
            }
        case Self.collisionAvoidantNavigationID:
            state.collisionAvoidantNavigationEnabled = isOn
        case Self.materialAlignedNavigationID:
            state.materialAlignedNavigationEnabled = isOn
        case Self.carpetModeID:
            state.carpetModeEnabled = isOn
        case Self.mopTwistID:
            state.mopTwistEnabled = isOn
        case Self.obstacleAvoidanceID:
            state.obstacleAvoidanceEnabled = isOn
        case Self.petObstacleAvoidanceID:
            state.petObstacleAvoidanceEnabled = isOn
        case Self.obstacleImagesID:
            state.obstacleImagesEnabled = isOn
        case Self.mopAutoDryingID:
            state.mopAutoDryingEnabled = isOn
        case Self.locateRobotID, Self.cleanRouteID, Self.carpetSensorID, Self.dockAutoEmptyID, Self.mopDryingTimeID, Self.systemOptionsID, Self.quirksID:
            return
        default:
            return
        }
    }

    override func collectionView(_: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }
        return item.base is VTKeyValueItem
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        defer { collectionView.deselectItem(at: indexPath, animated: true) }
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        guard item.base is VTKeyValueItem else { return }
    }

    @MainActor
    override func reconnectAndRefresh() async {
        await reloadData(animated: false)
    }
}
