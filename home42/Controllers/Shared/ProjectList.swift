// home42/ProjectList.swift
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

final class ProjectListViewController: HomeViewController, UITableViewDelegate, UITableViewDataSource, SearchFieldViewDelegate {
    
    private let projectsSource: ContiguousArray<IntraProject>
    private let parentProject: IntraProject?
    private var projects: ContiguousArray<IntraProject>
    
    private let header: HeaderWithActionsView
    private let searchField: SearchFieldView
    private let tableView: BasicUITableView
    
    convenience required init() {
        self.init(projects: HomeApiResources.projects.filter({ $0.parent == nil }), parentProject: nil)
    }
    private init(projects: ContiguousArray<IntraProject>, parentProject: IntraProject?) {
        self.projectsSource = projects
        self.parentProject = parentProject
        self.projects = self.projectsSource
        self.header = HeaderWithActionsView(title: parentProject?.name ?? ~"general.projects")
        self.searchField = SearchFieldView()
        self.tableView = BasicUITableView()
        super.init()
        self.view.backgroundColor = HomeDesign.white
        self.view.addSubview(self.header)
        self.header.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.header.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.header.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.view.addSubview(self.searchField)
        self.searchField.delegate = self
        self.searchField.topAnchor.constraint(equalTo: self.header.bottomAnchor, constant: HomeLayout.margin).isActive = true
        self.searchField.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: HomeLayout.margin).isActive = true
        self.searchField.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -HomeLayout.margin).isActive = true
        self.view.insertSubview(self.tableView, belowSubview: self.searchField)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(HomeFramingTableViewCell<ProjectView>.self, forCellReuseIdentifier: "cell")
        self.tableView.register(HomeFramingTableViewCell<ProjectViewWithLeftCurvedTitle>.self, forCellReuseIdentifier: "cellTitle")
        self.tableView.topAnchor.constraint(equalTo: self.searchField.centerYAnchor).isActive = true
        self.tableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        self.tableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.tableView.contentInsetAdjustTopConstant(HomeLayout.roundedGenericActionsViewRadius + HomeLayout.margin)
    }
    required init?(coder: NSCoder) { fatalError() }
    
    func searchFieldBeginEditing(_ searchField: SearchFieldView) {
        
    }
    func searchFieldTextUpdated(_ searchField: SearchFieldView) {
        if searchField.text.count == 0 {
            self.projects = self.projectsSource
        }
        else {
            self.projects = self.projectsSource.filter({ $0.name.contains(searchField.text) })
        }
        self.tableView.reloadData()
    }
    func searchFieldEndEditing(_ searchField: SearchFieldView) {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.projects.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let project = self.projects[indexPath.row]
        
        if project.exam || project.children.count > 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellTitle", for: indexPath) as! HomeFramingTableViewCell<ProjectViewWithLeftCurvedTitle>
        
            cell.view.update(with: project)
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HomeFramingTableViewCell<ProjectView>
        
            cell.view.update(with: project)
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let project = self.projects[indexPath.row]
    
        if project.children.count > 0 {
            self.presentWithBlur(ProjectListViewController(projects: project.childrenProjects, parentProject: project))
        }
        else {
            self.presentWithBlur(UsersListViewController(.projectsWithProjectIdUsers(project.id), extra: .project(project.id), primary: HomeDesign.primary))
        }
    }
    
    final private class ProjectView: BasicUIView, HomeFramingTableViewCellView {
        static let edges: UIEdgeInsets = .init(top: 0.0, left: HomeLayout.margin, bottom: HomeLayout.margin, right: HomeLayout.margin)
        
        private let nameLabel: BasicUILabel
        
        override init() {
            self.nameLabel = BasicUILabel(text: "???")
            self.nameLabel.textColor = HomeDesign.black
            self.nameLabel.font = HomeLayout.fontSemiBoldMedium
            self.nameLabel.textAlignment = .left
            self.nameLabel.numberOfLines = 0
            super.init()
            self.layer.cornerRadius = HomeLayout.scorner
            self.backgroundColor = HomeDesign.primary.withAlphaComponent(HomeDesign.alphaLowLayer)
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }
            
            self.addSubview(self.nameLabel)
            self.nameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: HomeLayout.margin).isActive = true
            self.nameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: HomeLayout.margin).isActive = true
            self.nameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.margin).isActive = true
            self.nameLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -HomeLayout.margin).isActive = true
        }
        
        func update(with project: IntraProject) {
            self.nameLabel.text = project.name
        }
    }
    final private class ProjectViewWithLeftCurvedTitle: BasicUIView, HomeFramingTableViewCellView {
        static var edges: UIEdgeInsets = ProjectView.edges
        
        private let titleView: LeftCurvedTitleView
        private let projectView: ProjectView
        
        override init() {
            self.titleView = LeftCurvedTitleView(text: "???", primaryColor: HomeDesign.primary, addTopCorner: false)
            self.projectView = ProjectView()
            self.projectView.layer.cornerRadius = 0.0
            super.init()
            self.layer.cornerRadius = HomeLayout.scorner
            self.layer.masksToBounds = true
            self.backgroundColor = HomeDesign.primary.withAlphaComponent(HomeDesign.alphaLowLayer)
            self.titleView.backgroundColor = self.backgroundColor
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }
            
            self.addSubview(self.titleView)
            self.titleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            self.titleView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            self.titleView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            self.addSubview(self.projectView)
            self.projectView.topAnchor.constraint(equalTo: self.titleView.bottomAnchor).isActive = true
            self.projectView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            self.projectView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            self.projectView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        }
        
        func update(with project: IntraProject) {
            if project.exam {
                self.titleView.update(with: ~"event.kind.exam", primaryColor: HomeDesign.primary)
            }
            else {
                self.titleView.update(with: "\(project.children.count) " + ~"general.projects", primaryColor: HomeDesign.primary)
            }
            self.projectView.update(with: project)
        }
    }
}

