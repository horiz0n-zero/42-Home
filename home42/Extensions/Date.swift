//
//  Date.swift
//  home42
//
//  Created by Antoine Feuerstein on 13/04/2021.
//

import Foundation
import UIKit
import SwiftDate

extension Date {
    
    static private let formatterIntraApi: DateFormatter = {
        let formatter = DateFormatter()
        
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return formatter
    }()
    static private let formatterIntraNetApi: DateFormatter = {
        let formatter = DateFormatter()
        
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter
    }()
    
    static func fromIntraFormat(_ format: String) -> Date {
        return Date.formatterIntraApi.date(from: format) ?? Date()
    }
    static func fromIntraNetFormat(_ format: String) -> Date {
        return Date.formatterIntraNetApi.date(from: format) ?? Date()
    }
    
    static let dayKeys: [String] = ["DIMANCHE", "LUNDI", "MARDI", "MERCREDI", "JEUDI", "VENDREDI", "SAMEDI"]
    static let monthsKeys: [String] = ["JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE", "JULY", "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER"]
    
    static let apiMonths: [String] = ["january", "february", "march", "april", "may", "june", "july", "august", "september", "october", "november", "december"]
    
    func nextDays(_ numberOfDay: Int = 7) -> [Date] {
        let now = Date()
        var days: [Date] = [now]
        
        days.reserveCapacity(numberOfDay)
        for index in 1 ..< numberOfDay {
            days.append(now.dateByAdding(index, .day).date)
        }
        return days
    }
    
    static private let diffTimeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        
        formatter.allowedUnits = [.hour, .day, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter
    }()
    
    func toStringDiffTime(to: Date) -> String {
        return Date.diffTimeFormatter.string(from: self, to: to)!
    }
    
    func newDiffTime(to toDate: Date) -> String {
        let text =  DateInRegion.init(self, region: Region.local).timeIntervalSince(DateInRegion.init(toDate, region: Region.local)).toString {
            $0.unitsStyle = .positional
            $0.collapsesLargestUnit = false
            $0.allowsFractionalUnits = true
        }
        
        if self > toDate {
            return ~"DIFFTIME_WILL" + text
        }
        else {
            return ~"DIFFTIME_BEFORE" + text
        }
    }
    
}

extension DateToStringStyles {
    
    static let fullReadable: DateToStringStyles = .custom("EEEE dd MMM HH:mm:ss")
    static let eventDetails: DateToStringStyles = .custom("EEEE dd HH:mm")
    static let historicSmall: DateToStringStyles = .custom("EEEE dd MMMM HH:mm")
    static let historicWithYear: DateToStringStyles = .custom("EEEE dd MMM yyyy HH:mm")
    static let comprehensive: DateToStringStyles = .custom("dd/MM/yyyy HH:mm")
    static let comprehensiveShort: DateToStringStyles = .custom("dd/MM/yyyy")
}

extension Array where Element == Date {
    
    var dayKeys: [String] {
        return self.map({ Date.dayKeys[$0.weekday - 1] })
    }
}
