//
//  VTHomeViewController.swift
//  Valetudo
//
//  Created by David Klopp on 18.03.25.
//
//

import UIKit

private let bottomPad: CGFloat = 20
private let legendHeight: CGFloat = 45.0
private let sheetCornerRadius: CGFloat = 39.0

/// Displays the live map and coordinates it with the shared robot control controller.
///
/// Segment selection on the map and legend mutates `robotControlViewController.currentConfiguration`.
/// In compact layouts the shared controller is presented as a sheet; in regular layouts it is
/// shown by the split view's inspector column.
class VTHomeViewController: VTViewController {
    private let client: VTAPIClientProtocol
    /// Shared controller instance owned by the split view and reused across size classes.
    private let robotControlViewController: VTRobotControlViewController

    private let mapScrollView = VTZoomableScrollView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private var mapView: VTMapView? {
        mapScrollView.zoomableView as? VTMapView
    }

    private var legendView: VTLegendView!
    private var robotStatusView: VTRobotStatusView!
    private var observerToken: VTListenerToken?
    private var eventObservationTask: Task<Void, Never>?
    private var hasConnectedMapStream = false

    private var legendViewBottomAnchor: NSLayoutConstraint!
    private var mapScrollViewBottomAnchor: NSLayoutConstraint!
    private weak var observedSheetView: UIView?
    /// Leaves vertical room for the control sheet only when the shared controller is presented modally.
    private var mapBottomInset: CGFloat {
        if isCompact {
            -bottomPad
        } else {
            -UISheetPresentationController.Detent.bottomHeight + sheetCornerRadius
        }
    }

    private var legendBottomInset: CGFloat {
        let safeAreaInset = view.safeAreaInsets.bottom
        return if isCompact {
            -bottomPad + safeAreaInset
        } else {
            -bottomPad - UISheetPresentationController.Detent.bottomHeight + safeAreaInset
        }
    }

    // MARK: - Cached data

    private var robotInfo: VTRobotInfo?
    private var robotState: VTStateAttributeList?
    private var obstacleImagesCapabilityIsEnabled = false
    private var supportsSegmentation = false

    private var segmentLayer: [VTLayer] {
        mapView?.data.segmentLayer ?? []
    }

