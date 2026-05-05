//
//  VTMapViewController.swift
//  Valetudo
//
//  Created by David Klopp on 28.09.25.
//

import UIKit

private let legendHeight: CGFloat = 45.0

/// Provides shared map loading, selection, toolbar, and SSE synchronization behavior for map editors.
@MainActor
class VTMapViewController: VTToolbarViewController {
    /// Tracks callers waiting for the next server-pushed map snapshot after a mutating action.
    private struct PendingMapUpdate {
        let baselineMapData: VTMapData?
        let continuation: CheckedContinuation<VTMapData, any Error>
    }

    /// API entry point used for one-shot fetches and live map observation.
    let client: VTAPIClientProtocol

    /// Scroll container that provides pan and zoom behavior for the rendered map.
    private let mapScrollView = VTZoomableScrollView()
    /// Horizontal legend that mirrors map segment selection.
    private let legendView = VTLegendView()
    /// Shared loading indicator for initial map fetches and blocking mutations.
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    /// Cached bottom constraint so callers can adjust legend placement without rebuilding layout.
    private var legendBottomConstraint: NSLayoutConstraint?
    /// Last applied map snapshot after editor-specific filtering.
    private var currentMapData: VTMapData?
    /// Token used to unregister the active `.map` event stream.
    private var observerToken: VTListenerToken?
    /// Task that owns the lifecycle of the `.map` SSE observation loop.
    private var eventObservationTask: Task<Void, Never>?
    /// Continuations waiting for the next distinct server-pushed map snapshot.
    private var pendingMapUpdates: [UUID: PendingMapUpdate] = [:]
    /// Distinguishes the first socket connect event from later reconnects that require a refetch.
    private var hasConnectedMapStream = false

    /// Controls whether the rendered map should hide no-go areas for this controller.
    var hidesNoGoAreas: Bool {
        false
    }

    /// Convenience accessor for the currently hosted map view instance.
    var mapView: VTMapView? {
        mapScrollView.zoomableView as? VTMapView
    }

    /// Segment layers currently selected on the map.
    var selectedSegments: [VTLayer] {
        Array(mapView?.selectedLayers ?? [])
    }

    /// Segment layers present in the current filtered map snapshot.
    private var segmentLayer: [VTLayer] {
        currentMapData?.segmentLayer ?? []
    }

    // MARK: - Init

    /// Creates a map editor bound to the provided API client.
    init(client: VTAPIClientProtocol) {
        self.client = client
        super.init(nibName: nil, bundle: nil)

        mapScrollView.minimumZoomScale = 1.0
        mapScrollView.maximumZoomScale = 3.0
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Allows keyboard commands to move selected overlays while the controller is visible.
    override var canBecomeFirstResponder: Bool {
        true
    }

    // MARK: - View life cycle

    /// Configures the shared map editor UI and toolbar when the view loads.
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        navigationItem.hidesBackButton = false
        navigationItem.rightBarButtonItem = VTValetudoEventBarButtonItem(client: client, parentViewController: self)

        configureViewHierarchy()
        configureLegend()
    }

