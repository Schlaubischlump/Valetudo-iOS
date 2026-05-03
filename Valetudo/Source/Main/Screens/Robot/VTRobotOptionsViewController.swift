//
//  VTRobotOptionsViewController.swift
//  Valetudo
//
//  Created by David Klopp on 02.05.26.
//

import UIKit

private let kLocateRobotID = "LOCATE_ROBOT"
private let kLockKeysID = "LOCK_KEYS"
private let kCollisionAvoidantNavigationID = "COLLISION_AVOIDANT_NAVIGATION"
private let kMaterialAlignedNavigationID = "MATERIAL_ALIGNED_NAVIGATION"
private let kCleanRouteID = "CLEAN_ROUTE"
private let kCarpetModeID = "CARPET_MODE"
private let kCarpetSensorID = "CARPET_SENSOR"
private let kMopTwistID = "MOP_TWIST"
private let kObstacleAvoidanceID = "OBSTACLE_AVOIDANCE"
private let kPetObstacleAvoidanceID = "PET_OBSTACLE_AVOIDANCE"
private let kObstacleImagesID = "OBSTACLE_IMAGES"
private let kDockAutoEmptyID = "DOCK_AUTO_EMPTY"
private let kMopAutoDryingID = "MOP_AUTO_DRYING"
private let kMopDryingTimeID = "MOP_DRYING_TIME"
private let kSystemOptionsID = "SYSTEM_OPTIONS"
private let kQuirksID = "QUIRKS"

// TODO: Check if we covered all options. For that we need to check the Valetudo source code

final class VTRobotOptionsViewController: VTCollectionViewController {
    private struct State {
        var lockKeysEnabled = false
        var collisionAvoidantNavigationEnabled = false
        var materialAlignedNavigationEnabled = false
        var cleanRoute: VTCleanRoute = .normal
        var supportedCleanRoutes: [VTCleanRoute] = []
        var carpetModeEnabled = false
        var carpetSensor: VTCarpetSensorMode = .lift
        var supportedCarpetSensorModes: [VTCarpetSensorMode] = []
        var mopTwistEnabled = false
        var obstacleAvoidanceEnabled = false
        var petObstacleAvoidanceEnabled = false
        var obstacleImagesEnabled = false
        var dockAutoEmpty: VTAutoEmptyDockAutoEmptyInterval = .normal
        var supportedDockAutoEmptyIntervals: [VTAutoEmptyDockAutoEmptyInterval] = []
        var mopAutoDryingEnabled = false
        var mopDryingTime: VTMopDockMopDryingDuration = .threeHours
        var supportedMopDryingTimes: [VTMopDockMopDryingDuration] = []
    }

