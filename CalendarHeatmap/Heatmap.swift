//
//  Heatmap.swift
//  CalendarHeatmap_Example
//
//  Created by Venkateswara Rao Meda on 10/05/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit

protocol HeatmapDelegate: AnyObject {
    func colorFor(eventColors: EventColors) -> UIColor
    func didSelectedAt(dateComponents: DateComponents, time: String)
    func finishLoadCalendar()
}
enum EventColors: String {
    case busy = "busy"
    case meeting = "meeting"
    case outOIOffice = "outOIOffice"
    case others = "others"
    
    static func evetColor(event: String) -> EventColors {
        if EventColors.busy.rawValue.caseInsensitiveCompare(event) == .orderedSame {
            return .busy
        } else if EventColors.meeting.rawValue.caseInsensitiveCompare(event) == .orderedSame {
            return .meeting
        } else if EventColors.outOIOffice.rawValue.caseInsensitiveCompare(event) == .orderedSame {
            return .outOIOffice
        } else {
            return .others
        }
    }
    
}

enum FillStatus {
    case full
    case partial
    case none
    
}
class Heatmap: UIView {
    
    // MARK: ui components
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        cv.delegate = self
        cv.dataSource = self
        cv.register(HeatmapCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        cv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: config.contentRightInset)
        cv.showsHorizontalScrollIndicator = false
        cv.showsVerticalScrollIndicator = false
        cv.layer.masksToBounds = false
        cv.backgroundColor = .clear
        return cv
    }()
    
    private lazy var flowLayout: UICollectionViewFlowLayout = {
        let flow = UICollectionViewFlowLayout()
        flow.scrollDirection = .horizontal
        flow.itemSize = CGSize(width: config.itemSide, height: config.itemSide)
        flow.sectionInset = UIEdgeInsets(top: config.headerHeight, left: 0, bottom: 0, right: config.lineSpacing)
        flow.minimumLineSpacing = config.lineSpacing
        flow.minimumInteritemSpacing = config.interitemSpacing
        return flow
    }()
    
    private lazy var rowView: RowView = {
        config.rowItems = heatmapData?.getWeeksName() ?? []
        let row = RowView(config: config)
        return RowView(config: config)
    }()
    
    private lazy var headerView: HeaderView = {
        return HeaderView(config: config)
    }()
    
    private let cellIdentifier = "HeatmapCell"
    private var config: HeatmapConfig
    
    private var heatmapData: HeatmapData?
    
    open weak var delegate: HeatmapDelegate?
    let items: [Item]

    init(config: HeatmapConfig = HeatmapConfig(), items: [Item]) {
        self.config = config
        self.items = items
        super.init(frame: .zero)
        self.heatmapData = HeatmapData(config: self.config, items: self.items)
        render()
        setup()

    }
    
    func reload() {
        DispatchQueue.main.async {
            [weak self] in
            self?.collectionView.reloadData()

        }
    }
    
    func reload(newStartDate: Date?, newEndDate: Date?) {
//        guard newStartDate != nil || newEndDate != nil else {
//            reload()
//            return
//        }
//        startDate = newStartDate ?? startDate
//        endDate = newEndDate ?? endDate
        setup()
    }
    
//    func scrollTo(date: Date, at: UICollectionView.ScrollPosition, animated: Bool) {
//        let difference = Date.daysBetween(start: startDate, end: date)
//        collectionView.scrollToItem(at: IndexPath(item: difference - 1, section: 0), at: at, animated: animated)
//    }
    
    private func setup() {
        backgroundColor = config.backgroundColor
        DispatchQueue.global(qos: .userInteractive).async {
            // calculate calendar date in background
            self.headerView.build(headers: self.heatmapData!.config.headerItems)
            DispatchQueue.main.async { [weak self] in
                // then reload
                self?.collectionView.reloadData()
                self?.delegate?.finishLoadCalendar()
            }
        }
    }
    
    private func render() {
        clipsToBounds = true
        
        addSubview(collectionView)
        addSubview(rowView)
        collectionView.addSubview(headerView)
        collectionView.bringSubviewToFront(headerView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        rowView.translatesAutoresizingMaskIntoConstraints = false
        headerView.translatesAutoresizingMaskIntoConstraints = false
        let itemSideHeight = Int(config.itemSide) * (heatmapData?.getNumberofDays() ?? 0)
        let spaceBetweenHeight = Int(config.interitemSpacing) * 2 * (heatmapData?.getNumberofDays() ?? 0)
        let heightForCollection =  (itemSideHeight + spaceBetweenHeight + Int(config.headerHeight))
        NSLayoutConstraint.activate([
            rowView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            rowView.topAnchor.constraint(equalTo: self.topAnchor),
            rowView.widthAnchor.constraint(equalToConstant: config.rowWidth),
            rowView.heightAnchor.constraint(equalToConstant: CGFloat(heightForCollection)),

            collectionView.topAnchor.constraint(equalTo: self.topAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: CGFloat(heightForCollection)),
            collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            collectionView.leadingAnchor.constraint(equalTo: rowView.trailingAnchor),
            headerView.topAnchor.constraint(equalTo: collectionView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: config.headerHeight)
        ])
        let bottomConstraint = collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        bottomConstraint.priority = .defaultLow
        bottomConstraint.isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("no storyboard implementation, should not enter here")
    }
}

extension Heatmap: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (heatmapData?.config.headerItems.count ?? 0)*(heatmapData?.getNumberofDays() ?? 0)
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! HeatmapCollectionViewCell
        cell.config = config
        if let date = heatmapData?.itemAt(indexPath: indexPath) {
            cell.selectedDate = date.0
            cell.selectedTime = date.1
            let item = heatmapData?.getEventTypeForTime(date: date.0, time: date.1)
            let itemColor = delegate?.colorFor(eventColors: item?.0 ?? .others)
            cell.itemColor = itemColor ?? .white
//            if item?.1 == FillStatus.partial {
//                cell.applyGradient(colours: [itemColor ?? .white, .white])
//            }

        } else {
            cell.itemColor = .white
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let date = heatmapData?.itemAt(indexPath: indexPath) else { return }
        delegate?.didSelectedAt(dateComponents: date.0, time: date.1)
    }
}
