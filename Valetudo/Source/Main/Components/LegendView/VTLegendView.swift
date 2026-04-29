//
//  VTLegendView.swift
//  Valetudo
//
//  Created by David Klopp on 20.05.25.
//
import UIKit

@MainActor
class VTLegendView: UIView {
    var items: [VTLegendItem] = [] {
        didSet {
            reload()
        }
    }

    var shouldChangeSelection: ((Int, Bool) async -> Bool)?

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private var itemViews: [VTLegendItemView] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

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

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        Task { [weak self] in
            await self?.handleTapAsync(gesture)
        }
    }

    private func handleTapAsync(_ gesture: UITapGestureRecognizer) async {
        guard let tappedView = gesture.view as? VTLegendItemView else { return }
        let index = tappedView.tag
        let wasSelected = tappedView.isSelected
        let shouldChange = await shouldChangeSelection?(index, wasSelected) ?? true

        if shouldChange {
            tappedView.isSelected.toggle()
        }
    }

    var selectedIndices: [Int] {
        itemViews.enumerated().compactMap { $0.element.isSelected ? $0.offset : nil }
    }

    var selectedItems: [VTLegendItem] {
        selectedIndices.map { items[$0] }
    }

    func select(at index: Int) async {
        guard index >= 0, index < itemViews.count else { return }
        itemViews[index].isSelected = true
    }

    func deselect(at index: Int) async {
        guard index >= 0, index < itemViews.count else { return }
        itemViews[index].isSelected = false
    }

    func clearSelection() async {
        itemViews.forEach { $0.isSelected = false }
    }
}