    init(client: VTAPIClientProtocol, robotControlViewController: VTRobotControlViewController) {
        self.client = client
        self.robotControlViewController = robotControlViewController

        super.init(nibName: nil, bundle: nil)
        title = "MAP".localized()
        view.backgroundColor = .systemBackground

        // map
        mapScrollView.minimumZoomScale = 1.0
        mapScrollView.maximumZoomScale = 3.0

        view.addSubview(mapScrollView)
        view.addSubview(activityIndicator)

        mapScrollView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        mapScrollViewBottomAnchor = mapScrollView.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor,
            constant: bottomPad
        )
        NSLayoutConstraint.activate([
            mapScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapScrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            mapScrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            mapScrollViewBottomAnchor,
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        // legend
        legendView = VTLegendView()
        legendView.backgroundColor = .clear

        view.addSubview(legendView)

        legendView.translatesAutoresizingMaskIntoConstraints = false
        legendViewBottomAnchor = legendView.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0
        )

        NSLayoutConstraint.activate([
            legendViewBottomAnchor,
            legendView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            legendView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            legendView.heightAnchor.constraint(equalToConstant: legendHeight),
        ])

        // status
        robotStatusView = VTRobotStatusView()
        robotStatusView.backgroundColor = .systemBackground

        view.addSubview(robotStatusView)

        robotStatusView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            robotStatusView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            robotStatusView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            robotStatusView.heightAnchor.constraint(equalToConstant: 86),
            robotStatusView.widthAnchor.constraint(equalToConstant: 118),
        ])

        navigationItem.rightBarButtonItem = VTValetudoEventBarButtonItem(client: client, parentViewController: self)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Rehome the shared robot control controller when the layout switches
        // between compact sheet presentation and split-view inspector presentation.
        registerForTraitChanges([UITraitHorizontalSizeClass.self]) { (self: Self, _) in
            self.updateRobotControlViewPresentation(animated: false)
            self.mapScrollViewBottomAnchor.constant = self.mapBottomInset
            self.legendViewBottomAnchor.constant = self.legendBottomInset
        }

        updateRobotControlViewPresentation(animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        mapScrollViewBottomAnchor.constant = mapBottomInset
        legendViewBottomAnchor.constant = legendBottomInset

        super.viewWillAppear(animated)

        startSSEObservation()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        stopSSEObservation()
    }

    @MainActor
    override func reconnectAndRefresh() async {
        // Cancel existing SSE task and reconnect
        stopSSEObservation()
        startSSEObservation()
    }

    private func startSSEObservation() {
        guard eventObservationTask == nil else { return }

        eventObservationTask = Task {
            do {
                try await loadInitialData()
                hasConnectedMapStream = false

                let (token, stream) = await client.registerEventObserver(for: .map)
                observerToken = token

                for await event in stream {
                    switch event {
                    case .didConnect:
                        if hasConnectedMapStream {
                            if let mapData = try? await client.getMap() {
                                await self.mapView?.updateData(data: mapData)
                                await self.updateLegend(data: mapData)
                            }
                        } else {
                            hasConnectedMapStream = true
                        }
                    case let .didReceiveData(mapData):
                        await self.mapView?.updateData(data: mapData)
                        await self.updateLegend(data: mapData)
                    case let .didReceiveError(message):
                        log(message: message, forSubsystem: .map, level: .error)
                    default:
                        break
                    }
                }
            } catch {
                log(message: error.localizedDescription, forSubsystem: .map, level: .error)
                // TODO: Show error
            }
        }
    }

    private func stopSSEObservation() {
        eventObservationTask?.cancel()
        eventObservationTask = nil
        hasConnectedMapStream = false

        if let token = observerToken {
            let client = client
            Task { await client.removeEventObserver(token: token, for: .map) }
            observerToken = nil
        }
    }

    private func hideEntityPopup() {
        guard let vc = calloutPresenter.presentedViewController as? VTCalloutViewController else { return }
        vc.dismiss(animated: true)
    }

    /// Entity callouts should appear above the sheet when compact presentation is active.
    private var calloutPresenter: UIViewController {
        (presentedViewController as? VTRobotControlViewController) ?? self
    }

    private func presentCallout(_ vc: VTCalloutViewController, at point: CGPoint) {
        guard let popover = vc.popoverPresentationController else { return }

        popover.sourceView = mapView
        popover.sourceRect = CGRect(origin: point, size: .one)
        popover.permittedArrowDirections = .any
        popover.delegate = self

        let presenter = calloutPresenter
        if let presentedCallout = presenter.presentedViewController as? VTCalloutViewController {
            presentedCallout.dismiss(animated: false) {
                presenter.present(vc, animated: true)
            }
        } else {
            presenter.present(vc, animated: true)
        }
    }

    private func showEntityPopup(entity: VTEntity, at point: CGPoint) async -> Bool {
        var title = ""
        var subtitle = ""
        var image: UIImage?
        var showsImageCallout = false

        switch entity.type {
        case .charger_location:
            title = "CHARGER".localized()
            subtitle = robotInfo?.description ?? ""
        case .robot_position:
            title = robotInfo?.description ?? "ROBOT".localized()
            if let state = robotState {
                subtitle = "\(state.statusState.description.localizedUppercase()) - \(state.batterLevel)%"
            } else {
                subtitle = ""
            }
        case .obstacle:
            title = "OBSTACLE".localized()
            subtitle = entity.label ?? ""
            if let label = entity.label,
               let range = label.range(of: " (", options: .backwards), label.hasSuffix(")")
            {
                title = String(label[..<range.lowerBound])
                subtitle = String(label[range.upperBound ..< label.index(before: label.endIndex)])
            }
            showsImageCallout = obstacleImagesCapabilityIsEnabled
        default: return false
        }

        let vc = if showsImageCallout {
            VTCalloutViewController(
                title: title,
                subtitle: subtitle,
                image: image,
                isLoadingImage: true
            )
        } else {
            VTCalloutViewController(
                title: title,
                subtitle: subtitle
            )
        }
        presentCallout(vc, at: point)

        guard showsImageCallout,
              entity.type == .obstacle,
              let id = entity.id,
              let obstacleImage = try? await client.getObstacleImage(id: id)
        else {
            return true
        }

        image = UIImage(ciImage: obstacleImage)
        vc.update(
            title: title,
            subtitle: subtitle,
            image: image,
            isLoadingImage: false
        )
        return true
    }

    private func updateLegend(data _: VTMapData) async {
        legendView.isHidden = !supportsSegmentation || segmentLayer.isEmpty
        guard supportsSegmentation else {
            legendView.items = []
            return
        }

        legendView.items = segmentLayer.map { layer in
            VTLegendItem(color: layer.fillColor ?? .black, text: layer.name ?? layer.segmentId!)
        }
    }

    private func mapShouldChangeSelection(forLayer layer: VTLayer, isSelected _: Bool) async -> Bool {
        guard supportsSegmentation, segmentLayer.contains(layer) else { return false }
        return true
    }

    private func mapDidChangeSelection(forLayer layer: VTLayer, isSelected: Bool) async {
        guard let index = segmentLayer.firstIndex(of: layer) else { return }

        // Keep map-driven selection in sync with the shared control sheet / inspector state.
        var config = robotControlViewController.currentConfiguration

        if isSelected {
            await legendView.select(at: index)
            config = config.appending(segmentId: layer.segmentId!)
        } else {
            await legendView.deselect(at: index)
            config = config.removing(segmentId: layer.segmentId!)
        }
        robotControlViewController.currentConfiguration = config
    }

    private func legendShouldChangedSelection(atIndex index: Int, isSelected _: Bool) async -> Bool {
        guard supportsSegmentation,
              segmentLayer.indices.contains(index) else { return false }
        return true
    }

    private func legendDidChangeSelection(atIndex index: Int, isSelected: Bool) async {
        guard segmentLayer.indices.contains(index) else { return }

        // Legend selection mirrors map selection and updates the shared control state directly.
        var config = robotControlViewController.currentConfiguration
        let layer = segmentLayer[index]

        if isSelected {
            await mapView?.select(layer: layer)
            config = config.appending(segmentId: layer.segmentId!)
        } else {
            await mapView?.deselect(layer: layer)
            config = config.removing(segmentId: layer.segmentId!)
        }
        robotControlViewController.currentConfiguration = config
    }

    @MainActor
    func loadInitialData() async throws {
        activityIndicator.startAnimating()
        defer { activityIndicator.stopAnimating() }

        let mapData = try await client.getMap()
        robotInfo = try? await client.getRobotInfo()
        robotState = try? await client.getStateAttributes()
        let capabilities = await Set((try? client.getCapabilities()) ?? [])
        supportsSegmentation = capabilities.contains(.mapSegmentation)
        obstacleImagesCapabilityIsEnabled = await (try? client.getObstacleImagesCapabilityIsEnabled()) ?? false

        if let state = robotState {
            robotStatusView.update(
                forStatus: state.statusState.description,
                batteryLevel: state.batterLevel
            )
        }

        let viewSize = view.bounds.size == .zero ? (UIScreen.current?.bounds.size ?? .zero) : view.bounds.size
        let mapSize = CGSize(width: min(viewSize.width, 500), height: min(viewSize.height, 500))
        let mapRect = CGRect(origin: .zero, size: mapSize)
        let mapView = VTMapView(frame: mapRect, data: mapData)
        mapView.shouldChangeLayerSelection = mapShouldChangeSelection
        mapView.didChangeLayerSelection = mapDidChangeSelection
        mapView.onEntityClicked = showEntityPopup

        mapScrollView.zoomableView = mapView

        await updateLegend(data: mapView.data)
        legendView.shouldChangeSelection = legendShouldChangedSelection
        legendView.didChangeSelection = legendDidChangeSelection
    }
}

