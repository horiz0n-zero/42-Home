// home42/Profil.swift
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

final class ProfilViewController: HomeViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let tableView: BasicUITableView
    private let headerCell: HeaderTableViewCell
    private var userEventsCell: UserEventsTableViewCell!
    private var correctionsCell: CorrectionsTableViewCell!
    private var userLogsCell: UserLogsTableViewCell!
    private let projectsCell: ProjectsTableViewCell
    private let skillsCell: SkillsTableViewCell
    private var tagsCell: GenericTableViewCell<TagsView>!
    
    @frozen enum ProfilLayout: Int, CaseIterable {
        case header = 0
        case tags
        case events
        case corrections
        case logs
        case projects
        case skills
        case partnerships
        case titles
        case expertises
        case achievements
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.user == nil {
            return 1
        }
        return ProfilLayout.allCases.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch ProfilLayout(rawValue: section)! {
        case .header:
            return 1
        case .tags where self.tagsCell != nil:
            return 1
        case .events where self.userEventsCell != nil:
            if let count = self.userEvents?.count {
                if count == 0 {
                    return 2
                }
                return 1 + count
            }
            return 2
        case .corrections where self.correctionsCell != nil:
            return 1
        case .logs where self.userLogsCell != nil && self.user != nil:
            return 1
        case .projects where self.currentCursus != nil && self.user.projects_users.count > 0:
            return 1
        case .skills where self.currentCursus != nil && self.currentCursus.skills.count > 0:
            return 1
        case .partnerships where App.settings.profilShowPartnerships && self.user.partnerships.count > 0:
            return 1 + self.user.partnerships.count
        case .titles where self.user.titles.count > 0:
            return 1 + self.user.titles.count
        case .expertises where self.user.expertises_users.count > 0:
            return 1 + self.user.expertises_users.count
        case .achievements where self.user.achievements.count > 0:
            return 1 + self.user.achievements.count
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        func headerWithTitle(_ title: String) -> SectionTableViewCell {
            let view = tableView.dequeueReusableCell(withIdentifier: "Header") as! SectionTableViewCell
            
            view.update(with: title, primaryColor: self.currentPrimary)
            return view
        }
        
        switch ProfilLayout(rawValue: indexPath.section)! {
        case .header:
            return self.headerCell
        case .tags:
            return self.tagsCell
        case .events:
            if indexPath.row == 0 {
                return self.userEventsCell
            }
            if indexPath.row == 1 && (self.userEvents == nil || self.userEvents!.count == 0) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Message", for: indexPath) as! MessageTableViewCell
                
                cell.setHeigthConstraint = true
                cell.marginX = HomeLayout.margin
                cell.marginBottom = HomeLayout.smargin
                cell.update(with: self.userEvents == nil ? ~"general.loading" : ~"profil.no-futur-event", primary: self.currentPrimary)
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "Event", for: indexPath) as! EventsViewController.EventTableViewCell
            let userEvent = self.userEvents[indexPath.row - 1]
            
            cell.fill(with: userEvent.event, userSubcribed: true)
            cell.fill(with: userEvent.event)
            return cell
        case .corrections:
            return self.correctionsCell
        case .logs:
            return self.userLogsCell
        case .projects:
            return self.projectsCell
        case .skills:
            return self.skillsCell
        case .partnerships:
            if indexPath.row == 0 {
                return headerWithTitle(~"title.partnerships")
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "PartnershipView", for: indexPath) as! HomeFramingTableViewCell<PartnershipView>
            
            cell.view.update(with: self.user.partnerships[indexPath.row &- 1], primary: self.currentPrimary)
            return cell
        case .titles:
            if indexPath.row == 0 {
                return headerWithTitle(~"title.titles")
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "TitleView", for: indexPath) as! HomeFramingTableViewCell<TitleView>
            
            cell.view.update(with: self.user.titles[indexPath.row &- 1], login: self.user.login, primary: self.currentPrimary)
            return cell
        case .expertises:
            if indexPath.row == 0 {
                return headerWithTitle(~"title.expertises")
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "ExpertiseView", for: indexPath) as! HomeFramingTableViewCell<ExpertiseView>
            
            cell.view.update(with: self.user.expertises_users[indexPath.row &- 1], primary: self.currentPrimary)
            return cell
        case .achievements:
            if indexPath.row == 0 {
                return headerWithTitle(~"title.achievements")
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "AchievementView", for: indexPath) as! HomeFramingTableViewCell<AchievementView>
            
            cell.view.update(with: self.user.achievements[indexPath.row &- 1], primary: self.currentPrimary)
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch ProfilLayout(rawValue: indexPath.section)! {
        case .events:
            guard self.userEvents != nil && self.userEvents.count > 0 && indexPath.row - 1 < self.userEvents.count else { return }
            let userEvent = self.userEvents[indexPath.row - 1]
            
            DynamicAlert.init(.event(userEvent.event), contents: [.text(userEvent.event.eventDescription)], actions: [.normal(~"general.ok", nil), .highligth(~"event.action.unregister", {
                Task.init(priority: .userInitiated, operation: {
                    do {
                        let _: Int = try await HomeApi.delete(.eventsUsersWithId(userEvent.id))
                        
                        if let index = self.userEvents.firstIndex(of: userEvent) {
                            self.userEvents.remove(at: index)
                            HomeDefaults.save(self.userEvents, forKey: .userEvents)
                        }
                        self.tableView.reloadSections(IndexSet.init(integer: ProfilLayout.events.rawValue), with: .fade)
                        self.tableView.reloadRows(at: [IndexPath.init(row: 1, section: ProfilLayout.events.rawValue)], with: .fade)
                    }
                    catch {
                        DynamicAlert.presentWith(error: error as! HomeApi.RequestError)
                    }
                })
            })])
        case .partnerships:
            guard indexPath.row != 0 else { return }
            let partnership = self.user.partnerships[indexPath.row &- 1]
            let userList = UsersListViewController(.partnershipsWithPartnershipIdUsers(partnership.id), primary: self.currentPrimary)
            
            userList.headerTitle = partnership.name
            self.presentWithBlur(userList)
        case .titles:
            guard indexPath.row != 0 else { return }
            let title = self.user.titles[indexPath.row &- 1]
            let userList = UsersListViewController(.titlesWithTitleIdUsers(title.id),
                                                   primary: self.currentPrimary,
                                                   extra: .title(title),
                                                   warnAboutIncorrectAPIResult: true)
            
            self.presentWithBlur(userList)
        case .expertises:
            guard indexPath.row != 0 else { return }
            let expertise = self.user.expertises_users[indexPath.row &- 1]
            let usersList = UsersListViewController(.expertisesWithExpertiseIdUsers(expertise.expertise_id),
                                                    primary: self.currentPrimary,
                                                    extra: .expertise(expertise.expertise_id))
            
            self.presentWithBlur(usersList)
        case .achievements:
            let achievement = self.user.achievements[indexPath.row &- 1]
            let usersList = UsersListViewController(.achievementsWithAchievementIdUsers(achievement.id),
                                                    primary: self.currentPrimary,
                                                    extra: .achievement(achievement),
                                                    warnAboutIncorrectAPIResult: true)
            
            self.presentWithBlur(usersList)
        default:
            break
        }
    }
        
    // MARK: -
    required init() {
        self.tableView = BasicUITableView()
        self.tableView.register(EventsViewController.EventTableViewCell.self, forCellReuseIdentifier: "Event")
        self.tableView.register(MessageTableViewCell.self, forCellReuseIdentifier: "Message")
        self.tableView.register(SectionTableViewCell.self, forCellReuseIdentifier: "Header")
        self.tableView.register(HomeFramingTableViewCell<PartnershipView>.self, forCellReuseIdentifier: "PartnershipView")
        self.tableView.register(HomeFramingTableViewCell<TitleView>.self, forCellReuseIdentifier: "TitleView")
        self.tableView.register(HomeFramingTableViewCell<ExpertiseView>.self, forCellReuseIdentifier: "ExpertiseView")
        self.tableView.register(HomeFramingTableViewCell<AchievementView>.self, forCellReuseIdentifier: "AchievementView")
        self.headerCell = HeaderTableViewCell()
        if App.settings.profilShowLogs {
            self.userLogsCell = UserLogsTableViewCell.init(style: .default, reuseIdentifier: nil)
        }
        self.projectsCell = ProjectsTableViewCell.init(style: .default, reuseIdentifier: nil)
        self.skillsCell = SkillsTableViewCell.init(style: .default, reuseIdentifier: nil)
        super.init()
        self.view.addSubview(self.tableView)
        self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.headerCell.coalitionImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfilViewController.headerCoalitionIconTapped(sender:))))
        self.tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: HomeLayout.safeAera.bottom, right: 0.0)
        self.tableView.contentInsetAdjustmentBehavior = .never
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: -
    private var isMyProfil: Bool = false
    private var user: IntraUser!
    private var userEvents: ContiguousArray<IntraUserEvent>!
    private var currentCampus: IntraUserCampus!
    private var currentCursus: IntraUserCursus!
    private var coalitions: ContiguousArray<IntraCoalition>!
    private var currentCoalition: IntraCoalition!
    var currentPrimary: UIColor = HomeDesign.primaryDefault
    
    // MARK: -
    private func dataReceived(_ user: IntraUser, coalitions: ContiguousArray<IntraCoalition>) {
        guard App.userLoggedIn else {
            return
        }
        self.user = user
        self.coalitions = coalitions
        self.currentCampus = user.primaryCampus
        self.currentCursus = user.primaryCursus
        if self.currentCursus != nil, let coalition = coalitions.primaryCoalition(campus: self.currentCampus, cursus: self.currentCursus) {
            self.currentCoalition = coalition
            self.currentPrimary = coalition.uicolor
        }
        else {
            self.currentCoalition = nil
        }
        self.headerCell.update(with: user, coalition: self.currentCoalition, parent: self)
        if self.tagsCell == nil, let tags = user.tags {
            self.tagsCell = GenericTableViewCell<TagsView>(style: .default, reuseIdentifier: nil)
            self.tagsCell.view.update(with: tags)
        }
        if self.currentCursus != nil {
            self.projectsCell.update(with: user, cursus: self.currentCursus, primary: self.currentPrimary)
            if self.currentCursus.skills.count > 0 {
                self.skillsCell.update(with: self.currentCursus.skills, primary: self.currentPrimary)
            }
        }
        self.tableView.reloadData()
    }
    
    private func setupErrorOccured(_ error: HomeApi.RequestError, dismiss: Bool = true) {
        DynamicAlert.presentWith(error: error)
        if dismiss {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @MainActor func setupWithUser(_ login: String, id: Int) async {
        async let user: IntraUser = HomeApi.get(.userWithId(id))
        async let coalitions: ContiguousArray<IntraCoalition> = HomeApi.get(.usersWithUserIdCoalitions(id))
        let closeButton = ActionButtonView(asset: .actionClose, color: HomeDesign.actionRed)
        let holyGraphButton = ActionButtonView(asset: .actionGraph, color: HomeDesign.actionOrange)
        let addFriendsButton = ActionButtonView(asset: .actionAddFriends, color: HomeDesign.actionGreen)

        closeButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfilViewController.actionCloseTapped(sender:))))
        holyGraphButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfilViewController.actionHolyGraphTapped(sender:))))
        addFriendsButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfilViewController.actionPeoplesTapped(sender:))))
        self.headerCell.actionsStack.addArrangedSubview(closeButton)
        self.headerCell.actionsStack.addArrangedSubview(holyGraphButton)
        self.headerCell.actionsStack.addArrangedSubview(addFriendsButton)
        self.headerCell.userIcon.isUserInteractionEnabled = true
        self.headerCell.userIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfilViewController.seeProfilIconInFullScreen(sender:))))
        self.headerCell.loginLabel.text = login
        do {
            try await self.dataReceived(user, coalitions: coalitions)
            addFriendsButton.isUserInteractionEnabled = true
        }
        catch {
            self.setupErrorOccured(error as! HomeApi.RequestError)
        }
    }
    
    @MainActor func setupWithMe() async {
        #if false
        async let user: IntraUser = HomeApi.get(.userWithId(128443))
        async let coalitions: ContiguousArray<IntraCoalition> = HomeApi.get(.usersWithUserIdCoalitions(128443))
        #else
        async let user: IntraUser = HomeApi.get(.me)
        async let coalitions: ContiguousArray<IntraCoalition> = HomeApi.get(.usersWithUserIdCoalitions(App.user.id))
        #endif
        let closeButton = ActionButtonView(asset: .actionClose, color: HomeDesign.actionRed)
        let logoutButton = ActionButtonView(asset: .actionLogout, color: HomeDesign.actionOrange)
        let settingsButton = ActionButtonView(asset: .actionSettings, color: HomeDesign.actionGreen)
        
        self.isMyProfil = true
        closeButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfilViewController.actionCloseTapped(sender:))))
        self.headerCell.actionsStack.addArrangedSubview(closeButton)
        logoutButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfilViewController.actionLogoutTapped(sender:))))
        self.headerCell.actionsStack.addArrangedSubview(logoutButton)
        settingsButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfilViewController.actionSettingsTapped(sender:))))
        self.headerCell.actionsStack.addArrangedSubview(settingsButton)
        self.headerCell.userIcon.isUserInteractionEnabled = true
        self.headerCell.userIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfilViewController.seeProfilIconInFullScreen(sender:))))
        if App.settings.profilShowEvents {
            self.userEventsCell = UserEventsTableViewCell.init(style: .default, reuseIdentifier: nil)
            self.userEventsCell.logsButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfilViewController.userEventsLogsTapped)))
        }
        if App.settings.profilShowCorrections {
            self.correctionsCell = CorrectionsTableViewCell.init(style: .default, reuseIdentifier: nil)
            // self.correctionsCell.slotsButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfilViewController.correctionSlotsTapped)))
            self.correctionsCell.logsButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfilViewController.correctionLogsTapped)))
        }
        self.user = App.user
        self.coalitions = App.coalitions
        self.dataReceived(self.user, coalitions: self.coalitions)
        do {
            let user = try await user
            let coalitions: ContiguousArray<IntraCoalition> = try await coalitions
            // try await HomeApi.get(.test("users/\(user.id)/quests_users")), /quests_users
            
            self.dataReceived(user, coalitions: coalitions)
            App.user = user
            App.coalitions = coalitions
            HomeDefaults.save(user, forKey: .user)
            HomeDefaults.save(coalitions, forKey: .coalitions)
            if App.settings.profilShowCorrections {
                do {
                    try self.correctionsCell.view.refreshUserCorrections()
                }
                catch {
                    DynamicAlert.presentWith(error: error as! HomeApi.RequestError)
                }
            }
            if App.settings.profilShowEvents {
                self.userEvents = try await EventsViewController.refreshUserEvents()
                if self.userEvents.count > 1 {
                    self.tableView.reloadSections(IndexSet.init(integer: ProfilLayout.events.rawValue), with: .fade)
                    self.tableView.reloadRows(at: [IndexPath.init(row: 1, section: ProfilLayout.events.rawValue)], with: .fade)
                }
                else {
                    self.tableView.reloadRows(at: [IndexPath(row: 1, section: ProfilLayout.events.rawValue)], with: .fade)
                }
            }
        }
        catch {
            self.setupErrorOccured(error as! HomeApi.RequestError, dismiss: false)
        }
    }
    
    // MARK: -
    @objc private func cursusButtonTapped(sender: UITapGestureRecognizer) {
        let block: (Int, String) -> Void = { index, _ in
            self.currentCursus = self.user.cursus_users[index]
            self.currentCoalition = self.coalitions.primaryCoalition(campus: self.currentCampus, cursus: self.currentCursus)
            self.currentPrimary = self.currentCoalition?.uicolor ?? HomeDesign.primaryDefault
            self.headerCell.update(with: self.user, coalition: self.currentCoalition, parent: self)
            if self.currentCursus != nil {
                self.projectsCell.update(with: self.user, cursus: self.currentCursus, primary: self.currentPrimary)
                self.skillsCell.update(with: self.currentCursus.skills, primary: self.currentPrimary)
            }
            if self.userEventsCell != nil {
                self.userEventsCell.setPrimary(self.currentPrimary)
            }
            if self.correctionsCell != nil {
                self.correctionsCell.setPrimary(self.currentPrimary)
            }
            self.tableView.reloadData()
        }
        
        DynamicAlert(.withPrimary(~"profil.info.cursus", self.currentPrimary),
                     contents: [.roulette(self.user.cursus_users.map({ $0.cursus.name }), self.user.cursus_users.firstIndex(where: { $0 == self.currentCursus }) ?? 0)],
                     actions: [.normal(~"general.cancel", nil), .getRoulette(~"general.select", block)])
    }
    
    @objc private func headerCoalitionIconTapped(sender: UITapGestureRecognizer) {
        guard self.headerCell.coalitionImage.image != UIImage.Assets.svgFactionless.image, self.currentCursus != nil, self.currentCoalition != nil else {
            return
        }
        let coalitionBloc = CoalitionsBlocViewController()
        
        Task.init(priority: .userInitiated, operation: {
            await coalitionBloc.setup(with: self.currentCampus.campus_id, cursusId: self.currentCursus.cursus_id)
        })
        self.presentWithBlur(coalitionBloc)
    }
    
    @objc private func actionCloseTapped(sender: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func actionLogoutTapped(sender: UITapGestureRecognizer) {
        func logout() {
            self.dismiss(animated: true, completion: {
                App.logout()
            })
        }
        
        DynamicAlert.init(.withPrimary(~"general.warning", self.currentPrimary),
                          contents: [.title(~"disconnect.title"), .text(~"disconnect.message")],
                          actions: [.normal(~"general.cancel", nil), .highligth(~"general.disconnect", logout)])
    }
    
    @objc private func actionSettingsTapped(sender: UITapGestureRecognizer) {
        self.presentWithBlur(SettingsViewController())
    }
    
    @objc private func actionHolyGraphTapped(sender: UITapGestureRecognizer) {
        guard self.user != nil, self.coalitions != nil else { return }
        if self.currentCursus == nil {
            DynamicAlert(contents: [.text(String(format: ~"graph.required-cursus", self.user.login))], actions: [.normal(~"general.ok", nil)])
        }
        else {
            self.presentWithBlur(GraphSharedViewController(user: self.user, cursus: self.currentCursus, coalition: self.currentCoalition), completion: nil)
        }
    }
    
    @objc private func actionPeoplesTapped(sender: UITapGestureRecognizer) {
        guard self.user != nil, self.coalitions != nil else { return }
        var peoples: Dictionary<String, People> = HomeDefaults.read(.peoples) ?? [:]
        var actions: [DynamicActionsSheet.Action]
        
        func updateCluster() {
            if let cluster = App.mainController.controller as? ClustersViewController {
                cluster.peoplesUpdated(peoples)
            }
        }
        func remove() {
            peoples.removeValue(forKey: self.user.login)
            HomeDefaults.save(peoples, forKey: .peoples)
            updateCluster()
        }
        
        if App.settings.peopleExtraList1 != nil || App.settings.peopleExtraList2 != nil {
            
            if let people = peoples[self.user.login] {
                DynamicAlert.init(.withPrimary(people.list.title, self.currentPrimary),
                                  contents: [.title(String(format: ~"peoples.remove", people.login))],
                                  actions: [.normal(~"general.cancel", nil), .highligth(~"general.remove", remove)])
            }
            else {
                func add(listType: People.ListType) {
                    peoples[self.user.login] = People(id: self.user.id, login: self.user.login, image: self.user.image, list: listType)
                    HomeDefaults.save(peoples, forKey: .peoples)
                    updateCluster()
                }
                
                actions = [.title(String(format: ~"peoples.add", self.user.login)), .separator,
                           .normalWithPrimary(~"peoples.friends", .actionPeople, People.ListType.friends.color, { add(listType: .friends) })]
                if let extra1 = App.settings.peopleExtraList1 {
                    actions.append(.normalWithPrimary(extra1.name, extra1.icon, People.ListType.extraList1.color, { add(listType: .extraList1) }))
                }
                if let extra2 = App.settings.peopleExtraList2 {
                    actions.append(.normalWithPrimary(extra2.name, extra2.icon, People.ListType.extraList2.color, { add(listType: .extraList2) }))
                }
                DynamicActionsSheet(actions: actions, primary: self.currentPrimary)
            }
        }
        else {
            
            func add() {
                peoples[self.user.login] = People(id: self.user.id, login: self.user.login, image: self.user.image, list: .friends)
                HomeDefaults.save(peoples, forKey: .peoples)
                updateCluster()
            }
            
            if peoples[self.user.login] == nil {
                DynamicAlert(.fullPrimary(~"peoples.friends", HomeDesign.greenSuccess),
                             contents: [.text(String(format: ~"peoples.friends-add", self.user.login))],
                             actions: [.normal(~"general.cancel", nil), .highligth(~"general.add", add)])
            }
            else {
                DynamicAlert(.fullPrimary(~"peoples.friends", HomeDesign.redError),
                             contents: [.text(String(format: ~"peoples.friends-remove", self.user.login))],
                             actions: [.normal(~"general.cancel", nil), .highligth(~"general.remove", remove)])
            }
        }
    }
    
    @objc private func locationTapped(sender: UITapGestureRecognizer) {
        
        func sharedClusterFor(campus: IntraUserCampus) {
            do {
                let vc = try ClustersSharedViewController(campus: self.currentCampus, coalition: self.currentCoalition)
                
                self.presentWithBlur(vc) {
                    if let location = self.user?.location {
                        vc.focusOnClusterView(with: location, animated: true)
                    }
                }
            }
            catch {
                HomeGuides.alertShowGuides(self)
            }
        }
        
        if self.currentCampus.campus_id != App.userCampus.campus_id {
            sharedClusterFor(campus: self.currentCampus)
        }
        else {
            if let cluster = App.mainController.controller as? ClustersViewController {
                if cluster.focusOnClusterView(with: self.user.location, animated: true) == false {
                    DynamicAlert(contents: [.text(String(format: ~"clusters.nofocus-for-host", self.user.login, self.user.location))], actions: [.normal(~"general.i-understand", nil)])
                }
                else {
                    self.dismissToRootController(animated: true)
                }
            }
            else {
                sharedClusterFor(campus: self.currentCampus)
            }
        }
    }
    
    @objc private func phoneTapped(sender: UITapGestureRecognizer) {
        guard let phone = self.user.phone else {
            return
        }
        
        HomeTelephony.call(phone)
    }
    
    @objc private func correctionPointsHistoric(sender: UITapGestureRecognizer) {
        self.presentWithBlur(EvaluationPointsHistoricViewController(userId: self.user.id, userLogin: self.user.login, userImage: self.user.image, primary: self.currentPrimary), completion: nil)
    }
    
    @objc private func overCampusTapped(sender: UITapGestureRecognizer) {
        let users = UsersListViewController(.users, primary: self.currentPrimary, settings: [.campus(self.currentCampus.campus_id)])

        self.presentWithBlur(users, completion: nil)
    }
    
    @objc private func poolButtonTapped(sender: UITapGestureRecognizer) {
        let users = UsersListViewController(.users, primary: self.currentPrimary,
                                            settings: [.poolYear(Int(self.user.pool_year) ?? Date().year),
                                                       .poolMonth(self.user.pool_month),
                                                       .campus(self.currentCampus.campus_id)])

        self.presentWithBlur(users)
    }
    
    @objc private func seeProfilIconInFullScreen(sender: UITapGestureRecognizer) {
        (sender.view as? UserProfilIconView)?.showImageInFullScreen()
    }
    
    @objc private func userEventsLogsTapped() {
        let eventsHistory = UserEventsHistoricViewController(user: self.user, primary: self.currentPrimary)
        
        self.presentWithBlur(eventsHistory, completion: nil)
    }
    
    @objc private func userEventsFeedbackTapped() {
        let eventFeedbacksHistory = EventFeedbacksHistoricViewController()
        
        self.presentWithBlur(eventFeedbacksHistory, completion: nil)
    }
    
    @objc private func correctionLogsTapped() {
        self.presentWithBlur(UserCorrectionsLogsViewController(user: self.user, primary: self.currentPrimary))
    }
    
    @objc private func correctionSlotsTapped() {
        self.presentWithBlur(UserSlotsViewController())
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0.0 {
            let scale = (HomeLayout.profilBackgroundHeigth + -scrollView.contentOffset.y) / HomeLayout.profilBackgroundHeigth
            
            self.headerCell.coalitionBackground.transform = CGAffineTransform(translationX: 0.0, y: scrollView.contentOffset.y / 2.0).scaledBy(x: scale, y: scale)
        }
    }
}

