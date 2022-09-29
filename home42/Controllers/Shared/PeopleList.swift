// home42/PeopleList.swift
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

final class People: IntraObject {
    
    let id: Int
    let login: String
    let image_url: String!
    let createdAt: Date
    
    @frozen enum ListType: Int, Codable, CaseIterable {
        case me = 0
        case friends = 1
        case extraList1 = 2
        case extraList2 = 3
        
        var color: UIColor {
            switch self {
            case .me:
                return HomeDesign.primary
            case .friends:
                return HomeDesign.greenSuccess
            case .extraList1:
                return App.settings.peopleExtraList1Color.uiColor
            case .extraList2:
                return App.settings.peopleExtraList2Color.uiColor
            }
        }
        var title: String {
            switch self {
            case .me:
                return ~"title.profil"
            case .friends:
                return ~"peoples.friends"
            case .extraList1:
                return App.settings.peopleExtraList1Name
            case .extraList2:
                return App.settings.peopleExtraList2Name
            }
        }
        var asset: UIImage.Assets {
            switch self {
            case .me:
                return .actionPeopleSunglass
            case .friends:
                return .actionFriends
            case .extraList1:
                return App.settings.peopleExtraList1Icon
            case .extraList2:
                return App.settings.peopleExtraList2Icon
            }
        }
    }
    let list: People.ListType
    
    init(id: Int, login: String, image_url: String!, list: People.ListType) {
        self.id = id
        self.login = login
        self.image_url = image_url
        self.createdAt = Date()
        self.list = list
        super.init()
    }
    
    @inlinable static var me: People {
        return People(id: App.user.id, login: App.user.login, image_url: App.user.image_url, list: .me)
    }
    static let assets: [UIImage.Assets] = [.actionFriends, .actionEnemies, .actionAddFriends, .actionAddEnemies,
                                           .actionPeopleKo, .actionPeopleBore, .actionPeopleForced, .actionPeopleHunger,
                                           .actionPeopleNeutral, .actionPeopleUnhappy, .actionPeopleHumorist, .actionPeopleSunglass,
                                           .actionPeopleHypnotic]
}

final class PeopleListViewController: HomeViewController, UITableViewDelegate, UITableViewDataSource, HeaderWithActionsDelegate {
    
    private let primary: UIColor
    private let header: HeaderWithActionsView
    private let tableView: BasicUITableView
    private var shouldUpdateClusterPeoples: Bool = false
    private let list: People.ListType
    private var peoples: [People]
    weak var cluster: ClustersBaseViewController? = nil
    weak var tracker: TrackerViewController? = nil
    
    init(with list: People.ListType) {
        self.primary = list.color
        self.header = HeaderWithActionsView(title: list.title)
        self.header.backgroundColor = self.primary
        self.header.titleLabel.font = HomeLayout.fontBlackTitle
        self.header.titleLabel.textColor = HomeDesign.white
        self.tableView = BasicUITableView()
        self.tableView.contentInset = .init(top: 0.0, left: 0.0, bottom: HomeLayout.safeAera.bottom, right: 0.0)
        self.tableView.register(SeparatorTableViewCell<PeopleView>.self, forCellReuseIdentifier: "cell")
        self.list = list
        if let peoples: Dictionary<String, People> = HomeDefaults.read(.peoples) {
            self.peoples = peoples.filter({ $0.value.list == list }).map(\.value).sorted(by: App.settings.peopleListViewControllerSort.sortFunction)
        }
        else {
            self.peoples = []
        }
        super.init()
        self.view.backgroundColor = HomeDesign.white
        self.view.addSubview(self.header)
        self.header.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.header.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.header.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.view.addSubview(self.tableView)
        self.tableView.topAnchor.constraint(equalTo: self.header.bottomAnchor).isActive = true
        self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    required init() { fatalError("init(coder:) has not been implemented") }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let peoples: Dictionary<String, People> = HomeDefaults.read(.peoples) {
            self.peoples = peoples.filter({ $0.value.list == self.list }).map(\.value).sorted(by: App.settings.peopleListViewControllerSort.sortFunction)
        }
        else {
            self.peoples = []
        }
        self.tableView.reloadData()
    }
    
    final private class PeopleView: BasicUIView, SeparatorTableViewCellView {
        
        private let icon: UserProfilIconView
        private let login: BasicUILabel
        private let locationLabel: HomeInsetsLabel
        
