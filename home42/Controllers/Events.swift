// home42/Events.swift
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

final class EventsViewController: HomeViewController {
    
    private let tableView: EventInfiniteRequestTableView
    
    required init() {
        let parameters: [String: Any] = ["filter[future]":true, "sort":"begin_at"]
        
        if let cursus = App.userCursus {
            self.tableView = .init(.campusWithCampusIdCursusWithCursusIdEvents(App.userCampus.campus_id, cursus.cursus_id), parameters: parameters, pageSize: 30)
        }
        else {
            self.tableView = .init(.campusWithCampusIdEvents(App.userCampus.campus_id), parameters: parameters, pageSize: 30)
        }
        super.init()
        self.view.addSubview(self.tableView)
        self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.tableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        self.tableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.tableView.contentInsetAdjustTopAndBottom()
        self.tableView.backgroundColor = .clear
        self.tableView.block = self.eventSelected(_:)
        Task.init(priority: .userInitiated, operation: {
            await self.tableView.nextPage()
        })
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    @MainActor override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if App.userLoggedIn { // FIXME: - app can crash if user disconnect when call like this start
            Task.init(priority: .userInitiated, operation: {
                do {
                    try await self.tableView.userEvents = EventsViewController.refreshUserEvents()
                    self.tableView.restart(with: self.tableView.parameters)
                }
                catch {
                    DynamicAlert.presentWith(error: error as! HomeApi.RequestError)
                }
            })
        }
    }
    
    static func refreshUserEvents() async throws -> ContiguousArray<IntraUserEvent> { // get userEvents for synchro when not going to profil
        let today = Date()
        var events: ContiguousArray<IntraUserEvent> = try await HomeApi.get(.usersWithUserIdEventsUsers(App.user.id),
                                                                            params: ["sort":"-created_at", "page[size]": 30])
        
        events.removeAll { event in
            return event.event.beginDate < today
        }
        events.sort { e1, e2 in
            return e1.event.beginDate < e2.event.beginDate
        }
        HomeDefaults.save(events, forKey: .userEvents)
        return events
    }
    
    private func eventSelected(_ event: IntraEvent) {
        var actions: [DynamicAlert.Action] = [.normal(~"general.ok", nil)]
        let userSubscribed: IntraUserEvent? = self.tableView.userEvents.first(where: { $0.event_id == event.id })
        
        @Sendable @MainActor func register() async {
            do {
                let response: IntraUserEvent = try await HomeApi.post(.eventsUsers, params: ["events_user[event_id]": event.id, "events_user[user_id]": App.user.id])
                
                self.tableView.userEvents.append(response)
                HomeDefaults.save(self.tableView.userEvents, forKey: .userEvents)
                if let index = self.tableView.elements.firstIndex(of: event) {
                    self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                }
            }
            catch {
                DynamicAlert.presentWith(error: error as! HomeApi.RequestError)
            }
        }
        @Sendable @MainActor func unregister(userEvent: IntraUserEvent) async {
            do {
                let _: Int = try await HomeApi.delete(.eventsUsersWithId(userEvent.id))
                
                if let index = self.tableView.userEvents.firstIndex(of: userEvent) {
                    self.tableView.userEvents.remove(at: index)
                    HomeDefaults.save(self.tableView.userEvents, forKey: .userEvents)
                }
                if let index = self.tableView.elements.firstIndex(of: event) {
                    self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                }
            }
            catch {
                DynamicAlert.presentWith(error: error as! HomeApi.RequestError)
            }
        }
        
        if let userEvent = userSubscribed {
            // check cannot unsubscribe !
            actions.append(.highligth(~"event.action.unregister", {
                Task.init(priority: .userInitiated, operation: { await unregister(userEvent: userEvent) })
            }))
        }
        else if event.canSubscribe {
            // warn unsubscribe impossible ?
            if App.settings.eventsWarnSubscription {
                // 
            }
            actions.append(.highligth(~"event.action.register", {
                Task.init(priority: .userInitiated, operation: { await register() })
            }))
        }
        DynamicAlert.init(.event(event), contents: [.text(event.eventDescription)], actions: actions)
    }

    // MARK: - EventInfiniteRequestTableView
    final class EventInfiniteRequestTableView: GenericSingleInfiniteRequestTableView<EventTableViewCell, IntraEvent> {
        
        var userEvents: ContiguousArray<IntraUserEvent>

        override init(_ route: HomeApi.Routes, parameters: [String : Any]? = nil, page: Int = 1, pageSize: Int = 100, blurAntenne: Bool = false) {
            let userEvents: ContiguousArray<IntraUserEvent> = HomeDefaults.read(.userEvents) ?? []
            
            self.userEvents = userEvents.filter({ $0.event.beginDate >= Date() })
            super.init(route, parameters: parameters, page: page, pageSize: pageSize, blurAntenne: blurAntenne)
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            let event: IntraEvent
            
            if let eventCell = cell as? EventTableViewCell {
                event = self.elements[indexPath.row]
                eventCell.fill(with: event, userSubcribed: self.userEvents.contains(where: { $0.event_id == event.id }))
            }
            return cell
        }
    }
    
    // MARK: - EventTableViewCell
    final class EventTableViewCell: BasicUITableViewCell, GenericSingleInfiniteRequestCell {
        