fileprivate extension ProfilViewController {
    
    final private class HeaderTableViewCell: BasicUITableViewCell {
        
        fileprivate let coalitionBackground: CoalitionBackgroundWithParallaxImageView
        fileprivate let coalitionImage: BasicUIImageView
        fileprivate let userIcon: UserProfilIconView
        fileprivate let loginLabel: AlternateLabel
        private let levelBar: Level21Bar
        fileprivate let actionsStack: BasicUIStackView
        
        final private class InfosView: BasicUIView {
            
            private let viewRecycler: ViewRecycler<InfosView.InfoView>
            
            final class InfoView: BasicUIVisualEffectView, ViewRecyclable {
                
                fileprivate let actionButtonView: SmallActionButtonView
                fileprivate let valueLabel: BasicUILabel
                var data: InfoView.Data
                
                struct Data: Equatable, CustomStringConvertible {
                    let type: ContentType
                    let value: String
                    let asset: UIImage.Assets
                    let selector: Selector
                    
                    static func ==(lhs: Self, rhs: Self) -> Bool {
                        return lhs.type == rhs.type
                    }
                    var description: String { return "\(~self.type.rawValue) \(self.value)" }
                }
                init(data: InfoView.Data) {
                    self.data = data
                    self.actionButtonView = .init(asset: data.asset, color: HomeDesign.primary)
                    self.valueLabel = BasicUILabel(text: data.value)
                    self.valueLabel.textColor = HomeDesign.white
                    self.valueLabel.font = HomeLayout.fontSemiBoldNormal
                    self.valueLabel.textAlignment = .left
                    self.valueLabel.adjustsFontSizeToFitWidth = true
                    super.init()
                    self.layer.cornerRadius = HomeLayout.scorner
                    self.layer.masksToBounds = true
                    self.isUserInteractionEnabled = true
                    self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(InfoView.actionButtonTapped(sender:))))
                }
                required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
                
                func update(with data: Data) {
                    self.data = data
                    self.valueLabel.text = data.value
                    self.actionButtonView.set(asset: data.asset, color: self.actionButtonView.primary)
                }
                
                @objc private func actionButtonTapped(sender: UITapGestureRecognizer) {
                    let parent: ProfilViewController = self.parentViewController as! ProfilViewController
                    
                    _ = parent.perform(self.data.selector, with: sender)
                }
                
                override func willMove(toSuperview newSuperview: UIView?) {
                    guard newSuperview != nil else { return }
                    
                    self.contentView.addSubview(self.valueLabel)
                    self.contentView.addSubview(self.actionButtonView)
                    self.actionButtonView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
                    self.actionButtonView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
                    self.valueLabel.leadingAnchor.constraint(equalTo: self.actionButtonView.trailingAnchor, constant: HomeLayout.smargin).isActive = true
                    self.valueLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -HomeLayout.smargin).isActive = true
                    self.valueLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
                    self.contentView.heightAnchor.constraint(equalToConstant: HomeLayout.smallActionButtonSize).isActive = true
                }
            }
            
            @frozen enum ContentType: String {
                case wallet = "profil.info.wallet"
                case evaluationPoints = "profil.info.evaluation-points"
                case location = "profil.info.location"
                case phone = "profil.info.phone"
                case cursus = "profil.info.cursus"
                case pool = "profil.info.pool"
                case campus = "profil.info.campus"
            }
            override init() {
                self.viewRecycler = ViewRecycler(datas: [], constant: HomeLayout.smargin)
                super.init()
                self.layer.cornerRadius = HomeLayout.scorner
                self.layer.masksToBounds = true
                self.translatesAutoresizingMaskIntoConstraints = false
            }
            required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
            
            func update(with contents: [InfoView.Data], primary: UIColor) {
                for content in contents {
                    self.viewRecycler.insert(content)
                }
                for view in self.viewRecycler.views {
                    view.actionButtonView.primary = primary
                }
                self.viewRecycler.updateIfNeeded()
            }
            
            override func willMove(toSuperview newSuperview: UIView?) {
                guard newSuperview != nil else { return }
            
                self.addSubview(self.viewRecycler)
                self.viewRecycler.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
                self.viewRecycler.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
                self.viewRecycler.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            }
        }
        private let infoView: InfosView
        
        init() {
            self.coalitionBackground = CoalitionBackgroundWithParallaxImageView()
            self.coalitionBackground.layer.masksToBounds = true
            self.coalitionImage = .init(asset: .svgFactionless)
            self.coalitionImage.tintColor = HomeDesign.white
            self.coalitionImage.translatesAutoresizingMaskIntoConstraints = false
            self.coalitionImage.isUserInteractionEnabled = true
            self.userIcon = UserProfilIconView()
            self.loginLabel = AlternateLabel(text: "???")
            self.loginLabel.textColor = HomeDesign.black
            self.loginLabel.font = HomeLayout.fontSemiBoldMedium
            self.loginLabel.adjustsFontSizeToFitWidth = true
            self.levelBar = Level21Bar()
            self.actionsStack = BasicUIStackView()
            self.actionsStack.axis = .vertical
            self.actionsStack.alignment = .center
            self.actionsStack.distribution = .fill
            self.actionsStack.spacing = HomeLayout.margin
            self.infoView = InfosView()
            super.init(style: .default, reuseIdentifier: "HeaderTableViewCell")
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }
            
            self.contentView.addSubview(self.coalitionBackground)
            self.coalitionBackground.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
            self.coalitionBackground.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
            self.coalitionBackground.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
            self.coalitionBackground.heightAnchor.constraint(equalToConstant: HomeLayout.profilBackgroundHeigth).isActive = true
            self.contentView.addSubview(self.userIcon)
            self.userIcon.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: HomeLayout.margin).isActive = true
            self.userIcon.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -HomeLayout.margin).isActive = true
            self.userIcon.setSize(HomeLayout.userProfilIconProfilHeigth, HomeLayout.userProfilIconProfilRadius)
            self.coalitionBackground.bottomAnchor.constraint(equalTo: self.userIcon.centerYAnchor).isActive = true
            self.contentView.addSubview(self.coalitionImage)
            self.coalitionImage.centerXAnchor.constraint(equalTo: self.userIcon.centerXAnchor).isActive = true
            self.coalitionImage.bottomAnchor.constraint(equalTo: self.userIcon.topAnchor, constant: -HomeLayout.margin).isActive = true
            self.coalitionImage.heightAnchor.constraint(equalTo: self.coalitionImage.widthAnchor).isActive = true
            self.coalitionImage.widthAnchor.constraint(equalTo: self.userIcon.widthAnchor, multiplier: 0.8).isActive = true
            self.contentView.addSubview(self.actionsStack)
            self.actionsStack.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -HomeLayout.margin).isActive = true
            self.actionsStack.bottomAnchor.constraint(equalTo: self.coalitionBackground.bottomAnchor, constant: -HomeLayout.margin).isActive = true
            self.actionsStack.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: HomeLayout.safeAera.top + HomeLayout.margin).isActive = true
            self.actionsStack.widthAnchor.constraint(equalToConstant: HomeLayout.actionButtonSize).isActive = true
            self.contentView.addSubview(self.infoView)
            self.infoView.leadingAnchor.constraint(equalTo: self.userIcon.trailingAnchor, constant: HomeLayout.smargin).isActive = true
            self.infoView.topAnchor.constraint(equalTo: self.actionsStack.topAnchor).isActive = true
            self.infoView.bottomAnchor.constraint(equalTo: self.coalitionBackground.bottomAnchor, constant: -HomeLayout.margin).isActive = true
            self.infoView.trailingAnchor.constraint(equalTo: self.actionsStack.leadingAnchor, constant: -HomeLayout.dmargin).isActive = true
            self.contentView.insertSubview(self.levelBar, belowSubview: self.userIcon)
            self.levelBar.leadingAnchor.constraint(equalTo: self.userIcon.trailingAnchor, constant: -HomeLayout.level21BarSemiHeigth).isActive = true
            self.levelBar.topAnchor.constraint(equalTo: self.coalitionBackground.bottomAnchor).isActive = true
            self.levelBar.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -HomeLayout.smargin).isActive = true
            self.contentView.addSubview(self.loginLabel)
            self.loginLabel.leadingAnchor.constraint(equalTo: self.levelBar.leadingAnchor, constant: HomeLayout.smargin).isActive = true
            self.loginLabel.topAnchor.constraint(equalTo: self.levelBar.bottomAnchor).isActive = true
            self.loginLabel.bottomAnchor.constraint(equalTo: self.userIcon.bottomAnchor).isActive = true
            self.loginLabel.trailingAnchor.constraint(equalTo: self.levelBar.trailingAnchor).isActive = true
        }
        
        func update(with user: IntraUser, coalition: IntraCoalition?, parent: ProfilViewController) {
            let primary: UIColor
            var contents: [InfosView.InfoView.Data] = []
            
            self.userIcon.update(with: user)
            if let coalition = coalition {
                if let background = HomeResources.storageCoalitionsImages.get(coalition) {
                    self.coalitionBackground.image = background
                }
                else {
                    self.coalitionBackground.image = UIImage.Assets.coalitionDefaultBackground.image
                    Task.init(priority: .userInitiated, operation: {
                        if let (coa, background) = await HomeResources.storageCoalitionsImages.obtain(coalition), coa.id == coalition.id {
                            self.coalitionBackground.image = background
                        }
                    })
                }
                if let image = HomeResources.storageSVGCoalition.get(coalition) {
                    self.coalitionImage.image = image
                }
                else {
                    self.coalitionImage.image = UIImage.Assets.svgFactionless.image
                    Task.init(priority: .userInitiated, operation: {
                        if let (coa, image) = await HomeResources.storageSVGCoalition.obtain(coalition), coa.id == coalition.id {
                            self.coalitionImage.image = image
                        }
                    })
                }
                primary = coalition.uicolor
            }
            else {
                primary = HomeDesign.primaryDefault
                self.coalitionImage.image = UIImage.Assets.svgFactionless.image
                self.coalitionBackground.image = UIImage.Assets.coalitionDefaultBackground.image
            }
            if user.location != nil {
                contents.append(.init(type: .location, value: user.location, asset: .actionSee, selector: #selector(ProfilViewController.locationTapped(sender:))))
            }
            if user.phone != nil && user.phone != "hidden" {
                contents.append(.init(type: .phone, value: user.phone, asset: .actionSee, selector: #selector(ProfilViewController.phoneTapped(sender:))))
            }
            if parent.currentCursus != nil {
                contents.append(.init(type: .cursus, value: parent.currentCursus.cursus.name, asset: .actionSelect, selector: #selector(ProfilViewController.cursusButtonTapped(sender:))))
            }
            if let poolYear = user.pool_year, let poolMonth = user.pool_month, let monthIndex = Date.apiMonths.firstIndex(of: poolMonth) {
                contents.append(.init(type: .pool, value: "\(~Date.monthsKeys[monthIndex]) \(poolYear)", asset: .actionPeople, selector: #selector(ProfilViewController.poolButtonTapped(sender:))))
            }
            if contents.count < 5 && parent.currentCampus.campus_id != App.userCampus.campus_id {
                contents.append(.init(type: .campus, value: parent.user.campus(forUserCampusId: parent.currentCampus.campus_id).name, asset: .actionPeople, selector: #selector(ProfilViewController.overCampusTapped(sender:))))
            }
            if user.correction_point != 0 {
                contents.append(.init(type: .evaluationPoints, value: user.correction_point.scoreFormatted, asset: .actionHistoric, selector: #selector(ProfilViewController.correctionPointsHistoric(sender:))))
            }
            if contents.count > 4 {
                contents.removeLast(contents.count - 4)
            }
            self.infoView.update(with: contents, primary: primary)
            self.loginLabel.update(with: [user.login, user.displayname])
            self.levelBar.update(with: parent.currentCursus?.level ?? 0.0, primary: coalition?.uicolor ?? HomeDesign.primaryDefault)
        }
    }
}

extension ProfilViewController {
        
    final private class UserEventsTableViewCell: BasicUITableViewCell {
        private let title: LeftCurvedTitleView
        let logsButton: ActionButtonView
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            self.title = LeftCurvedTitleView(text: ~"title.events", primaryColor: HomeDesign.primary, addTopCorner: false)
            self.logsButton = .init(asset: .actionHistoric, color: HomeDesign.primary)
            super.init(style: style, reuseIdentifier: reuseIdentifier)
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }
            
            self.contentView.addSubview(self.title)
            self.title.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
            self.title.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
            self.title.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
            self.contentView.addSubview(self.logsButton)
            self.logsButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -HomeLayout.smargin).isActive = true
            self.logsButton.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: LeftCurvedTitleView.minHeight).isActive = true
            self.title.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -HomeLayout.margin).isActive = true
        }
        
        func setPrimary(_ color: UIColor) {
            self.title.update(with: self.title.text!, primaryColor: color)
            self.logsButton.primary = color
        }
    }
}

extension ProfilViewController {
    
    final private class CorrectionsTableViewCell: BasicUITableViewCell {
        
        private let title: LeftCurvedTitleView
        let logsButton: ActionButtonView
        // let slotsButton: ActionButtonView
        let view: CorrectionsView
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            self.title = LeftCurvedTitleView(text: ~"title.corrections", primaryColor: HomeDesign.primary, addTopCorner: false)
            self.logsButton = .init(asset: .actionHistoric, color: HomeDesign.primary)
            // self.slotsButton = .init(asset: .actionLock, color: HomeDesign.primary)
            self.view = CorrectionsView()
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            self.backgroundColor = HomeDesign.white
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }
  
            self.contentView.addSubview(self.title)
            self.title.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
            self.title.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
            self.title.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
            self.contentView.addSubview(self.logsButton)
            self.logsButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -HomeLayout.smargin).isActive = true
            self.logsButton.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: LeftCurvedTitleView.minHeight).isActive = true
            self.contentView.addSubview(self.view)
            self.view.topAnchor.constraint(equalTo: self.title.bottomAnchor, constant: HomeLayout.margin).isActive = true
            self.view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: HomeLayout.smargin).isActive = true
            self.view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -HomeLayout.smargin).isActive = true
            self.view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        }
        
        func setPrimary(_ color: UIColor) {
            self.title.update(with: self.title.text!, primaryColor: color)
            self.logsButton.primary = color
            self.view.setPrimary(color)
        }
    }
    
    final class CorrectionsView: BasicUIView, UITableViewDelegate, UITableViewDataSource {
        
        var isSizeLimited: Bool = false
        private var isLoading: Bool = true
        
        private let tableView: BasicUITableView
        private let tableViewHeight: NSLayoutConstraint
        
        private unowned(unsafe) var primary: UIColor = HomeDesign.primary
        fileprivate func setPrimary(_ color: UIColor) {
            self.primary = color
            self.tableView.reloadData()
        }
        
        override init() {
            self.tableView = BasicUITableView()
            self.tableViewHeight = self.tableView.heightAnchor.constraint(equalToConstant: HomeLayout.userProfilCorrectionViewEmptyHeight)
            super.init()
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.isScrollEnabled = false
            self.tableView.register(GenericTableViewCell<CorrectionsView.Cell>.self, forCellReuseIdentifier: "cell")
            self.tableView.register(MessageTableViewCell.self, forCellReuseIdentifier: "message")
            self.tableView.layer.cornerRadius = HomeLayout.scorner
            self.tableView.layer.masksToBounds = true
            self.tableView.backgroundColor = .clear
            self.backgroundColor = .clear
            self.layer.cornerRadius = HomeLayout.corner
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }
            
            self.addSubview(self.tableView)
            self.tableView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: HomeLayout.smargin).isActive = true
            self.tableView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.smargin).isActive = true
            self.tableView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            self.tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -HomeLayout.smargin).isActive = true
            self.tableViewHeight.priority = .defaultLow
            self.tableViewHeight.isActive = true
        }
        
        final private class Cell: BasicUIView, GenericTableViewCellView {
            
            private let container: BasicUIView
            private let correctorIcon: UserView = UserView()
            private let correctorArrow: BasicUIImageView = BasicUIImageView(asset: .actionArrowRight)
            private let correctedContainer: BasicUIScrollView = BasicUIScrollView()
            private let detailsContainer: BasicUIView = BasicUIView()
            private let detailsLabel: BasicUILabel = BasicUILabel(text: "???")
            
            private unowned(unsafe) var primary: UIColor = HomeDesign.primary
            
            private var timer: Timer!
            
            final private class UserView: BasicUIView {
                
                private let icon: UserProfilIconView
                private let label: BasicUILabel
                var user: IntraUserInfo!
                
                init(user: IntraUserInfo) {
                    self.icon = UserProfilIconView(user: user)
                    self.label = BasicUILabel(text: user.login)
                    self.label.textColor = HomeDesign.black
                    self.label.font = HomeLayout.fontSemiBoldNormal
                    self.user = user
                    super.init()
                    self.layer.cornerRadius = HomeLayout.scorner
                    self.layer.masksToBounds = true
                }
                override init() {
                    self.icon = UserProfilIconView()
                    self.label = BasicUILabel(text: "???")
                    self.label.textColor = HomeDesign.black
                    self.label.font = HomeLayout.fontSemiBoldNormal
                    self.user = nil
                    super.init()
                    self.layer.cornerRadius = HomeLayout.scorner
                    self.layer.masksToBounds = true
                }
                required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
                
                override func willMove(toSuperview newSuperview: UIView?) {
                    guard newSuperview != nil else { return }
                    
                    self.addSubview(self.icon)
                    self.icon.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: HomeLayout.dmargin).isActive = true
                    self.icon.topAnchor.constraint(equalTo: self.topAnchor, constant: HomeLayout.dmargin).isActive = true
                    self.icon.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -HomeLayout.dmargin).isActive = true
                    self.icon.setSize(HomeLayout.userProfilIconHeigth, HomeLayout.userProfilIconRadius)
                    self.addSubview(self.label)
                    self.label.leadingAnchor.constraint(equalTo: self.icon.trailingAnchor, constant: HomeLayout.smargin).isActive = true
                    self.label.centerYAnchor.constraint(equalTo: self.icon.centerYAnchor).isActive = true
                    self.label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.smargin).isActive = true
                }
                
                func update(with user: IntraUserInfo) {
                    self.icon.update(with: user)
                    self.label.text = user.login
                    self.user = user
                }
                
                func reset() {
                    self.icon.reset()
                    self.label.text = "???"
                }
            }
            
            override init() {
                self.container = BasicUIView()
                self.container.layer.cornerRadius = HomeLayout.scorner
                self.container.layer.masksToBounds = true
                self.detailsContainer.layer.cornerRadius = HomeLayout.scorner
                self.detailsLabel.font = HomeLayout.fontSemiBoldNormal
                self.detailsLabel.textColor = HomeDesign.black
                self.detailsLabel.numberOfLines = 2
                self.detailsLabel.adjustsFontSizeToFitWidth = true
                super.init()
                self.correctorIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CorrectionsView.Cell.iconTapped(sender:))))
                self.detailsContainer.isUserInteractionEnabled = true
                self.detailsContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CorrectionsView.Cell.detailsLabelTapped(sender:))))
                self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] _ in
                    if let `self` = self {
                        self.updateText()
                    }
                })
            }
            required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
            deinit {
                self.timer?.invalidate()
            }
            
            override func willMove(toSuperview newSuperview: UIView?) {
                guard newSuperview != nil else { return }
                
                self.addSubview(self.container)
                self.container.topAnchor.constraint(equalTo: self.topAnchor, constant: HomeLayout.smargin).isActive = true
                self.container.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
                self.container.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
                self.container.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
                self.container.addSubview(self.correctorIcon)
                self.correctorIcon.topAnchor.constraint(equalTo: self.container.topAnchor, constant: HomeLayout.smargin).isActive = true
                self.correctorIcon.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: HomeLayout.smargin).isActive = true
                self.container.addSubview(self.correctorArrow)
                self.correctorArrow.leadingAnchor.constraint(equalTo: self.correctorIcon.trailingAnchor).isActive = true
                self.correctorArrow.centerYAnchor.constraint(equalTo: self.correctorIcon.centerYAnchor).isActive = true
                self.correctorArrow.widthAnchor.constraint(equalToConstant: 30.0).isActive = true
                self.correctorArrow.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
                self.container.addSubview(self.correctedContainer)
                self.correctedContainer.leadingAnchor.constraint(equalTo: self.correctorArrow.trailingAnchor, constant: -HomeLayout.dmargin).isActive = true
                self.correctedContainer.centerYAnchor.constraint(equalTo: self.correctorArrow.centerYAnchor).isActive = true
                self.correctedContainer.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.smargin).isActive = true
                self.correctedContainer.heightAnchor.constraint(equalTo: self.correctorIcon.heightAnchor).isActive = true
                self.container.addSubview(self.detailsContainer)
                self.detailsContainer.topAnchor.constraint(equalTo: self.correctorIcon.bottomAnchor, constant: HomeLayout.smargin).isActive = true
                self.detailsContainer.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: HomeLayout.smargin).isActive = true
                self.detailsContainer.trailingAnchor.constraint(equalTo: self.container.trailingAnchor, constant: -HomeLayout.smargin).isActive = true
                self.detailsContainer.bottomAnchor.constraint(equalTo: self.container.bottomAnchor, constant: -HomeLayout.smargin).isActive = true
                self.detailsContainer.addSubview(self.detailsLabel)
                self.detailsLabel.topAnchor.constraint(equalTo: self.detailsContainer.topAnchor, constant: HomeLayout.smargin).isActive = true
                self.detailsLabel.leadingAnchor.constraint(equalTo: self.detailsContainer.leadingAnchor, constant: HomeLayout.smargin).isActive = true
                self.detailsLabel.trailingAnchor.constraint(equalTo: self.detailsContainer.trailingAnchor, constant: -HomeLayout.smargin).isActive = true
                self.detailsLabel.bottomAnchor.constraint(equalTo: self.detailsContainer.bottomAnchor, constant: -HomeLayout.smargin).isActive = true
            }
            
            private unowned(unsafe) var scaleTeam: IntraScaleTeam! = nil
            func update(with scaleTeam: IntraScaleTeam, primary: UIColor) {
                var recycledCorrecteds = self.correctedContainer.subviews as! [UserView]
                var correctedIcon: UserView
                var leadingAnchor = self.correctedContainer.leadingAnchor
                
                self.scaleTeam = scaleTeam
                
                if let corrector = scaleTeam.corrector {
                    self.correctorIcon.update(with: corrector)
                }
                else {
                    self.correctorIcon.reset()
                }
                // self.correctorIcon.backgroundColor = primary.withAlphaComponent(HomeDesign.alphaLowLayer)
                
                for recycledCorrected in recycledCorrecteds {
                    recycledCorrected.removeFromSuperview()
                }
                for corrected in scaleTeam.correcteds {
                    if recycledCorrecteds.count > 0 {
                        correctedIcon = recycledCorrecteds.removeLast()
                        correctedIcon.update(with: corrected)
                    }
                    else {
                        correctedIcon = UserView(user: corrected)
                        correctedIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CorrectionsView.Cell.iconTapped(sender:))))
                    }
                    self.correctedContainer.addSubview(correctedIcon)
                    correctedIcon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: HomeLayout.dmargin).isActive = true
                    correctedIcon.topAnchor.constraint(equalTo: self.correctedContainer.topAnchor).isActive = true
                    correctedIcon.bottomAnchor.constraint(equalTo: self.correctedContainer.bottomAnchor).isActive = true
                    // correctedIcon.backgroundColor = primary.withAlphaComponent(HomeDesign.alphaLowLayer)
                    leadingAnchor = correctedIcon.trailingAnchor
                }
                if scaleTeam.correcteds.count == 0 {
                    if recycledCorrecteds.count > 0 {
                        correctedIcon = recycledCorrecteds.removeLast()
                        correctedIcon.reset()
                    }
                    else {
                        correctedIcon = UserView()
                        correctedIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CorrectionsView.Cell.iconTapped(sender:))))
                    }
                    self.correctedContainer.addSubview(correctedIcon)
                    correctedIcon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: HomeLayout.dmargin).isActive = true
                    correctedIcon.topAnchor.constraint(equalTo: self.correctedContainer.topAnchor).isActive = true
                    correctedIcon.bottomAnchor.constraint(equalTo: self.correctedContainer.bottomAnchor).isActive = true
                    correctedIcon.trailingAnchor.constraint(equalTo: self.correctedContainer.trailingAnchor).isActive = true
                    // correctedIcon.backgroundColor = primary.withAlphaComponent(HomeDesign.alphaLowLayer)
                }
                else {
                    leadingAnchor.constraint(equalTo: self.correctedContainer.trailingAnchor, constant: -HomeLayout.smargin).isActive = true
                }
                self.updateText()
                self.primary = primary
                self.correctorArrow.tintColor = self.primary.withAlphaComponent(HomeDesign.alphaLow)
                self.detailsContainer.backgroundColor = self.primary.withAlphaComponent(HomeDesign.alphaLowLayer)
                self.container.backgroundColor = primary.withAlphaComponent(HomeDesign.alphaLowLayer)
                self.updateText()
            }
            
            private func updateText() {
                guard let scaleTeam = self.scaleTeam else {
                    return
                }
                let projectName: String
                
                if let project = scaleTeam.associatedProject {
                    projectName = project.parent != nil ? (project.name + " - " + project.parent!.name) : project.name
                }
                else {
                    projectName = "???"
                }
                if let correctorId = scaleTeam.corrector?.id, correctorId == App.user.id {
                    self.detailsLabel.text = String(format: ~"you-will-correct",
                                                    scaleTeam.team.name, projectName)
                }
                else {
                    self.detailsLabel.text = String(format: ~"you-will-be-corrected",
                                                    scaleTeam.correcteds.first?.login ?? "???", projectName)
                }
                self.detailsLabel.text = self.detailsLabel.text! + "\n" + scaleTeam.beginAtDate.newDiffTime(to: Date())
            }
            
            @objc private func detailsLabelTapped(sender: UITapGestureRecognizer) {
                if let userInfo = self.scaleTeam.correcteds.first {
                    Task.init(priority: .userInitiated, operation: {
                        do {
                            let user: IntraUser = try await HomeApi.get(.userWithId(userInfo.id))
                            let vc: UserProjectViewController
                            
                            if let userProject = user.projects_users.first(where: { $0.project.id == self.scaleTeam.team.project_id }) {
                                vc = UserProjectViewController(user: user, userProject: userProject, primary: self.primary)
                                self.parentHomeViewController?.presentWithBlur(vc)
                            }
                        }
                        catch {
                            DynamicAlert.presentWith(error: error as! HomeApi.RequestError)
                        }
                    })
                }
            }
            
            @objc private func iconTapped(sender: UITapGestureRecognizer) {
                let user = (sender.view as! UserView).user!
                let profil = ProfilViewController()
                
                Task.init(priority: .userInitiated, operation: {
                    await profil.setupWithUser(user.login, id: user.id)
                })
                self.parentHomeViewController?.presentWithBlur(profil, completion: nil)
            }
        }
        
        private var scaleTeams: ContiguousArray<IntraScaleTeam> = []
        
        func refreshUserCorrections() throws {
            Task.init(priority: .userInitiated, operation: {
                let newHeight: CGFloat
                let count: Int
                
                self.scaleTeams = try await HomeApi.get(.meScaleTeams,
                                                        params: ["page[size]": 15, "sort": "-begin_at"])
                count = min(self.scaleTeams.count, self.isSizeLimited ? 15 : App.settings.profilCorrectionsCount)
                self.isLoading = false
                if self.scaleTeams.count == 0 {
                    newHeight = HomeLayout.userProfilCorrectionViewEmptyHeight
                }
                else {
                    if self.isSizeLimited && self.scaleTeams.count > 1 {
                        newHeight = HomeLayout.userProfilCorrectionViewCellHeight * 1
                        self.tableView.isScrollEnabled = true
                    }
                    else {
                        self.tableView.isScrollEnabled = false
                        newHeight = HomeLayout.userProfilCorrectionViewCellHeight * CGFloat(count)
                    }
                }
                self.tableView.reloadSections(.init(integer: 0), with: .fade)
                if let cell: UITableViewCell = self.parent(), let table: UITableView = cell.parent() {
                    table.beginUpdates()
                    self.tableViewHeight.constant = newHeight
                    cell.contentView.layoutIfNeeded()
                    table.endUpdates()
                }
                else {
                    HomeAnimations.animateMedium({
                        self.tableViewHeight.constant = newHeight
                        self.parentViewController?.view.layoutIfNeeded()
                        // FIXME: what happen if parent is nil?
                    })
                }
            })
        }
    
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if self.scaleTeams.count == 0 {
                return 1
            }
            return min(self.scaleTeams.count, self.isSizeLimited ? 15 : App.settings.profilCorrectionsCount)
        }
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            if self.scaleTeams.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "message", for: indexPath) as! MessageTableViewCell
                
                cell.update(with: self.isLoading ? ~"general.loading" : ~"profil.no-futur-correction", primary: self.primary)
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! GenericTableViewCell<CorrectionsView.Cell>
                
                cell.view.update(with: self.scaleTeams[indexPath.row], primary: self.primary)
                return cell
            }
        }
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            if self.scaleTeams.count == 0 {
                return HomeLayout.userProfilCorrectionViewEmptyHeight
            }
            return UITableView.automaticDimension
        }
    }
}

