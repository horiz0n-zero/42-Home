// home42/CalendarView.swift
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

protocol CalendarDaysViewDelegate: AnyObject {
    
    func calendarDaysViewSelect(dayView: CalendarDaysView.DayView, date: Date)
    func calendarDaysViewSwipeLeft()
    func calendarDaysViewSwipeRight()
    func calendarDaysViewUpdated(dayView: CalendarDaysView.DayView, newDate: Date)
}

final class CalendarDaysView: BasicUIView {
    
    static let rowCount: Int = 6
    static let columnCount: Int = 7
    static private let count = CalendarDaysView.rowCount * CalendarDaysView.columnCount
    
    private(set) var date: Date
    var dateMonthText: String {
        return self.date.dateAtStartOf(.month).toString(.custom("MMMM yyyy"))
    }
    var primary: UIColor
    private(set) var daysView: ContiguousArray<DayView>
    
    weak var delegate: CalendarDaysViewDelegate? = nil
    
    init(date: Date, primary: UIColor) {
        let left: UISwipeGestureRecognizer
        let right: UISwipeGestureRecognizer
        
        self.date = date.dateAt(.startOfMonth)
        self.primary = primary
        self.daysView = []
        self.daysView.reserveCapacity(Self.count)
        for _ in 0 ..< Self.count {
            self.daysView.append(DayView())
        }
        super.init()
        self.isUserInteractionEnabled = true
        left = UISwipeGestureRecognizer(target: self, action: #selector(CalendarDaysView.swipeLeft(sender:)))
        left.direction = .left
        self.addGestureRecognizer(left)
        right = UISwipeGestureRecognizer(target: self, action: #selector(CalendarDaysView.swipeRight(sender:)))
        right.direction = .right
        self.addGestureRecognizer(right)
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CalendarDaysView.tapGesture(sender:))))
        print("CalendarDaysView", #function, self.date.toString(.comprehensive))
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    @objc private func swipeLeft(sender: UISwipeGestureRecognizer) {
        self.delegate?.calendarDaysViewSwipeLeft()
    }
    
    @objc private func swipeRight(sender: UISwipeGestureRecognizer) {
        self.delegate?.calendarDaysViewSwipeRight()
    }
    
    @objc private func tapGesture(sender: UITapGestureRecognizer) {
        guard let delegate = self.delegate else {
            return
        }
        let location = sender.location(in: self)
        
        for view in self.daysView where view.isVisible {
            if view.frame.contains(location) {
                delegate.calendarDaysViewSelect(dayView: view, date: self.dayViewDate(view).dateAt(.startOfDay))
            }
        }
    }
    
    func addMonth() {
        self.date = self.date.dateAt(.nextMonth)
        self.configure()
    }
    
    func removeMonth() {
        self.date = self.date.dateAt(.prevMonth)
        self.configure()
    }
    
    func setNewDate(_ date: Date) {
        self.date = date.dateAt(.startOfMonth)
        self.configure()
    }
    
    private func configure() {
        var index: Int = 0
        let startDay = self.date.dateAtStartOf(.month)
        var offset: Int = startDay.weekday - 2
        let count = startDay.monthDays
        
        let lastMonthStartDay = startDay.dateAt(.prevMonth)
        let lastMonthCount = lastMonthStartDay.monthDays
        
        func setDayView(_ view: DayView, text: String) {
            view.alpha = 1.0
            view.label.text = text
            self.delegate?.calendarDaysViewUpdated(dayView: view, newDate: self.dayViewDate(view))
        }
        
        func hideDayView(_ view: DayView, text: String) {
            view.alpha = HomeDesign.alphaLow
            view.label.text = text
            view.resetStyle()
        }
        
        if offset < 0 {
            offset += 7
        }
        while index < CalendarDaysView.count && index < offset {
            hideDayView(self.daysView[index], text: "\(lastMonthCount &- offset &+ index &+ 1)")
            index &+= 1
        }
        while index < CalendarDaysView.count && index - offset < count {
            setDayView(self.daysView[index], text: "\(index &- offset &+ 1)")
            index &+= 1
        }
        while index < CalendarDaysView.count {
            hideDayView(self.daysView[index], text: "\(index &- count &- offset &+ 1)")
            index &+= 1
        }
    }
    
    private func dayViewDate(_ dayView: DayView) -> Date {
        if let value = Int(dayView.label.text!), value > 1 {
            return self.date.dateAt(.startOfMonth) + (value - 1).days
        }
        return self.date.dateAt(.startOfMonth)
    }
    
    func dayViewForDate(_ date: Date) -> DayView? {
        let stringDay: String
        
        if date.year == self.date.year && date.month == self.date.month {
            stringDay = "\(date.day)"
            return self.daysView.first(where: { $0.isVisible && $0.label.text! == stringDay })
        }
        return nil
    }
    
    func enumerateDayViews(_ handler: @escaping (DayView, Date) -> ()) {
        for view in self.daysView where view.isVisible {
            handler(view, self.dayViewDate(view))
        }
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview != nil else { return }
        unowned(unsafe) var dayView: DayView!
        unowned(unsafe) var lastDayView: DayView? = nil
        var top: NSLayoutYAxisAnchor = self.topAnchor
        var index = 0
        let daysText = WeekDay.allDaysShortWeekdaySymbols
        var dayLabel: BasicUILabel!
        unowned(unsafe) var lastDayLabel: BasicUILabel!
        
        func addDayLabel(_ text: String) {
            dayLabel = BasicUILabel(text: text)
            dayLabel.textAlignment = .center
            dayLabel.textColor = HomeDesign.gray
            dayLabel.font = HomeLayout.fontRegularMedium
            self.addSubview(dayLabel)
            dayLabel.topAnchor.constraint(equalTo: top).isActive = true
            dayLabel.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
            if lastDayLabel == nil {
                dayLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            }
            else {
                dayLabel.leadingAnchor.constraint(equalTo: lastDayLabel.trailingAnchor, constant: HomeLayout.smargin).isActive = true
                dayLabel.widthAnchor.constraint(equalTo: lastDayLabel.widthAnchor).isActive = true
            }
            lastDayLabel = dayLabel
        }
        
        for weekDaySymbol in daysText {
            addDayLabel(weekDaySymbol)
        }
        
        top = dayLabel.bottomAnchor
        dayLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        for _ in 0 ..< CalendarDaysView.rowCount {
            for _ in 0 ..< CalendarDaysView.columnCount {
                dayView = self.daysView[index]
                index &+= 1
                self.addSubview(dayView)
                dayView.topAnchor.constraint(equalTo: top, constant: HomeLayout.smargin).isActive = true
                dayView.heightAnchor.constraint(equalTo: dayView.widthAnchor).isActive = true
                if let last = lastDayView {
                    dayView.leadingAnchor.constraint(equalTo: last.trailingAnchor, constant: HomeLayout.smargin).isActive = true
                    dayView.widthAnchor.constraint(equalTo: last.widthAnchor).isActive = true
                }
                else {
                    dayView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
                }
                lastDayView = dayView
            }
            lastDayView!.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            lastDayView = nil
            top = dayView.bottomAnchor
        }
        dayView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.configure()
    }
    
    final class DayView: BasicUIView {
        
        var date: Date {
            return (self.parent() as! CalendarDaysView).dayViewDate(self)
        }
        var isVisible: Bool {
            return self.alpha == 1.0
        }
        
        let label: BasicUILabel
        
        override init() {
            self.label = BasicUILabel(text: "?")
            super.init()
            self.label.textAlignment = .center
            self.layer.masksToBounds = true
            self.layer.cornerRadius = HomeLayout.corner
            self.label.font = HomeLayout.fontSemiBoldNormal
            self.label.textColor = HomeDesign.black
            self.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMinYCorner]
            self.backgroundColor = HomeDesign.lightGray
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else {
                return
            }
            
            self.addSubview(self.label)
            self.label.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            self.label.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            self.label.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            self.label.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        }
        
        func primarySelectedStyle() {
            self.backgroundColor = (self.parent() as! CalendarDaysView).primary
            self.label.textColor = HomeDesign.white
        }
        func resetStyle() {
            self.backgroundColor = HomeDesign.lightGray
            self.label.textColor = HomeDesign.black
        }
    }
}

internal extension WeekDay {
    
    static let allDays: [WeekDay] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
    static var allDaysShortWeekdaySymbols: [String] = {
        return allDays.map({ $0.name(style: .veryShort) })
    }()
}