extension VTHomeViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for _: UIPresentationController) -> UIModalPresentationStyle {
        .none
    }
}

extension VTHomeViewController: UISheetPresentationControllerDelegate {
    /// Maps the custom detent identifiers to the sheet heights used for legend positioning.
    private func proposedHeight(for detentIdentifier: UISheetPresentationController.Detent.Identifier) -> CGFloat? {
        switch detentIdentifier {
        case .bottom: UISheetPresentationController.Detent.bottomHeight
        case .middle: UISheetPresentationController.Detent.middleHeight
        default: nil
        }
    }

    func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
        // Animate when the user drags the sheet to a different detent.
        if let identifier = sheetPresentationController.selectedDetentIdentifier,
           let height = proposedHeight(for: identifier)
        {
            // `updateLegendPosition` already accounts for the safe-area inset. Passing the
            // raw detent height keeps detent settling aligned with the live frame observer.
            updateLegendPosition(basedOn: height, animate: true)
        }
    }

    /// Moves the shared robot control controller between inspector and sheet presentation.
    fileprivate func updateRobotControlViewPresentation(animated: Bool = false) {
        let splitVC = splitViewController as? VTSplitViewController

        if isCompact {
            splitVC?.setRobotControlViewControllerPresentedInInspector(false)
            presentControlSheet(animated: animated)
        } else {
            dismissControlSheet(animated: animated) { [weak splitVC] in
                splitVC?.setRobotControlViewControllerPresentedInInspector(true)
            }
        }
    }

    private func presentControlSheet(animated: Bool) {
        guard isCompact else { return }
        let sheetVC = robotControlViewController

        sheetVC.modalPresentationStyle = .pageSheet

        if let sheet = sheetVC.sheetPresentationController {
            sheet.detents = [.bottom(), .middle(), .top()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = sheetCornerRadius
            sheet.delegate = self

            // Prevent swipe-to-dismiss
            sheet.largestUndimmedDetentIdentifier = .middle
            sheet.prefersEdgeAttachedInCompactHeight = true

            // Prevent full dismissal
            sheetVC.isModalInPresentation = true
        }

        guard presentedViewController != sheetVC else {
            // in case we swipe back and cancel the swipe, just reposition the view
            let detentHeight = sheetVC.view.frame.height
            updateLegendPosition(basedOn: detentHeight, animate: animated)
            return
        }

        // Pre-position the legend so the first sheet animation does not jump.
        let bottomHeight = UISheetPresentationController.Detent.bottomHeight
        updateLegendPosition(basedOn: bottomHeight, animate: animated)

        present(sheetVC, animated: animated) { [weak sheetVC] in
            self.startObservingSheetFrame(for: sheetVC?.view)
        }
    }

    private func dismissControlSheet(animated: Bool, completion: (() -> Void)? = nil) {
        guard presentedViewController === robotControlViewController else {
            completion?()
            return
        }

        stopObservingSheetFrame()

        // Reattaching to the inspector must wait until UIKit has fully dismissed the sheet.
        presentedViewController?.dismiss(animated: animated, completion: completion)
    }

    private func startObservingSheetFrame(for view: UIView?) {
        guard let view else { return }
        if observedSheetView === view { return }

        stopObservingSheetFrame()
        view.addObserver(self, forKeyPath: "frame", options: [.new, .initial], context: nil)
        observedSheetView = view
    }

    private func stopObservingSheetFrame() {
        guard let observedSheetView else { return }
        observedSheetView.removeObserver(self, forKeyPath: "frame")
        self.observedSheetView = nil
    }

    override func observeValue(forKeyPath keyPath: String?,
                               of _: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context _: UnsafeMutableRawPointer?)
    {
        guard keyPath == "frame",
              let frame = (change?[.newKey] as? NSValue)?.cgRectValue else { return }

        Task { @MainActor in
            guard isCompact,
                  presentedViewController === robotControlViewController else { return }
            updateLegendPosition(basedOn: frame.height, animate: false)
        }
    }

    @MainActor
    private func updateLegendPosition(basedOn sheetHeight: CGFloat, animate: Bool) {
        let bottomInset = view.safeAreaInsets.bottom
        let midHeight = UISheetPresentationController.Detent.middleHeight

        // Keep the legend visible above the compact sheet until the sheet reaches the
        // middle detent, after which the legend stops moving further upward.
        legendViewBottomAnchor.constant = max(
            -bottomPad - sheetHeight + bottomInset,
            -bottomPad - midHeight
        )
        if animate {
            UIView.animate(withDuration: 0.25) { [weak self] in
                self?.view.layoutIfNeeded()
            }
        } else {
            view.layoutIfNeeded()
        }

        // Fade out legend
        // let progress = (sheetHeight - bottomInset - midHeight) / legendHeight
        // legendView.alpha = 1 - min(max(progress, 0), 1)
    }
}