private extension ProfilViewController {
    
    final private class UserLogsTableViewCell: BasicUITableViewCell {
        
        private let title: LeftCurvedTitleView
        private let leftButton: ActionButtonView
        private let rightButton: ActionButtonView
        private let dayViewsContainer: BasicUIView
        
        private var today: Date = Date()
        private unowned(unsafe) var primary: UIColor = HomeDesign.primary
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            self.title = LeftCurvedTitleView(text: ~Date.monthsKeys[self.today.month &- 1], primaryColor: self.primary, addTopCorner: false)
            self.leftButton = ActionButtonView(asset: .actionArrowLeft, color: self.primary)
            self.rightButton = ActionButtonView(asset: .actionArrowRight, color: self.primary)
            self.dayViewsContainer = BasicUIView()
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            self.leftButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UserLogsTableViewCell.leftGesture)))
            self.rightButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UserLogsTableViewCell.rightGesture)))
            self.dayViewsContainer.isUserInteractionEnabled = true
            self.dayViewsContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UserLogsTableViewCell.tapGesture(gesture:))))
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        func setup(with userId: Int, primary: UIColor) {
            
        }
        
        @objc private func leftGesture() {
            
        }
        @objc private func rightGesture() {
            
        }
        @objc private func tapGesture(gesture: UITapGestureRecognizer) {
            let location = gesture.location(in: self.dayViewsContainer)
            
            if let _ = self.dayViewsContainer.subviews.first(where: { $0.frame.contains(location) }) {
                Task.init(priority: .userInitiated, operation: {
                    do {
                        let locations: ContiguousArray<IntraClusterLocation> = try await HomeApi.get(.usersWithUserIdLocations(App.user.id), params: ["sort": "begin_at"])
                        
                        dump(locations)
                    }
                    catch {
                        
                    }
                })
            }
        }
        
        
        static private let rowCount: Int = 6
        static private let colomnCount: Int = 7
        
        private func configureCurrentMonth() {
            var index: Int = 0
            let offset = self.today.weekday
            let count = self.today.monthDays
            
            print(self.today.weekday, self.today.weekdayOrdinal)
            for _ in 0 ..< UserLogsTableViewCell.rowCount {
                for _ in 0 ..< UserLogsTableViewCell.colomnCount {
                    if index < offset {
                        (self.dayViewsContainer.subviews[index] as! DayView).text = ""
                    }
                    else if index + offset < count {
                        (self.dayViewsContainer.subviews[index] as! DayView).text = "\(index - offset)"
                    }
                    else {
                        (self.dayViewsContainer.subviews[index] as! DayView).text = ""
                    }
                    index &+= 1
                }
            }
        }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil && self.dayViewsContainer.superview == nil else { return }
            let width = floor((UIScreen.main.bounds.width - HomeLayout.margin * 2.0 - HomeLayout.smargin * CGFloat(UserLogsTableViewCell.colomnCount - 1)) / CGFloat(UserLogsTableViewCell.colomnCount))
            var dayView: DayView!
            var lastDayView: DayView? = nil
            var top: NSLayoutYAxisAnchor = self.dayViewsContainer.topAnchor
            
            self.contentView.addSubview(self.title)
            self.title.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
            self.title.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
            self.title.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
            self.contentView.addSubview(self.rightButton)
            self.rightButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -HomeLayout.smargin).isActive = true
            self.rightButton.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: LeftCurvedTitleView.minHeight).isActive = true
            self.contentView.addSubview(self.leftButton)
            self.leftButton.centerYAnchor.constraint(equalTo: self.rightButton.centerYAnchor).isActive = true
            self.leftButton.trailingAnchor.constraint(equalTo: self.rightButton.leadingAnchor, constant: -HomeLayout.dmargin).isActive = true
            self.contentView.addSubview(self.dayViewsContainer)
            self.dayViewsContainer.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true
            self.dayViewsContainer.topAnchor.constraint(equalTo: self.title.bottomAnchor, constant: HomeLayout.margins).isActive = true
            self.dayViewsContainer.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -HomeLayout.smargin).isActive = true
            for _ in 0 ..< UserLogsTableViewCell.rowCount {
                for _ in 0 ..< UserLogsTableViewCell.colomnCount {
                    dayView = DayView()
                    self.dayViewsContainer.addSubview(dayView)
                    dayView.topAnchor.constraint(equalTo: top, constant: HomeLayout.smargin).isActive = true
                    dayView.widthAnchor.constraint(equalToConstant: width).isActive = true
                    dayView.heightAnchor.constraint(equalToConstant: width).isActive = true
                    if let last = lastDayView {
                        dayView.leadingAnchor.constraint(equalTo: last.trailingAnchor, constant: HomeLayout.smargin).isActive = true
                    }
                    else {
                        dayView.leadingAnchor.constraint(equalTo: self.dayViewsContainer.leadingAnchor).isActive = true
                    }
                    lastDayView = dayView
                }
                lastDayView!.trailingAnchor.constraint(equalTo: self.dayViewsContainer.trailingAnchor).isActive = true
                lastDayView = nil
                top = dayView.bottomAnchor
            }
            dayView.bottomAnchor.constraint(equalTo: self.dayViewsContainer.bottomAnchor).isActive = true
            self.configureCurrentMonth()
        }
        
        final private class DayView: BasicUILabel {
            
            init() {
                super.init(text: "?")
                self.textAlignment = .center
                self.layer.masksToBounds = true
                self.layer.cornerRadius = HomeLayout.scorner
                self.font = HomeLayout.fontSemiBoldNormal
                self.textColor = HomeDesign.black
                // self.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMinYCorner]
                self.backgroundColor = HomeDesign.lightGray
            }
            required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        }
        
        func setPrimary(_ color: UIColor) {
            if self.primary != color {
                self.primary = color
                // update
            }
        }
    }
}

