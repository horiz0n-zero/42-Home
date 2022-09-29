// home42/CoalitionsList.swift
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

final class CoalitionsListViewController: HomeViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let header: HeaderWithActionsView
    private let tableView: BasicUITableView
    
    required init() {
        self.header = HeaderWithActionsView(title: ~"title.coalitions")
        self.header.backgroundColor = HomeDesign.white
        self.tableView = BasicUITableView()
        super.init()
        self.view.addSubview(self.tableView)
        self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.tableView.contentInsetAdjustTopAndBottom()
        self.tableView.register(CoalitionTableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.view.addSubview(self.header)
        self.header.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.header.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.header.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    deinit {
        HomeResources.storageCoalitionsImages.clearCache()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return HomeApiResources.blocs.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return HomeApiResources.blocs[section].coalitions.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CoalitionTableViewCell
        
        cell.update(with: HomeApiResources.blocs[indexPath.section].coalitions[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let coalition = HomeApiResources.blocs[indexPath.section].coalitions[indexPath.row]
        let userList = UsersListViewController.init(.coalitionsWithCoalitionIdUsers(coalition.id), primary: coalition.uicolor, extra: .coalition(coalition))
        
        self.presentWithBlur(userList)
    }
    
    final private class CoalitionTableViewCell: BasicUITableViewCell {
        
        private let flagView = CoalitionHorizontalFlagView()
        private let background = BasicUIImageView(asset: .coalitionDefaultBackground)
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            self.background.layer.cornerRadius = HomeLayout.corner
            self.background.layer.masksToBounds = true
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }
            
            self.contentView.addSubview(self.background)
            self.background.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: HomeLayout.margin).isActive = true
            self.background.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: HomeLayout.margin).isActive = true
            self.background.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -HomeLayout.margin).isActive = true
            self.background.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
            self.background.addSubview(self.flagView)
            self.flagView.topAnchor.constraint(equalTo: self.background.topAnchor).isActive = true
            self.flagView.leadingAnchor.constraint(equalTo: self.background.leadingAnchor).isActive = true
            self.flagView.trailingAnchor.constraint(lessThanOrEqualTo: self.background.trailingAnchor, constant: -HomeLayout.margin).isActive = true
            self.background.heightAnchor.constraint(equalToConstant: 200.0).isActive = true
        }
        
        private unowned(unsafe) var coalition: IntraCoalition!
        func update(with coalition: IntraCoalition) {
            self.coalition = coalition
            if let background = HomeResources.storageCoalitionsImages.get(coalition) {
                HomeAnimations.transitionQuick(withView: self.background, {
                    self.background.image = background
                })
            }
            else {
                self.background.image = UIImage.Assets.coalitionDefaultBackground.image
                Task.init(priority: .userInitiated, operation: {
                    if let (coa, background) = await HomeResources.storageCoalitionsImages.obtain(coalition), coa.id == coalition.id {
                        HomeAnimations.transitionQuick(withView: self.background, {
                            self.background.image = background
                        })
                    }
                })
            }
            self.flagView.update(with: coalition, position: 1, blocSize: 4)
        }
    }
}
