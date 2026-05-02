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
            "General"
        case .behavior:
            "Behavior"
        case .perception:
            "Perception"
        case .dock:
            "Dock"
        case .misc:
            "Misc"
        }
    }
}

private enum VTRobotOptionID: String {
    case locateRobot
    case lockKeys
    case collisionAvoidantNavigation
    case materialAlignedNavigation
    case cleanRoute
    case carpetMode
    case carpetSensor
    case mopTwist
    case obstacleAvoidance
    case petObstacleAvoidance
    case obstacleImages
    case dockAutoEmpty
    case mopAutoDrying
    case mopDryingTime
    case systemOptions
    case quirks
}

private enum VTCleanRouteOption: String, CaseIterable, Sendable {
    case fast = "Fast"
    case balanced = "Balanced"
    case deep = "Deep"
}

private enum VTCarpetSensorOption: String, CaseIterable, Sendable {
    case ignore = "Ignore"
    case avoid = "Avoid"
    case liftMop = "Lift Mop"
}

private enum VTDockAutoEmptyOption: String, CaseIterable, Sendable {
    case off = "Off"
    case afterEveryCleanup = "After Every Cleanup"
    case everyTwoCleanups = "Every 2 Cleanups"
}

private enum VTMopDryingTimeOption: String, CaseIterable, Sendable {
    case twoHours = "2 Hours"
    case threeHours = "3 Hours"
    case fourHours = "4 Hours"
}

extension VTCleanRouteOption: Describable {
    var description: String { rawValue }
}

extension VTCarpetSensorOption: Describable {
    var description: String { rawValue }
}

extension VTDockAutoEmptyOption: Describable {
    var description: String { rawValue }
}

extension VTMopDryingTimeOption: Describable {
    var description: String { rawValue }
}

final class VTRobotOptionsViewController: VTCollectionViewController {
    private typealias DataSource = UICollectionViewDiffableDataSource<VTRobotOptionsSection, VTAnyItem>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<VTRobotOptionsSection, VTAnyItem>

    private let client: any VTAPIClientProtocol
    private var dataSource: DataSource!

    private var lockKeysEnabled = false
    private var collisionAvoidantNavigationEnabled = true
    private var materialAlignedNavigationEnabled = false
    private var cleanRoute: VTCleanRouteOption = .balanced
    private var carpetModeEnabled = true
    private var carpetSensor: VTCarpetSensorOption = .liftMop
    private var mopTwistEnabled = true
    private var obstacleAvoidanceEnabled = true
    private var petObstacleAvoidanceEnabled = false
    private var obstacleImagesEnabled = true
    private var dockAutoEmpty: VTDockAutoEmptyOption = .afterEveryCleanup
    private var mopAutoDryingEnabled = true
    private var mopDryingTime: VTMopDryingTimeOption = .threeHours

    init(client: any VTAPIClientProtocol) {
        self.client = client

        super.init(collectionViewLayout: UICollectionViewLayout())
        setupAndApplyListLayout()

        title = "Robot Options"
    }