private extension ProfilViewController {
    
    final private class ProjectsTableViewCell: BasicUITableViewCell, UITableViewDelegate, UITableViewDataSource, SegmentViewDelegate {
        private let title: LeftCurvedTitleView
        private let segment: SegmentView
        private let tableView: BasicUITableView
        private let tableViewHeigth: NSLayoutConstraint
        private let gradientTop: GradientView
        private let gradientBottom: GradientView
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            self.title = LeftCurvedTitleView(text: ~"general.projects", primaryColor: HomeDesign.primary, addTopCorner: false)
            self.segment = SegmentView(values: [~"general.inrun", ~"general.ended"], selectedIndex: 0)
            self.tableView = BasicUITableView()
            self.tableView.register(UserProjectTableViewCell.self, forCellReuseIdentifier: "cell")
            self.tableViewHeigth = self.tableView.heightAnchor.constraint(equalToConstant: 0.0)
            self.tableViewHeigth.priority = .defaultLow
            self.tableView.contentInset = .init(top: HomeLayout.smargin, left: 0.0, bottom: HomeLayout.smargin, right: 0.0)
            self.gradientTop = GradientView()
            self.gradientTop.startPoint = .init(x: 0.5, y: 0.0)
            self.gradientTop.endPoint = .init(x: 0.5, y: 1.0)
            self.gradientTop.colors = [HomeDesign.white.cgColor, UIColor.init(white: 1.0, alpha: 0.0).cgColor]
            self.gradientBottom = GradientView()
            self.gradientBottom.startPoint = .init(x: 0.5, y: 0.0)
            self.gradientBottom.endPoint = .init(x: 0.5, y: 1.0)
            self.gradientBottom.colors = [UIColor.init(white: 1.0, alpha: 0.0).cgColor, HomeDesign.white.cgColor]
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            self.segment.delegate = self
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.backgroundColor = HomeDesign.white
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }
            
