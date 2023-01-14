// home42/EventsList.swift
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

final class EventsListViewController: HomeViewController, SearchFieldViewDelegate, AdjustableParametersProviderDelegate {
    
    private let header: HeaderWithActionsBase
    var headerTitle: String {
        set { self.header.title = newValue }
        get { return self.header.title }
    }
    private let searchField: SearchFieldViewWithTimer
    private let settingsButton: ActionButtonView
    private var settings: AdjustableParametersProviderViewController<EventsListViewController>!
    private let tableView: EventsViewController.EventInfiniteRequestTableView
    private let gradientView: GradientView
    
    let primary: UIColor
    
    static let defaultParameters: [String : Any] = [:]
    static let searchParameter: AdjustableParametersProviderViewController<EventsListViewController>.SearchParameter? = .init(title: "field.search-description",
                                                                                                                              keys: [.searchName, .searchDescription, .searchLocation],
                                                                                                                              keysName: ["sort.name", "sort.description", "sort.location"],
                                                                                                                              textGetter: \.searchField.text)
    static let parameters: [AdjustableParametersProviderViewController<EventsListViewController>.Parameter] = [
        .init(key: .sort, source: .eventSort, selectorType: .stringAscDesc(.desc), selectorTitleKey: "field.sort-message", selectorInlineWithNextElement: false, selectorCanSelectNULL: false),
        .init(key: .filterFuture, source: .boolean, selectorType: .boolean, selectorTitleKey: "field.is-future", selectorInlineWithNextElement: true, selectorCanSelectNULL: true),
        .init(key: .filterRemote, source: .boolean, selectorType: .boolean, selectorTitleKey: "field.is-remote", selectorInlineWithNextElement: false, selectorCanSelectNULL: true),
        .init(key: .filterBeginAt, source: .calendar, selectorType: .date, selectorTitleKey: "sort.begin-at", selectorInlineWithNextElement: false, selectorCanSelectNULL: true),
        .init(key: .filterEndAt, source: .calendar, selectorType: .date, selectorTitleKey: "sort.end-at", selectorInlineWithNextElement: false, selectorCanSelectNULL: true)
    ]
    
    required init() {
        self.primary = HomeDesign.primary
        self.header = HeaderWithActionsView(title: ~"title.events")
        self.searchField = SearchFieldViewWithTimer()
        self.searchField.setPrimary(self.primary)
        self.settingsButton = ActionButtonView(asset: .actionSettings, color: self.primary)
        if let cursus = App.userCursus {
            self.tableView = .init(.campusWithCampusIdCursusWithCursusIdEvents(App.userCampus.campus_id, cursus.cursus_id))
        }
        else {
            self.tableView = .init(.campusWithCampusIdEvents(App.userCampus.campus_id))
        }
        self.gradientView = GradientView()
        self.gradientView.startPoint = .init(x: 0.5, y: 0.0)
        self.gradientView.endPoint = .init(x: 0.5, y: 1.0)
        self.gradientView.colors = [HomeDesign.white.cgColor, UIColor.init(white: 1.0, alpha: 0.0).cgColor]
        super.init()
        self.settings = .init(delegate: self, defaultParameters: [:], extra: .eventCampus)
        self.view.backgroundColor = HomeDesign.white
        self.searchField.delegate = self
        self.view.addSubview(self.header)
        self.header.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.header.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.header.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.view.addSubview(self.searchField)
        self.searchField.topAnchor.constraint(equalTo: self.header.bottomAnchor, constant: HomeLayout.margin).isActive = true
        self.searchField.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: HomeLayout.margin).isActive = true
        self.view.addSubview(self.settingsButton)
        self.settingsButton.leadingAnchor.constraint(equalTo: self.searchField.trailingAnchor, constant: HomeLayout.margin).isActive = true
        self.settingsButton.centerYAnchor.constraint(equalTo: self.searchField.centerYAnchor).isActive = true
        self.settingsButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -HomeLayout.margin).isActive = true
        self.view.addSubview(self.tableView)
        self.tableView.topAnchor.constraint(equalTo: self.searchField.bottomAnchor).isActive = true
        self.tableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        self.tableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.tableView.contentInset = .init(top: HomeLayout.margin, left: 0.0, bottom: HomeLayout.safeAera.bottom, right: 0.0)
        self.view.addSubview(self.gradientView)
        self.gradientView.topAnchor.constraint(equalTo: self.tableView.topAnchor).isActive = true
        self.gradientView.leadingAnchor.constraint(equalTo: self.tableView.leadingAnchor).isActive = true
        self.gradientView.trailingAnchor.constraint(equalTo: self.tableView.trailingAnchor).isActive = true
        self.gradientView.heightAnchor.constraint(equalToConstant: HomeLayout.margin).isActive = true
        self.settingsButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(EventsListViewController.settingsButtonTapped(sender:))))
        self.tableView.block = self.eventSelected(event:)
        self.tableView.parameters = self.settings.parameters
        self.tableView.nextPage()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func adjustableParametersProviderExtraValueSelected(_ newTitle: String, newRoute: HomeApi.Routes) {
        self.headerTitle = newTitle
        self.tableView.route = newRoute
    }
    
    func adjustableParametersProviderParametersUpdated(_ newParameters: [String : Any]) {
        self.tableView.reset()
        self.tableView.parameters = newParameters
        self.tableView.nextPage()
    }
    
    // MARK: -
    func searchFieldBeginEditing(_ searchField: SearchFieldView) { }
    func searchFieldEndEditing(_ searchField: SearchFieldView) { }
    func searchFieldTextUpdated(_ searchField: SearchFieldView) {
        self.tableView.reset()
        self.tableView.parameters = self.settings.parameters
        self.tableView.nextPage()
    }
    
    private func eventSelected(event: IntraEvent) {
        DynamicAlert.init(.event(event), contents: [.text(event.eventDescription)], actions: [.normal(~"general.ok", nil)])
    }
            
    @objc private func settingsButtonTapped(sender: UITapGestureRecognizer) {
        self.presentWithBlur(self.settings)
    }
    
    static let canExport: Bool = false
    func adjustableParametersProviderWillExport() -> String { fatalError() }
}
