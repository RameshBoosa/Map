//
//  ViewController.swift
//  CalendarHeatmap
//
//  Created by Zacharysp on 03/02/2020.
//  Copyright (c) 2020 Zacharysp. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    lazy var itemDetails: ItemDetails = {
        loadHeatMapData()
    }()
    
    lazy var heatMap: Heatmap = {
        var config = HeatmapConfig()
        config.backgroundColor = .gray
        // config item
        config.selectedItemBorderColor = .white
        config.allowItemSelection = true
        // config month header
        config.headerHeight = 30
        config.headerFont = UIFont.systemFont(ofSize: 18)
        config.headerColor = UIColor(named: "text")!
        // config weekday label on left
        config.rowFont = UIFont.systemFont(ofSize: 12)
        config.rowWidth = 30
        config.rowColor = UIColor(named: "text")!
        
        let heatmap = Heatmap(config: config, items: itemDetails.items ?? [])
        heatmap.delegate = self
        return heatmap
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray
        
        view.addSubview(heatMap)
        heatMap.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            heatMap.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 10),
            heatMap.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 10),
            heatMap.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 300),
//            heatMap.heightAnchor.constraint(equalToConstant: 500)
        ])
    }
    
    func loadHeatMapData() -> ItemDetails {
        if let path = Bundle.main.path(forResource: "data", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: [])
                let decoder = JSONDecoder()
                let modelData = try decoder.decode(ItemDetails.self, from: data)
                return modelData
              } catch let error {
                  print("parse error: \(error.localizedDescription)")
                
              }
        }
        return ItemDetails.init(items: [])
    }
    
//    private func readHeatmap() -> [String: Int]? {
//        guard let url = Bundle.main.url(forResource: "heatmap", withExtension: "plist") else { return nil }
//        return NSDictionary(contentsOf: url) as? [String: Int]
//    }
    
}

extension ViewController: HeatmapDelegate {
    func colorFor(eventColors: EventColors) -> UIColor {
        switch eventColors {
        case .busy:
            return .red
        case .meeting:
            return .green
        case .outOIOffice:
            return .cyan
        case .others:
            return .white
        }
    }
    
    
    func didSelectedAt(dateComponents: DateComponents, time: String) {
        guard let year = dateComponents.year,
            let month = dateComponents.month,
            let day = dateComponents.day else { return }
        // do something here
        print(year, month, day)
        print("Timme: \(time)")
    }
    
    func finishLoadCalendar() {
//        heatMap.scrollTo(date: Date(2023, 5, 12), at: .right, animated: false)
    }
}

extension Date {
    init(_ year:Int, _ month: Int, _ day: Int) {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        self.init(timeInterval:0, since: Calendar.current.date(from: dateComponents)!)
    }
}