            self.contentView.addSubview(self.title)
            self.title.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
            self.title.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
            self.title.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
            self.contentView.addSubview(self.segment)
            self.segment.leadingAnchor.constraint(equalTo: self.title.leadingAnchor, constant: HomeLayout.margin).isActive = true
            self.segment.trailingAnchor.constraint(equalTo: self.title.trailingAnchor, constant: -HomeLayout.margin).isActive = true
            self.segment.topAnchor.constraint(equalTo: self.title.bottomAnchor, constant: HomeLayout.smargin).isActive = true
            self.contentView.addSubview(self.tableView)
            self.tableViewHeigth.isActive = true
            self.tableView.topAnchor.constraint(equalTo: self.segment.bottomAnchor).isActive = true
            self.tableView.leadingAnchor.constraint(equalTo: self.segment.leadingAnchor).isActive = true
            self.tableView.trailingAnchor.constraint(equalTo: self.segment.trailingAnchor).isActive = true
            self.tableView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
            self.contentView.addSubview(self.gradientTop)
            self.gradientTop.topAnchor.constraint(equalTo: self.segment.bottomAnchor).isActive = true
            self.gradientTop.leadingAnchor.constraint(equalTo: self.tableView.leadingAnchor).isActive = true
            self.gradientTop.trailingAnchor.constraint(equalTo: self.tableView.trailingAnchor).isActive = true
            self.gradientTop.heightAnchor.constraint(equalToConstant: HomeLayout.smargin).isActive = true
            self.contentView.addSubview(self.gradientBottom)
            self.gradientBottom.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
            self.gradientBottom.leadingAnchor.constraint(equalTo: self.tableView.leadingAnchor).isActive = true
            self.gradientBottom.trailingAnchor.constraint(equalTo: self.tableView.trailingAnchor).isActive = true
            self.gradientBottom.heightAnchor.constraint(equalToConstant: HomeLayout.smargin).isActive = true
        }
        
        private unowned(unsafe) var user: IntraUser!
        private unowned(unsafe) var primary: UIColor!
        private var inrun: ContiguousArray<IntraUserProject>!
        private var ended: ContiguousArray<IntraUserProject>!
        func update(with user: IntraUser, cursus: IntraUserCursus, primary: UIColor) {
            self.user = user
            self.primary = primary
            self.inrun = []
            self.inrun.reserveCapacity(user.projects_users.count)
            self.ended = []
            self.ended.reserveCapacity(user.projects_users.count)
            for project in user.projects_users.filter({ $0.cursus_ids.contains(cursus.cursus_id) && $0.project.parent_id == nil }) {
                switch project.status {
                case .creatingGroup, .inProgress, .waitingForCorrection, .searchingGroup:
                    self.inrun.append(project)
                default:
                    self.ended.append(project)
                }
            }
            self.segment.primary = primary
            if self.inrun.count == 0 && self.ended.count > 0 {
                self.segment.setSelectedIndex(1)
            }
            self.title.update(with: self.title.text!, primaryColor: primary, animate: true)
            self.updateTableViewHeight()
            self.tableView.reloadData()
        }
        private func updateTableViewHeight() {
            let width = (UIScreen.main.bounds.width - HomeLayout.margin * 2.0)
            
            if self.segment.selectedIndex == 0 {
                self.tableViewHeigth.constant = CGFloat(self.inrun.count) * HomeLayout.profilProjectViewCellHeigth + HomeLayout.smargin * 2.0
            }
            else {
                self.tableViewHeigth.constant = CGFloat(self.ended.count) * HomeLayout.profilProjectViewCellHeigth + HomeLayout.smargin * 2.0
            }
            if self.tableViewHeigth.constant > width {
                self.tableViewHeigth.constant = width
            }
        }
        
        func segmentViewSelect(_ segmentView: SegmentView) {
            self.tableView.reloadSections(.init(integer: 0), with: .fade)
            if let table: UITableView = self.parent() {
                table.beginUpdates()
                self.updateTableViewHeight()
                self.layoutIfNeeded()
                table.endUpdates()
            }
        }

        final private class UserProjectTableViewCell: BasicUITableViewCell {
            private let container: BasicUIView = BasicUIView()
            private let nameLabel: BasicUILabel = BasicUILabel(text: "???")
            private let extraLabel: HomeInsetsLabel = HomeInsetsLabel(text: "???", inset: .init(width: HomeLayout.margin, height: 0.0))
            
            override func willMove(toSuperview newSuperview: UIView?) {
                guard newSuperview != nil else { return }
                
                self.contentView.addSubview(self.container)
                self.container.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: HomeLayout.smargin).isActive = true
                self.container.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
                self.container.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
                self.container.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
                self.container.layer.cornerRadius = HomeLayout.scorner
                self.container.addSubview(self.nameLabel)
                self.nameLabel.font = HomeLayout.fontRegularMedium
                self.nameLabel.textColor = HomeDesign.black
                self.nameLabel.adjustsFontSizeToFitWidth = true
                self.nameLabel.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: HomeLayout.smargin).isActive = true
                self.nameLabel.centerYAnchor.constraint(equalTo: self.container.centerYAnchor).isActive = true
                self.container.addSubview(self.extraLabel)
                self.extraLabel.layer.cornerRadius = HomeLayout.scorner
                self.extraLabel.layer.masksToBounds = true
                self.extraLabel.textAlignment = .center
                self.extraLabel.textColor = HomeDesign.white
                self.extraLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: HomeLayout.profilProjectViewCellExtraMinWidth).isActive = true
                self.extraLabel.trailingAnchor.constraint(equalTo: self.container.trailingAnchor, constant: -HomeLayout.smargin).isActive = true
                self.extraLabel.centerYAnchor.constraint(equalTo: self.container.centerYAnchor).isActive = true
                self.nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.extraLabel.leadingAnchor, constant: -HomeLayout.smargin).isActive = true
                self.nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            }
            
            func updateInrunProject(with project: IntraUserProject, primary: UIColor) {
                self.nameLabel.text = project.project.name
                self.extraLabel.backgroundColor = primary
                self.extraLabel.text = ~project.status.key
                self.extraLabel.font = HomeLayout.fontRegularMedium
                self.container.backgroundColor = primary.withAlphaComponent(HomeDesign.alphaLowLayer)
            }
            func updateEndedProject(with project: IntraUserProject) {
                let mark = project.final_mark ?? 100
                let markColor = IntraUserProject.finalMarkColor(project.final_mark ?? 100)
                
                self.nameLabel.text = project.project.name
                self.extraLabel.text = "\(mark)"
                self.extraLabel.font = HomeLayout.fontBoldMedium
                self.extraLabel.backgroundColor = markColor
                self.container.backgroundColor = markColor.withAlphaComponent(HomeDesign.alphaLowLayer)
            }
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return HomeLayout.profilProjectViewCellHeigth
        }
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if self.user == nil {
                return 0
            }
            if self.segment.selectedIndex == 0 {
                return self.inrun.count
            }
            return self.ended.count
        }
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UserProjectTableViewCell
            
            if self.segment.selectedIndex == 0 {
                cell.updateInrunProject(with: self.inrun[indexPath.row], primary: self.primary)
            }
            else {
                cell.updateEndedProject(with: self.ended[indexPath.row])
            }
            return cell
        }
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let project: IntraUserProject = self.segment.selectedIndex == 0 ? self.inrun[indexPath.row] : self.ended[indexPath.row]
            let viewController = UserProjectViewController(user: self.user, userProject: project, primary: self.primary)
            
            self.parentHomeViewController?.presentWithBlur(viewController)
        }
    }
}

