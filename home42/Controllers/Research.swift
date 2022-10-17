// home42/Research.swift
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
import SwiftUI

final class ResearchViewController: HomeViewController, UITableViewDelegate, UITableViewDataSource {
    
    @frozen enum ResearchSection: Int, CaseIterable {
        case peoples = 0
        case items = 1
    }
    
    // MARK: Peoples
    private var peoplesListType: [People.ListType]
    
    // MARK: - Items
    private struct ResearchItem {
        let titleKey: String
        let icon: UIImage.Assets?
        let descriptionKey: String
        let warningKey: String?
        let selector: Selector
        
        init(titleKey: String, _ descriptionKey: String, selector: Selector, icon: UIImage.Assets? = nil, warningKey: String? = nil) {
            self.titleKey = titleKey
            self.icon = icon
            self.descriptionKey = descriptionKey
            self.warningKey = warningKey
            self.selector = selector
        }
    }
    static private let items: [ResearchItem] = [
        .init(titleKey: "general.users", "research.users",
              selector: #selector(ResearchViewController.seeUsers)),
        .init(titleKey: "research.users-admitted", "research.users-admitted-description",
              selector: #selector(ResearchViewController.seeUsersAdmitted)),
        .init(titleKey: "title.clusters", "research.clusters",
              selector: #selector(ResearchViewController.seeCampusClusters)),
        .init(titleKey: "general.users", "research.users-title",
              selector: #selector(ResearchViewController.seeUsersTitle)),
        .init(titleKey: "general.users", "research.users-group",
              selector: #selector(ResearchViewController.seeUsersGroup)),
        .init(titleKey: "general.users", "research.users-campus",
              selector: #selector(ResearchViewController.seeUsersCampus)),
        .init(titleKey: "general.projects", "research.projects",
              selector: #selector(ResearchViewController.seeProjectsList))
        // .init(titleKey: "title.coalitions", "research.coalitions", selector: #selector(ResearchViewController.seeCoalitions))
    ]
    
    private let tableView: BasicUITableView
    
    required init() {
        self.peoplesListType = [People.ListType.friends]
        if App.settings.peopleExtraList1Available {
            self.peoplesListType.append(.extraList1)
        }
        if App.settings.peopleExtraList2Available {
            self.peoplesListType.append(.extraList2)
        }
        self.tableView = BasicUITableView()
        self.tableView.register(HomeFramingTableViewCell<ResearchPeopleView>.self, forCellReuseIdentifier: "people")
        self.tableView.register(HomeFramingTableViewCell<ResearchView>.self, forCellReuseIdentifier: "item")
        self.tableView.contentInsetAdjustTopAndBottom()
        self.tableView.backgroundColor = .clear
        super.init()
        self.view.addSubview(self.tableView)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func numberOfSections(in tableView: UITableView) -> Int {
        return ResearchSection.allCases.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == ResearchSection.peoples.rawValue {
            if App.settings.peopleExtraList1Available && App.settings.peopleExtraList2Available {
                return 3
            }
            if App.settings.peopleExtraList1Available || App.settings.peopleExtraList2Available {
                return 2
            }
            return 1
        }
        return ResearchViewController.items.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == ResearchSection.peoples.rawValue {
            let cell = tableView.dequeueReusableCell(withIdentifier: "people") as! HomeFramingTableViewCell<ResearchPeopleView>
            
            cell.view.update(with: self.peoplesListType[indexPath.row])
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "item") as! HomeFramingTableViewCell<ResearchView>
        
        cell.view.update(with: ResearchViewController.items[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == ResearchSection.peoples.rawValue {
            return self.presentWithBlur(PeopleListViewController(with: self.peoplesListType[indexPath.row]))
        }
        self.perform(ResearchViewController.items[indexPath.row].selector)
    }
    
    @objc private func seeUsers() {
        self.presentWithBlur(UsersListViewController(.users))
    }
    
    @objc private func seeUsersTitle() {
        func selectTitle(_ title: IntraTitle) {
            self.presentWithBlur(UsersListViewController.init(.titlesWithTitleIdUsers(title.id),
                                                              primary: HomeDesign.primary,
                                                              extra: .title(title),
                                                              warnAboutIncorrectAPIResult: true))
        }

        DynamicAlert.init(.primary(~"title.titles"),
                          contents: [.advancedSelector(.title, Array<IntraTitle>(HomeApiResources.titles!), 0)],
                          actions: [.normal(~"general.cancel", nil), .getAdvancedSelector(unsafeBitCast(selectTitle, to: ((Any) -> ()).self))])
    }
    
    @objc private func seeUsersGroup() {
        func selectGroup(_ group: IntraGroup) {
            self.presentWithBlur(UsersListViewController.init(.groupsWithGroupIdUsers(group.id),
                                                              primary: HomeDesign.primary,
                                                              extra: .group(group),
                                                              warnAboutIncorrectAPIResult: true))
        }

        DynamicAlert.init(.primary(~"title.groups"),
                          contents: [.advancedSelector(.group, Array<IntraGroup>(HomeApiResources.groups!), 0)],
                          actions: [.normal(~"general.cancel", nil), .getAdvancedSelector(unsafeBitCast(selectGroup, to: ((Any) -> ()).self))])
    }
    
    @objc private func seeUsersCampus() {
        func selectCampus(_ campus: IntraCampus) {
            self.presentWithBlur(UsersListViewController.init(.users, primary: HomeDesign.primary, settings: [.campus(campus.id)]))
        }

        DynamicAlert.init(.primary(~"profil.info.campus"),
                          contents: [.advancedSelector(.campus, Array<IntraCampus>(HomeApiResources.campus!), 0)],
                          actions: [.normal(~"general.cancel", nil), .getAdvancedSelector(unsafeBitCast(selectCampus, to: ((Any) -> ()).self))])
    }
    
    @objc private func seeUsersAdmitted() {
        
        let date = Date()
        let months = Date.monthsKeys.map({ ~$0 })
        let title = ~"research.users-admitted"
        
        func selectMonth(index: Int, month: String) {
            let vc = UsersListViewController(.achievementsWithAchievementIdUsers(1),
                                             primary: HomeDesign.primary,
                                             settings: [.campus(App.userCampus.campus_id),
                                                        .poolMonth(Date.apiMonths[index]),
                                                        .poolYear(date.year)],
                                             extra: nil)
            
            vc.headerTitle = title
            self.presentWithBlur(vc, completion: nil)
        }
        
        DynamicAlert(.none,
                     contents: [.title(title), .roulette(months, months.count / 2)],
                     actions: [.normal(~"general.cancel", nil),
                               .getRoulette(~"general.select", selectMonth(index:month:))])
    }
    
    @objc private func seeCampusClusters() {
        
        func selectClusterCampus(_ campus: IntraCampus) {
            do {
                let vc = try ClustersSharedViewController(campus: .init(campus: campus), coalition: App.userCoalition)
                
                self.presentWithBlur(vc)
            }
            catch {
                HomeGuides.alertShowGuides(self)
            }
        }
        
        DynamicAlert.init(.primary(~"title.clusters"),
                          contents: [.advancedSelector(.clusters, Array<IntraCampus>(HomeApiResources.campus!), 0)],
                          actions: [.normal(~"general.cancel", nil), .getAdvancedSelector(unsafeBitCast(selectClusterCampus, to: ((Any) -> ()).self))])
    }
    
    @objc private func seeProjectsList() {
        self.presentWithBlur(ProjectListViewController())
    }
    
    @objc private func seeCoalitions() {
        self.presentWithBlur(CoalitionsListViewController())
    }
}

private extension ResearchViewController {
    
    final private class ResearchView: BasicUIView, HomeFramingTableViewCellView {
        static var edges: UIEdgeInsets = .init(top: HomeLayout.margin, left: HomeLayout.margin, bottom: 0.0, right: HomeLayout.margin)
        
        private let titleHeader: LeftCurvedTitleView
        private let descriptionLabel: BasicUILabel
        
        override init() {
            self.titleHeader = LeftCurvedTitleView(text: "???", primaryColor: HomeDesign.primary, addTopCorner: false)
            self.descriptionLabel = BasicUILabel(text: "???")
            self.descriptionLabel.font = HomeLayout.fontRegularMedium
            self.descriptionLabel.textColor = HomeDesign.black
            self.descriptionLabel.numberOfLines = 0
            self.descriptionLabel.textAlignment = .left
            super.init()
            self.backgroundColor = HomeDesign.white
            self.layer.cornerRadius = HomeLayout.corner
            self.layer.masksToBounds = true
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }
            
            self.addSubview(self.titleHeader)
            self.titleHeader.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            self.titleHeader.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            self.titleHeader.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            self.addSubview(self.descriptionLabel)
            self.descriptionLabel.topAnchor.constraint(equalTo: self.titleHeader.bottomAnchor, constant: HomeLayout.margin).isActive = true
            self.descriptionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: HomeLayout.margin).isActive = true
            self.descriptionLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.margin).isActive = true
            self.descriptionLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -HomeLayout.margin).isActive = true
        }
        
        func update(with item: ResearchItem) {
            self.titleHeader.update(with: ~item.titleKey, primaryColor: HomeDesign.primary)
            self.descriptionLabel.text = ~item.descriptionKey
        }
    }
    
    final private class ResearchPeopleView: BasicUIView, HomeFramingTableViewCellView {
        static var edges: UIEdgeInsets = .init(top: HomeLayout.margin, left: HomeLayout.margin,
                                               bottom: 0.0, right: HomeLayout.margin)
        
        private let titleHeader: LeftCurvedTitleView
        private let peopleButton: ActionButtonView
        
        override init() {
            self.titleHeader = LeftCurvedTitleView(text: "???", primaryColor: HomeDesign.primary, addTopCorner: false)
            self.peopleButton = ActionButtonView(asset: .actionPeopleKo, color: HomeDesign.primary)
            self.peopleButton.isUserInteractionEnabled = false
            self.peopleButton.alpha = 1.0
            super.init()
            self.backgroundColor = HomeDesign.white
            self.layer.cornerRadius = HomeLayout.corner
            self.layer.masksToBounds = true
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }
            
            self.addSubview(self.titleHeader)
            self.titleHeader.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            self.titleHeader.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            self.titleHeader.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            self.addSubview(self.peopleButton)
            self.peopleButton.topAnchor.constraint(equalTo: self.titleHeader.bottomAnchor, constant: HomeLayout.smargin).isActive = true
            self.peopleButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            self.peopleButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -HomeLayout.smargin).isActive = true
        }
        
        func update(with peopleList: People.ListType) {
            self.titleHeader.update(with: peopleList.title, primaryColor: peopleList.color)
            self.peopleButton.set(asset: peopleList.asset, color: peopleList.color)
        }
    }
}