    /// Shows the editing toolbar and starts observing live map updates.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startSSEObservation()
    }

    /// Becomes first responder so keyboard movement shortcuts are available.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
    }

    /// Stops map observation when leaving the editor stack.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopSSEObservation()
    }

    // MARK: - Subclass hooks

    /// Lets subclasses restrict segment selection changes when a specialized editing mode is active.
    func canChangeSelection(forLayer _: VTLayer, isSelected _: Bool) async -> Bool {
        true
    }

    /// Lets subclasses react after the shared map/legend selection state has been synchronized.
    func didUpdateSelectedSegmentIDs(_: Set<String>) async {}

    /// Lets subclasses consume taps on empty map space once overlays, entities, and segments did not.
    func didTapMap(at _: CGPoint) async -> Bool {
        false
    }

    // MARK: - View Configuration

    /// Repositions the legend above the toolbar when the toolbar is bottom-aligned.
    private func updateLegendViewConstraints() {
        legendBottomConstraint?.isActive = false
        if toolbarPlacement.isBottom {
            legendBottomConstraint = legendView.bottomAnchor.constraint(
                equalTo: toolbar.topAnchor, constant: -10
            )
        } else {
            legendBottomConstraint = legendView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10
            )
        }
        legendBottomConstraint?.isActive = true
    }

    /// Reapplies legend positioning after the shared toolbar constraints change.
    override func updateToolbarConstraints() {
        super.updateToolbarConstraints()
        guard let _ = legendBottomConstraint else { return }
        updateLegendViewConstraints()
    }

    /// Builds the shared view hierarchy and activates the editor layout constraints.
    private func configureViewHierarchy() {
        mapScrollView.translatesAutoresizingMaskIntoConstraints = false
        legendView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(mapScrollView)
        view.addSubview(legendView)
        view.addSubview(activityIndicator)

        updateLegendViewConstraints()

        NSLayoutConstraint.activate([
            mapScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapScrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            mapScrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            mapScrollView.bottomAnchor.constraint(equalTo: legendView.topAnchor),

            legendView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            legendView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            legendView.heightAnchor.constraint(equalToConstant: legendHeight),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    // MARK: - Legend

    /// Handles confirmed legend selection changes by mirroring them into the map and recalculating
    /// visible toolbar actions.
    private func legendDidChangeSelection(atIndex index: Int, isSelected: Bool) async {
        guard segmentLayer.indices.contains(index) else { return }
        let layer = segmentLayer[index]

        if isSelected {
            await mapView?.select(layer: layer)
        } else {
            await mapView?.deselect(layer: layer)
        }

        let selectedSegmentIDs = Set(selectedSegments.compactMap(\.segmentId))
        updateToolbarItems()
        await didUpdateSelectedSegmentIDs(selectedSegmentIDs)
    }

    /// Validates legend taps against the same selection rules used for direct map interaction.
    private func legendShouldChangedSelection(atIndex index: Int, isSelected: Bool) async -> Bool {
        guard segmentLayer.indices.contains(index) else { return false }
        let layer = segmentLayer[index]
        return await canChangeSelection(forLayer: layer, isSelected: isSelected)
    }

    /// Connects legend selection callbacks back into the shared editor selection flow.
    private func configureLegend() {
        legendView.backgroundColor = .clear
        legendView.shouldChangeSelection = { [weak self] index, isSelected in
            guard let self else { return false }
            return await legendShouldChangedSelection(atIndex: index, isSelected: isSelected)
        }
        legendView.didChangeSelection = { [weak self] index, isSelected in
            await self?.legendDidChangeSelection(atIndex: index, isSelected: isSelected)
        }
    }

    /// Rebuilds the legend items from the current segment layers shown in the editor.
    private func updateLegend(data _: VTMapData) async {
        legendView.items = segmentLayer.map { layer in
            VTLegendItem(color: layer.fillColor ?? .black, text: layer.name ?? layer.segmentId ?? "")
        }.sorted { $0.text < $1.text }
    }

    // MARK: - Map

    /// Validates map taps against the active editing mode before the map mutates its selection.
    private func mapShouldChangedSelection(forLayer layer: VTLayer, isSelected: Bool) async -> Bool {
        guard segmentLayer.contains(layer) else { return false }
        return await canChangeSelection(forLayer: layer, isSelected: isSelected)
    }

    /// Handles confirmed map selection changes by mirroring them into the legend and recalculating
    /// visible toolbar actions.
    private func mapDidChangeSelection(forLayer layer: VTLayer, isSelected: Bool) async {
        guard let index = segmentLayer.firstIndex(of: layer) else { return }

        if isSelected {
            await legendView.select(at: index)
        } else {
            await legendView.deselect(at: index)
        }

        let selectedSegmentIDs = Set(selectedSegments.compactMap(\.segmentId))
        updateToolbarItems()
        await didUpdateSelectedSegmentIDs(selectedSegmentIDs)
    }

    /// Fetches the current map snapshot once and applies it to the editor immediately.
    func loadMap() async throws {
        setMapInteractionBlocked(true)
        defer { setMapInteractionBlocked(false) }

        let mapData = try await client.getMap()
        await applyMapData(mapData)
    }

    /// Removes transient runtime entities that are useful on the home screen but unnecessary while
    /// editing the map structure.
    func filterMapData(from mapData: VTMapData) -> VTMapData {
        mapData
    }

    /// Filters incoming map data for editing, then refreshes the map view, legend, and toolbar
    /// state from that normalized snapshot.
    func applyMapData(_ data: VTMapData) async {
        let filteredMapData = filterMapData(from: data)
        // We only need to redraw and clear the selection if something actually changed
        guard currentMapData != filteredMapData else { return }
        currentMapData = filteredMapData

        let viewSize = view.bounds.size == .zero ? (UIScreen.current?.bounds.size ?? .zero) : view.bounds.size
        let mapSize = CGSize(width: min(viewSize.width, 500), height: min(viewSize.height, 500))
        let mapRect = CGRect(origin: .zero, size: mapSize)

        if let mapView = mapScrollView.zoomableView as? VTMapView {
            mapView.hideNoGoAreas = hidesNoGoAreas
            mapView.shouldChangeLayerSelection = mapShouldChangedSelection
            mapView.didChangeLayerSelection = mapDidChangeSelection
            mapView.didChangeOverlaySelection = { [weak self] _ in self?.becomeFirstResponder() }
            mapView.onMapTapped = { [weak self] point in
                guard let self else { return false }
                return await didTapMap(at: point)
            }
            await mapView.updateData(data: filteredMapData)
        } else {
            // The initial view size is capped so very large maps do not create an oversized
            // drawing surface before zooming behavior is established.
            let mapView = VTMapView(frame: mapRect, data: filteredMapData)
            mapView.hideNoGoAreas = hidesNoGoAreas
            mapView.shouldChangeLayerSelection = mapShouldChangedSelection
            mapView.didChangeLayerSelection = mapDidChangeSelection
            mapView.didChangeOverlaySelection = { [weak self] _ in self?.becomeFirstResponder() }
            mapView.onMapTapped = { [weak self] point in
                guard let self else { return false }
                return await didTapMap(at: point)
            }
            mapScrollView.zoomableView = mapView
            await mapView.updateData(data: filteredMapData)
        }

        await legendView.clearSelection()
        await updateLegend(data: filteredMapData)
        let selectedSegmentIDs = Set(selectedSegments.compactMap(\.segmentId))
        updateToolbarItems()
        await didUpdateSelectedSegmentIDs(selectedSegmentIDs)
    }

    /// Runs a mutating map request and waits until the SSE stream publishes a different map
    /// snapshot, ensuring the UI reflects server state instead of an optimistic local guess.
    @discardableResult
    func performAndWaitForMapUpdate(_ operation: @escaping @Sendable () async throws -> Void) async throws -> VTMapData {
        setMapInteractionBlocked(true)
        defer { setMapInteractionBlocked(false) }

        let pendingID = UUID()
        let baselineMapData = currentMapData

        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                // Record the current map so we can ignore unrelated SSE events that do not reflect
                // a real server-side change yet.
                pendingMapUpdates[pendingID] = PendingMapUpdate(
                    baselineMapData: baselineMapData,
                    continuation: continuation
                )

                Task { @MainActor [weak self] in
                    guard let self else {
                        continuation.resume(throwing: CancellationError())
                        return
                    }

                    do {
                        try await operation()
                    } catch {
                        resumePendingMapUpdate(id: pendingID, with: .failure(error))
                    }
                }
            }
        } onCancel: { [weak self] in
            Task { @MainActor in
                self?.resumePendingMapUpdate(id: pendingID, with: .failure(CancellationError()))
            }
        }
    }

    // MARK: - Pending Map Updates

    /// Resolves all pending waiters whose baseline snapshot differs from the latest applied map.
    private func resumePendingMapUpdatesIfNeeded(with mapData: VTMapData?) {
        let resumableIDs = pendingMapUpdates.compactMap { id, pending in
            pending.baselineMapData != mapData ? id : nil
        }

        for id in resumableIDs {
            guard let mapData else { continue }
            resumePendingMapUpdate(id: id, with: .success(mapData))
        }
    }

    /// Finishes a single pending map-update wait and removes it from the tracking table.
    private func resumePendingMapUpdate(
        id: UUID,
        with result: Result<VTMapData, any Error>
    ) {
        guard let pending = pendingMapUpdates.removeValue(forKey: id) else { return }

        switch result {
        case let .success(mapData):
            pending.continuation.resume(returning: mapData)
        case let .failure(error):
            pending.continuation.resume(throwing: error)
        }
    }

    // MARK: - SSE observing

    /// Restarts the map observation pipeline after a reconnect request.
    override func reconnectAndRefresh() async {
        stopSSEObservation()
        startSSEObservation()
    }

    /// Starts observing `.map` SSE events so the editor stays live and pending edit actions can
    /// complete when the backend publishes an updated snapshot.
    private func startSSEObservation() {
        guard eventObservationTask == nil else { return }

        eventObservationTask = Task { @MainActor [weak self] in
            guard let self else { return }

            do {
                try await loadMap()
                hasConnectedMapStream = false

                let (token, stream) = await client.registerEventObserver(for: .map)
                observerToken = token

                for await event in stream {
                    switch event {
                    case .didConnect:
                        if hasConnectedMapStream {
                            if let mapData = try? await client.getMap() {
                                await applyMapData(mapData)
                                resumePendingMapUpdatesIfNeeded(with: currentMapData)
                            }
                        } else {
                            hasConnectedMapStream = true
                        }
                    case let .didReceiveData(mapData):
                        // Always render the freshest server state first, then resolve any callers
                        // waiting for a changed snapshot from a previous mutation request.
                        await applyMapData(mapData)
                        resumePendingMapUpdatesIfNeeded(with: currentMapData)
                    case let .didReceiveError(message):
                        log(message: message, forSubsystem: .map, level: .error)
                    default:
                        break
                    }
                }
            } catch {
                log(message: error.localizedDescription, forSubsystem: .map, level: .error)
            }
        }
    }

    /// Stops map observation and fails any callers still waiting for a post-mutation map update.
    private func stopSSEObservation() {
        eventObservationTask?.cancel()
        eventObservationTask = nil
        hasConnectedMapStream = false

        // Any pending mutation should fail once observation stops, otherwise callers would wait
        // forever for an event that can no longer arrive.
        for id in pendingMapUpdates.keys {
            resumePendingMapUpdate(id: id, with: .failure(CancellationError()))
        }

        if let token = observerToken {
            let client = client
            Task { await client.removeEventObserver(token: token, for: .map) }
            observerToken = nil
        }
    }

    /// Applies the shared loading state used while fetching a map or waiting for the next SSE
    /// snapshot after an editing action.
    private func setMapInteractionBlocked(_ isBlocked: Bool) {
        view.isUserInteractionEnabled = !isBlocked
        if isBlocked {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }

    // MARK: - Keyboard Handling

    /// Handles arrow-key presses by nudging the currently selected overlay.
    override func didReceiveKeyEvent(_ key: UIKey) -> Bool {
        switch key.keyCode {
        case .keyboardUpArrow:
            moveSelectedOverlay(by: CGPoint(x: 0, y: -5))
        case .keyboardDownArrow:
            moveSelectedOverlay(by: CGPoint(x: 0, y: 5))
        case .keyboardLeftArrow:
            moveSelectedOverlay(by: CGPoint(x: -5, y: 0))
        case .keyboardRightArrow:
            moveSelectedOverlay(by: CGPoint(x: 5, y: 0))
        default:
            return false
        }

        return true
    }

    // MARK: - Shared Editor Controls

    /// Moves the selected overlay by a fixed number of points in overlay space.
    private func moveSelectedOverlay(by delta: CGPoint) {
        mapView?.moveSelectedOverlay(by: delta)
    }

    /// Clears both map and legend segment selection, then notifies subclasses of the empty state.
    func clearSegmentSelection() async {
        await mapView?.clearSelection()
        await legendView.clearSelection()
        let selectedSegmentIDs = Set<String>()
        updateToolbarItems()
        await didUpdateSelectedSegmentIDs(selectedSegmentIDs)
    }

    /// Shows or hides the shared legend without changing its contents.
    func setLegendHidden(_ isHidden: Bool) {
        legendView.isHidden = isHidden
    }

    /// Enables or disables legend interaction while dimming it to match the current editing mode.
    func setLegendInteractionEnabled(_ isEnabled: Bool) {
        legendView.isUserInteractionEnabled = isEnabled
        legendView.alpha = isEnabled ? 1.0 : 0.55
    }

    /// Adjusts the legend's bottom inset for containers that need custom positioning behavior.
    func setLegendBottomInset(_ inset: CGFloat) {
        legendBottomConstraint?.constant = inset
        view.layoutIfNeeded()
    }
}
