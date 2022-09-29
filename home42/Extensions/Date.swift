// home42/Date.swift
/* +++++++++++++++++++++++++++++++++++++++++++++++++++ *
+
+      :::       ::::::::
+     :+:       :+:    :+:
+    +:+   +:+        +:+
+   +#+   +:+       +#+
+  +#+#+#+#+#+    +#+
+       #+#     #+#
+      ###    ######## H O M E
+
+   Copyright Antoine Feuerstein. All rights reserved.
+
* ++++++++++++++++++++++++++++++++++++++++++++++++++++ */

import Foundation
import UIKit
import SwiftDate

extension Date {
    
    static private let formatterIntraApi: DateFormatter = {
        let formatter = DateFormatter()
        
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter
    }()
    static private let formatterIntraNetApi: DateFormatter = {
        let formatter = DateFormatter()
        
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter
    }()
    static private let formatterIntraNetCookie: DateFormatter = {
        let formatter = DateFormatter()
        
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        return formatter
    }()
    
    static func fromIntraFormat(_ format: String) -> Date {
        return Date.formatterIntraApi.date(from: format) ?? Date()
    }
    static func fromIntraNetFormat(_ format: String) -> Date {
        return Date.formatterIntraNetApi.date(from: format) ?? Date()
    }
    static func fromIntraNetCookie(_ format: String) -> Date {
        return Date.formatterIntraNetCookie.date(from: format) ?? Date()
    }
    
    static let dayKeys: [String] = ["date.sunday", "date.monday", "date.tuesday", "date.wednesday", "date.thursday", "date.friday", "date.saturday"]
    static let monthsKeys: [String] = ["date.january", "date.february", "date.march", "date.april", "date.may", "date.june", "date.july", "date.august", "date.september", "date.october", "date.november", "date.december"]
    
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
        let diff = DateInRegion(toDate).timeIntervalSince(DateInRegion(self))
        let date = Date() - diff
        
        return date.toRelative(style: RelativeFormatter.timeStyle())
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
