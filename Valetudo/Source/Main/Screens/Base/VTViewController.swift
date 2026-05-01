//
//  VTViewController.swift
//  Valetudo
//
//  Created by David Klopp on 28.03.26.
//
import UIKit

class VTViewController: UIViewController, VTViewControllerProtocol {
    var lastKnownViewWidth: CGFloat = 0
    var lastKnownViewDesign: VTViewDesign?
    private lazy var keyboardEventController = VTKeyboardEventController { [weak self] event in
        self?.didReceiveKeyEvent(event) ?? false
    }

    @objc
    private func sceneWillEnterForeground(_: Notification) {
        Task {
            guard self.viewIfLoaded?.window != nil else { return }
            await self.reconnectAndRefresh()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // We don't need any cleanup, since we are using target / action pattern
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sceneWillEnterForeground(_:)),
            name: .scene​Did​Request​Refresh​After​Background,
            object: nil
        )
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        recomputeViewMetricsChange()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardEventController.stop()
        resignFirstResponder()
    }

    override var canBecomeFirstResponder: Bool {
        true
    }

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        let didHandleEvent = keyboardEventController.handlePressesBegan(presses)
        if !didHandleEvent {
            super.pressesBegan(presses, with: event)
        }
    }

    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        let didHandleEvent = keyboardEventController.handlePressesEnded(presses)
        if !didHandleEvent {
            super.pressesEnded(presses, with: event)
        }
    }

    override func pressesCancelled(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        let didHandleEvent = keyboardEventController.handlePressesCancelled(presses)
        if !didHandleEvent {
            super.pressesCancelled(presses, with: event)
        }
    }

    @MainActor
    func reconnectAndRefresh() async {
        // Override me
    }

    func viewDesign(forAvailableWidth width: CGFloat, traitCollection: UITraitCollection) -> VTViewDesign {
        guard width >= 520, traitCollection.horizontalSizeClass != .compact else { return .compact }
        return .regular
    }

    func viewMetricsDidChange() {
        // Override me
    }

    func viewDesignDidChange(to _: VTViewDesign) {
        // Override me
    }

    func didReceiveKeyEvent(_: UIKey) -> Bool {
        false
    }
}