        private let borderView: BasicUIView
        private let titleView: BasicUILabel
        private let dateSquareContainer: BasicUIView
        private let dateSquare: BasicUILabel
        private let peopleCurvedLabel: EventPeopleCurvedView
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            self.borderView = BasicUIView()
            self.titleView = BasicUILabel(text: "???")
            self.titleView.font = HomeLayout.fontSemiBoldMedium
            self.titleView.textColor = HomeDesign.black
            self.titleView.textAlignment = .left
            self.titleView.numberOfLines = 2
            self.dateSquareContainer = BasicUIView()
            self.dateSquare = BasicUILabel(text: "???")
            self.dateSquare.font = HomeLayout.fontBoldMedium
            self.dateSquare.textColor = HomeDesign.white
            self.dateSquare.textAlignment = .center
            self.dateSquare.adjustsFontSizeToFitWidth = true
            self.dateSquare.numberOfLines = 0
            self.peopleCurvedLabel = EventPeopleCurvedView(text: "???", primaryColor: HomeDesign.primary, secondaryColor: HomeDesign.white)
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            self.backgroundColor = .clear
            self.borderView.layer.cornerRadius = HomeLayout.scorner
            self.borderView.layer.borderWidth = HomeLayout.border
            self.borderView.layer.masksToBounds = true
            self.borderView.backgroundColor = HomeDesign.white
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }
            self.contentView.addSubview(self.borderView)
            self.borderView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: HomeLayout.margin).isActive = true
            self.borderView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -HomeLayout.margin).isActive = true
            self.borderView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: HomeLayout.smargin).isActive = true
            self.borderView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -HomeLayout.smargin).isActive = true
            self.borderView.heightAnchor.constraint(equalToConstant: HomeLayout.eventViewHeigth).isActive = true
            
            self.borderView.addSubview(self.dateSquareContainer)
            self.dateSquareContainer.widthAnchor.constraint(equalTo: self.dateSquareContainer.heightAnchor).isActive = true
            self.dateSquareContainer.topAnchor.constraint(equalTo: self.borderView.topAnchor).isActive = true
            self.dateSquareContainer.leadingAnchor.constraint(equalTo: self.borderView.leadingAnchor).isActive = true
            self.dateSquareContainer.bottomAnchor.constraint(equalTo: self.borderView.bottomAnchor).isActive = true
            self.dateSquareContainer.addSubview(self.dateSquare)
            self.dateSquare.widthAnchor.constraint(equalTo: self.dateSquare.heightAnchor).isActive = true
            self.dateSquare.topAnchor.constraint(equalTo: self.dateSquareContainer.topAnchor, constant: HomeLayout.smargin).isActive = true
            self.dateSquare.leadingAnchor.constraint(equalTo: self.dateSquareContainer.leadingAnchor, constant: HomeLayout.smargin).isActive = true
            self.dateSquare.bottomAnchor.constraint(equalTo: self.dateSquareContainer.bottomAnchor, constant: -HomeLayout.smargin).isActive = true
        
            self.borderView.addSubview(self.titleView)
            self.titleView.leadingAnchor.constraint(equalTo: self.dateSquareContainer.trailingAnchor, constant: HomeLayout.smargin).isActive = true
            self.titleView.trailingAnchor.constraint(equalTo: self.borderView.trailingAnchor, constant: -HomeLayout.smargin).isActive = true
            self.titleView.topAnchor.constraint(equalTo: self.borderView.topAnchor, constant: HomeLayout.smargin).isActive = true
            
            self.borderView.addSubview(self.peopleCurvedLabel)
            self.peopleCurvedLabel.trailingAnchor.constraint(equalTo: self.borderView.trailingAnchor).isActive = true
            self.peopleCurvedLabel.bottomAnchor.constraint(equalTo: self.borderView.bottomAnchor).isActive = true
            self.peopleCurvedLabel.leadingAnchor.constraint(equalTo: self.dateSquare.trailingAnchor).isActive = true
        }
        
        func fill(with event: IntraEvent, userSubcribed: Bool) {
            let peopleText: String
            
            if event.max_people != nil {
                if userSubcribed {
                    peopleText = ~"event.state.registered" + " \(event.nbr_subscribers) / \(event.max_people!)"
                }
                else if event.max_people == event.nbr_subscribers {
                    peopleText = ~"event.state.full" + " \(event.nbr_subscribers) / \(event.max_people!)"
                }
                else {
                    peopleText = "\(event.nbr_subscribers) / \(event.max_people!)"
                }
            }
            else {
                if userSubcribed {
                    peopleText = ~"event.state.registered" + " \(event.nbr_subscribers)"
                }
                else {
                    peopleText = "\(event.nbr_subscribers)"
                }
            }
            self.peopleCurvedLabel.update(with: peopleText.uppercased(), primaryColor: event.uicolor, secondaryColor: HomeDesign.white)
        }
        
        func fill(with element: IntraEvent) {
            self.borderView.layer.borderColor = element.uicolor.cgColor
            self.titleView.text = element.name
            self.dateSquareContainer.backgroundColor = element.uicolor
            self.dateSquare.text = element.beginDate.toString(.custom("EEEE\nd\nMMMM"))
        }
    }
}
