// home42/UserProject.swift
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

final class UserProjectViewController: HomeViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let header: HeaderWithActionsView
    
    let primary: UIColor
    private let user: IntraUser
    private let userProject: IntraUserProject
    private var project: IntraProject!
    private var scaleTeams: ContiguousArray<IntraScaleTeam>!
    
    private var errorOccured: HomeApi.RequestError! = nil
    private lazy var antenneCell = self.tableView.dequeueReusableCell(withIdentifier: "antenne") as! AntenneTableViewCell
    private let tableView: BasicUITableView
    
    init(user: IntraUser, userProject: IntraUserProject, primary: UIColor = HomeDesign.primary) {
        let peopleAction = ActionButtonView(asset: .actionPeople, color: primary)
                
        self.header = HeaderWithActionsView(title: userProject.project.name, actions: [peopleAction])
        self.primary = primary
        self.user = user
        self.userProject = userProject
        
        self.tableView = BasicUITableView()
        super.init()
        self.view.backgroundColor = HomeDesign.white
        self.view.addSubview(self.header)
        self.header.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.header.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.header.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        self.view.addSubview(self.tableView)
        self.tableView.topAnchor.constraint(equalTo: self.header.bottomAnchor, constant: HomeLayout.margin).isActive = true
        self.tableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        self.tableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.tableView.contentInset = .init(top: 0.0, left: 0.0, bottom: HomeLayout.safeAeraMain.bottom + HomeLayout.margin, right: 0.0)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(AntenneWhiteTableViewCell.self, forCellReuseIdentifier: "antenne")
        self.tableView.register(LinkProjectTableViewCell.self, forCellReuseIdentifier: "link")
        self.tableView.register(SectionTableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "headerTitle")
        self.tableView.register(ScaleTeamHeaderTableViewCell.self, forCellReuseIdentifier: "header")
        self.tableView.register(HomeFramingTableViewCell<UserCorrectionsLogsViewController.ScaleTeamView>.self, forCellReuseIdentifier: "scale")
        
        peopleAction.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UserProjectViewController.peopleTapped(sender:))))
        Task.init(priority: .userInitiated, operation: {
            do {
                try await self.startGettingProject()
            }
            catch {
                DynamicAlert.presentWith(error: error as! HomeApi.RequestError)
                self.errorOccured = error as? HomeApi.RequestError
                self.antenneCell.antenne.isBreak = true
            }
        })
    }
    required init() { fatalError() }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    @MainActor private func startGettingProject() async throws {
        
        let params: [String: Any] = self.userProject.current_team_id == nil ? ["filter[user_id]": self.user.id, "filter[filled]": true] :
                                                                              ["filter[team_id]":self.userProject.current_team_id!, "filter[filled]": true]
        async let project: IntraProject = HomeApi.get(.projectsWithProjectId(self.userProject.project.id))
        async let scaleTeams: ContiguousArray<IntraScaleTeam> = HomeApi.get(.projectsWithProjectIdScaleTeams(self.userProject.project.id), params: params)
        
        self.project = try await project
        self.scaleTeams = try await scaleTeams
        if self.scaleTeams.count == 0, self.userProject.status == .finished,
            let other = self.user.projects_users.first(where: { $0.project.name == self.userProject.project.name && $0.id != self.userProject.id }), other.current_team_id != nil {
            self.scaleTeams = try await HomeApi.get(.projectsWithProjectIdScaleTeams(other.project.id), params: ["filter[team_id]":other.current_team_id!])
        }
        self.tableView.reloadSections(IndexSet(integersIn: 0 ..< TableViewSection.count), with: .fade)
        self.antenneCell.antenne.isAntenneAnimating = false
    }
    
    @frozen private enum TableViewSection: Int {
        case antenne = 0
        case links
        case scaleTeams
        
        static let count: Int = 3
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return TableViewSection.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch TableViewSection(rawValue: section)! {
        case .antenne where self.project == nil && self.scaleTeams == nil:
            return 1
        case .links where self.project != nil:
            return self.project.children.count
        case .scaleTeams where self.scaleTeams != nil:
            return 1 + self.scaleTeams.count
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch TableViewSection(rawValue: indexPath.section)! {
        case .antenne:
            self.antenneCell.antenne.isBreak = self.errorOccured != nil
            self.antenneCell.antenne.isAntenneAnimating = true
            return self.antenneCell
        case .links:
            let cell = tableView.dequeueReusableCell(withIdentifier: "link", for: indexPath) as! LinkProjectTableViewCell
        
            cell.view.attributedText = NSAttributedString.init(string: self.project.children[indexPath.row].name,
                                                               attributes: [.foregroundColor: self.primary, .font: HomeLayout.fontSemiBoldMedium, .underlineStyle: NSUnderlineStyle.single.rawValue])
            return cell
        case .scaleTeams:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "header", for: indexPath) as! ScaleTeamHeaderTableViewCell
                
                cell.update(with: .init(id: self.user.id, login: self.user.login, image: self.user.image), project: self.userProject, scaleTeams: self.scaleTeams)
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "scale", for: indexPath) as! HomeFramingTableViewCell<UserCorrectionsLogsViewController.ScaleTeamView>
            
            cell.view.update(with: self.scaleTeams[indexPath.row &- 1])
            return cell
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == TableViewSection.scaleTeams.rawValue, let title = self.scaleTeams?.first?.team.name {
            let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: "headerTitle") as! SectionTableViewHeaderFooterView
            
            footer.update(with: title, primaryColor: self.userProject.markColor)
            return footer
        }
        return nil
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == TableViewSection.scaleTeams.rawValue, self.scaleTeams?.first?.team.name != nil {
            return HomeLayout.leftCurvedTitleViewHeigth
        }
        return 0.0
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == TableViewSection.links.rawValue else { return }
        let link = self.project.children[indexPath.row]
        
        if let userProject = self.user.projects_users.first(where: { $0.project.id == link.id }) {
            self.presentWithBlur(UserProjectViewController(user: self.user, userProject: userProject, primary: self.primary))
        }
    }
    
    final private class ScaleTeamHeaderTableViewCell: BasicUITableViewCell {
        
        private let statusView: StatusWithTeamMemberView
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            self.statusView = StatusWithTeamMemberView()
            super.init(style: style, reuseIdentifier: reuseIdentifier)
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }
            
            self.contentView.addSubview(self.statusView)
            self.statusView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: HomeLayout.margin).isActive = true
            self.statusView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
            self.statusView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
            self.statusView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -HomeLayout.margin).isActive = true
        }

        func update(with user: IntraUserInfo, project: IntraUserProject, scaleTeams: ContiguousArray<IntraScaleTeam>) {
            self.statusView.addUser(user)
            self.statusView.update(with: project, scaleTeams: scaleTeams)
        }
        
        final private class StatusWithTeamMemberView: BasicUIView, UITableViewDelegate, UITableViewDataSource {
            
            private let squareLabel: BasicUILabel
            private let tableView: BasicUITableView
            private var users: ContiguousArray<IntraUserInfo> = []
            
            final class SmartUserInfoView: BasicUITableViewCell {
                private let profilIcon: UserProfilIconView
                private let loginLabel: BasicUILabel
                
                override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
                    self.profilIcon = UserProfilIconView()
                    self.loginLabel = BasicUILabel(text: "???")
                    self.loginLabel.font = HomeLayout.fontBoldMedium
                    self.loginLabel.textColor = HomeDesign.black
                    super.init(style: style, reuseIdentifier: reuseIdentifier)
                }
                required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
                
                override func willMove(toSuperview newSuperview: UIView?) {
                    guard newSuperview != nil else { return }
                    
                    self.contentView.addSubview(self.profilIcon)
                    self.profilIcon.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
                    self.profilIcon.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: HomeLayout.smargin).isActive = true
                    self.profilIcon.setSize(HomeLayout.userProfilIconHeigth, HomeLayout.userProfilIconRadius)
                    self.profilIcon.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
                    self.contentView.addSubview(self.loginLabel)
                    self.loginLabel.leadingAnchor.constraint(equalTo: self.profilIcon.trailingAnchor, constant: HomeLayout.smargin).isActive = true
                    self.loginLabel.centerYAnchor.constraint(equalTo: self.profilIcon.centerYAnchor).isActive = true
                    self.loginLabel.trailingAnchor.constraint(greaterThanOrEqualTo: self.trailingAnchor).isActive = true
                }
                
                func update(with userInfo: IntraUserInfo) {
                    self.profilIcon.update(with: userInfo)
                    self.loginLabel.text = userInfo.login
                }
            }
            
            override init() {
                self.squareLabel = BasicUILabel(text: "???")
                self.squareLabel.layer.cornerRadius = HomeLayout.scorner
                self.squareLabel.layer.masksToBounds = true
                self.squareLabel.textAlignment = .center
                self.squareLabel.numberOfLines = 0
                self.tableView = BasicUITableView()
                super.init()
                self.tableView.delegate = self
                self.tableView.dataSource = self
                self.tableView.register(SmartUserInfoView.self, forCellReuseIdentifier: "cell")
            }
            required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
            
            override func willMove(toSuperview newSuperview: UIView?) {
                guard newSuperview != nil else { return }
                
                self.addSubview(squareLabel)
                self.squareLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: HomeLayout.margin).isActive = true
                self.squareLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: HomeLayout.margin).isActive = true
                self.squareLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.4).isActive = true
                self.squareLabel.heightAnchor.constraint(equalTo: self.squareLabel.widthAnchor, multiplier: 1.0).isActive = true
                self.squareLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: HomeLayout.smargin).isActive = true
                self.addSubview(self.tableView)
                self.tableView.leadingAnchor.constraint(equalTo: self.squareLabel.trailingAnchor, constant: HomeLayout.margin).isActive = true
                self.tableView.topAnchor.constraint(equalTo: self.squareLabel.topAnchor).isActive = true
                self.tableView.bottomAnchor.constraint(equalTo: self.squareLabel.bottomAnchor).isActive = true
                self.tableView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.margin).isActive = true
            }
            
            func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return self.users.count
            }
            func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SmartUserInfoView
                
                cell.update(with: self.users[indexPath.row])
                return cell
            }
            func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                let user = self.users[indexPath.row]
                let profil = ProfilViewController()
                
                Task.init(priority: .userInitiated, operation: {
                    await profil.setupWithUser(user.login, id: user.id)
                })
                self.parentHomeViewController?.presentWithBlur(profil, completion: nil)
            }
            
            func addUser(_ newUser: IntraUserInfo) {
                for user in self.users where user.id == newUser.id {
                    return
                }
                self.users.append(newUser)
            }
            
            func update(with project: IntraUserProject, scaleTeams: ContiguousArray<IntraScaleTeam>) {
                switch project.status {
                case .parent, .creatingGroup, .inProgress, .searchingGroup, .waitingForCorrection, .waitingToStart:
                    self.squareLabel.backgroundColor = HomeDesign.blueAccess
                    self.squareLabel.attributedText = .init(string: .init(describing: (~project.status.key).replacingOccurrences(of: " ", with: "\n")),
                                                       attributes: [.font: HomeLayout.fontBoldMedium, .foregroundColor: HomeDesign.white])
                case .finished:
                    let attr = NSMutableAttributedString(string: "\(project.final_mark ?? 0)",
                                                         attributes: [.font: UIFont.systemFont(ofSize: 36.0, weight: .black), .foregroundColor: HomeDesign.white])
                    
                    attr.append(.init(string: " / 100", attributes: [.font: HomeLayout.fontBoldTitle, .foregroundColor: HomeDesign.white]))
                    self.squareLabel.attributedText = attr
                    self.squareLabel.backgroundColor = IntraUserProject.finalMarkColor(project.final_mark ?? 100)
                }
                if let first = scaleTeams.first {
                    for corrected in first.correcteds {
                        self.addUser(corrected)
                    }
                }
                self.tableView.reloadData()
            }
        }
    }
    
    final private class LinkProjectTableViewCell: BasicUITableViewCell {
        let view: HomeInsetsLabel = HomeInsetsLabel(text: "???", inset: .init(width: HomeLayout.margin, height: HomeLayout.margin))
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }
            
            self.view.textAlignment = .center
            self.view.layer.cornerRadius = HomeLayout.scorner
            self.view.layer.masksToBounds = true
            self.view.backgroundColor = HomeDesign.lightGray
            self.contentView.addSubview(self.view)
            self.view.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: HomeLayout.dmargin).isActive = true
            self.view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -HomeLayout.dmargin).isActive = true
            self.view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: HomeLayout.margin).isActive = true
            self.view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -HomeLayout.margin).isActive = true
        }
    }
    
    @objc private func peopleTapped(sender: UITapGestureRecognizer) {
        let vc = UsersListViewController(.projectsWithProjectIdUsers(self.userProject.project.id), settings: nil, extra: .project(self.userProject.project.id), primary: self.primary)
        
        self.presentWithBlur(vc)
    }
}


// Students who can subscribe and never did > https://projects.intra.42.fr/projects/42cursus-particle-system/all_users/can_register
// [...document.body.getElementsByClassName('student-item student-kind-student')].map(element => element.getAttribute('data-tooltip-login'))
// Students looking for a team > https://projects.intra.42.fr/projects/42cursus-humangl/all_users/without_team
// [...document.body.getElementsByClassName('student-item student-kind-student')].map(element => element.getAttribute('data-tooltip-login'))