fileprivate extension ProfilViewController {
    
    final private class SkillsTableViewCell: BasicUITableViewCell {
        private let title: LeftCurvedTitleView
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            self.title = LeftCurvedTitleView(text: ~"general.skills", primaryColor: HomeDesign.primary, addTopCorner: false)
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            self.layer.isOpaque = true
            self.layer.shouldRasterize = true
            self.layer.rasterizationScale = UIScreen.main.scale
            self.backgroundColor = HomeDesign.white
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }
      
            self.addSubview(self.title)
            self.title.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            self.title.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            self.title.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            self.heightAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        }
        
        unowned(unsafe) var primaryColor: UIColor = HomeDesign.primaryDefault
                
        final private class BubbleView: HomePressableUIView {
            unowned(unsafe) var skill: IntraUserSkill!
            
            init(skill: IntraUserSkill) {
                self.skill = skill
                super.init()
                self.layer.borderColor = HomeDesign.black.cgColor
                self.layer.borderWidth = HomeLayout.sborder
            }
            required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
            
            override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
                super.touchesBegan(touches, with: event)
                if let superview: SkillsTableViewCell = self.parent() {
                    superview.selectSkill(bubbleView: self)
                }
            }
        }
        
        private var skills: [IntraUserSkill]!
        func update(with skills: [IntraUserSkill], primary: UIColor) {
            self.primaryColor = primary
            self.title.update(with: ~"general.skills", primaryColor: primary, animate: false)
            self.skills = skills.sorted(by: { $0.id < $1.id })
            self.setNeedsDisplay()
        }
        
        private var selectedBubbleView: BubbleView? = nil
        private func selectSkill(bubbleView: BubbleView) {
            guard self.selectedBubbleView == nil || self.selectedBubbleView! != bubbleView else {
                return
            }
            
            self.title.update(with: String(format: "%.2f%% %@", bubbleView.skill.level / 20.0 * 100.0, bubbleView.skill.name), primaryColor: self.primaryColor, animate: true)
            HomeAnimations.animateShort({
                bubbleView.frame.size = .init(width: SkillsTableViewCell.bubbleSelectedHeigth, height: SkillsTableViewCell.bubbleSelectedHeigth)
                bubbleView.frame.origin.x -= SkillsTableViewCell.bubbleSizeDiff
                bubbleView.frame.origin.y -= SkillsTableViewCell.bubbleSizeDiff
                bubbleView.layer.cornerRadius = SkillsTableViewCell.bubbleSelectedRadius
            }, completion: nil)
            if let last = self.selectedBubbleView {
                HomeAnimations.animateShort({
                    last.frame.size = .init(width: SkillsTableViewCell.bubbleHeigth, height: SkillsTableViewCell.bubbleHeigth)
                    last.frame.origin.x += SkillsTableViewCell.bubbleSizeDiff
                    last.frame.origin.y += SkillsTableViewCell.bubbleSizeDiff
                    last.layer.cornerRadius = SkillsTableViewCell.bubbleRadius
                }, completion: nil)
            }
            self.selectedBubbleView = bubbleView
        }
        
        static private let drawMargin: CGFloat = HomeLayout.margind
        static private let bubbleHeigth: CGFloat = 20.0
        static private let bubbleSelectedHeigth: CGFloat = 23.0
        static private let bubbleRadius: CGFloat = SkillsTableViewCell.bubbleHeigth / 2.0
        static private let bubbleSelectedRadius: CGFloat = SkillsTableViewCell.bubbleSelectedHeigth / 2.0
        static private let bubbleSizeDiff: CGFloat = (SkillsTableViewCell.bubbleSelectedHeigth - SkillsTableViewCell.bubbleHeigth) / 2.0
        override func draw(_ rect: CGRect) {
            guard self.skills != nil else { return }
            let context = UIGraphicsGetCurrentContext()!
            let middle = CGPoint(x: rect.size.width / 2.0, y: rect.size.height / 2.0 + HomeLayout.leftCurvedTitleViewHeigth / 2.0)
            let size = CGSize(width: (rect.size.width / 2.0) - SkillsTableViewCell.drawMargin, height: (rect.size.height / 2.0) - SkillsTableViewCell.drawMargin)
            let toupi = CGFloat.pi * 2.0
            
            let bezier = UIBezierPath()
            let angle = toupi / CGFloat(self.skills.count)
            var currentAngle: CGFloat = 0.0
            var level: CGFloat
            var pic: CGPoint
            var sommet: CGPoint
            var bubbleView: BubbleView
            
            HomeDesign.black.setStroke()
            context.setLineWidth(1.0)
            context.addArc(center: middle, radius: size.width, startAngle: 0.0, endAngle: toupi, clockwise: true)
            context.strokePath()
            context.addArc(center: middle, radius: size.width * 0.75, startAngle: 0.0, endAngle: toupi, clockwise: true)
            context.strokePath()
            context.addArc(center: middle, radius: size.width * 0.50, startAngle: 0.0, endAngle: toupi, clockwise: true)
            context.strokePath()
            context.addArc(center: middle, radius: size.width * 0.25, startAngle: 0.0, endAngle: toupi, clockwise: true)
            context.strokePath()
            
            if self.subviews.count > 1 {
                for subview in self.subviews where subview is BubbleView {
                    subview.removeFromSuperview()
                }
            }
            bezier.move(to: middle)
            for skill in skills {
                level = CGFloat(skill.level) / 20.0
                pic = .init(x: middle.x + (size.width * cos(currentAngle)) * level, y: middle.y + (size.height * sin(currentAngle)) * level)
                sommet = .init(x: (middle.x + size.width * cos(currentAngle)), y: middle.y + (size.height * sin(currentAngle)))
                bubbleView = BubbleView(skill: skill)
                bubbleView.layer.cornerRadius = SkillsTableViewCell.bubbleRadius
                bubbleView.frame = .init(x: sommet.x - SkillsTableViewCell.bubbleRadius,
                                         y: sommet.y - SkillsTableViewCell.bubbleRadius,
                                         width: SkillsTableViewCell.bubbleHeigth, height: SkillsTableViewCell.bubbleHeigth)
                bubbleView.backgroundColor = self.primaryColor
                self.addSubview(bubbleView)
                context.move(to: middle)
                context.addLine(to: sommet)
                context.strokePath()
                if currentAngle == 0.0 {
                    bezier.move(to: pic)
                }
                else {
                    bezier.addLine(to: pic)
                }
                currentAngle += angle
            }
            self.primaryColor.withAlphaComponent(HomeDesign.alphaLayer).setFill()
            self.primaryColor.setStroke()
            bezier.close()
            bezier.fill()
            bezier.stroke()
        }
    }
}

