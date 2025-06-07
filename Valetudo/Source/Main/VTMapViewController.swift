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
fileprivate let sheetCornerRadius: CGFloat = 20

class VTMapViewController: UIViewController {
    private let client: VTAPIClientProtocol

    var mapInteractionEnabled: Bool = true
    
    private let mapScrollView = VTZoomableScrollView()
    private var mapView: VTMapView? { mapScrollView.zoomableView as? VTMapView }
    private var legendView: VTLegendView!
    private var robotStatusView: VTRobotStatusView!
    private var observerToken: VTListenerToken?
    
    #if targetEnvironment(macCatalyst)
    private var robotControlViewController: VTRobotControlViewController?
    #else
    private lazy var robotControlViewController: VTRobotControlViewController? = { VTRobotControlViewController(client: self.client)
    }()
    #endif
    
    private var legendViewBottomAnchor: NSLayoutConstraint!
    
    // MARK: - Cached data
    private var robotInfo: VTRobotInfo?
    private var robotState: VTStateAttributes?
    
    private var segmentLayer: [VTLayer] {
        mapView?.data.segmentLayer ?? []
    }
    
    init(client: VTAPIClientProtocol) {
        self.client = client

        super.init(nibName: nil, bundle: nil)
        title = "MAP".localized()
        view.backgroundColor = .systemBackground
        
        #if targetEnvironment(macCatalyst)
        let legendBottomInset = -bottomPad
        let mapBottomInset = bottomPad
        #else
        let legendBottomInset = -bottomPad - UISheetPresentationController.Detent.bottomHeight
        let mapBottomInset = -UISheetPresentationController.Detent.bottomHeight + sheetCornerRadius
        #endif
        
        // map
        mapScrollView.minimumZoomScale = 1.0
        mapScrollView.maximumZoomScale = 3.0

        view.addSubview(mapScrollView)
        
        mapScrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapScrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            mapScrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            mapScrollView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: mapBottomInset
            )
        ])
        
        // legend
        legendView = VTLegendView()
        legendView.backgroundColor = .clear
        
        view.addSubview(legendView)
        
        legendView.translatesAutoresizingMaskIntoConstraints = false
        legendViewBottomAnchor = legendView.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: legendBottomInset
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
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        #if !targetEnvironment(macCatalyst)
        if traitCollection.horizontalSizeClass == .compact {
            self.presentControlSheet()
        }
        #endif
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Task {
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
                        // TODO: Handle error
                    default:
                        break
                    }
                }
            } catch {
                // TODO: Do something with the error
                print("Failed to load map data: \(error)")
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let token = observerToken {
            // capture a strong reference, since we know the client will outlive self
            let client = self.client
            Task { await client.removeEventObserver(token: token, for: .map) }
        }
    }
    
    #if !targetEnvironment(macCatalyst)
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        // Dismiss the sheet if entering regular size class
        if traitCollection.horizontalSizeClass != .compact {
            presentedViewController?.dismiss(animated: true, completion: nil)
        }
    }
    #endif
    
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
            title = "CHARGER".localizedCapitalized
            subtitle = robotInfo?.description ?? ""
        case .robot_position:
            title = robotInfo?.description ?? "ROBOT".localizedCapitalized
            if let state = robotState {
                subtitle = "\(state.statusState.description.localizedUppercase) - \(state.batterLevel)%"
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
            return VTLegendItem(color: layer.color, text: layer.name ?? layer.segmentId!)
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
        
        let screenSize = UIScreen.main.bounds.size
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

extension VTMapViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        .none
    }
}

#if !targetEnvironment(macCatalyst)
extension VTMapViewController {
    fileprivate func presentControlSheet() {
        
        guard let sheetVC = robotControlViewController, presentedViewController != sheetVC else { return }
        
        robotControlViewController = sheetVC
        sheetVC.modalPresentationStyle = .pageSheet

        if let sheet = sheetVC.sheetPresentationController {
            sheet.detents = [.bottom(), .middle(), .top()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = sheetCornerRadius

            // Prevent swipe-to-dismiss
            sheet.largestUndimmedDetentIdentifier = .middle
            sheet.prefersEdgeAttachedInCompactHeight = true
            
            // Prevent full dismissal
            sheetVC.isModalInPresentation = true
        }

        present(sheetVC, animated: true) { [weak sheetVC] in
            sheetVC?.view.superview?.addObserver(
                self, forKeyPath: "frame", options: [.new, .initial], context: nil
            )
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        guard keyPath == "frame",
              let frame = (change?[.newKey] as? NSValue)?.cgRectValue else { return }
        animateLegend(basedOn: frame.height)
    }
    
    private func animateLegend(basedOn sheetHeight: CGFloat) {
        let bottomInset = view.safeAreaInsets.bottom
        let midHeight = UISheetPresentationController.Detent.middleHeight
        legendViewBottomAnchor.constant = max(
            -bottomPad - sheetHeight + bottomInset,
            -bottomPad - midHeight
        )
        let progress = (sheetHeight - bottomInset - midHeight) / legendHeight
        legendView.alpha = 1 - min(max(progress, 0), 1)
    }
}
#endif
