//
//  UsersList.swift
//  home42
//
//  Created by Antoine Feuerstein on 23/04/2021.
//

import Foundation
import UIKit

final class UsersListViewController: HomeViewController, SearchFieldViewDelegate {
    
    private let header: HeaderWithActionsBase
    var headerTitle: String {
        set { self.header.title = newValue }
        get { return self.header.title }
    }
    private let searchField: SearchFieldViewWithTimer
    private let settingsButton: ActionButtonView
    private lazy var settings: UsersListSettingsViewController = UsersListSettingsViewController(userList: self)
    private let tableView: UserInfoInfiniteRequestTableView
    private let gradientView: GradientView
    
    private let primary: UIColor
    
    @frozen enum SettingsOption {
        case poolYear(Int)
        case poolMonth(String)
        case sort(String)
        case campus(Int)
    }
    private var settingsOptions: [SettingsOption]?
    @frozen enum ExtraOptions {
        case coalition(IntraCoalition)
        case project(Int)
        case expertise(Int)
        case title(IntraTitle)
        case group(IntraGroup)
    }
    private let extra: ExtraOptions?
    
    init(_ route: HomeApi.Routes = .users, primary: UIColor = HomeDesign.primary, settings: [SettingsOption]? = nil, extra: ExtraOptions? = nil) {
        switch extra {
        case .coalition(let coalition):
            self.header = CoalitionHeaderWithActionsView(coalition: coalition)
        case .expertise(let expertiseId):
            self.header = HeaderWithActionsView(title: HomeApiResources.expertises[expertiseId]?.name ?? "???")
        case .title(let title):
            self.header = HeaderWithActionsView(title: title.name)
        case .group(let group):
            self.header = HeaderWithActionsView(title: group.name)
        //case .project(let id):
        //
        //case .campus(let campus):
        //    self.header = HeaderWithActionsView(title: campus.name) // +action which point to campus location ? with map to show, map can show all other campus
        default:
            self.header = HeaderWithActionsView(title: ~"USERS")
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
        self.settingsOptions = settings
        self.extra = extra
        super.init()
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
        self.tableView.contentInset = .init(top: 0.0, left: 0.0, bottom: App.safeAera.bottom, right: 0.0)
        self.view.addSubview(self.gradientView)
        self.gradientView.topAnchor.constraint(equalTo: self.tableView.topAnchor).isActive = true
        self.gradientView.leadingAnchor.constraint(equalTo: self.tableView.leadingAnchor).isActive = true
        self.gradientView.trailingAnchor.constraint(equalTo: self.tableView.trailingAnchor).isActive = true
        self.gradientView.heightAnchor.constraint(equalToConstant: HomeLayout.margin).isActive = true
        self.settingsButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(settingsButtonTapped(sender:))))
        self.tableView.block = self.userSelected(user:)
        self.tableView.primary = primary
        self.tableView.route = route
        self.tableView.parameters = self.settings.parameters
        self.tableView.nextPage()
    }
    required init() { fatalError() }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    deinit {
        print("UsersListViewController", #function)
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
    
    @objc private func settingsButtonTapped(sender: UITapGestureRecognizer) {
        self.presentWithBlur(self.settings)
    }
}

fileprivate extension UsersListViewController {
    
    final private class UsersListSettingsViewController: HomeViewController, SelectorViewDelegate, HeaderWithActionsDelegate {
        
        private let header: HeaderWithActionsView
        private let scrollView: BasicUIScrollView
        private let container: BasicUIView
        
        static private let sortOptions: [String] = ["login", "first_name", "last_name", "pool_year", "pool_month", "id", "last_seen_at"]
        static private let sortOptionsKeys: [String] = ["SORT_LOGIN", "SORT_FIRST_NAME", "SORT_LAST_NAME", "SORT_POOL_YEAR", "SORT_POOL_MONTH", "SORT_ID", "SORT_LAST_SEEN_AT"]
        private let fieldSort: MessageView<SelectorView<String>>
        private let fieldPoolYear: MessageView<SelectorView<Int>>
        private let fieldPoolMonth: MessageView<SelectorView<String>>
        private let fieldPrimaryCampus: MessageView<SelectorView<IntraCampus>>
        
        private var extraFieldProjectState: MessageView<SelectorView<IntraUserProject.Status>>!
        //private var extraFieldCoalitionSort: MessageView<SelectorView<String>>! // associated blocs ?
        private var extraFieldExpertisesSelector: MessageView<SelectorView<IntraExpertise>>!
        private var extraFieldTitlesSelector: MessageView<SelectorView<IntraTitle>>!
        private var extraFieldGroupsSelector: MessageView<SelectorView<IntraGroup>>!
        
        private unowned(unsafe) let userList: UsersListViewController
        private var needUpdate: Bool = false
        
        init(userList: UsersListViewController) {
            var last: NSLayoutYAxisAnchor!
            let selectNone = ~"FIELD_SELECT_NONE"
            let years: [Int] = (2014 ... Date().year).map({ $0 })
            let campusName: [String] = HomeApiResources.campus.map({ $0.name })
            var selectedIndexSort: Int = 0
            var selectedIndexPoolYear: Int = 0
            var selectedIndexPoolMonth: Int = 0
            var selectedIndexCampus: Int = 0
            
            if let settingsOptions = userList.settingsOptions {
                for settingsOption in settingsOptions {
                    switch settingsOption {
                    case .poolYear(let year):
                        selectedIndexPoolYear = (years.firstIndex(of: year) ?? 0) + 1
                    case .poolMonth(let month):
                        selectedIndexPoolMonth = (Date.apiMonths.firstIndex(of: month) ?? 0) + 1
                    case .sort(let sort):
                        selectedIndexSort = Self.sortOptions.firstIndex(of: sort) ?? 0
                    case .campus(let id):
                        selectedIndexCampus = (HomeApiResources.campus.firstIndex(where: { $0.id == id }) ?? 0) + 1
                    }
                }
            }
            
            self.header = HeaderWithActionsView(title: ~"TITLE_SETTINGS_SEARCH")
            self.scrollView = BasicUIScrollView()
            self.container = BasicUIView()
            self.fieldSort = MessageView(text: ~"FIELD_SORT_MESSAGE", primary: userList.primary, radius: HomeLayout.roundedGenericActionsViewRadius,
                                         view: SelectorView(keys: Self.sortOptionsKeys.map({ ~$0 }), values: Self.sortOptions, selectedIndex: selectedIndexSort))
            self.fieldSort.view.setPrimary(userList.primary)
            self.fieldPoolYear = MessageView(text: ~"FIELD_POOL_YEAR_MESSAGE", primary: userList.primary, radius: HomeLayout.roundedGenericActionsViewRadius,
                                             view: SelectorView(keys: years.map({ "\($0)" }), values: years,
                                                                selectedIndex: selectedIndexPoolYear, selectNoneString: selectNone))
            self.fieldPoolYear.view.setPrimary(userList.primary)
            self.fieldPoolMonth = MessageView(text: ~"FIELD_POOL_MONTH_MESSAGE", primary: userList.primary, radius: HomeLayout.roundedGenericActionsViewRadius,
                                              view: SelectorView(keys: Date.monthsKeys.map({ ~$0 }), values: Date.apiMonths,
                                                                 selectedIndex: selectedIndexPoolMonth, selectNoneString: selectNone))
            self.fieldPoolMonth.view.setPrimary(userList.primary)
            self.fieldPrimaryCampus = MessageView(text: ~"FIELD_PRIMARY_CAMPUS", primary: userList.primary, radius: HomeLayout.roundedGenericActionsViewRadius,
                                                  view: SelectorView(keys: campusName, values: unsafeBitCast(HomeApiResources.campus, to: Array<IntraCampus>.self),
                                                                     selectedIndex: selectedIndexCampus, selectNoneString: selectNone))
            self.fieldPrimaryCampus.view.setPrimary(userList.primary)
                        
            self.userList = userList
            super.init()
            self.view.backgroundColor = HomeDesign.white
            self.view.addSubview(self.header)
            self.header.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
            self.header.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            self.header.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
            self.view.addSubview(self.scrollView)
            self.scrollView.topAnchor.constraint(equalTo: self.header.bottomAnchor).isActive = true
            self.scrollView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
            self.scrollView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
            self.scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
            self.scrollView.contentInset = .init(top: 0.0, left: 0.0, bottom: App.safeAera.bottom, right: 0.0)
            self.scrollView.addSubview(self.container)
            self.container.topAnchor.constraint(equalTo: self.scrollView.topAnchor).isActive = true
            self.container.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor).isActive = true
            self.container.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor).isActive = true
            self.container.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor).isActive = true
            self.container.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor).isActive = true
            
            func addElementToContainer(_ element: UIView, margin: CGFloat = HomeLayout.margin) {
                self.container.addSubview(element)
                element.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: margin).isActive = true
                element.trailingAnchor.constraint(equalTo: self.container.trailingAnchor, constant: -margin).isActive = true
                element.topAnchor.constraint(equalTo: last, constant: HomeLayout.margin).isActive = true
                last = element.bottomAnchor
            }
            func addDoubleElementsToContainer(_ e1: UIView, _ e2: UIView, margin: CGFloat = HomeLayout.margin) {
                self.container.addSubview(e1)
                self.container.addSubview(e2)
                e1.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: margin).isActive = true
                e1.topAnchor.constraint(equalTo: last, constant: margin).isActive = true
                e2.trailingAnchor.constraint(equalTo: self.container.trailingAnchor, constant: -margin).isActive = true
                e2.topAnchor.constraint(equalTo: e1.topAnchor).isActive = true
                e1.widthAnchor.constraint(equalTo: e2.widthAnchor).isActive = true
                e1.trailingAnchor.constraint(equalTo: e2.leadingAnchor, constant: -HomeLayout.margin).isActive = true
                last = e1.bottomAnchor
            }
            
            last = self.container.topAnchor
            if self.userList.extra != nil {
                addElementToContainer(LeftCurvedTitleView(text: ~"GENERAL", primaryColor: userList.primary, addTopCorner: false), margin: 0.0)
            }
            addElementToContainer(self.fieldSort)
            addDoubleElementsToContainer(self.fieldPoolYear, self.fieldPoolMonth)
            addElementToContainer(self.fieldPrimaryCampus)
            
            switch self.userList.extra {
            case .project(_):
                let states = IntraUserProject.Status.allCases
                let statesKeys: [String] = states.map({ ~$0.key })
                
                addElementToContainer(LeftCurvedTitleView(text: ~"PROJECTS", primaryColor: userList.primary, addTopCorner: false), margin: 0.0)
                self.extraFieldProjectState = MessageView(text: ~"STATUS", primary: userList.primary, radius: HomeLayout.roundedGenericActionsViewRadius,
                                                          view: SelectorView(keys: statesKeys, values: states,
                                                                             selectedIndex: 0, selectNoneString: selectNone))
                self.extraFieldProjectState.view.setPrimary(userList.primary)
                self.extraFieldProjectState.view.delegate = self
                addElementToContainer(self.extraFieldProjectState)
            case .coalition(_):
                break
                /*addElementToContainer(LeftCurvedTitleView(text: ~"TITLE_COALITIONS", primaryColor: userList.primary, addTopCorner: false), margin: 0.0)
                self.extraFieldCoalitionSort = MessageView(text: ~"STATUS", primary: userList.primary, radius: HomeLayout.roundedGenericActionsViewRadius,
                                                           view: SelectorView(keys: ["this_year_score"], values: ["this_year_score"],
                                                                              selectedIndex: 0, selectNoneString: selectNone))
                self.extraFieldCoalitionSort.view.setPrimary(userList.primary)
                self.extraFieldCoalitionSort.view.delegate = self
                addElementToContainer(self.extraFieldCoalitionSort)*/
            case .expertise(let expertiseId):
                let expertises: Array<IntraExpertise> = HomeApiResources.expertises.values.map({ $0 })
                let names = expertises.map(\.name)
                let index = expertises.firstIndex(where: { $0.id == expertiseId }) ?? 0
                
                addElementToContainer(LeftCurvedTitleView(text: ~"TITLE_EXPERTISES", primaryColor: userList.primary, addTopCorner: false), margin: 0.0)
                self.extraFieldExpertisesSelector = MessageView(text: ~"TITLE_EXPERTISE", primary: userList.primary, radius: HomeLayout.roundedGenericActionsViewRadius,
                                                                view: SelectorView(keys: names, values: expertises, selectedIndex: index, selectNoneString: nil))
                self.extraFieldExpertisesSelector.view.setPrimary(userList.primary)
                self.extraFieldExpertisesSelector.view.delegate = self
                addElementToContainer(self.extraFieldExpertisesSelector)
            case .title(let title):
                let names = HomeApiResources.titles.map(\.name)
                let index = HomeApiResources.titles.firstIndex(where: { $0.id == title.id }) ?? 0
                
                addElementToContainer(LeftCurvedTitleView(text: ~"TITLE_TITLES", primaryColor: userList.primary, addTopCorner: false), margin: 0.0)
                self.extraFieldTitlesSelector = MessageView(text: ~"TITLE_TITLE", primary: userList.primary, radius: HomeLayout.roundedGenericActionsViewRadius,
                                                            view: SelectorView(keys: names, values: unsafeBitCast(HomeApiResources.titles, to: [IntraTitle].self),
                                                                               selectedIndex: index, selectNoneString: nil))
                self.extraFieldTitlesSelector.view.setPrimary(userList.primary)
                self.extraFieldTitlesSelector.view.delegate = self
                addElementToContainer(self.extraFieldTitlesSelector)
            case .group(let group):
                let names = HomeApiResources.groups.map(\.name)
                let index = HomeApiResources.groups.firstIndex(where: { $0.id == group.id }) ?? 0
                
                addElementToContainer(LeftCurvedTitleView(text: ~"TITLE_GROUPS", primaryColor: userList.primary, addTopCorner: false), margin: 0.0)
                self.extraFieldGroupsSelector = MessageView(text: ~"TITLE_GROUP", primary: userList.primary, radius: HomeLayout.roundedGenericActionsViewRadius,
                                                            view: SelectorView(keys: names, values: unsafeBitCast(HomeApiResources.groups, to: [IntraGroup].self),
                                                                               selectedIndex: index, selectNoneString: nil))
                self.extraFieldGroupsSelector.view.setPrimary(userList.primary)
                self.extraFieldGroupsSelector.view.delegate = self
                addElementToContainer(self.extraFieldGroupsSelector)
            default:
                break
            }
            last.constraint(equalTo: self.container.bottomAnchor).isActive = true
            
            self.fieldSort.view.delegate = self
            self.fieldPoolMonth.view.delegate = self
            self.fieldPoolYear.view.delegate = self
            self.fieldPrimaryCampus.view.delegate = self
        }
        required init() { fatalError("\(#function) has not been implemented") }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        private var lastParameters: [String: Any]? = nil
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            self.lastParameters = self.parameters
        }
     
        func selectorSelect<E>(_ selector: SelectorView<E>) {
            if let expertise = self.extraFieldExpertisesSelector, expertise.view == selector {
                self.userList.header.title = expertise.view.value.name
                self.userList.tableView.route = .expertisesWithExpertiseIdUsers(expertise.view.value.id)
                self.needUpdate = true
            }
            else if let title = self.extraFieldTitlesSelector, title.view == selector {
                self.userList.header.title = title.view.value.name
                self.userList.tableView.route = .titlesWithTitleIdUsers(title.view.value.id)
                self.needUpdate = true
            }
            else if let group = self.extraFieldGroupsSelector, group.view == selector {
                self.userList.header.title = group.view.value.name
                self.userList.tableView.route = .groupsWithGroupIdUsers(group.view.value.id)
                self.needUpdate = true
            }
        }
        
        var parameters: [String: Any] {
            var params: [String: Any] = ["sort": "-\(self.fieldSort.view.value!)"]
            
            if self.userList.searchField.text.count > 0 {
                params["search[login]"] = self.userList.searchField.text
            }
            if let value = self.fieldPoolYear.view.value {
                params["filter[pool_year]"] = "\(value)"
            }
            if let value = self.fieldPoolMonth.view.value {
                params["filter[pool_month]"] = value
            }
            if let value = self.fieldPrimaryCampus.view.value {
                params["filter[primary_campus_id]"] = value.id
            }
            switch self.userList.extra {
            case .project(_):
                if let value = self.extraFieldProjectState.view.value {
                    params["filter[status]"] = value.rawValue
                }
            case .coalition(_):
                break
            default:
                break
            }
            return params
        }
        
        func closeButtonTapped() {
            let completion: (() -> Void)?
            let newParameters = self.parameters
            
            if let last = self.lastParameters, newParameters.isContentEqual(last), self.needUpdate == false {
                completion = nil
            }
            else {
                completion = {
                    self.userList.tableView.restart(with: newParameters)
                }
            }
            self.needUpdate = false
            self.dismiss(animated: true, completion: completion)
        }
    }
}
