//
//  RowView.swift
//  CalendarHeatmap_Example
//
//  Created by Venkateswara Rao Meda on 10/05/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit

class RowView: UIView {
    
    fileprivate func createRowStack(_ config: HeatmapConfig) {
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.distribution = .equalCentering
        stackView.spacing = config.interitemSpacing
        stackView.backgroundColor = config.backgroundColor
        
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: config.headerHeight),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
        for index in 0...config.rowItems.count-1 {
            let label = UILabel()
            label.text = config.rowItems[index]
            label.textColor = config.rowColor
            label.textAlignment = .center
            label.font = config.rowFont
            label.backgroundColor = config.backgroundColor
            label.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(label)
        }
    }
    
    init(config: HeatmapConfig) {
        super.init(frame: .zero)
        backgroundColor = config.backgroundColor
        createRowStack(config)
    }
    
    required init?(coder: NSCoder) {
        fatalError("no storyboard implementation, should not enter here")
    }
}
