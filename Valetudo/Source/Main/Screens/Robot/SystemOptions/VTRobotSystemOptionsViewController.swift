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

final class VTRobotSystemOptionsViewController: VTRobotOptionsViewControllerBase<VTRobotSystemOptionsSection> {
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

    /*private struct VoicePackState {
         var url: URL? = nil
         var languageCode: String? = nil
         var hash: String? = nil
     }*/

    private struct State {
        var currentVolume: Int = 0
        /// var voicePack = VoicePackState()
        var doNotDisturb = DoNotDisturbState()
    }

    private let client: any VTAPIClientProtocol
    private let availableCapabilities: Set<VTCapability>

    private var state = State()

    init(client: any VTAPIClientProtocol, capabilities: Set<VTCapability>) {
        self.client = client
        availableCapabilities = capabilities

        super.init()
        title = "ROBOT_SYSTEM_OPTIONS".localized()
    }

    override func title(forSection: VTRobotSystemOptionsSection) -> String {
        forSection.title
    }

    override func sections() -> [VTRobotSystemOptionsSection] {
        [
            .speaker,
            // .voicePacks,
            .doNotDisturb,
        ]
    }

    override func items(forSection: VTRobotSystemOptionsSection) -> [VTAnyItem] {
        var items: [VTAnyItem] = []
        switch forSection {
        case .speaker:
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
        case .doNotDisturb:
            if availableCapabilities.contains(.doNotDisturb) {
                items.append(
                    .checkbox(
                        kDoNotDisturbEnabledID,
                        title: "ENABLED".localized(),
                        enabled: state.doNotDisturb.enabled)
                )
                items.append(
                    .timePicker(
                        kDoNotDisturbStartID,
                        title: "START_TIME".localized(),
                        hours: state.doNotDisturb.localStartTime.hour,
                        minutes: state.doNotDisturb.localStartTime.minute
                    )
                )
                items.append(
                    .timePicker(
                        kDoNotDisturbEndID,
                        title: "END_TIME".localized(),
                        hours: state.doNotDisturb.localEndTime.hour,
                        minutes: state.doNotDisturb.localEndTime.minute
                    )
                )
            }
        }
        return items

    }

    override func cellRegistration(forType: any VTItem.Type) -> VTCellRegistration {
        switch forType {
        case is VTButtonItem.Type:
            VTCellRegistration { [weak self] cell, _, wrappedItem in
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
                    }
                }
                cell.backgroundConfiguration = .adaptiveListCell()
                cell.accessories = []
            }
        case is VTSliderItem.Type:
            VTCellRegistration { [weak self] cell, _, wrappedItem in
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
        case is VTTimePickerItem.Type:
            VTCellRegistration { [weak self] cell, _, wrappedItem in
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
        default:
            fatalError("Unsupported cell registration for type \(forType)")
        }
    }

    override var supportedCellTypes: [any VTItem.Type] {
        [
            VTButtonItem.self,
            VTSliderItem.self,
            VTCheckboxItem.self,
            VTTimePickerItem.self,
        ]
    }

    /* private func makeVoicePackItems() -> [VTAnyItem] {
         var items: [VTAnyItem] = []

         guard availableCapabilities.contains(.voicePackManagement) else {
             return items
         }

         return items
     } */

    override func updateState() async {
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
    }
}
