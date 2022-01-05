//
//  Research.swift
//  home42
//
//  Created by Antoine Feuerstein on 17/05/2021.
//

import Foundation
import UIKit
import SwiftUI

final class ResearchViewController: HomeViewController, UITableViewDelegate, UITableViewDataSource {
    
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
        .init(titleKey: "USERS", "RESEARCH_USERS", selector: #selector(ResearchViewController.seeUsers)),
        .init(titleKey: "USERS", "RESEARCH_USERS_TITLE", selector: #selector(ResearchViewController.seeUsersTitle)),
        .init(titleKey: "USERS", "RESEARCH_USERS_GROUP", selector: #selector(ResearchViewController.seeUsersGroup)),
        .init(titleKey: "USERS", "RESEARCH_USERS_CAMPUS", selector: #selector(ResearchViewController.seeUsersCampus)),
        .init(titleKey: "PROJECTS", "RESEARCH_PROJECTS", selector: #selector(ResearchViewController.seeProjectsList))
        // .init(titleKey: "TITLE_COALITIONS", "RESEARCH_COALITIONS", selector: #selector(ResearchViewController.seeCoalitions))
    ]
    
    private let tableView: BasicUITableView
    
    required init() {
        self.tableView = BasicUITableView()
        self.tableView.register(HomeFramingTableViewCell<ResearchView>.self, forCellReuseIdentifier: "cell")
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            self.presentWithBlur(PeopleListViewController(with: .friends), completion: nil)
        })
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ResearchViewController.items.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! HomeFramingTableViewCell<ResearchView>
        
        cell.view.update(with: ResearchViewController.items[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.perform(ResearchViewController.items[indexPath.row].selector)
    }
    
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
    
    @objc private func seeUsers() {
        self.presentWithBlur(UsersListViewController.init(.users, primary: HomeDesign.primary))
    }
    
    @objc private func seeUsersTitle() {
        
        func selectTitle(_ index: Int, _ value: String) {
            let selection = HomeApiResources.titles[index]
            
            self.presentWithBlur(UsersListViewController.init(.titlesWithTitleIdUsers(selection.id), primary: HomeDesign.primary, extra: .title(selection)))
        }
        
        DynamicAlert.init(.primary(~"TITLE_TITLES"), contents: [.roulette(HomeApiResources.titles.map(\.name), 0)], actions: [.normal(~"CANCEL", nil), .getRoulette(~"SELECT", selectTitle(_:_:))])
    }
    
    @objc private func seeUsersGroup() {
        
        func selectGroup(_ index: Int, _ value: String) {
            let selection = HomeApiResources.groups[index]
            
            self.presentWithBlur(UsersListViewController.init(.groupsWithGroupIdUsers(selection.id), primary: HomeDesign.primary, extra: .group(selection)))
        }
        
        DynamicAlert.init(.primary(~"TITLE_GROUPS"), contents: [.roulette(HomeApiResources.groups.map(\.name), 0)], actions: [.normal(~"CANCEL", nil), .getRoulette(~"SELECT", selectGroup(_:_:))])
    }
    
    @objc private func seeUsersCampus() {
        
        func selectCampus(_ index: Int, _ value: String) {
            let selection = HomeApiResources.campus[index]
            
            self.presentWithBlur(UsersListViewController.init(.users, primary: HomeDesign.primary, settings: [.campus(selection.id)]))
        }
        
        DynamicAlert.init(.primary(~"INFO_CAMPUS"), contents: [.roulette(HomeApiResources.campus.map(\.name), 0)], actions: [.normal(~"CANCEL", nil), .getRoulette(~"SELECT", selectCampus(_:_:))])
    }
    
    @objc private func seeProjectsList() {
        self.presentWithBlur(ProjectListViewController())
    }
    
    @objc private func seeCoalitions() {
        self.presentWithBlur(CoalitionsListViewController())
    }
}
