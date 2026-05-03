//
//  VTAPIClientProtocol.swift
//  Valetudo
//
//  Created by David Klopp on 16.05.25.
//

import CoreGraphics
import CoreImage
import Foundation

public struct VTLogEntry: Sendable, Hashable {
    let timestamp: Date
    let level: String
    let message: String
}

/// Central point
public func makeAPIClient(baseURL: URL, configuration: URLSessionConfiguration = .default) -> any VTAPIClientProtocol {
    VTAPIClient(baseURL: baseURL, configuration: configuration)
}

public protocol VTAPIClientProtocol: Actor {
    // MARK: - 1. Robot

    func getRobotInfo() async throws -> VTRobotInfo

    // MARK: - 1.1 State

    // MARK: - 1.1.1 Attributes

    func getStateAttributes() async throws -> VTStateAttributeList

    // MARK: - 1.1.2 Map

    func getMap() async throws -> VTMapData

    // MARK: - 1.1.3 SSE

    @discardableResult
    func registerEventObserver<O>(for endpoint: VTEventEndpoint<some Decodable & Equatable, O>) async -> (VTListenerToken, AsyncStream<VTEventAction<O>>)

    func removeEventObserver(token: VTListenerToken, for endpoint: VTEventEndpoint<some Decodable & Equatable, some Any>) async

    // MARK: - 1.2 Capabilities

    func getCapabilities() async throws -> [VTCapability]

    // MARK: - 1.2.1 CurrentStatisticsCapability

    func getCurrentStatisticsCapability() async throws -> [VTValetudoDataPoint]
    func getCurrentStatisticsCapabilityProperties() async throws -> VTStatisticsCapabilityProperties

    // MARK: - 1.2.2 BasicControlCapability

    func start() async throws
    func pause() async throws
    func stop() async throws
    func home() async throws
    func getBasicControlCapabilityProperties() async throws -> VTBasicControlCapabilityProperties

    // MARK: - 1.2.3 MapSegmentationCapability

    func clean(segmentIDs: [String], customOrder: Bool, iterations: Int) async throws
    func getMapSegmentationProperties() async throws -> VTMapSegmentationProperties
    func getMapSegments() async throws -> [VTMapSegment]

    // MARK: - 1.2.4 AutoEmptyDockManualTriggerCapability

    func autoEmptyDock() async throws
    func getAutoEmptyDockManualTriggerCapabilityProperties() async throws -> VTAutoEmptyDockManualTriggerCapabilityProperties

    // MARK: - 1.2.5 MopDockCleanManualTriggerCapability

    func startMopDockClean() async throws
    func stopMopDockClean() async throws

    // MARK: - 1.2.6 MopDockDryManualTriggerCapability

    func startMopDockDry() async throws
    func stopMopDockDry() async throws

    // MARK: - 1.2.7 FanSpeedControlCapability / WaterUsageControlCapability / OperationModeControlCapability

    func getPresets(forType type: VTPresetType) async throws -> [VTPresetValue]
    func setPreset(_ preset: VTPresetValue, forType type: VTPresetType) async throws

    // MARK: - 1.2.10 ConsumableMonitoringCapability

    func getConsumables() async throws -> [VTConsumableState]
    func getPropertiesForConsumables() async throws -> [VTConsumableStateProperties]
    func resetConsumable(type: VTConsumableType) async throws
    func resetConsumable(type: VTConsumableType, subtype: VTConsumableSubType) async throws

    // MARK: - 1.2.11 ManualControlCapability

    func getManualControlIsEnabled() async throws -> Bool
    func getManualControlSupportedMovementDirections() async throws -> [VTMoveDirection]
    func enableManualControl() async throws
    func disableManualControl() async throws
    func manualControlMove(direction: VTMoveDirection) async throws

    // MARK: - 1.2.12 HighResolutionManualControlCapability

    func getHighResolutionManualControlIsEnabled() async throws -> Bool
    func enableHighResolutionManualControl() async throws
    func disableHighResolutionManualControl() async throws
    // angle: +- 180.0 and velocity: +-1.0
    func highResolutionManualControlMove(angle: CGFloat, velocity: CGFloat) async throws
    func getHighResolutionManualControlCapabilityProperties() async throws -> VTHighResolutionManualControlCapabilityProperties

    // MARK: - 1.2.13 ObstacleImagesCapability

    func getObstacleImagesCapabilityIsEnabled() async throws -> Bool
    func enableObstacleImagesCapability() async throws
    func disableObstacleImagesCapability() async throws
    func getObstacleImage(id: String) async throws -> CIImage
    func getObstacleImagesCapabilityProperties() async throws -> VTObstacleImagesProperties

    // MARK: - 1.2.14 MapResetCapability

    func resetMap() async throws
    func getMapResetProperties() async throws -> VTMapResetProperties

