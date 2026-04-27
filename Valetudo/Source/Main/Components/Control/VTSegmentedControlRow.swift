//
//  VTControlRow.swift
//  Valetudo
//
//  Created by David Klopp on 21.05.25.
//
import UIKit

protocol VTSegmentedItem: Equatable {
    var title: String { get }
    var icon: UIImage? { get }
}

final class VTSegmentedControlRow<T: VTSegmentedItem>: VTControlRow<UISegmentedControl> {
    var values: [T] = [] {
        didSet { refresh() }
    }

    private var allowsValueChange: Bool = true

    var selectedValue: T? {
        get {
            let index = content.selectedSegmentIndex
            return (index >= 0 && index < values.count) ? values[index] : nil
        }
        set {
            guard allowsValueChange, let newValue, let index = values.firstIndex(of: newValue) else {
                return
            }
            previousValue = selectedValue
            content.selectedSegmentIndex = index
        }
    }

    private var previousValue: T?

    var onValueChanged: ((T?, T) -> Void)?

    init(title: String, titleIcon: UIImage?) {
        let segmentedControl = UISegmentedControl() // RoundedSegmentedControl()
        segmentedControl.selectedSegmentTintColor = .tintColor
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        super.init(title: title, titleIcon: titleIcon, content: segmentedControl)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setup() {
        super.setup()

        content.heightAnchor.constraint(equalToConstant: 45).isActive = true
        content.addTarget(self, action: #selector(selectedSegmentChanged(_:)), for: .valueChanged)
    }

    private func refresh() {
        previousValue = nil
        content.removeAllSegments()
        for (idx, item) in values.enumerated() {
            if let icon = item.icon {
                content.insertSegment(with: icon, at: idx, animated: false)
            } else {
                content.insertSegment(withTitle: item.title, at: idx, animated: false)
            }
        }
        if let selectedValue, let currentIndex = values.firstIndex(of: selectedValue) {
            content.selectedSegmentIndex = currentIndex
        }
    }

    var isEnabled: Bool = true {
        didSet {
            allowsValueChange = isEnabled
            content.isEnabled = isEnabled
        }
    }

    @objc private func selectedSegmentChanged(_: UISegmentedControl) {
        guard let selectedValue else { return }

        onValueChanged?(previousValue, selectedValue)

        previousValue = selectedValue
    }
}