private extension ProfilViewController {
    
    final private class SectionTableViewCell: BasicUITableViewCell {
        private let header: LeftCurvedTitleView
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            self.header = LeftCurvedTitleView(text: "???", primaryColor: HomeDesign.primary, addTopCorner: false)
            self.header.backgroundColor = .clear
            super.init(style: style, reuseIdentifier: reuseIdentifier)
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }
          
            self.contentView.addSubview(self.header)
            self.header.removeConstraints(self.header.constraints)
            self.header.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
            self.header.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -HomeLayout.smargin).isActive = true
            self.header.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
            self.header.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
            self.header.heightAnchor.constraint(equalToConstant: HomeLayout.leftCurvedTitleViewHeigth).isActive = true
        }
        
        func update(with title: String, primaryColor: UIColor) {
            self.header.update(with: title, primaryColor: primaryColor)
        }
    }
    
    final private class PartnershipView: BasicUIView, HomeFramingTableViewCellView {
        static var edges: UIEdgeInsets = HomeLayout.profilCellInsets
        
        private let name: BasicUILabel
        private let xpLabel: BasicUILabel
        
        override init() {
            self.name = BasicUILabel(text: "???")
            self.name.font = HomeLayout.fontSemiBoldTitle
            self.name.textColor = HomeDesign.black
            self.name.adjustsFontSizeToFitWidth = true
            self.name.numberOfLines = 0
            self.xpLabel = BasicUILabel(text: "???")
            self.xpLabel.font = HomeLayout.fontThinMedium
            self.xpLabel.textColor = HomeDesign.black
            self.xpLabel.textAlignment = .right
            super.init()
            self.layer.cornerRadius = HomeLayout.scorner
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }
     
            self.addSubview(self.name)
            self.name.topAnchor.constraint(equalTo: self.topAnchor, constant: HomeLayout.margin).isActive = true
            self.name.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: HomeLayout.margin).isActive = true
            self.name.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.margin).isActive = true
            self.addSubview(self.xpLabel)
            self.xpLabel.leadingAnchor.constraint(equalTo: self.name.leadingAnchor).isActive = true
            self.xpLabel.trailingAnchor.constraint(equalTo: self.name.trailingAnchor).isActive = true
            self.xpLabel.topAnchor.constraint(equalTo: self.name.bottomAnchor, constant: HomeLayout.margin).isActive = true
            self.xpLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -HomeLayout.margin).isActive = true
        }
        
        func update(with partnership: IntraUserPartnership, primary: UIColor) {
            self.name.text = partnership.name
            self.xpLabel.text = partnership.difficulty.scoreFormatted + " XP"
            self.xpLabel.textColor = primary
            self.backgroundColor = HomeDesign.lightGray
        }
    }
    
    final private class TitleView: BasicUIView, HomeFramingTableViewCellView {
        static var edges: UIEdgeInsets = HomeLayout.profilCellInsets
        
        private let name: BasicUILabel
        
        override init() {
            self.name = BasicUILabel(text: "")
            self.name.font = HomeLayout.fontSemiBoldTitle
            self.name.textColor = HomeDesign.black
            self.name.numberOfLines = 0
            super.init()
            self.layer.cornerRadius = HomeLayout.scorner
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }
            
            self.addSubview(self.name)
            self.name.topAnchor.constraint(equalTo: self.topAnchor, constant: HomeLayout.smargin).isActive = true
            self.name.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -HomeLayout.smargin).isActive = true
            self.name.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: HomeLayout.margin).isActive = true
            self.name.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.margin).isActive = true
        }
        
        func update(with title: IntraTitle, login: String, primary: UIColor) {
            let text = title.name.replacingOccurrences(of: "%login", with: login)
            let attr = NSMutableAttributedString(string: text, attributes: [.foregroundColor: HomeDesign.black, .font: HomeLayout.fontSemiBoldTitle])
            var locations: [Int] = []
            
            for (index, char) in text.enumerated() where char == login.first! && index + login.count <= text.count {
                if text[text.index(text.startIndex, offsetBy: index) ..< text.index(text.startIndex, offsetBy: index + login.count)] == login {
                    locations.append(index)
                }
            }
            for location in locations {
                attr.setAttributes([.foregroundColor: primary, .font: HomeLayout.fontBoldTitle], range: NSMakeRange(location, login.count))
            }
            self.name.attributedText = attr
            self.backgroundColor = HomeDesign.lightGray
        }
    }
    
    final private class ExpertiseView: BasicUIView, HomeFramingTableViewCellView {
        static var edges: UIEdgeInsets = HomeLayout.profilCellInsets
        
        private let name: BasicUILabel
        private let stars: StarsView
        
        override init() {
            self.name = BasicUILabel(text: "")
            self.name.font = HomeLayout.fontSemiBoldTitle
            self.name.textColor = HomeDesign.black
            self.name.adjustsFontSizeToFitWidth = true
            self.stars = StarsView()
            super.init()
            self.layer.cornerRadius = HomeLayout.scorner
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }
            
            self.addSubview(self.name)
            self.name.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            self.name.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: HomeLayout.margin).isActive = true
            self.addSubview(self.stars)
            self.stars.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            self.stars.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.margin).isActive = true
            self.name.trailingAnchor.constraint(lessThanOrEqualTo: self.stars.leadingAnchor, constant: -HomeLayout.smargin).isActive = true
            self.heightAnchor.constraint(equalToConstant: HomeLayout.profilCellExpertiseHeigth).isActive = true
        }
        
        func update(with expertise: IntraUserExpertise, primary: UIColor) {
            self.name.text = HomeApiResources.expertises[expertise.expertise_id]?.name ?? "???"
            self.stars.note = expertise.value
            self.stars.primary = primary
            self.backgroundColor = HomeDesign.lightGray
        }
    }
    
    final private class AchievementView: BasicUIView, HomeFramingTableViewCellView {
        static var edges: UIEdgeInsets = HomeLayout.profilCellInsets
        
        private let imageView: BasicUIImageView
        private let nameLabel: BasicUILabel
        private let descriptionContainer: BasicUIView
        private let descriptionLabel: BasicUILabel
        
        override init() {
            self.imageView = .init(image: nil)
            self.imageView.contentMode = .scaleAspectFill
            self.imageView.layer.cornerRadius = HomeLayout.scorner
            self.imageView.layer.masksToBounds = true
            self.nameLabel = BasicUILabel(text: "???")
            self.nameLabel.font = HomeLayout.fontSemiBoldTitle
            self.nameLabel.textColor = HomeDesign.black
            self.nameLabel.numberOfLines = 0
            self.descriptionContainer = BasicUIView()
            self.descriptionContainer.layer.cornerRadius = HomeLayout.scorner
            self.descriptionLabel = BasicUILabel(text: "???")
            self.descriptionLabel.font = HomeLayout.fontRegularMedium
            self.descriptionLabel.textColor = HomeDesign.black
            self.descriptionLabel.numberOfLines = 0
            super.init()
            self.layer.cornerRadius = HomeLayout.scorner
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }
          
            self.addSubview(self.imageView)
            self.imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: HomeLayout.margin).isActive = true
            self.imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: HomeLayout.margin).isActive = true
            self.imageView.heightAnchor.constraint(equalToConstant: HomeLayout.profilAchievementImageSize).isActive = true
            self.imageView.widthAnchor.constraint(equalToConstant: HomeLayout.profilAchievementImageSize).isActive = true
            self.addSubview(self.nameLabel)
            self.nameLabel.leadingAnchor.constraint(equalTo: self.imageView.trailingAnchor, constant: HomeLayout.margin).isActive = true
            self.nameLabel.centerYAnchor.constraint(equalTo: self.imageView.centerYAnchor).isActive = true
            self.nameLabel.topAnchor.constraint(lessThanOrEqualTo: self.imageView.topAnchor).isActive = true
            self.nameLabel.bottomAnchor.constraint(lessThanOrEqualTo: self.imageView.bottomAnchor).isActive = true
            self.nameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.smargin).isActive = true
            self.addSubview(self.descriptionContainer)
            self.descriptionContainer.topAnchor.constraint(equalTo: self.imageView.bottomAnchor, constant: HomeLayout.margin).isActive = true
            self.descriptionContainer.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: HomeLayout.smargin).isActive = true
            self.descriptionContainer.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.smargin).isActive = true
            self.descriptionContainer.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -HomeLayout.smargin).isActive = true
            self.descriptionContainer.addSubview(self.descriptionLabel)
            self.descriptionLabel.topAnchor.constraint(equalTo: self.descriptionContainer.topAnchor, constant: HomeLayout.smargin).isActive = true
            self.descriptionLabel.leadingAnchor.constraint(equalTo: self.descriptionContainer.leadingAnchor, constant: HomeLayout.smargin).isActive = true
            self.descriptionLabel.trailingAnchor.constraint(equalTo: self.descriptionContainer.trailingAnchor, constant: -HomeLayout.smargin).isActive = true
            self.descriptionLabel.bottomAnchor.constraint(equalTo: self.descriptionContainer.bottomAnchor, constant: -HomeLayout.smargin).isActive = true
        }
        
        private unowned(unsafe) var achievement: IntraUserAchievement!
        
        func update(with achievement: IntraUserAchievement, primary: UIColor) {
            self.achievement = achievement
            if let image = HomeResources.storageSVGAchievement.get(achievement) {
                self.imageView.image = image
            }
            else {
                Task.init(priority: .userInitiated, operation: {
                    if let (achiev, image) = await HomeResources.storageSVGAchievement.obtain(achievement), achiev.id == self.achievement.id {
                        self.imageView.image = image
                    }
                })
            }
            self.nameLabel.text = achievement.name
            self.descriptionLabel.text = achievement.achievementDescription
            if achievement.visible {
                self.backgroundColor = HomeDesign.lightGray
                self.descriptionContainer.backgroundColor = primary.withAlphaComponent(HomeDesign.alphaLowLayer)
            }
            else {
                self.backgroundColor = HomeDesign.gold.withAlphaComponent(HomeDesign.alphaLowLayer)
                self.descriptionContainer.backgroundColor = HomeDesign.gold.withAlphaComponent(HomeDesign.alphaLowLayer)
            }
        }
    }
}
