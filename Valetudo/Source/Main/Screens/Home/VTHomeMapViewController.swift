//
//  VTHomeMapViewController.swift
//  Valetudo
//
//  Created by OpenAI on 08.10.25.
//

import UIKit

// TODO: Localize all of this

/// Specializes the shared map controller for the home screen's cleaning and navigation modes.
@MainActor
final class VTHomeMapViewController: VTMapViewController {
    /// User-facing map interaction modes available from the home screen.
    enum Mode: CaseIterable {
        case segment
        case zone
        case goTo

        var menuTitle: String {
            switch self {
            case .segment: "SEGMENT".localized()
            case .zone: "ZONE".localized()
            case .goTo: "GO_TO".localized()
            }
        }
    }

    /// Describes a mode entry for the parent controller's dropdown menu.
    struct ModeOption {
        let mode: Mode
        let isEnabled: Bool
    }

    /// Notifies the parent when the visible title should reflect a new active mode.
    var onModeTitleChanged: ((String) -> Void)?
    /// Notifies the parent when the dropdown contents or current selection changed.
    var onModeOptionsChanged: (([ModeOption], Mode) -> Void)?
    /// Delegates callout presentation to the host home controller so compact sheet presentation
    /// uses the same popover path as the pre-refactor implementation.
    var onCalloutPresentationRequested: ((VTCalloutViewController, UIView, CGRect) -> Void)?

    /// Shared robot controls whose start action is redirected based on the current home mode.
    private let robotControlViewController: VTRobotControlViewController
    /// Active home-screen mode that determines how map taps and overlays are interpreted.
    private(set) var mode: Mode = .segment
    /// Whether segment selection should be exposed on the map and legend.
    private var supportsSegmentation = false
    /// Whether zone overlays may be converted into a zone-cleaning request.
    private var supportsZoneCleaning = false
    /// Whether a go-to target may be placed and executed from the home screen.
    private var supportsGoToLocation = false
    /// Server-advertised minimum and maximum number of zones allowed for zone cleaning.
    private var zoneCountRange = VTZoneCleaningCountRange(min: 1, max: 1)
    /// Cached obstacle-image capability flag used when building obstacle callouts.
    private var obstacleImagesAreEnabled = false

    /// Creates the home map controller and binds it to the shared robot controls.
    init(client: VTAPIClientProtocol, robotControlViewController: VTRobotControlViewController) {
        self.robotControlViewController = robotControlViewController
        super.init(client: client)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Life Cycle

    /// Hooks the shared start button into mode-specific actions and loads capability gating.
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        robotControlViewController.startActionHandler = { [weak self] configuration in
            guard let self else { return false }
            return try await handleStartAction(for: configuration)
        }

        Task { [weak self] in
            await self?.loadCapabilities()
        }
    }

    /* override func viewDesignDidChange(to design: VTViewDesign) {
         toolbarPlacement = design == .compact ? .topTrailing : .bottomTrailing
     } */

    // MARK: - VTMapViewController Overrides

    /// Only segment mode allows direct segment selection on the map or legend.
    override func canChangeSelection(forLayer _: VTLayer, isSelected _: Bool) async -> Bool {
        mode == .segment && supportsSegmentation
    }

    /// Mirrors the shared segment selection into the robot control configuration.
    override func didUpdateSelectedSegmentIDs(_ selectedSegmentIDs: Set<String>) async {
        guard mode == .segment else { return }

        if selectedSegmentIDs.isEmpty {
            robotControlViewController.currentConfiguration = .full
        } else {
            robotControlViewController.currentConfiguration = .segments(
                ids: selectedSegmentIDs.sorted(),
                customOrder: false,
                iterations: robotControlViewController.currentIterations
            )
        }

        refreshControls()
    }

    /// Treats empty-map taps as go-to target placement while go-to mode is active.
    override func didTapMap(at point: CGPoint) async -> Bool {
        guard mode == .goTo else { return false }

        if let overlay = goToOverlay {
            overlay.centerPoint = point
            mapView?.setTransientOverlays([overlay], selectedOverlayID: overlay.id)
        } else {
            let overlay = VTGoToMapOverlay(centerPoint: point)
            mapView?.setTransientOverlays([overlay], selectedOverlayID: overlay.id)
        }

        updateGoToConfiguration()
        refreshControls()
        return true
    }

    /// Rebinds overlay callbacks after each map refresh so local overlay changes keep controls in sync.
    override func applyMapData(_ data: VTMapData) async {
        await super.applyMapData(data)

        mapView?.onEntityClicked = { [weak self] entity, point in
            guard let self else { return false }
            return await handleEntityTap(entity, at: point)
        }
        mapView?.didChangeOverlaySelection = { [weak self] _ in
            self?.becomeFirstResponder()
            self?.refreshControls()
        }
        mapView?.didMutateOverlays = { [weak self] in
            self?.synchronizeConfigurationWithCurrentMode()
            self?.refreshControls()
        }

        refreshControls()
    }

