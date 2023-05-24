//
//  HeatmapCollectionViewCell.swift
//  CalendarHeatmap_Example
//
//  Created by Venkateswara Rao Meda on 10/05/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit

class HeatmapCollectionViewCell: UICollectionViewCell {
    
    var config: HeatmapConfig! {
        didSet {
            backgroundColor = config.backgroundColor
        }
    }
    
    var itemColor: UIColor = .clear {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override var isSelected: Bool {
        didSet {
            setNeedsDisplay()
        }
    }
    var selectedTime: String?
    
    var selectedDate: DateComponents?

    override func draw(_ rect: CGRect) {
        let cornerRadius = config.itemCornerRadius
        let maxCornerRadius = min(bounds.width, bounds.height) * 0.5
        let path = UIBezierPath(roundedRect: rect, cornerRadius: min(cornerRadius, maxCornerRadius))
        itemColor.setFill()
        path.fill()
        guard isSelected, config.allowItemSelection else { return }
        config.selectedItemBorderColor.setStroke()
        path.lineWidth = config.selectedItemBorderLineWidth
        path.stroke()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

extension UIView {
    func applyGradient(colours: [UIColor]) -> Void {
         let gradient: CAGradientLayer = CAGradientLayer()
         gradient.frame = self.bounds
         gradient.colors = colours.map { $0.cgColor }
         gradient.startPoint = CGPoint(x : 0.0, y : 0.5)
         gradient.endPoint = CGPoint(x :1.0, y: 0.5)
         self.layer.insertSublayer(gradient, at: 0)
     }
}
