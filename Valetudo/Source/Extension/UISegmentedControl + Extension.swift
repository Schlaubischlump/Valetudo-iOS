//
//  UISegmentedControl + Extension.swift
//  Valetudo
//
//  Created by David Klopp on 08.06.25.
//
import UIKit

class RoundedSegmentedControl: UISegmentedControl {
    let segmentInset: CGFloat = 5
            
    override var selectedSegmentTintColor: UIColor? {
        didSet {
            applyCornerRadius()
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    init() {
        super.init(frame: .zero)
        
        // remove the divider images
        setDividerImage(
            UIImage(),
            forLeftSegmentState: .normal,
            rightSegmentState: .normal,
            barMetrics: .default
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        applyCornerRadius()
    }
    
    func applyCornerRadius() {
        layer.masksToBounds = true
        layer.cornerRadius = bounds.height * 0.5
                
        guard selectedSegmentIndex > -1,
              subviews.indices.contains(numberOfSegments),
              let foregroundImageView = subviews[numberOfSegments] as? UIImageView
        else {
            return
        }
                
        foregroundImageView.bounds = foregroundImageView.bounds.insetBy(dx: segmentInset, dy: segmentInset)
        foregroundImageView.image = UIImage(color: selectedSegmentTintColor ?? .gray)
        foregroundImageView.layer.removeAnimation(forKey: "SelectionBounds")
        foregroundImageView.layer.masksToBounds = true
        foregroundImageView.layer.cornerRadius = foregroundImageView.bounds.height * 0.5
    }
}