    /// Switches the home map into a new mode and clears any state owned by the previous one.
    func selectMode(_ mode: Mode) {
        guard isModeEnabled(mode), self.mode != mode else { return }

        self.mode = mode
        Task { [weak self] in
            await self?.applyModeTransition()
        }
    }

    // MARK: - Overlay Accessors

    /// Zone overlays currently drawn on the map for zone-cleaning mode.
    private var zoneOverlays: [VTHomeZoneMapOverlay] {
        (mapView?.transientOverlays ?? []).compactMap { $0 as? VTHomeZoneMapOverlay }
    }

    /// Selected zone overlay identifier, if the current overlay selection belongs to zone mode.
    private var selectedZoneOverlayID: UUID? {
        guard let selectedOverlayID = mapView?.selectedOverlayID,
              mapView?.overlay(withID: selectedOverlayID) is VTHomeZoneMapOverlay
        else { return nil }

        return selectedOverlayID
    }

    /// The single go-to target overlay currently present on the map, if any.
    private var goToOverlay: VTGoToMapOverlay? {
        (mapView?.transientOverlays ?? []).compactMap { $0 as? VTGoToMapOverlay }.first
    }

    // MARK: - Capability Loading

    /// Loads capability support once so unsupported modes can be hidden or disabled.
    private func loadCapabilities() async {
        let capabilities = await Set((try? client.getCapabilities()) ?? [])
        supportsSegmentation = capabilities.contains(.mapSegmentation)
        supportsZoneCleaning = capabilities.contains(.zoneCleaning)
        supportsGoToLocation = capabilities.contains(.goToLocation)
        let obstacleImagesCapabilityIsEnabled = await (try? client.getObstacleImagesCapabilityIsEnabled()) ?? false
        obstacleImagesAreEnabled = capabilities.contains(.obstacleImages) && obstacleImagesCapabilityIsEnabled
        if supportsZoneCleaning,
           let properties = try? await client.getZoneCleaningCapabilityProperties()
        {
            zoneCountRange = properties.zoneCount
        }
        refreshControls()
    }

    /// Returns whether the requested mode is currently supported by robot capabilities.
    private func isModeEnabled(_ mode: Mode) -> Bool {
        switch mode {
        case .segment:
            true
        case .zone:
            supportsZoneCleaning
        case .goTo:
            supportsGoToLocation
        }
    }

    // MARK: - Mode State

    /// Clears conflicting selections and installs the base configuration for the newly active mode.
    private func applyModeTransition() async {
        await clearSegmentSelection()
        mapView?.clearTransientOverlays()

        switch mode {
        case .segment:
            setLegendHidden(!supportsSegmentation)
            setLegendInteractionEnabled(supportsSegmentation)
            robotControlViewController.currentConfiguration = .full
        case .zone:
            setLegendHidden(!supportsSegmentation)
            setLegendInteractionEnabled(false)
            ensureMinimumZoneOverlays()
            robotControlViewController.currentConfiguration = .zones(currentZones(), iterations: robotControlViewController.currentIterations)
        case .goTo:
            setLegendHidden(!supportsSegmentation)
            setLegendInteractionEnabled(false)
            ensureGoToOverlay()
            updateGoToConfiguration()
        }

        refreshControls()
    }

    /// Rebuilds the robot control configuration from the current mode-specific map state.
    private func synchronizeConfigurationWithCurrentMode() {
        switch mode {
        case .segment:
            let selectedSegmentIDs = Set(selectedSegments.compactMap(\.segmentId))
            if selectedSegmentIDs.isEmpty {
                robotControlViewController.currentConfiguration = .full
            } else {
                robotControlViewController.currentConfiguration = .segments(
                    ids: selectedSegmentIDs.sorted(),
                    customOrder: false,
                    iterations: robotControlViewController.currentIterations
                )
            }
        case .zone:
            ensureMinimumZoneOverlays()
            robotControlViewController.currentConfiguration = .zones(
                currentZones(),
                iterations: robotControlViewController.currentIterations
            )
        case .goTo:
            updateGoToConfiguration()
        }
    }

    /// Updates the shared configuration to either the current go-to target or an empty placeholder.
    private func updateGoToConfiguration() {
        if let coordinate = currentGoToCoordinate() {
            robotControlViewController.currentConfiguration = .goTo(coordinate)
        } else {
            robotControlViewController.currentConfiguration = .goTo(VTMapCoordinate(x: -1, y: -1))
        }
    }

