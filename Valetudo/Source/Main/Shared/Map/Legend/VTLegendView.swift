//
//  VTLegendView.swift
//  Valetudo
//
//  Created by David Klopp on 20.05.25.
//
import UIKit

@MainActor
/// Horizontally scrolling legend that displays selectable map overlay categories.
class VTLegendView: UIView {
    var items: [VTLegendItem] = [] {
        didSet {
            reload()
        }
    }

    var shouldChangeSelection: ((Int, Bool) async -> Bool)?
    var didChangeSelection: ((Int, Bool) async -> Void)?

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private var itemViews: [VTLegendItemView] = []

    // MARK: - Init

    /// Creates the legend view programmatically.
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    /// Creates the legend view from an archive.
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - Setup

    /// Builds the horizontal scrolling legend layout.
    private func setup() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.backgroundColor = .clear

        stackView.backgroundColor = .clear
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(scrollView)
        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
        ])
    }

    /// Rebuilds the visible legend item views from the current `items` array.
    private func reload() {
        itemViews.forEach { $0.removeFromSuperview() }
        itemViews = []

        for (index, item) in items.enumerated() {
            let itemView = VTLegendItemView(item: item)
            itemView.tag = index
            itemView.isUserInteractionEnabled = true

            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            itemView.addGestureRecognizer(tap)

            stackView.addArrangedSubview(itemView)
            itemViews.append(itemView)
        }
    }

    // MARK: - Selection

    /// Bridges the tap gesture callback into the async selection flow.
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        Task { [weak self] in
            await self?.handleTapAsync(gesture)
        }
    }

    /// Applies the selection policy callbacks for the tapped legend item.
    private func handleTapAsync(_ gesture: UITapGestureRecognizer) async {
        guard let tappedView = gesture.view as? VTLegendItemView else { return }
        let index = tappedView.tag
        let wasSelected = tappedView.isSelected
        let shouldChange = await shouldChangeSelection?(index, wasSelected) ?? true

        if shouldChange {
            tappedView.isSelected.toggle()
            await didChangeSelection?(index, tappedView.isSelected)
        }
    }

    /// Returns the indices of all currently selected legend item views.
    var selectedIndices: [Int] {
        itemViews.enumerated().compactMap { $0.element.isSelected ? $0.offset : nil }
    }

    /// Returns the currently selected legend items.
    var selectedItems: [VTLegendItem] {
        selectedIndices.map { items[$0] }
    }

    /// Selects the legend item at the provided index if it exists.
    func select(at index: Int) async {
        guard index >= 0, index < itemViews.count else { return }
        itemViews[index].isSelected = true
    }

    /// Deselects the legend item at the provided index if it exists.
    func deselect(at index: Int) async {
        guard index >= 0, index < itemViews.count else { return }
        itemViews[index].isSelected = false
    }

    /// Clears selection from every visible legend item.
    func clearSelection() async {
        itemViews.forEach { $0.isSelected = false }
    }
}
