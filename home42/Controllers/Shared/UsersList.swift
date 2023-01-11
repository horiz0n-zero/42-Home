// home42/UsersList.swift
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

final class UsersListViewController: HomeViewController, SearchFieldViewDelegate, AdjustableParametersProviderDelegate {
    
    private let header: HeaderWithActionsBase
    var headerTitle: String {
        set { self.header.title = newValue }
        get { return self.header.title }
    }
    private let searchField: SearchFieldViewWithTimer
    private let settingsButton: ActionButtonView
    private var settings: AdjustableParametersProviderViewController<UsersListViewController>!
    private let tableView: UserInfoInfiniteRequestTableView
    private let gradientView: GradientView
    
    var primary: UIColor
    
    static let defaultParameters: [String : Any] = ["range[login]":"a,z"]
    static let searchParameter: AdjustableParametersProviderViewController<UsersListViewController>.SearchParameter? = .init(title: "general.search", keys: [.searchLogin], keysName: [""], textGetter: \.searchField.text)
    static let parameters: [AdjustableParametersProviderViewController<UsersListViewController>.Parameter] = [
        .init(key: .sort, source: .userSort, selectorType: .stringAscDesc(.asc), selectorTitleKey: "field.sort-message", selectorInlineWithNextElement: false, selectorCanSelectNULL: false),
        .init(key: .filterPoolYear, source: .poolYear, selectorType: .int, selectorTitleKey: "field.pool-year-message", selectorInlineWithNextElement: true, selectorCanSelectNULL: true),
        .init(key: .filterPoolMonth, source: .poolMonth, selectorType: .string, selectorTitleKey: "field.pool-month-message", selectorInlineWithNextElement: false, selectorCanSelectNULL: true),
        .init(key: .filterPrimaryCampusId, source: .campus, selectorType: .campus, selectorTitleKey: "field.primary-campus", selectorInlineWithNextElement: false, selectorCanSelectNULL: true)
        // .init(key: .isStaff, source: .boolean, selectorType: .boolean, selectorTitleKey: "field.is-staff", selectorInlineWithNextElement: true, selectorCanSelectNULL: false), // idem
        // .init(key: .isAlumni, source: .boolean, selectorType: .boolean, selectorTitleKey: "field.is-alumni", selectorInlineWithNextElement: false, selectorCanSelectNULL: false) // marche po
    ]
    
    init(_ route: HomeApi.Routes = .users, settings: [HomeApi.Parameter: Any]? = nil, extra: AdjustableParametersProviderViewController<UsersListViewController>.Extra? = nil,
         primary: UIColor = HomeDesign.primary, warnAboutIncorrectAPIResult: Bool = false) {
        let actions: [ActionButtonView]?
        
        if warnAboutIncorrectAPIResult {
            actions = [ActionButtonView(asset: .actionWarning, color: HomeDesign.redError)]
        }
        else {
            actions = nil
        }
        switch extra {
        case .coalitions(let coalition, _):
            self.header = CoalitionHeaderWithActionsView(coalition: coalition, actions: actions)
        case .expertise(let expertiseId):
            self.header = HeaderWithActionsView(title: HomeApiResources.expertises[expertiseId]?.name ?? "???", actions: actions)
        case .title(let title):
            self.header = HeaderWithActionsView(title: title.name, actions: actions)
        case .group(let group):
            self.header = HeaderWithActionsView(title: group.name, actions: actions)
        case .achievement(let achievement):
            self.header = HeaderWithActionsView(title: achievement.name, actions: actions)
        //case .project(let id):
        //
        //case .campus(let campus):
        //    self.header = HeaderWithActionsView(title: campus.name) // +action which point to campus location ? with map to show, map can show all other campus
        default:
            self.header = HeaderWithActionsView(title: ~"general.users", actions: actions)
        }
        self.searchField = SearchFieldViewWithTimer()
        self.searchField.setPrimary(primary)
        self.settingsButton = ActionButtonView(asset: .actionSettings, color: primary)
        self.primary = primary
        self.tableView = UserInfoInfiniteRequestTableView(.users)
        self.gradientView = GradientView()
        self.gradientView.startPoint = .init(x: 0.5, y: 0.0)
        self.gradientView.endPoint = .init(x: 0.5, y: 1.0)
        self.gradientView.colors = [HomeDesign.white.cgColor, UIColor.init(white: 1.0, alpha: 0.0).cgColor]
        super.init()
        self.settings = .init(delegate: self, defaultParameters: settings ?? [:], extra: extra)
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
        self.tableView.contentInset = .init(top: 0.0, left: 0.0, bottom: HomeLayout.safeAera.bottom, right: 0.0)
        self.view.addSubview(self.gradientView)
        self.gradientView.topAnchor.constraint(equalTo: self.tableView.topAnchor).isActive = true
        self.gradientView.leadingAnchor.constraint(equalTo: self.tableView.leadingAnchor).isActive = true
        self.gradientView.trailingAnchor.constraint(equalTo: self.tableView.trailingAnchor).isActive = true
        self.gradientView.heightAnchor.constraint(equalToConstant: HomeLayout.margin).isActive = true
        self.settingsButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UsersListViewController.settingsButtonTapped(sender:))))
        actions?[0].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UsersListViewController.warnAboutIncorrectAPIResult(sender:))))
        self.tableView.block = self.userSelected(user:)
        self.tableView.primary = primary
        self.tableView.route = route
        self.tableView.parameters = self.settings.parameters
        self.tableView.nextPage()
    }
    required init() { fatalError() }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func adjustableParametersProviderExtraValueSelected(_ newTitle: String, newRoute: HomeApi.Routes) {
        self.headerTitle = newTitle
        self.tableView.route = newRoute
        if case .coalitionsWithCoalitionIdUsers(let id) = newRoute, case .coalitions(_, let bloc) = self.settings.extra!, let coalition = bloc.coalitions.first(where: { $0.id == id }) {
            (self.header as! CoalitionHeaderWithActionsView).setCoalition(coalition)
            self.primary = coalition.uicolor
            self.tableView.primary = coalition.uicolor
            self.searchField.setPrimary(coalition.uicolor)
            self.settingsButton.primary = coalition.uicolor
        }
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
    
    private func userSelected(user: IntraUserInfo) {
        let profil = ProfilViewController()
        
        Task.init(priority: .userInitiated, operation: {
            await profil.setupWithUser(user.login, id: user.id)
        })
        self.presentWithBlur(profil)
    }
    
    @objc private func warnAboutIncorrectAPIResult(sender: UITapGestureRecognizer) {
        DynamicAlert(contents: [.text(~"userslist.api-possible-wrong-result")], actions: [.normal(~"general.ok", nil)])
    }
    
    @objc private func settingsButtonTapped(sender: UITapGestureRecognizer) {
        self.presentWithBlur(self.settings)
    }
    
    static let canExport: Bool = true
    
    func adjustableParametersProviderWillExport() -> String {
        var export: String = ""
        
        for user in self.tableView.elements {
            export += "\(user.login)\n"
        }
        return export
    }
}
