//
//  VTMapEditingViewController.swift
//  Valetudo
//
//  Created by David Klopp on 28.09.25.
//

import UIKit

private let legendHeight: CGFloat = 45.0

// TODO: Introduce VTMapViewController to unify home screen and this editing screen
// TODO: Can we unify this whole SSE observation and the resumePendingMapUpdatesIfNeeded into VTViewController or
// TODO: a VTEventViewController?

@MainActor
class VTMapEditingViewController: VTViewController {
    /// Tracks callers waiting for the next server-pushed map snapshot after a mutating action.
    private struct PendingMapUpdate {
        let baselineMapData: VTMapData?
        let continuation: CheckedContinuation<VTMapData, any Error>
    }

    struct ToolbarActionDefinition {
        let title: String
        let image: UIImage?
        let handler: @MainActor () -> Void
        let isVisible: @MainActor (_ selectedSegments: Set<String>) -> Bool
    }

    let client: VTAPIClientProtocol

    private let mapScrollView = VTZoomableScrollView()
    private let legendView = VTLegendView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private var currentMapData: VTMapData?
    private var observerToken: VTListenerToken?
    private var eventObservationTask: Task<Void, Never>?
    private var pendingMapUpdates: [UUID: PendingMapUpdate] = [:]

    var mapView: VTMapView? {
        mapScrollView.zoomableView as? VTMapView
    }

    var selectedSegments: [VTLayer] {
        Array(mapView?.selectedLayers ?? [])
    }

    private var segmentLayer: [VTLayer] {
        currentMapData?.segmentLayer ?? []
    }

    var toolbarActionDefinitions: [ToolbarActionDefinition] {
        []
    }

    /// Lets subclasses restrict segment selection changes when a specialized editing mode is active.
    func canChangeSelection(forLayer _: VTLayer, isSelected _: Bool) async -> Bool {
        true
    }

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

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        navigationItem.hidesBackButton = false
        navigationItem.rightBarButtonItem = VTValetudoEventBarButtonItem(client: client, parentViewController: self)

        configureViewHierarchy()
        configureLegend()
        configureToolbar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(false, animated: animated)
        startSSEObservation()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopSSEObservation()
        if isMovingFromParent || isBeingDismissed {
            navigationController?.setToolbarHidden(true, animated: animated)
        }
    }

    override func reconnectAndRefresh() async {
        stopSSEObservation()
        startSSEObservation()
    }

    private func configureViewHierarchy() {
        mapScrollView.translatesAutoresizingMaskIntoConstraints = false
        legendView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(mapScrollView)
        view.addSubview(legendView)
        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            mapScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapScrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            mapScrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            mapScrollView.bottomAnchor.constraint(equalTo: legendView.topAnchor),

            legendView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            legendView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            legendView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            legendView.heightAnchor.constraint(equalToConstant: legendHeight),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

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

    private func configureToolbar() {
        updateToolbarItems(forSelectedSegmentIDs: [])
    }

    func updateToolbarItems(forSelectedSegmentIDs: Set<String>) {
        let visibleDefinitions = toolbarActionDefinitions.filter {
            $0.isVisible(forSelectedSegmentIDs)
        }

        var items: [UIBarButtonItem] = [.flexibleSpace()]

        for definition in visibleDefinitions {
            let action = UIAction(title: definition.title, image: definition.image) { _ in
                definition.handler()
            }
            let button = UIBarButtonItem(
                title: definition.title,
                image: definition.image,
                primaryAction: action,
                menu: nil
            )
            items.append(button)
        }
        setToolbarItems(items, animated: true)
    }

    /// Fetches the current map snapshot once and applies it to the editor immediately.
    @discardableResult
    func loadMap() async -> VTMapData? {
        setMapInteractionBlocked(true)
        defer { setMapInteractionBlocked(false) }

        guard let mapData = try? await client.getMap() else { return nil }
        await applyMapData(mapData)
        return mapData
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
            mapView.hideNoGoAreas = false
            mapView.shouldChangeLayerSelection = mapShouldChangedSelection
            mapView.didChangeLayerSelection = mapDidChangeSelection
            await mapView.updateData(data: filteredMapData)
        } else {
            let mapView = VTMapView(frame: mapRect, data: filteredMapData)
            mapView.hideNoGoAreas = false
            mapView.shouldChangeLayerSelection = mapShouldChangedSelection
            mapView.didChangeLayerSelection = mapDidChangeSelection
            mapScrollView.zoomableView = mapView
            await mapView.updateData(data: filteredMapData)
        }

        await legendView.clearSelection()
        await updateLegend(data: filteredMapData)
        let selectedSegmentIDs = Set(selectedSegments.compactMap(\.segmentId))
        updateToolbarItems(forSelectedSegmentIDs: selectedSegmentIDs)
    }

    /// Removes transient runtime entities that are useful on the home screen but unnecessary while
    /// editing the map structure.
    func filterMapData(from mapData: VTMapData) -> VTMapData {
        mapData
    }

    /// Rebuilds the legend items from the current segment layers shown in the editor.
    private func updateLegend(data _: VTMapData) async {
        legendView.items = segmentLayer.map { layer in
            VTLegendItem(color: layer.fillColor ?? .black, text: layer.name ?? layer.segmentId ?? "")
        }
    }

    /// Starts observing `.map` SSE events so the editor stays live and pending edit actions can
    /// complete when the backend publishes an updated snapshot.
    private func startSSEObservation() {
        guard eventObservationTask == nil else { return }

        eventObservationTask = Task { @MainActor [weak self] in
            guard let self else { return }

            do {
                try await loadInitialMapData()

                let (token, stream) = await client.registerEventObserver(for: .map)
                observerToken = token

                for await event in stream {
                    switch event {
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

    /// Loads the initial map before the SSE loop begins so the editor has content as soon as it
    /// appears.
    private func loadInitialMapData() async throws {
        setMapInteractionBlocked(true)
        defer { setMapInteractionBlocked(false) }

        let mapData = try await client.getMap()
        await applyMapData(mapData)
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

        updateToolbarItems(forSelectedSegmentIDs: Set(selectedSegments.compactMap(\.segmentId)))
    }

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

        updateToolbarItems(forSelectedSegmentIDs: Set(selectedSegments.compactMap(\.segmentId)))
    }

    /// Validates legend taps against the same selection rules used for direct map interaction.
    private func legendShouldChangedSelection(atIndex index: Int, isSelected: Bool) async -> Bool {
        guard segmentLayer.indices.contains(index) else { return false }
        let layer = segmentLayer[index]
        return await canChangeSelection(forLayer: layer, isSelected: isSelected)
    }
}
