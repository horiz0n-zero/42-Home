// home42/ContributorsList.swift
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

final class ContributorsListViewController: HomeViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let header: HeaderWithActionsView
    private let tableView: BasicUITableView
    
    private var source: Array<Array<HomeApiResources.Contributor>>
    
    required init() {
        self.header = HeaderWithActionsView(title: ~"title.contributor", actions: nil)
        self.header.backgroundColor = HomeDesign.white
        self.tableView = BasicUITableView()
        self.tableView.estimatedSectionHeaderHeight = HomeLayout.leftCurvedTitleViewHeigth
        self.source = []
        self.source.reserveCapacity(HomeApiResources.contributorsGroups.count)
        for group in HomeApiResources.contributorsGroups {
            var contributors: [HomeApiResources.Contributor] = []
            
            for contributor in HomeApiResources.contributors where contributor.value.groups.contains(group) {
                contributors.append(contributor.value)
            }
            self.source.append(contributors)
        }
        super.init()
        self.view.addSubview(self.header)
        self.header.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.header.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.header.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(SeparatorTableViewCell<UserInfoView>.self, forCellReuseIdentifier: "cell")
        self.tableView.register(SectionTableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "header")
        self.view.addSubview(self.tableView)
        self.tableView.topAnchor.constraint(equalTo: self.header.bottomAnchor).isActive = true
        self.tableView.leadingAnchor.constraint(equalTo: self.header.leadingAnchor).isActive = true
        self.tableView.trailingAnchor.constraint(equalTo: self.header.trailingAnchor).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.source.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.source[section].count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SeparatorTableViewCell<UserInfoView>
        let contributor = self.source[indexPath.section][indexPath.row]
        let user = IntraUserInfo(id: contributor.id, login: contributor.login, image_url: contributor.image_url)
        
        cell.view.update(with: user)
        cell.separator.backgroundColor = HomeDesign.gold
        cell.separator.isHidden = indexPath.row &+ 1 >= self.source[indexPath.section].count
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as! SectionTableViewHeaderFooterView
        
        cell.update(with: HomeApiResources.contributorsGroups[section], primaryColor: HomeDesign.gold)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return HomeLayout.leftCurvedTitleViewHeigth
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = self.source[indexPath.section][indexPath.row]
        let vc = ProfilViewController()
        
        Task.init(priority: .userInitiated, operation: {
            await vc.setupWithUser(user.login, id: user.id)
        })
        self.presentWithBlur(vc)
    }
}
