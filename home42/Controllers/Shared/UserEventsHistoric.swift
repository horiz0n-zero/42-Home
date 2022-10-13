// home42/UserEventsHistoric.swift
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

final class UserEventsHistoricViewController: HomeViewController, UserSearchFieldViewDelegate {
    
    private let header: HeaderWithActionsView
    private let userSearchFieldView: UserSearchFieldView
    private let tableView: EventsViewController.EventInfiniteRequestTableView
    
    private unowned(unsafe) let primary: UIColor
    
    init(user: IntraUser, primary: UIColor) {
        self.header = HeaderWithActionsView(title: ~"title.events", actions: nil)
        self.userSearchFieldView = UserSearchFieldView(user: .init(id: user.id, login: user.login, image: user.image), primary: primary)
        self.tableView = .init(.usersWithUserIdEvents(App.user.id), parameters: ["sort":"-created_at"], page: 1, pageSize: 100)
        self.primary = primary
        super.init()
        self.view.backgroundColor = HomeDesign.white
        self.view.addSubview(self.header)
        self.header.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.header.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.header.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.userSearchFieldView)
        self.userSearchFieldView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: HomeLayout.margin).isActive = true
        self.userSearchFieldView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -HomeLayout.margin).isActive = true
        self.userSearchFieldView.topAnchor.constraint(equalTo: self.header.bottomAnchor, constant: HomeLayout.margin).isActive = true
        self.userSearchFieldView.delegate = self
        self.tableView.topAnchor.constraint(equalTo: self.userSearchFieldView.centerYAnchor).isActive = true
        self.tableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        self.tableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.tableView.contentInsetAdjustTopConstant(HomeLayout.roundedGenericActionsViewRadius + HomeLayout.margin)
        self.tableView.block = self.eventSelected(_:)
        self.tableView.nextPage()
    }
    required init() { fatalError("init() has not been implemented") }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func eventSelected(_ event: IntraEvent) {
        DynamicAlert.init(.event(event), contents: [.text(event.eventDescription)], actions: [.normal(~"general.ok", nil)])
    }
    
    func userSearchFieldViewSelect(view: UserSearchFieldView, user: IntraUserInfo) {
        self.tableView.route = .usersWithUserIdEvents(user.id)
        self.tableView.reset()
        self.tableView.nextPage()
    }
}