    // MARK: - 1.2.15 MappingPassCapability

    func startMappingPass() async throws
    func getMappingPassProperties() async throws -> VTMappingPassProperties

    // MARK: - 1.2.16 MapSegmentMaterialControlCapability

    func setMapSegmentMaterial(segmentID: String, material: VTMaterial) async throws
    func getSupportedMapSegmentMaterials() async throws -> [VTMaterial]

    // MARK: - 1.2.17 MapSegmentEditCapability

    func joinMapSegments(segmentAID: String, segmentBID: String) async throws
    func splitMapSegment(segmentID: String, pointA: CGPoint, pointB: CGPoint) async throws
    func getMapSegmentEditProperties() async throws -> VTMapSegmentEditProperties

    // MARK: - 1.2.18 MapSegmentRenameCapability

    func renameMapSegment(segmentID: String, name: String) async throws
    func getMapSegmentRenameProperties() async throws -> VTMapSegmentRenameProperties

    // MARK: - 1.2.19 CombinedVirtualRestrictionsCapability

    func getVirtualRestrictions() async throws -> VTVirtualRestrictions
    func setVirtualRestrictions(_ restrictions: VTVirtualRestrictions) async throws
    func getVirtualRestrictionsProperties() async throws -> VTVirtualRestrictionsProperties

    // MARK: - 1.2.20 KeyLockCapability

    func getKeyLockIsEnabled() async throws -> Bool
    func enableKeyLock() async throws
    func disableKeyLock() async throws
    func getKeyLockProperties() async throws -> VTKeyLockProperties

    // MARK: - 1.2.21 LocateCapability

    func locateRobot() async throws
    func getLocateRobotProperties() async throws -> VTLocateRobotProperties

    // MARK: - 1.2.22 GoToLocationCapability

    func goTo(x: Int, y: Int) async throws
    func getGoToProperties() async throws -> VTGoToProperties

    // MARK: - 1.2.23 AutoEmptyDockAutoEmptyDurationControlCapability

    func getAutoEmptyDockAutoEmptyDuration() async throws -> VTAutoEmptyDockAutoEmptyDuration
    func setAutoEmptyDockAutoEmptyDuration(_ duration: VTAutoEmptyDockAutoEmptyDuration) async throws
    func getAutoEmptyDockAutoEmptyDurationProperties() async throws -> VTAutoEmptyDockAutoEmptyDurationProperties

    // MARK: - 1.2.24 AutoEmptyDockAutoEmptyIntervalControlCapability

    func getAutoEmptyDockAutoEmptyInterval() async throws -> VTAutoEmptyDockAutoEmptyInterval
    func setAutoEmptyDockAutoEmptyInterval(_ interval: VTAutoEmptyDockAutoEmptyInterval) async throws
    func getAutoEmptyDockAutoEmptyIntervalProperties() async throws -> VTAutoEmptyDockAutoEmptyIntervalProperties

    // MARK: - 1.2.24 CarpetSensorModeControlCapability

    func getCarpetSensorMode() async throws -> VTCarpetSensorMode
    func setCarpetSensorMode(_ mode: VTCarpetSensorMode) async throws
    func getCarpetSensorModeControlProperties() async throws -> VTCarpetSensorModeControlProperties

    // MARK: - 1.2.25 CleanRouteControlCapability

    func getCleanRoute() async throws -> VTCleanRoute
    func setCleanRoute(_ route: VTCleanRoute) async throws
    func getCleanRouteControlProperties() async throws -> VTCleanRouteControlProperties

    // MARK: - 1.2.26 DoNotDisturbCapability

    func getDoNotDisturbConfiguration() async throws -> VTDoNotDisturbConfiguration
    func setDoNotDisturbConfiguration(_ configuration: VTDoNotDisturbConfiguration) async throws
    func getDoNotDisturbCapabilityProperties() async throws -> VTDoNotDisturbCapabilityProperties

    // MARK: - 1.2.27 MapSnapshotCapability

    func getMapSnapshots() async throws -> [VTMapSnapshot]
    func restoreMapSnapshot(id: String) async throws
    func getMapSnapshotCapabilityProperties() async throws -> VTMapSnapshotCapabilityProperties

    // MARK: - 1.2.28 MopDockMopDryingTimeControlCapability

    func getMopDockMopDryingDuration() async throws -> VTMopDockMopDryingDuration
    func setMopDockMopDryingDuration(_ duration: VTMopDockMopDryingDuration) async throws
    func getMopDockMopDryingTimeControlProperties() async throws -> VTMopDockMopDryingTimeControlProperties

    // MARK: - 1.2.29 MopDockMopWashTemperatureControlCapability

