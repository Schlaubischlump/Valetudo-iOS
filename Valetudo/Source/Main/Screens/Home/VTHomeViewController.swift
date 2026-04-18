//
//  VTMainViewController.swift
//  Valetudo
//
//  Created by David Klopp on 18.03.25.
//  
//

import UIKit

fileprivate let bottomPad: CGFloat = 20
fileprivate let legendHeight: CGFloat = 45.0
fileprivate let sheetCornerRadius: CGFloat = 39.0

// TODO: Fix map resize when window size changes
class VTHomeViewController: VTViewController {
    private let client: VTAPIClientProtocol

    var mapInteractionEnabled: Bool = true
    
    private let mapScrollView = VTZoomableScrollView()
    private var mapView: VTMapView? { mapScrollView.zoomableView as? VTMapView }
    private var legendView: VTLegendView!
    private var robotStatusView: VTRobotStatusView!
    private var observerToken: VTListenerToken?
    private var sseTask: Task<Void, Never>?
        
    private lazy var robotControlViewController: VTRobotControlViewController? = {
        VTRobotControlViewController(client: self.client)
    }()
    
    private var legendViewBottomAnchor: NSLayoutConstraint!
    private var mapScrollViewBottomAnchor: NSLayoutConstraint!
    private var mapBottomInset: CGFloat {
        if self.isCompact {
            -bottomPad
        } else {
            -UISheetPresentationController.Detent.bottomHeight + sheetCornerRadius
        }
    }
    private var legendBottomInset: CGFloat {
        let safeAreaInset = self.view.safeAreaInsets.bottom
        return if self.isCompact {
            -bottomPad + safeAreaInset
        } else {
            -bottomPad - UISheetPresentationController.Detent.bottomHeight + safeAreaInset
        }
    }
    
    
    // MARK: - Cached data
    private var robotInfo: VTRobotInfo?
    private var robotState: VTStateAttributeList?
    
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
                