        override init() {
            self.icon = UserProfilIconView()
            self.icon.isUserInteractionEnabled = true
            self.login = BasicUILabel(text: "???")
            self.login.font = HomeLayout.fontBoldMedium
            self.login.textColor = HomeDesign.black
            self.login.adjustsFontSizeToFitWidth = true
            self.locationLabel = HomeInsetsLabel(text: "???", inset: .init(width: HomeLayout.margin, height: HomeLayout.dmargin))
            self.locationLabel.backgroundColor = HomeDesign.actionGreen.withAlphaComponent(HomeDesign.alphaMiddle)
            self.locationLabel.layer.cornerRadius = HomeLayout.scorner
            self.locationLabel.layer.masksToBounds = true
            self.locationLabel.font = HomeLayout.fontBlackNormal
            self.locationLabel.textColor = HomeDesign.white
            self.locationLabel.isUserInteractionEnabled = true
            super.init()
            self.icon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PeopleView.iconTapped(sender:))))
            self.locationLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PeopleView.locationTapped(sender:))))
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }
            
            self.addSubview(self.icon)
            self.icon.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: HomeLayout.margin).isActive = true
            self.icon.setSize(HomeLayout.userProfilIconHeigth, HomeLayout.userProfilIconRadius)
            self.icon.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            self.addSubview(self.login)
            self.login.centerYAnchor.constraint(equalTo: self.icon.centerYAnchor).isActive = true
            self.login.leadingAnchor.constraint(equalTo: self.icon.trailingAnchor, constant: HomeLayout.margin).isActive = true
            self.addSubview(self.locationLabel)
            self.locationLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.margins).isActive = true
            self.locationLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            self.login.trailingAnchor.constraint(equalTo: self.locationLabel.leadingAnchor, constant: -HomeLayout.margin).isActive = true
            self.heightAnchor.constraint(equalToConstant: HomeLayout.userInfoViewHeigth).isActive = true
        }
        
        fileprivate unowned var people: People!
        fileprivate var location: IntraClusterLocation!
        func fill(with people: People, location: IntraClusterLocation!) {
            self.people = people
            self.location = location
            self.icon.update(with: people)
            self.login.text = people.login
            if location != nil {
                self.locationLabel.isHidden = false
                self.locationLabel.text = location.host
            }
            else {
                self.locationLabel.isHidden = true
            }
        }
        
        @objc private func locationTapped(sender: UITapGestureRecognizer) {
            let parent = self.parentViewController as! PeopleListViewController

            parent.dismiss(animated: true, completion: {
                if let cluster = parent.cluster, let host = self.location?.host {
                    _ = cluster.focusOnClusterView(with: host, animated: true)
                }
            })
        }
        @objc private func iconTapped(sender: UITapGestureRecognizer) {
            let profil = ProfilViewController()
            
            Task.init(priority: .userInitiated, operation: {
                await profil.setupWithUser(self.people.login, id: self.people.id)
            })
            (self.parentViewController as! PeopleListViewController).presentWithBlur(profil, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.peoples.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SeparatorTableViewCell<PeopleView>
        let people = self.peoples[indexPath.row]
        
        cell.view.fill(with: people, location: self.cluster?.peopleConnected(people))
        cell.separator.backgroundColor = self.primary
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        func removePeople(action: UIContextualAction, view: UIView, block: @escaping (Bool) -> Void) {
            func remove() {
                let deletedPeople = self.peoples.remove(at: indexPath.row)
                
                block(true)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                if var peoples: Dictionary<String, People> = HomeDefaults.read(.peoples) {
                    peoples.removeValue(forKey: deletedPeople.login)
                    HomeDefaults.save(peoples, forKey: .peoples)
                    if let cluster = self.cluster {
                        cluster.peoplesUpdated(peoples)
                    }
                }
            }
            
            if App.settings.peopleWarnWhenRemove {
                DynamicAlert(contents: [.text(String(format: ~"peoples.remove", self.peoples[indexPath.row].login))], actions: [.normal(~"general.cancel", nil), .highligth(~"general.remove", remove)])
            }
            else {
                remove()
            }
        }
        
        let deleteAction = UIContextualAction(style: .destructive, title: nil, handler: removePeople(action:view:block:))
        
        deleteAction.image = UIImage.Assets.actionClose.image
        deleteAction.backgroundColor = HomeDesign.redError
        if let cluster = self.cluster, let cell = tableView.cellForRow(at: indexPath) as? SeparatorTableViewCell<PeopleView>, let location = cell.view.location {
            let seeAction = UIContextualAction(style: .normal, title: nil) { _, _, block in
                self.dismiss(animated: true, completion: {
                    block(cluster.focusOnClusterView(with: location.host, animated: true))
                })
            }
            
            seeAction.backgroundColor = HomeDesign.blueAccess
            seeAction.image = UIImage.Assets.actionSee.image
            return UISwipeActionsConfiguration(actions: [deleteAction, seeAction])
        }
        else if let tracker = self.tracker {
            let trackAction = UIContextualAction(style: .normal, title: nil) { _, _, block in
                let people = self.peoples[indexPath.row]
                
                self.dismiss(animated: true, completion: {
                    tracker.selectUser(user: .init(id: people.id, login: people.login, image_url: people.image_url))
                    block(true)
                })
            }
            
            trackAction.backgroundColor = HomeDesign.gold
            trackAction.image = UIImage.Assets.actionSearch.image
            return UISwipeActionsConfiguration(actions: [deleteAction, trackAction])
        }
        else {
            return UISwipeActionsConfiguration(actions: [deleteAction])
        }
    }
    
    func closeButtonTapped() {
        self.dismiss(animated: true, completion: nil)
        if self.shouldUpdateClusterPeoples {
            
        }
    }
}