    func getMopDockMopWashTemperature() async throws -> VTMopDockMopWashTemperature
    func setMopDockMopWashTemperature(_ temperature: VTMopDockMopWashTemperature) async throws
    func getMopDockMopWashTemperatureControlProperties() async throws -> VTMopDockMopWashTemperatureControlProperties

    // MARK: - 1.2.30 PendingMapChangeHandlingCapability

    func getPendingMapChangeHandlingIsEnabled() async throws -> Bool
    func acceptPendingMapChange() async throws
    func rejectPendingMapChange() async throws
    func getPendingMapChangeHandlingCapabilityProperties() async throws -> VTPendingMapChangeHandlingCapabilityProperties

    // MARK: - 1.2.31 FanSpeedControlCapability

    func getFanSpeedControlProperties() async throws -> VTFanSpeedControlCapabilityProperties

    // MARK: - 1.2.32 WaterUsageControlCapability

    func getWaterUsageControlProperties() async throws -> VTWaterUsageControlCapabilityProperties

    // MARK: - 1.2.33 OperationModeControlCapability

    func getOperationModeControlProperties() async throws -> VTOperationModeControlCapabilityProperties

    // MARK: - 1.2.32 QuirksCapability

    func getQuirk() async throws -> VTQuirk
    func setQuirk(id: String, value: String) async throws
    func getQuirksCapabilityProperties() async throws -> VTQuirksCapabilityProperties

    // MARK: - 1.2.33 CarpetModeControlCapability

    func getCarpetModeIsEnabled() async throws -> Bool
    func enableCarpetMode() async throws
    func disableCarpetMode() async throws
    func getCarpetModeControlProperties() async throws -> VTCarpetModeControlCapabilityProperties

    // MARK: - 1.2.34 PersistentMapControlCapability

    func getPersistentMapIsEnabled() async throws -> Bool
    func enablePersistentMap() async throws
    func disablePersistentMap() async throws
    func getPersistentMapControlProperties() async throws -> VTPersistentMapControlCapabilityProperties

    // MARK: - 1.2.35 ObstacleAvoidanceControlCapability

    func getObstacleAvoidanceIsEnabled() async throws -> Bool
    func enableObstacleAvoidance() async throws
    func disableObstacleAvoidance() async throws
    func getObstacleAvoidanceControlProperties() async throws -> VTObstacleAvoidanceControlCapabilityProperties

    // MARK: - 1.2.36 PetObstacleAvoidanceControlCapability

    func getPetObstacleAvoidanceIsEnabled() async throws -> Bool
    func enablePetObstacleAvoidance() async throws
    func disablePetObstacleAvoidance() async throws
    func getPetObstacleAvoidanceControlProperties() async throws -> VTPetObstacleAvoidanceControlCapabilityProperties

    // MARK: - 1.2.37 CollisionAvoidantNavigationControlCapability

    func getCollisionAvoidantNavigationIsEnabled() async throws -> Bool
    func enableCollisionAvoidantNavigation() async throws
    func disableCollisionAvoidantNavigation() async throws
    func getCollisionAvoidantNavigationControlProperties() async throws -> VTCollisionAvoidantNavigationControlCapabilityProperties

    // MARK: - 1.2.38 MopExtensionControlCapability

    func getMopExtensionIsEnabled() async throws -> Bool
    func enableMopExtension() async throws
    func disableMopExtension() async throws
    func getMopExtensionControlProperties() async throws -> VTMopExtensionControlCapabilityProperties

    // MARK: - 1.2.39 CameraLightControlCapability

    func getCameraLightIsEnabled() async throws -> Bool
    func enableCameraLight() async throws
    func disableCameraLight() async throws
    func getCameraLightControlProperties() async throws -> VTCameraLightControlCapabilityProperties

    // MARK: - 1.2.40 MopTwistControlCapability

    func getMopTwistIsEnabled() async throws -> Bool
    func enableMopTwist() async throws
    func disableMopTwist() async throws
    func getMopTwistControlProperties() async throws -> VTMopTwistControlCapabilityProperties

    // MARK: - 1.2.41 MopExtensionFurnitureLegHandlingControlCapability

    func getMopExtensionFurnitureLegHandlingIsEnabled() async throws -> Bool
    func enableMopExtensionFurnitureLegHandling() async throws
    func disableMopExtensionFurnitureLegHandling() async throws
    func getMopExtensionFurnitureLegHandlingControlProperties() async throws -> VTMopExtensionFurnitureLegHandlingControlCapabilityProperties

    // MARK: - 1.2.42 MopDockMopAutoDryingControlCapability

    func getMopDockMopAutoDryingIsEnabled() async throws -> Bool
    func enableMopDockMopAutoDrying() async throws
    func disableMopDockMopAutoDrying() async throws
    func getMopDockMopAutoDryingControlProperties() async throws -> VTMopDockMopAutoDryingControlCapabilityProperties