    private typealias DataSource = UICollectionViewDiffableDataSource<VTRobotOptionsSection, VTAnyItem>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<VTRobotOptionsSection, VTAnyItem>

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
        let keyValueCell = VTCellRegistration { [weak self] cell, _, wrappedItem in
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
                isOn: item.isOn,
                image: item.image,
                disableSelectionAfterAction: true
            ) { [weak self] isOn in
                self?.updateToggle(id: item.id, isOn: isOn)
            }
            cell.backgroundConfiguration = .adaptiveListCell()
            cell.accessories = []
        }

        let cleanRouteDropdownCell = VTCellRegistration { [weak self] cell, _, wrappedItem in
            guard let item = wrappedItem.base as? VTDropDownItem<VTCleanRoute> else {
                fatalError("Unsupported clean route item: \(wrappedItem.base)")
            }

            cell.contentConfiguration = VTDropDownCellContentConfiguration(
                id: item.id,
                title: item.title,
                subtitle: item.subtitle,
                options: item.options,
                selection: item.active,
                image: item.image,
                disableSelectionAfterAction: true
            ) { [weak self] selection in
                self?.updateCleanRoute(selection)
            }
            cell.backgroundConfiguration = .adaptiveListCell()
            cell.accessories = []
        }

        let carpetSensorDropdownCell = VTCellRegistration { [weak self] cell, _, wrappedItem in
            guard let item = wrappedItem.base as? VTDropDownItem<VTCarpetSensorMode> else {
                fatalError("Unsupported carpet sensor item: \(wrappedItem.base)")
            }

            cell.contentConfiguration = VTDropDownCellContentConfiguration(
                id: item.id,
                title: item.title,
                subtitle: item.subtitle,
                options: item.options,
                selection: item.active,
                image: item.image,
                disableSelectionAfterAction: true
            ) { [weak self] selection in
                self?.updateCarpetSensor(selection)
            }
            cell.backgroundConfiguration = .adaptiveListCell()
            cell.accessories = []
        }

        let dockAutoEmptyDropdownCell = VTCellRegistration { [weak self] cell, _, wrappedItem in
            guard let item = wrappedItem.base as? VTDropDownItem<VTAutoEmptyDockAutoEmptyInterval> else {
                fatalError("Unsupported dock auto-empty item: \(wrappedItem.base)")
            }

            cell.contentConfiguration = VTDropDownCellContentConfiguration(
                id: item.id,
                title: item.title,
                subtitle: item.subtitle,
                options: item.options,
                selection: item.active,
                image: item.image,
                disableSelectionAfterAction: true
            ) { [weak self] selection in
                self?.updateDockAutoEmpty(selection)
            }
            cell.backgroundConfiguration = .adaptiveListCell()
            cell.accessories = []
        }

        let mopDryingTimeDropdownCell = VTCellRegistration { [weak self] cell, _, wrappedItem in
            guard let item = wrappedItem.base as? VTDropDownItem<VTMopDockMopDryingDuration> else {
                fatalError("Unsupported mop drying time item: \(wrappedItem.base)")
            }

            cell.contentConfiguration = VTDropDownCellContentConfiguration(
                id: item.id,
                title: item.title,
                subtitle: item.subtitle,
                options: item.options,
                selection: item.active,
                image: item.image,
                disableSelectionAfterAction: true
            ) { [weak self] selection in
                self?.updateMopDryingTime(selection)
            }
            cell.backgroundConfiguration = .adaptiveListCell()
            cell.accessories = []
        }

        dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, wrappedItem in
            let registration = switch wrappedItem.base {
            case _ as VTKeyValueItem: keyValueCell
            case _ as VTCheckboxItem: checkboxCell
            case _ as VTDropDownItem<VTCleanRoute>: cleanRouteDropdownCell
            case _ as VTDropDownItem<VTCarpetSensorMode>: carpetSensorDropdownCell
            case _ as VTDropDownItem<VTAutoEmptyDockAutoEmptyInterval>: dockAutoEmptyDropdownCell
            case _ as VTDropDownItem<VTMopDockMopDryingDuration>: mopDryingTimeDropdownCell
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
        let sectionAndItems: [(VTRobotOptionsSection, [VTAnyItem])] = [
            .general => makeGeneralItems(),
            .behavior => makeBehaviorItems(),
            .perception => makePerceptionItems(),
            .dock => makeDockItems(),
            .misc => makeMiscItems(),
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

    private func makeGeneralItems() -> [VTAnyItem] {
        var items: [VTAnyItem] = []

        if availableCapabilities.contains(.locate) {
            items.append(.keyValue(
                kLocateRobotID,
                title: "LOCATE_ROBOT".localized(),
                value: "LOCATE_ROBOT_DESCRIPTION".localized(),
                image: .locateRobot
            ))
        }
        if availableCapabilities.contains(.keyLock) {
            items.append(.checkbox(
                kLockKeysID,
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
                kCollisionAvoidantNavigationID,
                title: "COLLISION_AVOIDANT_NAVIGATION".localized(),
                subtitle: "COLLISION_AVOIDANT_NAVIGATION_DESCRIPTION".localized(),
                enabled: state.collisionAvoidantNavigationEnabled,
                image: .collisionAvoidantNavigation
            ))
        }
        if availableCapabilities.contains(.floorMaterialDirectionAwareNavigationControl) {
            items.append(.checkbox(
                kMaterialAlignedNavigationID,
                title: "MATERIAL_ALIGNED_NAVIGATION".localized(),
                subtitle: "MATERIAL_ALIGNED_NAVIGATION_DESCRIPTION".localized(),
                enabled: state.materialAlignedNavigationEnabled,
                image: .materialAlignedNavigation
            ))
        }
        if availableCapabilities.contains(.cleanRouteControl) {
            items.append(.dropDown(
                kCleanRouteID,
                title: "CLEAN_ROUTE".localized(),
                subtitle: "CLEAN_ROUTE_DESCRIPTION".localized(),
                active: state.cleanRoute,
                options: state.supportedCleanRoutes.isEmpty ? [state.cleanRoute] : state.supportedCleanRoutes,
                image: .cleanRoute
            ))
        }
        if availableCapabilities.contains(.carpetModeControl) {
            items.append(.checkbox(
                kCarpetModeID,
                title: "CARPET_MODE".localized(),
                subtitle: "CARPET_MODE_DESCRIPTION".localized(),
                enabled: state.carpetModeEnabled,
                image: .carpetMode
            ))
        }
        if availableCapabilities.contains(.carpetSensorModeControl) {
            items.append(.dropDown(
                kCarpetSensorID,
                title: "CARPET_SENSOR".localized(),
                subtitle: "CARPET_SENSOR_DESCRIPTION".localized(),
                active: state.carpetSensor,
                options: state.supportedCarpetSensorModes.isEmpty ? [state.carpetSensor] : state.supportedCarpetSensorModes,
                image: .carpetSensor
            ))
        }
        if availableCapabilities.contains(.mopTwistControl) {
            items.append(.checkbox(
                kMopTwistID,
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
                kObstacleAvoidanceID,
                title: "OBSTACLE_AVOIDANCE".localized(),
                subtitle: "OBSTACLE_AVOIDANCE_DESCRIPTION".localized(),
                enabled: state.obstacleAvoidanceEnabled,
                image: .obstacleAvoidance
            ))
        }
        if availableCapabilities.contains(.petObstacleAvoidanceControl) {
            items.append(.checkbox(
                kPetObstacleAvoidanceID,
                title: "PET_OBSTACLE_AVOIDANCE".localized(),
                subtitle: "PET_OBSTACLE_AVOIDANCE_DESCRIPTION".localized(),
                enabled: state.petObstacleAvoidanceEnabled,
                image: .petObstacleAvoidance
            ))
        }
        if availableCapabilities.contains(.obstacleImages) {
            items.append(.checkbox(
                kObstacleImagesID,
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
                kDockAutoEmptyID,
                title: "DOCK_AUTO_EMPTY".localized(),
                subtitle: "DOCK_AUTO_EMPTY_DESCRIPTION".localized(),
                active: state.dockAutoEmpty,
                options: state.supportedDockAutoEmptyIntervals.isEmpty ? [state.dockAutoEmpty] : state.supportedDockAutoEmptyIntervals,
                image: .dockAutoEmpty
            ))
        }
        if availableCapabilities.contains(.mopDockMopAutoDryingControl) {
            items.append(.checkbox(
                kMopAutoDryingID,
                title: "MOP_AUTO_DRYING".localized(),
                subtitle: "MOP_AUTO_DRYING_DESCRIPTION".localized(),
                enabled: state.mopAutoDryingEnabled,
                image: .mopAutoDrying
            ))
        }
        if availableCapabilities.contains(.mopDockMopDryingTimeControl) {
            items.append(.dropDown(
                kMopDryingTimeID,
                title: "MOP_DRYING_TIME".localized(),
                subtitle: "MOP_DRYING_TIME_DESCRIPTION".localized(),
                active: state.mopDryingTime,
                options: state.supportedMopDryingTimes.isEmpty ? [state.mopDryingTime] : state.supportedMopDryingTimes,
                image: .mopDryingTime
            ))
        }

        return items
    }

    private func makeMiscItems() -> [VTAnyItem] {
        var items: [VTAnyItem] = []

        if supportsSystemOptions {
            items.append(.keyValue(
                kSystemOptionsID,
                title: "SYSTEM_OPTIONS".localized(),
                value: "SYSTEM_OPTIONS_DESCRIPTION".localized(),
                image: .systemOptions
            ))
        }
        if availableCapabilities.contains(.quirks) {
            items.append(.keyValue(
                kQuirksID,
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
    private func reloadData(animated: Bool, reconfigureItemWithIDs itemIDs: [String] = []) async {
        if let capabilities = try? await client.getCapabilities() {
            availableCapabilities = Set(capabilities)
        } else {
            availableCapabilities = []
        }

        var nextState = state

        if availableCapabilities.contains(.keyLock) {
            nextState.lockKeysEnabled = await (try? client.getKeyLockIsEnabled()) ?? nextState.lockKeysEnabled
        }
        if availableCapabilities.contains(.collisionAvoidantNavigationControl) {
            nextState.collisionAvoidantNavigationEnabled = await (try? client.getCollisionAvoidantNavigationIsEnabled()) ?? nextState.collisionAvoidantNavigationEnabled
        }
        if availableCapabilities.contains(.floorMaterialDirectionAwareNavigationControl) {
            nextState.materialAlignedNavigationEnabled = await (try? client.getFloorMaterialDirectionAwareNavigationIsEnabled()) ?? nextState.materialAlignedNavigationEnabled
        }
        if availableCapabilities.contains(.cleanRouteControl) {
            nextState.cleanRoute = await (try? client.getCleanRoute()) ?? nextState.cleanRoute
            nextState.supportedCleanRoutes = await (try? client.getCleanRouteControlProperties().supportedRoutes) ?? []
        }
        if availableCapabilities.contains(.carpetModeControl) {
            nextState.carpetModeEnabled = await (try? client.getCarpetModeIsEnabled()) ?? nextState.carpetModeEnabled
        }
        if availableCapabilities.contains(.carpetSensorModeControl) {
            nextState.carpetSensor = await (try? client.getCarpetSensorMode()) ?? nextState.carpetSensor
            nextState.supportedCarpetSensorModes = await (try? client.getCarpetSensorModeControlProperties().supportedModes) ?? []
        }
        if availableCapabilities.contains(.mopTwistControl) {
            nextState.mopTwistEnabled = await (try? client.getMopTwistIsEnabled()) ?? nextState.mopTwistEnabled
        }
        if availableCapabilities.contains(.obstacleAvoidanceControl) {
            nextState.obstacleAvoidanceEnabled = await (try? client.getObstacleAvoidanceIsEnabled()) ?? nextState.obstacleAvoidanceEnabled
        }
        if availableCapabilities.contains(.petObstacleAvoidanceControl) {
            nextState.petObstacleAvoidanceEnabled = await (try? client.getPetObstacleAvoidanceIsEnabled()) ?? nextState.petObstacleAvoidanceEnabled
        }
        if availableCapabilities.contains(.obstacleImages) {
            nextState.obstacleImagesEnabled = await (try? client.getObstacleImagesCapabilityIsEnabled()) ?? nextState.obstacleImagesEnabled
        }
        if availableCapabilities.contains(.autoEmptyDockAutoEmptyIntervalControl) {
            nextState.dockAutoEmpty = await (try? client.getAutoEmptyDockAutoEmptyInterval()) ?? nextState.dockAutoEmpty
            nextState.supportedDockAutoEmptyIntervals = await (try? client.getAutoEmptyDockAutoEmptyIntervalProperties().supportedIntervals) ?? []
        }
        if availableCapabilities.contains(.mopDockMopAutoDryingControl) {
            nextState.mopAutoDryingEnabled = await (try? client.getMopDockMopAutoDryingIsEnabled()) ?? nextState.mopAutoDryingEnabled
        }
        if availableCapabilities.contains(.mopDockMopDryingTimeControl) {
            nextState.mopDryingTime = await (try? client.getMopDockMopDryingDuration()) ?? nextState.mopDryingTime
            nextState.supportedMopDryingTimes = await (try? client.getMopDockMopDryingTimeControlProperties().supportedDurations) ?? []
        }

        state = nextState
        applySnapshot(animated: animated, reconfigureItemWithIDs: itemIDs)
    }

    private func accessories(for itemID: String) -> [UICellAccessory] {
        switch itemID {
        case kSystemOptionsID, kQuirksID: [.disclosureIndicator()]
        default: []
        }
    }

    // MARK: - Callbacks

    private func updateToggle(id: String, isOn: Bool) {
        switch id {
        case kLockKeysID:
            performUpdate(operationName: "KeyLockCapability toggle", itemID: id) { [client] in
                if isOn {
                    try await client.enableKeyLock()
                } else {
                    try await client.disableKeyLock()
                }
            } onSuccess: { [weak self] in
                self?.state.lockKeysEnabled = isOn
            }
        case kCollisionAvoidantNavigationID:
            performUpdate(operationName: "CollisionAvoidantNavigationControlCapability toggle", itemID: id) { [client] in
                if isOn {
                    try await client.enableCollisionAvoidantNavigation()
                } else {
                    try await client.disableCollisionAvoidantNavigation()
                }
            } onSuccess: { [weak self] in
                self?.state.collisionAvoidantNavigationEnabled = isOn
            }
        case kMaterialAlignedNavigationID:
            performUpdate(operationName: "FloorMaterialDirectionAwareNavigationControlCapability toggle", itemID: id) { [client] in
                if isOn {
                    try await client.enableFloorMaterialDirectionAwareNavigation()
                } else {
                    try await client.disableFloorMaterialDirectionAwareNavigation()
                }
            } onSuccess: { [weak self] in
                self?.state.materialAlignedNavigationEnabled = isOn
            }
        case kCarpetModeID:
            performUpdate(operationName: "CarpetModeControlCapability toggle", itemID: id) { [client] in
                if isOn {
                    try await client.enableCarpetMode()
                } else {
                    try await client.disableCarpetMode()
                }
            } onSuccess: { [weak self] in
                self?.state.carpetModeEnabled = isOn
            }
        case kMopTwistID:
            performUpdate(operationName: "MopTwistControlCapability toggle", itemID: id) { [client] in
                if isOn {
                    try await client.enableMopTwist()
                } else {
                    try await client.disableMopTwist()
                }
            } onSuccess: { [weak self] in
                self?.state.mopTwistEnabled = isOn
            }
        case kObstacleAvoidanceID:
            performUpdate(operationName: "ObstacleAvoidanceControlCapability toggle", itemID: id) { [client] in
                if isOn {
                    try await client.enableObstacleAvoidance()
                } else {
                    try await client.disableObstacleAvoidance()
                }
            } onSuccess: { [weak self] in
                self?.state.obstacleAvoidanceEnabled = isOn
            }
        case kPetObstacleAvoidanceID:
            performUpdate(operationName: "PetObstacleAvoidanceControlCapability toggle", itemID: id) { [client] in
                if isOn {
                    try await client.enablePetObstacleAvoidance()
                } else {
                    try await client.disablePetObstacleAvoidance()
                }
            } onSuccess: { [weak self] in
                self?.state.petObstacleAvoidanceEnabled = isOn
            }
        case kObstacleImagesID:
            performUpdate(operationName: "ObstacleImagesCapability toggle", itemID: id) { [client] in
                if isOn {
                    try await client.enableObstacleImagesCapability()
                } else {
                    try await client.disableObstacleImagesCapability()
                }
            } onSuccess: { [weak self] in
                self?.state.obstacleImagesEnabled = isOn
            }
        case kMopAutoDryingID:
            performUpdate(operationName: "MopDockMopAutoDryingControlCapability toggle", itemID: id) { [client] in
                if isOn {
                    try await client.enableMopDockMopAutoDrying()
                } else {
                    try await client.disableMopDockMopAutoDrying()
                }
            } onSuccess: { [weak self] in
                self?.state.mopAutoDryingEnabled = isOn
            }
        default:
            return
        }
    }

    private func updateCleanRoute(_ route: VTCleanRoute) {
        guard route != state.cleanRoute else { return }

        performUpdate(operationName: "CleanRouteControlCapability update", itemID: kCleanRouteID) { [client] in
            try await client.setCleanRoute(route)
        } onSuccess: { [weak self] in
            self?.state.cleanRoute = route
        }
    }

    private func updateCarpetSensor(_ mode: VTCarpetSensorMode) {
        guard mode != state.carpetSensor else { return }

        performUpdate(operationName: "CarpetSensorModeControlCapability update", itemID: kCarpetSensorID) { [client] in
            try await client.setCarpetSensorMode(mode)
        } onSuccess: { [weak self] in
            self?.state.carpetSensor = mode
        }
    }

    private func updateDockAutoEmpty(_ interval: VTAutoEmptyDockAutoEmptyInterval) {
        guard interval != state.dockAutoEmpty else { return }

        performUpdate(operationName: "AutoEmptyDockAutoEmptyIntervalControlCapability update", itemID: kDockAutoEmptyID) { [client] in
            try await client.setAutoEmptyDockAutoEmptyInterval(interval)
        } onSuccess: { [weak self] in
            self?.state.dockAutoEmpty = interval
        }
    }

    private func updateMopDryingTime(_ duration: VTMopDockMopDryingDuration) {
        guard duration != state.mopDryingTime else { return }

        performUpdate(operationName: "MopDockMopDryingTimeControlCapability update", itemID: kMopDryingTimeID) { [client] in
            try await client.setMopDockMopDryingDuration(duration)
        } onSuccess: { [weak self] in
            self?.state.mopDryingTime = duration
        }
    }

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

    override func collectionView(_: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }
        return item.base is VTKeyValueItem
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        defer { collectionView.deselectItem(at: indexPath, animated: true) }
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        guard item.base is VTKeyValueItem else { return }

        switch item.id {
        case kLocateRobotID:
            performUpdate(operationName: "LocateRobotCapability trigger", itemID: item.id) { [client] in
                try await client.locateRobot()
            }
        case kSystemOptionsID:
            presentSystemOptions()
        case kQuirksID:
            presentQuirks()
        default:
            return
        }
    }

    private func presentSystemOptions() {
        let systemVC = VTRobotSystemOptionsViewController(client: client, capabilities: availableCapabilities)
        navigationController?.pushViewController(systemVC, animated: true)
    }

    private func presentQuirks() {
        let quirksVC = VTQuirksOptionsViewController(client: client)
        navigationController?.pushViewController(quirksVC, animated: true)
    }

    @MainActor
    override func reconnectAndRefresh() async {
        await reloadData(animated: false)
    }
}
