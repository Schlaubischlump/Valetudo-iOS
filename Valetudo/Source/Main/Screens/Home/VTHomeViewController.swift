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

class VTHomeViewController: VTViewController {
    private let client: VTAPIClientProtocol

    var mapInteractionEnabled: Bool = true

    private let mapScrollView = VTZoomableScrollView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private var mapView: VTMapView? {
        mapScrollView.zoomableView as? VTMapView
    }

    private var legendView: VTLegendView!
    private var robotStatusView: VTRobotStatusView!
    private var observerToken: VTListenerToken?
    private var eventObservationTask: Task<Void, Never>?

    private lazy var robotControlViewController: VTRobotControlViewController? = VTRobotControlViewController(client: self.client)

    private var legendViewBottomAnchor: NSLayoutConstraint!
    private var mapScrollViewBottomAnchor: NSLayoutConstraint!
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

    private var segmentLayer: [VTLayer] {
        mapView?.data.segmentLayer ?? []
    }

    init(client: VTAPIClientProtocol) {
        self.client = client

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

        registerForTraitChanges(
            [UITraitHorizontalSizeClass.self],
            handler: { (self: Self, _: UITraitCollection) in
                self.updateRobotControlViewPresentation(animated: false)

                self.mapScrollViewBottomAnchor.constant = self.mapBottomInset
                self.legendViewBottomAnchor.constant = self.legendBottomInset
            }
        )

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

                let (token, stream) = await client.registerEventObserver(for: .map)
                observerToken = token

                for await event in stream {
                    switch event {
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

    private func showEntityPopup(
        entity: VTEntity,
        at point: CGPoint
    ) async -> Bool {
        guard mapInteractionEnabled else { return false }

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
        legendView.items = segmentLayer.map { layer in
            VTLegendItem(color: layer.fillColor ?? .black, text: layer.name ?? layer.segmentId!)
        }
    }

    private func mapShouldChangeSelection(forLayer layer: VTLayer, isSelected: Bool) async -> Bool {
        guard mapInteractionEnabled, //! self.refreshMap,
              robotControlViewController?.currentConfiguration != nil,
              segmentLayer.contains(layer) else { return false }
        return true
    }

    private func mapDidChangeSelection(forLayer layer: VTLayer, isSelected: Bool) async {
        guard let index = segmentLayer.firstIndex(of: layer),
              var config = robotControlViewController?.currentConfiguration else { return }

        if isSelected {
            await legendView.select(at: index)
            config = config.appending(segmentId: layer.segmentId!)
        } else {
            await legendView.deselect(at: index)
            config = config.removing(segmentId: layer.segmentId!)
        }
        robotControlViewController?.currentConfiguration = config
    }

    private func legendShouldChangedSelection(atIndex index: Int, isSelected: Bool) async -> Bool {
        guard mapInteractionEnabled, //! self.refreshMap
              robotControlViewController?.currentConfiguration != nil,
              segmentLayer.indices.contains(index) else { return false }
        return true
    }

    private func legendDidChangeSelection(atIndex index: Int, isSelected: Bool) async {
        guard segmentLayer.indices.contains(index),
              var config = robotControlViewController?.currentConfiguration else { return }
        let layer = segmentLayer[index]

        if isSelected {
            await mapView?.select(layer: layer)
            config = config.appending(segmentId: layer.segmentId!)
        } else {
            await mapView?.deselect(layer: layer)
            config = config.removing(segmentId: layer.segmentId!)
        }
        robotControlViewController?.currentConfiguration = config
    }

    @MainActor
    func loadInitialData() async throws {
        activityIndicator.startAnimating()
        defer { activityIndicator.stopAnimating() }

        let mapData = try await client.getMap()
        robotInfo = try? await client.getRobotInfo()
        robotState = try? await client.getStateAttributes()
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
    private func proposedHeight(for detentIdentifier: UISheetPresentationController.Detent.Identifier) -> CGFloat? {
        switch detentIdentifier {
        case .bottom: UISheetPresentationController.Detent.bottomHeight
        case .middle: UISheetPresentationController.Detent.middleHeight
        default: nil
        }
    }

    func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
        // animate when grabber is lifted
        if let identifier = sheetPresentationController.selectedDetentIdentifier,
           let height = proposedHeight(for: identifier)
        {
            updateLegendPosition(basedOn: height + view.safeAreaInsets.bottom, animate: true)
        }
    }

    fileprivate func updateRobotControlViewPresentation(animated: Bool = false) {
        let splitVC = splitViewController

        if isCompact {
            splitVC?.hide(.inspector)
            presentControlSheet(animated: animated)
        } else {
            dismissControlSheet(animated: animated)
            splitVC?.show(.inspector)
        }
    }

    private func presentControlSheet(animated: Bool) {
        guard isCompact else { return }
        guard let sheetVC = robotControlViewController else { return } // , presentedViewController != sheetVC

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

        // animate the legend to be at the right position when the view appears
        let bottomHeight = UISheetPresentationController.Detent.bottomHeight
        updateLegendPosition(basedOn: bottomHeight, animate: animated)

        present(sheetVC, animated: animated) { [weak sheetVC] in
            sheetVC?.view.addObserver(
                self, forKeyPath: "frame", options: [.new, .initial], context: nil
            )
        }
    }

    private func dismissControlSheet(animated: Bool) {
        presentedViewController?.dismiss(animated: animated, completion: nil)
    }

    override func observeValue(forKeyPath keyPath: String?,
                               of _: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context _: UnsafeMutableRawPointer?)
    {
        guard keyPath == "frame",
              let frame = (change?[.newKey] as? NSValue)?.cgRectValue else { return }

        Task {
            await MainActor.run {
                updateLegendPosition(basedOn: frame.height, animate: false)
            }
        }
    }

    @MainActor
    private func updateLegendPosition(basedOn sheetHeight: CGFloat, animate: Bool) {
        let bottomInset = view.safeAreaInsets.bottom
        let midHeight = UISheetPresentationController.Detent.middleHeight
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