    // MARK: - 1.2.43 FloorMaterialDirectionAwareNavigationControlCapability

    func getFloorMaterialDirectionAwareNavigationIsEnabled() async throws -> Bool
    func enableFloorMaterialDirectionAwareNavigation() async throws
    func disableFloorMaterialDirectionAwareNavigation() async throws
    func getFloorMaterialDirectionAwareNavigationControlProperties() async throws -> VTFloorMaterialDirectionAwareNavigationControlCapabilityProperties

    // MARK: - 1.2.44 SpeakerTestCapability

    func playSpeakerTestSound() async throws
    func getSpeakerTestCapabilityProperties() async throws -> VTSpeakerTestCapabilityProperties

    // MARK: - 1.2.45 SpeakerVolumeControlCapability

    func getSpeakerVolume() async throws -> Int
    func setSpeakerVolume(_ volume: Int) async throws
    func getSpeakerVolumeControlProperties() async throws -> VTSpeakerVolumeControlCapabilityProperties

    // MARK: - 1.2.46 TotalStatisticsCapability

    func getTotalStatisticsCapability() async throws -> [VTValetudoDataPoint]
    func getTotalStatisticsCapabilityProperties() async throws -> VTStatisticsCapabilityProperties

    // MARK: - 1.2.47 VoicePackManagementCapability

    func getVoicePackManagementStatus() async throws -> VTVoicePackManagementStatus
    func downloadVoicePack(url: String, language: String, hash: String) async throws
    func getVoicePackManagementCapabilityProperties() async throws -> VTVoicePackManagementCapabilityProperties

    // MARK: - 1.2.48 WifiConfigurationCapability

    func getWifiConfiguration() async throws -> VTWifiConfiguration
    func setWifiConfiguration(_ configuration: VTWifiConfigurationAction) async throws
    func getWifiConfigurationCapabilityProperties() async throws -> VTWifiConfigurationCapabilityProperties

    // MARK: - 1.2.49 WifiScanCapability

    func getWifiNetworks() async throws -> [VTWifiScanResult]
    func getWifiScanCapabilityProperties() async throws -> VTWifiScanCapabilityProperties

    // MARK: - 1.2.50 ZoneCleaningCapability

    func clean(zones: [VTZoneCleaningZone], iterations: Int) async throws
    func getZoneCleaningCapabilityProperties() async throws -> VTZoneCleaningCapabilityProperties

    // MARK: - 1.3 Properties

    func getRobotProperties() async throws -> VTRobotProperties

    // MARK: - 2. System

    // MARK: - 2.1. Host

    func getHostInfo() async throws -> VTHostInfo

    // MARK: - 2.2. Runtime

    func getRuntimeInfo() async throws -> VTRuntimeInfo

    // MARK: - 3. Valetudo

    func canReachValetudo() async -> Bool
    func getBasicValetudoInfo() async throws -> VTBasicValetudoInfo

    // MARK: - 3.1 Version

    func getValetudoVersionInfo() async throws -> VTValetudoVersionInfo

    // MARK: - 3.2 Log

    func getLogProperties() async throws -> VTLogLevel
    func setLogLevel(_ level: String) async throws
    func getLog() async throws -> [VTLogEntry]

    // MARK: - 4. Updater

    func checkForUpdate() async throws

    func downloadUpdate() async throws

    func applyUpdate() async throws

    // MARK: 4.1 State

    func getUpdaterState() async throws -> any VTUpdaterState

    // MARK: 4.2 State

    func getUpdaterConfiguration() async throws -> VTUpdaterConfig

    func setUpdaterConfiguration(_ config: VTUpdaterConfig) async throws

    // MARK: 5.0 Timer

    func getTimers() async throws -> [String: VTTimer]

    func addTimer(_ timer: VTTimer) async throws

    // MARK: - 5.1 {id}

    func getTimer(id: String) async throws -> VTTimer

    func updateTimer(_ timer: VTTimer) async throws

    func deleteTimer(id: String) async throws

    // MARK: - 5.2 {id}/action

    func executeTimer(id: String) async throws

    // MARK: - 5.3 Properties

    func getTimerProperties() async throws -> VTTimersProperties

    // MARK: 6.0 Events

    func getValetudoEvents() async throws -> [any VTValetudoEvent]

    // MARK: 6.1 {id}

    func getValetudoEvent(id: String) async throws -> any VTValetudoEvent

    // MARK: 6.1 {id}/interact

    func interactWithValetudoEvent(id: String, interaction: VTEventInteraction) async throws

    // MARK: - 7 NetworkAdvertisement

    // MARK: - 7.1 properties

    func getNetworkAdvertisementProperties() async throws -> VTNetworkAdvertisementProperties
}