    /// Converts the currently placed go-to overlay into backend coordinate space.
    private func currentGoToCoordinate() -> VTMapCoordinate? {
        guard let mapView, let goToOverlay else { return nil }

        let point = mapView.cmCoordinate(fromOverlayPoint: goToOverlay.centerPoint)
        return VTMapCoordinate(x: Int(point.x.rounded()), y: Int(point.y.rounded()))
    }

    /// Serializes the editable zone overlays into the backend's rectangular zone payloads.
    private func currentZones() -> [VTZoneCleaningZone] {
        guard let mapView else { return [] }

        return zoneOverlays.map { overlay in
            let topLeft = overlay.rect.origin
            let topRight = CGPoint(x: overlay.rect.maxX, y: overlay.rect.minY)
            let bottomRight = CGPoint(x: overlay.rect.maxX, y: overlay.rect.maxY)
            let bottomLeft = CGPoint(x: overlay.rect.minX, y: overlay.rect.maxY)

            return VTZoneCleaningZone(
                points: VTRectangularZonePoints(
                    pA: coordinate(from: mapView.cmCoordinate(fromOverlayPoint: topLeft)),
                    pB: coordinate(from: mapView.cmCoordinate(fromOverlayPoint: topRight)),
                    pC: coordinate(from: mapView.cmCoordinate(fromOverlayPoint: bottomRight)),
                    pD: coordinate(from: mapView.cmCoordinate(fromOverlayPoint: bottomLeft))
                ),
                metaData: nil
            )
        }
    }

    /// Converts a floating-point cm-space point into the integer coordinate type used by the API.
    private func coordinate(from point: CGPoint) -> VTMapCoordinate {
        VTMapCoordinate(x: Int(point.x.rounded()), y: Int(point.y.rounded()))
    }

    // MARK: - Robot Control Actions

    /// Intercepts the shared start action for zone-cleaning and go-to modes.
    private func handleStartAction(for configuration: VTRobotControlViewController.CleaningConfiguration) async throws -> Bool {
        switch configuration {
        case let .zones(zones, iterations):
            guard !zones.isEmpty else {
                showError(title: "Error", message: "Add at least one zone before starting.")
                return true
            }
            try await client.clean(zones: zones, iterations: iterations)
            return true
        case .goTo:
            guard let coordinate = currentGoToCoordinate() else {
                showError(title: "Error", message: "Place a target before starting.")
                return true
            }
            try await client.goTo(x: coordinate.x, y: coordinate.y)
            return true
        case .full, .segments:
            return false
        }
    }

    // MARK: - Toolbar

    /// Returns the title displayed by the parent controller for the current mode and selection state.
    private func currentModeTitle() -> String {
        switch mode {
        case .segment:
            selectedSegments.isEmpty ? "Full Cleanup" : "Segment Cleanup"
        case .zone:
            "Zone Cleanup"
        case .goTo:
            "Go-To"
        }
    }

    /// Builds the transient toolbar model for the currently active home mode.
    override var toolbarActionDefinitions: [ToolbarActionDefinition] {
        switch mode {
        case .segment:
            guard !selectedSegments.isEmpty else { return [] }
            return [
                .init(title: "CLEAR".localized(), image: .xmark) {
                    Task { [weak self] in
                        await self?.clearSegmentSelection()
                        self?.refreshControls()
                    }
                },
            ]
        case .zone:
            var actions: [ToolbarActionDefinition] = []
            if zoneOverlays.count < zoneCountRange.max {
                actions.append(.init(title: "ADD_ZONE".localized(), image: .zoneAdd) { [weak self] in
                    guard let self, zoneOverlays.count < zoneCountRange.max else { return }
                    mapView?.addOverlay(VTHomeZoneMapOverlay(rect: .zero))
                    synchronizeConfigurationWithCurrentMode()
                    refreshControls()
                })
            }
            if zoneOverlays.count > zoneCountRange.min, selectedZoneOverlayID != nil {
                actions.append(.separator)
                actions.append(.init(title: "REMOVE_ZONE".localized(), image: .zoneRemove) { [weak self] in
                    guard let self else { return }
                    if zoneOverlays.count > zoneCountRange.min, let selectedZoneOverlayID {
                        mapView?.removeOverlay(withID: selectedZoneOverlayID)
                        synchronizeConfigurationWithCurrentMode()
                    }
                    refreshControls()
                })
            }
            return actions
        case .goTo:
            return []
        }
    }

