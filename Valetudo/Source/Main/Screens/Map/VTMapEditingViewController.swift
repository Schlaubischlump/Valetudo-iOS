//
//  VTMapEditingViewController.swift
//  Valetudo
//
//  Created by David Klopp on 28.09.25.
//

import UIKit

private let legendHeight: CGFloat = 45.0

@MainActor
class VTMapEditingViewController: VTViewController {
    struct ToolbarActionDefinition {
        let title: String
        let image: UIImage?
        let handler: @MainActor (VTMapEditingViewController) -> Void
        let isVisible: @MainActor (VTMapEditingViewController) -> Bool
    }

    let client: VTAPIClientProtocol

    private let mapScrollView = VTZoomableScrollView()
    private let legendView = VTLegendView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private var currentMapData: VTMapData?
    private var pendingSelectedSegmentCount: Int?

    private var mapView: VTMapView? {
        mapScrollView.zoomableView as? VTMapView
    }

    var selectedSegmentCount: Int {
        pendingSelectedSegmentCount ?? mapView?.selectedLayers.count ?? 0
    }

    private var segmentLayer: [VTLayer] {
        currentMapData?.segmentLayer ?? []
    }

    private var visibleToolbarActionDefinitions: [ToolbarActionDefinition] {
        toolbarActionDefinitions.filter { $0.isVisible(self) }
    }

    var toolbarActionDefinitions: [ToolbarActionDefinition] {
        []
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
        navigationItem.hidesBackButton = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(didTapDone)
        )
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(didTapCancel)
        )

        configureViewHierarchy()
        configureLegend()
        configureToolbar()

        Task {
            await loadMap()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(false, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent || isBeingDismissed {
            navigationController?.setToolbarHidden(true, animated: animated)
        }
    }

    override func reconnectAndRefresh() async {
        await loadMap()
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
        legendView.onSelectionChange = { [weak self] index, isSelected in
            guard let self else { return false }
            return await legendChangedSelection(atIndex: index, isSelected: isSelected)
        }
    }

    private func configureToolbar() {
        updateToolbarItems()
    }

    func updateToolbarItems() {
        let visibleDefinitions = visibleToolbarActionDefinitions

        var items: [UIBarButtonItem] = [.flexibleSpace()]

        for definition in visibleDefinitions {
            let action = UIAction(title: definition.title, image: definition.image) { [weak self] _ in
                guard let self else { return }
                definition.handler(self)
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

    private func loadMap() async {
        activityIndicator.startAnimating()
        defer { activityIndicator.stopAnimating() }

        guard let mapData = try? await client.getMap() else { return }
        let filteredMapData = mapEditingData(from: mapData)
        currentMapData = filteredMapData

        let viewSize = view.bounds.size == .zero ? (UIScreen.current?.bounds.size ?? .zero) : view.bounds.size
        let mapSize = CGSize(width: min(viewSize.width, 500), height: min(viewSize.height, 500))
        let mapRect = CGRect(origin: .zero, size: mapSize)

        if let mapView = mapScrollView.zoomableView as? VTMapView {
            mapView.hideNoGoAreas = false
            mapView.onLayerSelectionChange = mapChangedSelection
            await mapView.updateData(data: filteredMapData)
        } else {
            let mapView = VTMapView(frame: mapRect, data: filteredMapData)
            mapView.hideNoGoAreas = false
            mapView.onLayerSelectionChange = mapChangedSelection
            mapScrollView.zoomableView = mapView
            await mapView.updateData(data: filteredMapData)
        }

        await legendView.clearSelection()
        await updateLegend(data: filteredMapData)
        updateToolbarItems()
    }

    private func mapEditingData(from mapData: VTMapData) -> VTMapData {
        let filteredEntities = mapData.entities.filter {
            switch $0.type {
            case .robot_position, .path, .predicted_path:
                false
            default:
                true
            }
        }

        return VTMapData(
            size: mapData.size,
            pixelSize: mapData.pixelSize,
            layers: mapData.layers,
            entities: filteredEntities,
            metaData: mapData.metaData
        )
    }

    private func updateLegend(data _: VTMapData) async {
        legendView.items = segmentLayer.map { layer in
            VTLegendItem(color: layer.fillColor ?? .black, text: layer.name ?? layer.segmentId ?? "")
        }
    }

    private func mapChangedSelection(forLayer layer: VTLayer, isSelected: Bool) async -> Bool {
        guard let index = segmentLayer.firstIndex(of: layer) else { return false }
        if !isSelected {
            await legendView.select(at: index)
        } else {
            await legendView.deselect(at: index)
        }
        let currentCount = mapView?.selectedLayers.count ?? 0
        pendingSelectedSegmentCount = max(0, currentCount + (isSelected ? -1 : 1))
        updateToolbarItems()
        pendingSelectedSegmentCount = nil
        return true
    }

    private func legendChangedSelection(atIndex index: Int, isSelected: Bool) async -> Bool {
        let layer = segmentLayer[index]
        if !isSelected {
            await mapView?.select(layer: layer)
        } else {
            await mapView?.deselect(layer: layer)
        }
        updateToolbarItems()
        return true
    }

    @objc private func didTapDone() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func didTapCancel() {
        let alert = UIAlertController(
            title: "MAP_EDITING_DISCARD_ALERT_TITLE".localized(),
            message: "MAP_EDITING_DISCARD_ALERT_MESSAGE".localized(),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "KEEP_EDITING".localized(), style: .cancel))
        alert.addAction(UIAlertAction(title: "DISCARD_CHANGES".localized(), style: .destructive) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
}