        mapScrollView.translatesAutoresizingMaskIntoConstraints = false
        mapScrollViewBottomAnchor = mapScrollView.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor,
            constant: bottomPad
        )
        NSLayoutConstraint.activate([
            mapScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapScrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            mapScrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            mapScrollViewBottomAnchor
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
        
        self.navigationItem.rightBarButtonItem = VTEventBarButton(client: client)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
                
        self.registerForTraitChanges(
            [UITraitHorizontalSizeClass.self],
            handler: { (self: Self, previousTraitCollection: UITraitCollection) in
                self.updateRobotControlViewPresentation(animated: false)
                
                self.mapScrollViewBottomAnchor.constant = self.mapBottomInset
                self.legendViewBottomAnchor.constant = self.legendBottomInset
        })
        
        self.updateRobotControlViewPresentation(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.mapScrollViewBottomAnchor.constant = self.mapBottomInset
        self.legendViewBottomAnchor.constant = self.legendBottomInset
        
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
        guard sseTask == nil else { return }
        
        sseTask = Task {
            do {
                try await loadInitialData()
                
                let (token, stream) = await client.registerEventObserver(for: .map)
                observerToken = token
                
                for await event in stream {
                    switch event {
                    case .didReceiveData(let mapData):
                        await self.mapView?.updateData(data: mapData)
                        await self.updateLegend(data: mapData)
                    case .didReceiveError(let msg):
                        print("Received error message: \(msg)")
                        // TODO: Show error
                    default:
                        break
                    }
                }
            } catch {
                // TODO: Show error
                print("Failed to load map data: \(error)")
            }
        }
    }
    
    private func stopSSEObservation() {
        sseTask?.cancel()
        sseTask = nil
        
        if let token = observerToken {
            let client = self.client
            Task { await client.removeEventObserver(token: token, for: .map) }
            observerToken = nil
        }
    }
    
    private func hideEntityPopup() {
        guard let vc = presentedViewController as? VTCalloutViewController else { return }
        vc.dismiss(animated: true)
    }
    
    private func showEntityPopup(
        entity: VTEntity,
        at point: CGPoint
    ) -> Bool {
        guard mapInteractionEnabled else { return false }
        
        var title: String = ""
        var subtitle: String = ""
        
        switch (entity.type) {
        case .charger_location:
            title = "CHARGER".localizedCapitalized()
            subtitle = robotInfo?.description ?? ""
        case .robot_position:
            title = robotInfo?.description ?? "ROBOT".localizedCapitalized()
            if let state = robotState {
                subtitle = "\(state.statusState.description.localizedUppercase()) - \(state.batterLevel)%"
            } else {
                subtitle = ""
            }
        default : return false
        }
        
        let vc = VTCalloutViewController(
            title: title,
            subtitle: subtitle
        )

        if let popover = vc.popoverPresentationController {
            popover.sourceView = mapView
            popover.sourceRect = CGRect(origin: point, size: .one)
            popover.permittedArrowDirections = .any
            popover.delegate = self
            
            // if we present a bottom sheet on iOS we need to use that to present our callouts
            let presented = (self.presentedViewController as? VTRobotControlViewController) ?? self
            presented.present(vc, animated: true)
        }
        return true
    }

    private func updateLegend(data: VTMapData) async {
        legendView.items = segmentLayer.map { layer in
            return VTLegendItem(color: layer.fillColor ?? .black, text: layer.name ?? layer.segmentId!)
        }
    }

    private func mapChangedSelection(forLayer layer: VTLayer, isSelected: Bool) async -> Bool {
        guard mapInteractionEnabled, //!self.refreshMap,
              var config = robotControlViewController?.currentConfiguration,
              let index = segmentLayer.firstIndex(of: layer) else { return false }
        if (!isSelected) {
            await legendView.select(at: index)
            config = config.appending(segmentId: layer.segmentId!)
        } else {
            await legendView.deselect(at: index)
            config = config.removing(segmentId: layer.segmentId!)
        }
        robotControlViewController?.currentConfiguration = config
        return true
    }
    
    private func legendChangedSelection(atIndex index: Int, isSelected: Bool) async -> Bool {
        guard mapInteractionEnabled, //!self.refreshMap
              var config = robotControlViewController?.currentConfiguration else { return false }
        let layer = segmentLayer[index]
        if (!isSelected) {
            await mapView?.select(layer: layer)
            config = config.appending(segmentId: layer.segmentId!)
        } else {
            await mapView?.deselect(layer: layer)
            config = config.removing(segmentId: layer.segmentId!)
        }
        robotControlViewController?.currentConfiguration = config
        return true
    }
    
    @MainActor
    func loadInitialData() async throws {
        let mapData = try await client.getMap()
        robotInfo = try? await client.getRobotInfo()
        robotState = try? await client.getStateAttributes()
                
        if let state = robotState {
            robotStatusView.update(
                forStatus: state.statusState.description,
                batteryLevel: state.batterLevel
            )
        }
        
        let screenSize = UIScreen.current?.bounds.size ?? .zero
        let mapSize = CGSize(width: min(screenSize.width, 500), height: min(screenSize.height, 500))
        let mapRect = CGRect(origin: .zero, size: mapSize)
        let mapView = VTMapView(frame: mapRect, data: mapData)
        mapView.onLayerSelectionChange = mapChangedSelection
        mapView.onEntityClicked = showEntityPopup

        mapScrollView.zoomableView = mapView

        await updateLegend(data: mapView.data)
        legendView.onSelectionChange = legendChangedSelection
    }
}

extension VTHomeViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        .none
    }
}

extension VTHomeViewController: UISheetPresentationControllerDelegate {
    private func proposedHeight(for detentIdentifier: UISheetPresentationController.Detent.Identifier) -> CGFloat? {
        switch (detentIdentifier) {
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
        let splitVC = self.splitViewController
        
        if self.isCompact {
            splitVC?.hide(.inspector)
            self.presentControlSheet(animated: animated)
        } else {
            self.dismissControlSheet(animated: animated)
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
        self.presentedViewController?.dismiss(animated: animated, completion: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
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
        if (animate) {
            UIView.animate(withDuration: 0.25) { [weak self] in
                self?.view.layoutIfNeeded()
            }
        } else {
            self.view.layoutIfNeeded()
        }
        
        // Fade out legend
        //let progress = (sheetHeight - bottomInset - midHeight) / legendHeight
        //legendView.alpha = 1 - min(max(progress, 0), 1)
    }
}