    @available(*, unavailable)
    @MainActor required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureCollectionView()
        configureDataSource()
        applySnapshot(animated: false)
    }

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
                value: item.value,
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
                isOn: item.enabled
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
                title: "Clean Route",
                options: item.options,
                selection: item.active,
                disableSelectionAfterAction: false
            ) { [weak self] selection in
                self?.cleanRoute = selection
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
                title: "Carpet Sensor",
                options: item.options,
                selection: item.active,
                disableSelectionAfterAction: false
            ) { [weak self] selection in
                self?.carpetSensor = selection
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
                title: "Dock Auto-Empty",
                options: item.options,
                selection: item.active,
                disableSelectionAfterAction: false
            ) { [weak self] selection in
                self?.dockAutoEmpty = selection
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
                title: "Mop Drying Time",
                options: item.options,
                selection: item.active,
                disableSelectionAfterAction: false
            ) { [weak self] selection in
                self?.mopDryingTime = selection
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
                let section = self.dataSource.sectionIdentifier(for: indexPath.section)
            else {
                return nil
            }

            header.configure(text: section.title)
            return header
        }
    }

    private func applySnapshot(animated: Bool) {
        _ = client

        var snapshot = Snapshot()
        snapshot.appendSections(VTRobotOptionsSection.allCases)

        snapshot.appendItems([
            .keyValue(
                VTRobotOptionID.locateRobot.rawValue,
                title: "Locate Robot",
                value: "The robot will play a sound to announce its location",
                image: UIImage(systemName: "questionmark.circle")
            ),
            .checkbox(VTRobotOptionID.lockKeys.rawValue, title: "Lock Keys", enabled: lockKeysEnabled),
        ], toSection: .general)

        snapshot.appendItems([
            .checkbox(
                VTRobotOptionID.collisionAvoidantNavigation.rawValue,
                title: "Collision-avoidant Navigation",
                enabled: collisionAvoidantNavigationEnabled
            ),
            .checkbox(
                VTRobotOptionID.materialAlignedNavigation.rawValue,
                title: "Material-aligned Navigation",
                enabled: materialAlignedNavigationEnabled
            ),
            .dropDown(
                VTRobotOptionID.cleanRoute.rawValue,
                active: cleanRoute,
                options: VTCleanRouteOption.allCases
            ),
            .checkbox(VTRobotOptionID.carpetMode.rawValue, title: "Carpet Mode", enabled: carpetModeEnabled),
            .dropDown(
                VTRobotOptionID.carpetSensor.rawValue,
                active: carpetSensor,
                options: VTCarpetSensorOption.allCases
            ),
            .checkbox(VTRobotOptionID.mopTwist.rawValue, title: "Mop Twist", enabled: mopTwistEnabled),
        ], toSection: .behavior)

        snapshot.appendItems([
            .checkbox(
                VTRobotOptionID.obstacleAvoidance.rawValue,
                title: "Obstacle Avoidance",
                enabled: obstacleAvoidanceEnabled
            ),
            .checkbox(
                VTRobotOptionID.petObstacleAvoidance.rawValue,
                title: "Pet Obstacle Avoidance",
                enabled: petObstacleAvoidanceEnabled
            ),
            .checkbox(
                VTRobotOptionID.obstacleImages.rawValue,
                title: "Obstacle Images",
                enabled: obstacleImagesEnabled
            ),
        ], toSection: .perception)

        snapshot.appendItems([
            .dropDown(
                VTRobotOptionID.dockAutoEmpty.rawValue,
                active: dockAutoEmpty,
                options: VTDockAutoEmptyOption.allCases
            ),
            .checkbox(
                VTRobotOptionID.mopAutoDrying.rawValue,
                title: "Mop Auto-Drying",
                enabled: mopAutoDryingEnabled
            ),
            .dropDown(
                VTRobotOptionID.mopDryingTime.rawValue,
                active: mopDryingTime,
                options: VTMopDryingTimeOption.allCases
            ),
        ], toSection: .dock)

        snapshot.appendItems([
            .keyValue(
                VTRobotOptionID.systemOptions.rawValue,
                title: "System Options",
                value: "Voice packs, Do not disturb, Speaker settings",
                image: UIImage(systemName: "globe")
            ),
            .keyValue(
                VTRobotOptionID.quirks.rawValue,
                title: "Quirks",
                value: "Configure firmware-specific quirks",
                image: UIImage(systemName: "star")
            ),
        ], toSection: .misc)

        dataSource.apply(snapshot, animatingDifferences: animated)
    }

    private func accessories(for itemID: String) -> [UICellAccessory] {
        switch VTRobotOptionID(rawValue: itemID) {
        case .locateRobot, .systemOptions, .quirks:
            [.disclosureIndicator()]
        default:
            []
        }
    }

    private func updateToggle(id: String, isOn: Bool) {
        guard let optionID = VTRobotOptionID(rawValue: id) else { return }

        switch optionID {
        case .lockKeys:
            lockKeysEnabled = isOn
        case .collisionAvoidantNavigation:
            collisionAvoidantNavigationEnabled = isOn
        case .materialAlignedNavigation:
            materialAlignedNavigationEnabled = isOn
        case .carpetMode:
            carpetModeEnabled = isOn
        case .mopTwist:
            mopTwistEnabled = isOn
        case .obstacleAvoidance:
            obstacleAvoidanceEnabled = isOn
        case .petObstacleAvoidance:
            petObstacleAvoidanceEnabled = isOn
        case .obstacleImages:
            obstacleImagesEnabled = isOn
        case .mopAutoDrying:
            mopAutoDryingEnabled = isOn
        case .locateRobot, .cleanRoute, .carpetSensor, .dockAutoEmpty, .mopDryingTime, .systemOptions, .quirks:
            return
        }
    }

    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }
        return item.base is VTKeyValueItem
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        defer { collectionView.deselectItem(at: indexPath, animated: true) }
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        guard item.base is VTKeyValueItem else { return }
    }
}
