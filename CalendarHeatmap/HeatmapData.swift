//
//  HeatmapData.swift
//  CalendarHeatmap_Example
//
//  Created by Venkateswara Rao Meda on 10/05/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//
import UIKit

struct HeatmapData {
  
    let config: HeatmapConfig
    let items: [Item]
    private var columnCountInSection: Int = 0

    init(config: HeatmapConfig, items: [Item]) {
        self.config = config
        self.items = items
    }
    
    func getNumberofDays() -> Int {
        return getSetofDates().count
    }
    
    func getEventTypeForTime(date: DateComponents, time: String) -> (EventColors, FillStatus) {
        let models = getStartAndEndModels().filter({$0.startDate.day == date.day})
        for model in models {
            let colorFilling = EventColors.evetColor(event: model.eventType)
            let sHour = model.startDate.hour ?? -1
            let sMint = model.startDate.minute ?? -1
            let eHour = model.endDate.hour ?? -1
            let eMint = model.endDate.minute ?? -1
            let matchTime = Int(time) ?? -1
           
            if sHour <= matchTime && eHour >= matchTime {
                if eHour == matchTime && eMint > 0 {
                    return (colorFilling, .partial)
                } else if eHour > matchTime {
                    return (colorFilling, .full)
                }
            }
        }
        return (EventColors.others, .none)
    }
    
    private func getStartAndEndModels() -> [SampleModel] {
        var dataModel: [SampleModel] = []
        for item in items {
            if let dateTimeFromServer = item.start?.dateTime {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

                let timeZone = TimeZone(identifier: item.start?.timeZone ?? "")
                dateFormatter.timeZone = timeZone
                let dateFormatted = dateFormatter.date(from:dateTimeFromServer)!
                
                var calendar = Calendar.current
                calendar.timeZone = timeZone!
                
                let startDate = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: dateFormatted)
                
                if let dateTimeFromServer = item.end?.dateTime {
                    let dateFormatted = dateFormatter.date(from:dateTimeFromServer)!
                    
                    let endDate = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: dateFormatted)
                    let model = SampleModel(startDate: startDate, endDate: endDate, eventType: item.eventType ?? "")
                    dataModel.append(model)
                }
            }
            
        }
        return dataModel
    }
    
    struct SampleModel {
        var startDate: DateComponents
        var endDate: DateComponents
        var eventType: String
    }
    
    private func getSetofDates() -> [DateComponents] {
        var days: Set<DateComponents> = []
        for item in items {
            if let dateTimeFromServer = item.start?.dateTime {
                let dateFormatter = ISO8601DateFormatter()
                let dateFormatted = dateFormatter.date(from:dateTimeFromServer)!
                
                let date = Calendar.current.dateComponents([.year, .month, .day], from: dateFormatted)
                days.insert(date)
            }
        }
        
        let sortedList = days.sorted(by: {
            Calendar.current.date(from: $0) ?? Date.distantFuture <
                Calendar.current.date(from: $1) ?? Date.distantFuture
        })
        return sortedList
    }
    func getWeeksName() -> [String] {
        var dates: Set<Date> = []
        for item in items {
            if let dateTimeFromServer = item.start?.dateTime {
                let dateFormatter = ISO8601DateFormatter()
                let dateFormatted = dateFormatter.date(from:dateTimeFromServer)!
                dates.insert(dateFormatted)
            }
        }
        let sortedDates = dates.sorted(by: {
            $0.compare($1) == .orderedAscending
        })
        return sortedDates.map({
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE"
            let weekDay = formatter.string(from: $0).capitalized
            return weekDay
        }).removeDuplicates()
    }
    //Returns Cell date and time
    func itemAt(indexPath: IndexPath) -> (DateComponents, String) {
        let totalSections = getWeeksName().count
        let sectionIndex = indexPath.row % (totalSections)
        let date = getSetofDates()[sectionIndex]
        let timeIndex = indexPath.row/(totalSections)
        let time = config.headerItems[timeIndex]
        return (date, time)
    }
    
    // MARK: setup header related functions
    private func calculateHeaderWidth(_ itemCount: Int, _ columnCount: Int) -> CGFloat {
        // based on the current item position.
        // if the current item is the first on in column, it belongs to the next month
        // otherwirs, it belongs to this month
        let sectionColumnCount = itemCount == 1 ? (columnCount - 1) : columnCount
        return CGFloat(sectionColumnCount) * (config.itemSide + config.lineSpacing)
    }
}
extension Array where Element:Equatable {
    func removeDuplicates() -> [Element] {
        var result = [Element]()

        for value in self {
            if result.contains(value) == false {
                result.append(value)
            }
        }

        return result
    }
}
