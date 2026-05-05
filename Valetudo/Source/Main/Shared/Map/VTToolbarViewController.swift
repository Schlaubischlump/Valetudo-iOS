//
//  VTToolbarViewController.swift
//  Valetudo
//
//  Created by David Klopp on 05.05.26.
//
import UIKit

/// Provides a lightweight configurable toolbar that map-oriented subclasses can position and populate.
class VTToolbarViewController: VTViewController, UIToolbarDelegate {
    /// Describes the toolbar edge and horizontal alignment inside the host view.
    enum ToolbarPlacement {
        case topLeading
        case topTrailing
        case bottomLeading
        case bottomTrailing

        /// Returns whether the toolbar should be attached to the top safe-area edge.
        var isTop: Bool {
            self == .topLeading || self == .topTrailing
        }

        /// Returns whether the toolbar should be attached to the bottom safe-area edge.
        var isBottom: Bool {
            self == .bottomLeading || self == .bottomTrailing
        }
    }

    /// Defines one toolbar item including visibility rules and tap behavior.
    struct ToolbarActionDefinition {
        let title: String
        let image: UIImage?
        let handler: @MainActor () -> Void
        let isVisible: @MainActor () -> Bool
        fileprivate var isSeparator = false

        /// Creates a toolbar action backed by a title, optional image, and tap handler.
        init(
            title: String,
            image: UIImage? = nil,
            handler: @escaping @MainActor @Sendable () -> Void,
            isVisible: (@escaping @MainActor @Sendable () -> Bool) = { true }
        ) {
            self.title = title
            self.image = image
            self.handler = handler
            self.isVisible = isVisible
        }

        /// Returns a spacing marker used to visually separate action groups.
        static var separator: ToolbarActionDefinition {
            var definition = ToolbarActionDefinition(title: "") {}
            definition.isSeparator = true
            return definition
        }
    }

    /// Returns the toolbar actions the subclass wants to expose for its current editing mode.
    var toolbarActionDefinitions: [ToolbarActionDefinition] {
        []
    }

    /// Controls toolbar position and alignment.
    var toolbarPlacement: ToolbarPlacement = .topTrailing {
        didSet {
            updateToolbarConstraints()
            updateToolbarItems()
        }
    }

    let toolbar = UIToolbar()
    private var toolbarConstraints: [NSLayoutConstraint] = []

    // MARK: - View Life Cycle

    /// Configures the toolbar once the controller's view hierarchy is loaded.
    override func viewDidLoad() {
        super.viewDidLoad()

        setupToolbar()
        updateToolbarItems()
    }

    /// Keeps the toolbar above other content after layout updates.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.bringSubviewToFront(toolbar)
    }

    // MARK: - Toolbar Configuration

    /// Installs the toolbar into the view hierarchy and applies its initial constraints.
    private func setupToolbar() {
        toolbar.delegate = self
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolbar)
        updateToolbarConstraints()
    }

    /// Rebuilds the toolbar's anchoring constraints to match the current placement.
    func updateToolbarConstraints() {
        guard toolbar.superview != nil else { return }

        NSLayoutConstraint.deactivate(toolbarConstraints)

        switch toolbarPlacement {
        case .topLeading, .topTrailing:
            toolbarConstraints = [
                toolbar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
                toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ]

        case .bottomLeading, .bottomTrailing:
            toolbarConstraints = [
                toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            ]
        }

        NSLayoutConstraint.activate(toolbarConstraints)
    }

    /// Rebuilds visible toolbar items from the current action definitions and alignment rules.
    @MainActor
    func updateToolbarItems() {
        let visibleDefinitions = toolbarActionDefinitions.filter { $0.isVisible() }

        let baseItems: [UIBarButtonItem] = visibleDefinitions.map { definition in
            if definition.isSeparator {
                // fixed space separates items in groups, so that they don't share the same background
                .fixedSpace()
            } else {
                UIBarButtonItem(
                    title: definition.title,
                    image: definition.image,
                    primaryAction: UIAction { _ in
                        definition.handler()
                    }
                )
            }
        }

        guard !baseItems.isEmpty else {
            toolbar.setItems([], animated: true)
            toolbar.isHidden = true
            return
        }

        let alignedItems: [UIBarButtonItem] = switch toolbarPlacement {
        case .topLeading, .bottomLeading:
            // Items on leading side → trailing flexible space
            baseItems + [.fixedSpace(), .flexibleSpace()]

        case .topTrailing, .bottomTrailing:
            // Items on trailing side → leading flexible space
            [.flexibleSpace()] + baseItems
        }

        toolbar.isHidden = false
        toolbar.setItems(alignedItems, animated: true)
    }

    // MARK: - UIToolbarDelegate

    /// Returns the bar position that matches the current toolbar placement.
    func position(for _: any UIBarPositioning) -> UIBarPosition {
        toolbarPlacement.isTop ? .top : .bottom
    }
}
