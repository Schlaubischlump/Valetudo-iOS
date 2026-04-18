//
//  VTStackedProgressBar.swift
//  Valetudo
//
//  Created by David Klopp on 16.09.25.
//
import UIKit

/**
 * Horizontal stack that automatically breaks the line if the row is full.
 */
fileprivate final class VTHorizontalFlowStack: UIView {
    var arrangedSubviews: [UIView] = [] {
        didSet {
            oldValue.forEach { $0.removeFromSuperview() }
            arrangedSubviews.forEach { addSubview($0) }
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    var availableWidth: CGFloat = 0
    
    var spacing: CGFloat = 0
    
    func addArrangedSubview(_ view: UIView) {
        self.arrangedSubviews.append(view)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var x: CGFloat = 0
        var y: CGFloat = 0
        
        for subview in arrangedSubviews {
            let size = subview.systemLayoutSizeFitting(
                CGSize(width: availableWidth, height: .greatestFiniteMagnitude)
            )
            if x + size.width > availableWidth { // wrap
                x = 0
                y += size.height + spacing
            }
            subview.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
            x += size.width + spacing
        }
    }

    func computeIntrinsicContentHeight(in width: CGFloat) -> CGFloat {
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
                
        for subview in arrangedSubviews {
            let size = subview.systemLayoutSizeFitting(
                CGSize(width: width, height: .greatestFiniteMagnitude)
            )
            if x + size.width > width { // wrap
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height) // compute the height of the heighest item in this row
        }
        
        // Add the last row
        y += rowHeight
        return y
    }
    
    override var intrinsicContentSize: CGSize {
        let height = computeIntrinsicContentHeight(in: availableWidth)
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }
}


final class VTStackedProgressBarCellContentView: UIView, UIContentView {
    private var currentConfiguration: VTStackedProgressBarCellContentConfiguration!

    // MARK: Subviews
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.textAlignment = .left
        return label
    }()

    private let barsStack = UIStackView()
    private let legendStack = VTHorizontalFlowStack()
    private let rootStack = UIStackView()

    var configuration: UIContentConfiguration {
        get { currentConfiguration }
        set {
            guard let newConfig = newValue as? VTStackedProgressBarCellContentConfiguration else { return }
            apply(configuration: newConfig)
        }
    }

    init(configuration: VTStackedProgressBarCellContentConfiguration) {
        super.init(frame: .zero)
        setupViews()
        apply(configuration: configuration)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupViews() {
        rootStack.axis = .vertical
        rootStack.spacing = 8
        rootStack.translatesAutoresizingMaskIntoConstraints = false

        barsStack.axis = .vertical
        barsStack.spacing = 4
        barsStack.translatesAutoresizingMaskIntoConstraints = false

        legendStack.spacing = 16

        addSubview(rootStack)

        preservesSuperviewLayoutMargins = true
        
        NSLayoutConstraint.activate([
            rootStack.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            rootStack.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            rootStack.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            rootStack.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        ])
    }

    // MARK: - Apply Configuration
    private func apply(configuration: VTStackedProgressBarCellContentConfiguration) {
        guard currentConfiguration != configuration else { return }
        currentConfiguration = configuration

        // clear views
        rootStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        barsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        legendStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        legendStack.availableWidth = configuration.availableWidth
        
        // title
        if let title = configuration.title {
            titleLabel.text = title
            rootStack.addArrangedSubview(titleLabel)
        }

        // bars
        let barHeight = 8.0
        
        for bar in configuration.bars {
            let horizontalStack = UIStackView()
            horizontalStack.axis = .horizontal
            horizontalStack.spacing = 0
            horizontalStack.distribution = .fill
            horizontalStack.translatesAutoresizingMaskIntoConstraints = false
            horizontalStack.layer.cornerRadius = barHeight/2
            horizontalStack.layer.masksToBounds = true
            
            for segment in bar {
                let segmentView = UIView()
                segmentView.backgroundColor = segment.color
                horizontalStack.addArrangedSubview(segmentView)
                
                let widthConstraint = segmentView.widthAnchor.constraint(
                    equalTo: horizontalStack.widthAnchor,
                    multiplier: max(0.0, min(segment.value, 1.0))
                )
                widthConstraint.isActive = true
            }

            horizontalStack.heightAnchor.constraint(equalToConstant: barHeight).isActive = true
            barsStack.addArrangedSubview(horizontalStack)
        }

        rootStack.addArrangedSubview(barsStack)

        // legend
        if let legend = configuration.legend, !legend.isEmpty {
            legendStack.arrangedSubviews = legend.map { makeLegendEntry($0) }
            rootStack.addArrangedSubview(legendStack)
        }
    }

    private func makeLegendEntry(_ entry: VTStackedProgressBarLegendEntry) -> UIView {
        let dot = UIView()
        dot.backgroundColor = entry.color
        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.layer.cornerRadius = 5
        dot.widthAnchor.constraint(equalToConstant: 10).isActive = true
        dot.heightAnchor.constraint(equalToConstant: 10).isActive = true

        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption2)
        label.textColor = .secondaryLabel
        label.text = entry.text

        let stack = UIStackView(arrangedSubviews: [dot, label])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 6
        return stack
    }
}