    /// Pushes the latest mode title, dropdown state, and toolbar actions to the parent controller.
    private func refreshControls() {
        onModeTitleChanged?(currentModeTitle())
        onModeOptionsChanged?(
            [
                .init(mode: .segment, isEnabled: true),
                .init(mode: .zone, isEnabled: supportsZoneCleaning),
                .init(mode: .goTo, isEnabled: supportsGoToLocation),
            ],
            mode
        )

        if mode != .segment {
            setLegendInteractionEnabled(false)
        }
        updateToolbarItems()
    }

    // MARK: - Overlay Management

    /// Ensures zone mode starts with at least the minimum allowed number of editable zone overlays.
    private func ensureMinimumZoneOverlays() {
        guard let mapView else { return }

        let missingZoneCount = max(0, zoneCountRange.min - zoneOverlays.count)
        guard missingZoneCount > 0 else { return }

        let center = CGPoint(
            x: mapView.data.boundingRect.width / 2,
            y: mapView.data.boundingRect.height / 2
        )

        let spacing: CGFloat = 64
        let startOffset = -CGFloat(missingZoneCount - 1) * spacing / 2

        for index in 0 ..< missingZoneCount {
            let overlay = VTHomeZoneMapOverlay(rect: .zero)
            overlay.prepareForInsertion(
                at: CGPoint(
                    x: center.x + startOffset + CGFloat(index) * spacing,
                    y: center.y
                )
            )
            mapView.addOverlay(overlay, selected: index == missingZoneCount - 1)
        }
    }

    /// Ensures go-to mode always has a target placed at the map center before the user interacts.
    private func ensureGoToOverlay() {
        guard goToOverlay == nil, let mapView else { return }

        let center = CGPoint(
            x: mapView.data.boundingRect.width / 2,
            y: mapView.data.boundingRect.height / 2
        )
        let overlay = VTGoToMapOverlay(centerPoint: center)
        mapView.addOverlay(overlay)
    }

    // MARK: - Entity Callouts

    /// Builds and presents the correct callout for supported tappable map entities.
    private func handleEntityTap(_ entity: VTEntity, at point: CGPoint) async -> Bool {
        switch entity.type {
        case .charger_location:
            let robotInfo = try? await client.getRobotInfo()
            presentCallout(
                VTCalloutViewController(
                    title: "CHARGER".localized(),
                    subtitle: robotInfo?.description ?? ""
                ),
                at: point
            )
            return true
        case .robot_position:
            async let robotInfo = client.getRobotInfo()
            async let stateAttributes = client.getStateAttributes()

            let info = try? await robotInfo
            let state = try? await stateAttributes
            let title = info?.description ?? "ROBOT".localized()
            let subtitle = if let state {
                "\(state.statusState.description.localizedUppercase()) - \(Int(state.batterLevel))%"
            } else {
                ""
            }

            presentCallout(
                VTCalloutViewController(title: title, subtitle: subtitle),
                at: point
            )
            return true
        case .obstacle:
            let (title, subtitle) = obstacleCalloutText(for: entity)
            let callout = VTCalloutViewController(
                title: title,
                subtitle: subtitle,
                isLoadingImage: obstacleImagesAreEnabled && entity.id != nil
            )
            presentCallout(callout, at: point)

            if obstacleImagesAreEnabled, let id = entity.id,
               let obstacleImage = try? await client.getObstacleImage(id: id)
            {
                callout.update(
                    title: title,
                    subtitle: subtitle,
                    image: UIImage(ciImage: obstacleImage),
                    isLoadingImage: false
                )
            }
            return true
        default:
            return false
        }
    }

    /// Splits the obstacle label into a stable title/subtitle pair for the callout.
    private func obstacleCalloutText(for entity: VTEntity) -> (title: String, subtitle: String) {
        guard let label = entity.label, !label.isEmpty else {
            return ("OBSTACLE".localized(), "")
        }

        if let startIndex = label.firstIndex(of: "("),
           label.hasSuffix(")")
        {
            let title = label[..<startIndex].trimmingCharacters(in: .whitespacesAndNewlines)
            let detailStart = label.index(after: startIndex)
            let detailEnd = label.index(before: label.endIndex)
            let subtitle = label[detailStart ..< detailEnd].trimmingCharacters(in: .whitespacesAndNewlines)

            if !title.isEmpty || !subtitle.isEmpty {
                return (
                    title.isEmpty ? "OBSTACLE".localized() : title,
                    subtitle
                )
            }
        }

        return ("OBSTACLE".localized(), label)
    }

    /// Presents a callout popover anchored to the tapped map position.
    private func presentCallout(_ callout: VTCalloutViewController, at point: CGPoint) {
        guard let mapView else { return }

        let calloutPresenter = (presentedViewController as? VTRobotControlViewController) ?? self
        calloutPresenter.presentCallout(callout, in: mapView, at: point)
    }
}
