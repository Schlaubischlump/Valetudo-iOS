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
private let kCameraLightID = "CAMERA_LIGHT"
private let kMopExtensionID = "MOP_EXTENSION"
private let kMopExtensionFurnitureLegHandlingID = "MOP_EXTENSION_FURNITURE_LEGS"
private let kDockAutoEmptyID = "DOCK_AUTO_EMPTY"
private let kAutoEmptyDurationID = "AUTO_EMPTY_DURATION"
private let kMopAutoDryingID = "MOP_AUTO_DRYING"
private let kMopDryingTimeID = "MOP_DRYING_TIME"
private let kMopWashTemperatureID = "MOP_WASH_TEMPERATURE"
private let kSystemOptionsID = "SYSTEM_OPTIONS"
private let kQuirksID = "QUIRKS"

final class VTRobotOptionsViewController: VTRobotOptionsViewControllerBase<VTRobotOptionsSection> {
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
        var mopExtensionEnabled = false
        var mopExtensionFurnitureLegHandlingEnabled = false
        var obstacleAvoidanceEnabled = false
        var petObstacleAvoidanceEnabled = false
        var obstacleImagesEnabled = false
        var cameraLightEnabled = false
        var dockAutoEmpty: VTAutoEmptyDockAutoEmptyInterval = .normal
        var supportedDockAutoEmptyIntervals: [VTAutoEmptyDockAutoEmptyInterval] = []
        var autoEmptyDuration: VTAutoEmptyDockAutoEmptyDuration = .auto
        var supportedAutoEmptyDurations: [VTAutoEmptyDockAutoEmptyDuration] = []
        var mopAutoDryingEnabled = false
        var mopDryingTime: VTMopDockMopDryingDuration = .threeHours
        var supportedMopDryingTimes: [VTMopDockMopDryingDuration] = []
        var mopWashTemperature: VTMopDockMopWashTemperature = .warm
        var supportedMopWashTemperatures: [VTMopDockMopWashTemperature] = []
    }

    private let client: any VTAPIClientProtocol
    private var availableCapabilities = Set<VTCapability>()
    private var state = State()

    init(client: any VTAPIClientProtocol) {
        self.client = client
        super.init()
        title = "ROBOT_OPTIONS".localized()
    }

    override func title(forSection: VTRobotOptionsSection) -> String {
        forSection.title
    }

    override func sections() -> [VTRobotOptionsSection] {
        VTRobotOptionsSection.allCases
    }

    override func items(forSection: VTRobotOptionsSection) -> [VTAnyItem] {
        var items: [VTAnyItem] = []
        switch forSection {
        case .general:
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
        case .behavior:
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
            if availableCapabilities.contains(.mopExtensionControl) {
                items.append(.checkbox(
                    kMopExtensionID,
                    title: "MOP_EXTENSION".localized(),
                    subtitle: "MOP_EXTENSION_DESCRIPTION".localized(),
                    enabled: state.mopExtensionEnabled,
                    image: .mopExtension
                ))
            }
            if availableCapabilities.contains(.mopExtensionFurnitureLegHandlingControl) {
                items.append(.checkbox(
                    kMopExtensionFurnitureLegHandlingID,
                    title: "MOP_EXTENSION_FURNITURE_LEGS".localized(),
                    subtitle: "MOP_EXTENSION_FURNITURE_LEGS_DESCRIPTION".localized(),
                    enabled: state.mopExtensionFurnitureLegHandlingEnabled,
                    image: .mopExtensionFurnitureLegHandling
                ))
            }
        case .perception:
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
            if availableCapabilities.contains(.cameraLightControl) {
                items.append(.checkbox(
                    kCameraLightID,
                    title: "CAMERA_LIGHT".localized(),
                    subtitle: "CAMERA_LIGHT_DESCRIPTION".localized(),
                    enabled: state.cameraLightEnabled,
                    image: .cameraLight
                ))
            }
        case .dock:
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
            if availableCapabilities.contains(.autoEmptyDockAutoEmptyDurationControl) {
                items.append(.dropDown(
                    kAutoEmptyDurationID,
                    title: "AUTO_EMPTY_DURATION".localized(),
                    subtitle: "AUTO_EMPTY_DURATION_DESCRIPTION".localized(),
                    active: state.autoEmptyDuration,
                    options: state.supportedAutoEmptyDurations.isEmpty ? [state.autoEmptyDuration] : state.supportedAutoEmptyDurations,
                    image: .autoEmptyDuration
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
            if availableCapabilities.contains(.mopDockMopWashTemperatureControl) {
                items.append(.dropDown(
                    kMopWashTemperatureID,
                    title: "MOP_WASH_TEMPERATURE".localized(),
                    subtitle: "MOP_WASH_TEMPERATURE_DESCRIPTION".localized(),
                    active: state.mopWashTemperature,
                    options: state.supportedMopWashTemperatures.isEmpty ? [state.mopWashTemperature] : state.supportedMopWashTemperatures,
                    image: .mopWashTemperature
                ))
            }
        case .misc:
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
        }
        return items
    }

    override func cellRegistration(forType: any VTItem.Type) -> VTCellRegistration {
        switch forType {
        case is VTKeyValueItem.Type:
            VTCellRegistration { [weak self] cell, _, wrappedItem in
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
        case is VTCheckboxItem.Type:
            VTCellRegistration { [weak self] cell, _, wrappedItem in
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
        case is VTDropDownItem<VTCleanRoute>.Type:
            VTCellRegistration { [weak self] cell, _, wrappedItem in
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
        case is VTDropDownItem<VTCarpetSensorMode>.Type:
            VTCellRegistration { [weak self] cell, _, wrappedItem in
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
        case is VTDropDownItem<VTAutoEmptyDockAutoEmptyInterval>.Type:
            VTCellRegistration { [weak self] cell, _, wrappedItem in
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
        case is VTDropDownItem<VTMopDockMopDryingDuration>.Type:
            VTCellRegistration { [weak self] cell, _, wrappedItem in
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
        case is VTDropDownItem<VTAutoEmptyDockAutoEmptyDuration>.Type:
            VTCellRegistration { [weak self] cell, _, wrappedItem in
                guard let item = wrappedItem.base as? VTDropDownItem<VTAutoEmptyDockAutoEmptyDuration> else {
                    fatalError("Unsupported auto-empty duration item: \(wrappedItem.base)")
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
                    self?.updateAutoEmptyDuration(selection)
                }
                cell.backgroundConfiguration = .adaptiveListCell()
                cell.accessories = []
            }
        case is VTDropDownItem<VTMopDockMopWashTemperature>.Type:
            VTCellRegistration { [weak self] cell, _, wrappedItem in
                guard let item = wrappedItem.base as? VTDropDownItem<VTMopDockMopWashTemperature> else {
                    fatalError("Unsupported mop wash temperature item: \(wrappedItem.base)")
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
                    self?.updateMopWashTemperature(selection)
                }
                cell.backgroundConfiguration = .adaptiveListCell()
                cell.accessories = []
            }
        default:
            fatalError("Unsupported cell registration for type \(forType)")
        }
    }

    override var supportedCellTypes: [any VTItem.Type] {
        [
            VTKeyValueItem.self,
            VTCheckboxItem.self,
            VTDropDownItem<VTCleanRoute>.self,
            VTDropDownItem<VTCarpetSensorMode>.self,
            VTDropDownItem<VTAutoEmptyDockAutoEmptyInterval>.self,
            VTDropDownItem<VTAutoEmptyDockAutoEmptyDuration>.self,
            VTDropDownItem<VTMopDockMopDryingDuration>.self,
            VTDropDownItem<VTMopDockMopWashTemperature>.self,
        ]
    }

    override func updateState() async {
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
        if availableCapabilities.contains(.mopExtensionControl) {
            nextState.mopExtensionEnabled = await (try? client.getMopExtensionIsEnabled()) ?? nextState.mopExtensionEnabled
        }
        if availableCapabilities.contains(.mopExtensionFurnitureLegHandlingControl) {
            nextState.mopExtensionFurnitureLegHandlingEnabled = await (try? client.getMopExtensionFurnitureLegHandlingIsEnabled()) ?? nextState.mopExtensionFurnitureLegHandlingEnabled
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
        if availableCapabilities.contains(.cameraLightControl) {
            nextState.cameraLightEnabled = await (try? client.getCameraLightIsEnabled()) ?? nextState.cameraLightEnabled
        }
        if availableCapabilities.contains(.autoEmptyDockAutoEmptyIntervalControl) {
            nextState.dockAutoEmpty = await (try? client.getAutoEmptyDockAutoEmptyInterval()) ?? nextState.dockAutoEmpty
            nextState.supportedDockAutoEmptyIntervals = await (try? client.getAutoEmptyDockAutoEmptyIntervalProperties().supportedIntervals) ?? []
        }
        if availableCapabilities.contains(.autoEmptyDockAutoEmptyDurationControl) {
            nextState.autoEmptyDuration = await (try? client.getAutoEmptyDockAutoEmptyDuration()) ?? nextState.autoEmptyDuration
            nextState.supportedAutoEmptyDurations = await (try? client.getAutoEmptyDockAutoEmptyDurationProperties().supportedDurations) ?? []
        }
        if availableCapabilities.contains(.mopDockMopAutoDryingControl) {
            nextState.mopAutoDryingEnabled = await (try? client.getMopDockMopAutoDryingIsEnabled()) ?? nextState.mopAutoDryingEnabled
        }
        if availableCapabilities.contains(.mopDockMopDryingTimeControl) {
            nextState.mopDryingTime = await (try? client.getMopDockMopDryingDuration()) ?? nextState.mopDryingTime
            nextState.supportedMopDryingTimes = await (try? client.getMopDockMopDryingTimeControlProperties().supportedDurations) ?? []
        }
        if availableCapabilities.contains(.mopDockMopWashTemperatureControl) {
            nextState.mopWashTemperature = await (try? client.getMopDockMopWashTemperature()) ?? nextState.mopWashTemperature
            nextState.supportedMopWashTemperatures = await (try? client.getMopDockMopWashTemperatureControlProperties().supportedTemperatures) ?? []
        }

        state = nextState
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

    private var supportsSystemOptions: Bool {
        availableCapabilities.contains(.voicePackManagement) ||
            availableCapabilities.contains(.doNotDisturb) ||
            availableCapabilities.contains(.speakerVolumeControl) ||
            availableCapabilities.contains(.speakerTest)
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
        case kMopExtensionID:
            performUpdate(operationName: "MopExtensionControlCapability toggle", itemID: id) { [client] in
                if isOn {
                    try await client.enableMopExtension()
                } else {
                    try await client.disableMopExtension()
                }
            } onSuccess: { [weak self] in
                self?.state.mopExtensionEnabled = isOn
            }
        case kMopExtensionFurnitureLegHandlingID:
            performUpdate(operationName: "MopExtensionFurnitureLegHandlingControlCapability toggle", itemID: id) { [client] in
                if isOn {
                    try await client.enableMopExtensionFurnitureLegHandling()
                } else {
                    try await client.disableMopExtensionFurnitureLegHandling()
                }
            } onSuccess: { [weak self] in
                self?.state.mopExtensionFurnitureLegHandlingEnabled = isOn
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
        case kCameraLightID:
            performUpdate(operationName: "CameraLightControlCapability toggle", itemID: id) { [client] in
                if isOn {
                    try await client.enableCameraLight()
                } else {
                    try await client.disableCameraLight()
                }
            } onSuccess: { [weak self] in
                self?.state.cameraLightEnabled = isOn
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

    private func updateAutoEmptyDuration(_ duration: VTAutoEmptyDockAutoEmptyDuration) {
        guard duration != state.autoEmptyDuration else { return }

        performUpdate(operationName: "AutoEmptyDockAutoEmptyDurationControlCapability update", itemID: kAutoEmptyDurationID) { [client] in
            try await client.setAutoEmptyDockAutoEmptyDuration(duration)
        } onSuccess: { [weak self] in
            self?.state.autoEmptyDuration = duration
        }
    }

    private func updateMopWashTemperature(_ temperature: VTMopDockMopWashTemperature) {
        guard temperature != state.mopWashTemperature else { return }

        performUpdate(operationName: "MopDockMopWashTemperatureControlCapability update", itemID: kMopWashTemperatureID) { [client] in
            try await client.setMopDockMopWashTemperature(temperature)
        } onSuccess: { [weak self] in
            self?.state.mopWashTemperature = temperature
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
}
