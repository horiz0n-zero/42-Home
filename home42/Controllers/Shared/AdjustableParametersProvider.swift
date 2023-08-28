// home42/AdjustableParametersProvider.swift
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

// also, add this page to UserEventsHistoric

protocol AdjustableParametersProviderDelegate: AnyObject {
    
    var primary: UIColor { get }
    
    static var defaultParameters: [String: Any] { get }
    static var searchParameter: AdjustableParametersProviderViewController<Self>.SearchParameter? { get }
    static var parameters: [AdjustableParametersProviderViewController<Self>.Parameter] { get }
    
    func adjustableParametersProviderExtraValueSelected(_ newTitle: String, newRoute: HomeApi.Routes)
    func adjustableParametersProviderParametersUpdated(_ newParameters: [String: Any])
    
    static var canExport: Bool { get }
    func adjustableParametersProviderWillExport() -> String
}

final class AdjustableParametersProviderViewController<G: AdjustableParametersProviderDelegate>: HomeViewController, SelectorViewDelegate, HeaderWithActionsDelegate {
    
    private unowned(unsafe) let delegate: G
    
    private let header: HeaderWithActionsView
    private let scrollView: BasicUIScrollView
    private let container: BasicUIView
    private var selectorViews: ContiguousArray<UIView>
    private var exportButton: ActionButtonView!
    
    @frozen @usableFromInline struct SearchParameter {
        let title: String
        let keys: [HomeApi.Parameter]
        let keysName: [String]
        let textGetter: KeyPath<G, String>
    }
    
    @frozen @usableFromInline struct Parameter {
        let key: HomeApi.Parameter
        let source: Source
        let selectorType: SelectorType
        let selectorTitleKey: String
        let selectorInlineWithNextElement: Bool
        let selectorCanSelectNULL: Bool
        
        @frozen @usableFromInline enum Source {
            case userSort
            case eventSort
            case eventFeedbacksSort
            case achievementSort
            case notionSort
            case poolYear
            case poolMonth
            case campus
            case boolean
            case calendar
            
            @inlinable var stringKeys: [String] {
                switch self {
                case .userSort:
                    return HomeApiResources.userSortOptionsKeys.map { ~$0 }
                case .eventSort:
                    return HomeApiResources.eventSortOptionsKeys.map { ~$0 }
                case .eventFeedbacksSort:
                    return HomeApiResources.eventFeedbacksOptionsKeys.map { ~$0 }
                case .achievementSort:
                    return HomeApiResources.achievementOptionsKeys.map { ~$0 }
                case .notionSort:
                    return HomeApiResources.notionOptionsKeys.map { ~$0 }
                case .poolYear:
                    return (2014 ... Date().year).map({ "\($0)" })
                case .poolMonth:
                    return Date.monthsKeys.map { ~$0 }
                case .campus:
                    return HomeApiResources.campus.map({ $0.name })
                default:
                    fatalError()
                }
            }
            @inlinable var stringValues: [String] {
                switch self {
                case .userSort:
                    return HomeApiResources.userSortOptions
                case .eventSort:
                    return HomeApiResources.eventSortOptions
                case .eventFeedbacksSort:
                    return HomeApiResources.eventFeedbacksOptions
                case .achievementSort:
                    return HomeApiResources.achievementOptions
                case .notionSort:
                    return HomeApiResources.notionOptions
                case .poolMonth:
                    return Date.apiMonths
                default:
                    fatalError()
                }
            }
            @inlinable var intValues: [Int] {
                switch self {
                case .poolYear:
                    return (2014 ... Date().year).map({ $0 })
                default:
                    fatalError()
                }
            }
            @inlinable var campusValues: [IntraCampus] {
                return unsafeBitCast(HomeApiResources.campus, to: Array<IntraCampus>.self)
            }
        }
        
        @frozen @usableFromInline enum SelectorType {
            case string
            case stringAscDesc(AscDesc)
            case int
            case campus
            case boolean
            case date
            
            @frozen enum AscDesc {
                case asc
                case desc
            }
        }
    }
    
    @frozen enum Extra {
        case project(Int)
        case expertise(Int)
        case title(IntraTitle)
        case group(IntraGroup)
        case achievement(IntraUserAchievement)
        case coalitions(IntraCoalition, IntraBloc)
        case eventCampus
        case achievementCampus
        case notionCursus
    }
    
    let extra: Extra?
    
    init(delegate: G, defaultParameters: [HomeApi.Parameter: Any], extra: Extra? = nil) {
        var last: NSLayoutYAxisAnchor!
        let selectNone = ~"field.select-none"
        var index = 0
        
        self.delegate = delegate
        self.extra = extra
        if G.canExport {
            self.exportButton = ActionButtonView(asset: .actionShare, color: delegate.primary)
            self.header = HeaderWithActionsView(title: ~"title.settings.search", actions: [self.exportButton])
        }
        else {
            self.exportButton = nil
            self.header = HeaderWithActionsView(title: ~"title.settings.search")
        }
        self.scrollView = BasicUIScrollView()
        self.container = BasicUIView()
        self.selectorViews = []
        self.selectorViews.reserveCapacity(G.parameters.count)
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
        self.scrollView.contentInset = .init(top: 0.0, left: 0.0, bottom: HomeLayout.safeAera.bottom, right: 0.0)
        self.scrollView.addSubview(self.container)
        self.container.topAnchor.constraint(equalTo: self.scrollView.topAnchor).isActive = true
        self.container.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor).isActive = true
        self.container.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor).isActive = true
        self.container.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor).isActive = true
        self.container.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor).isActive = true
        self.exportButton?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(AdjustableParametersProviderViewController<G>.export(sender:))))
        
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
        
        func viewForParameter(_ parameter: Parameter) -> UIView {
            switch parameter.selectorType {
            case .string:
                let keys = parameter.source.stringKeys
                let values = parameter.source.stringValues
                let value = defaultParameters[parameter.key] as? String
                let view: MessageView<SelectorView<String>>
                let selectedIndex: Int? = value != nil ? (values.firstIndex(of: value!) ?? 0) : nil
                let selectedNone: String? = parameter.selectorCanSelectNULL ? selectNone : nil
                
                view = MessageView(text: ~parameter.selectorTitleKey, primary: delegate.primary, radius: HomeLayout.roundedGenericActionsViewRadius,
                                   view: SelectorView(keys: keys, values: values, selectedIndex: selectedIndex, selectNoneString: selectedNone))
                view.view.setPrimary(delegate.primary)
                self.selectorViews.append(view.view)
                return view
            case .stringAscDesc(let ascDesc):
                let view: MessageView<AscDescContainerView<SelectorView<String>>>
                let keys = parameter.source.stringKeys
                let values = parameter.source.stringValues
                let value = defaultParameters[parameter.key] as? String
                let selectedIndex: Int? = value != nil ? (values.firstIndex(of: value!) ?? 0) : nil
                let selectedNone: String? = parameter.selectorCanSelectNULL ? selectNone : nil
                
                view = MessageView(text: ~parameter.selectorTitleKey, primary: delegate.primary, radius: HomeLayout.roundedGenericActionsViewRadius,
                                   view: AscDescContainerView(SelectorView(keys: keys, values: values, selectedIndex: selectedIndex, selectNoneString: selectedNone), ascDesc: ascDesc))
                view.view.selector.setPrimary(delegate.primary)
                view.view.ascDescSelector.setPrimary(delegate.primary)
                self.selectorViews.append(view.view)
                return view
            case .int:
                let keys = parameter.source.stringKeys
                let values = parameter.source.intValues
                let value = defaultParameters[parameter.key] as? Int
                let view: MessageView<SelectorView<Int>>
                let selectedIndex: Int? = value != nil ? (values.firstIndex(of: value!) ?? 0) : nil
                let selectedNone: String? = parameter.selectorCanSelectNULL ? selectNone : nil
                
                view = MessageView(text: ~parameter.selectorTitleKey, primary: delegate.primary, radius: HomeLayout.roundedGenericActionsViewRadius,
                                   view: SelectorView(keys: keys, values: values, selectedIndex: selectedIndex, selectNoneString: selectedNone))
                view.view.setPrimary(delegate.primary)
                self.selectorViews.append(view.view)
                return view
            case .campus:
                let keys = parameter.source.stringKeys
                let values = parameter.source.campusValues
                let value = defaultParameters[parameter.key] as? Int
                let view: MessageView<SelectorView<IntraCampus>>
                let selectedIndex: Int? = value != nil ? (values.firstIndex(where: { $0.id == value! }) ?? 0) : nil
                let selectedNone: String? = parameter.selectorCanSelectNULL ? selectNone : nil
                
                view = MessageView(text: ~parameter.selectorTitleKey, primary: delegate.primary, radius: HomeLayout.roundedGenericActionsViewRadius,
                                   view: SelectorView(keys: keys, values: values, selectedIndex: selectedIndex, selectNoneString: selectedNone))
                view.view.setPrimary(delegate.primary)
                self.selectorViews.append(view.view)
                return view
            case .boolean:
                let value = defaultParameters[parameter.key] as? Bool
                let index = value == nil ? nil : (value == true ? 1 : 0)
                let view: MessageView<SelectorView<Bool>>
                
                view = MessageView(text: ~parameter.selectorTitleKey, primary: delegate.primary, radius: HomeLayout.roundedGenericActionsViewRadius,
                                   view: SelectorView(keys: [~"general.off-state", ~"general.on-state"], values: [false, true], selectedIndex: index, selectNoneString: selectNone))
                view.view.setPrimary(delegate.primary)
                self.selectorViews.append(view.view)
                return view
            case .date:
                let view: MessageView<DateSelectorView>
                let value: Date!
                
                if let date = defaultParameters[parameter.key] as? Date {
                    value = date
                }
                else {
                    value = parameter.selectorCanSelectNULL ? nil : Date()
                }
                view = MessageView(text: ~parameter.selectorTitleKey, primary: delegate.primary, radius: HomeLayout.roundedGenericActionsViewRadius,
                                   view: DateSelectorView(date: value, canBeNull: parameter.selectorCanSelectNULL, primary: delegate.primary))
                self.selectorViews.append(view.view)
                return view
            }
        }
        
        func searchViewForSearchParamater(_ search: SearchParameter) -> UIView {
            let view: UIView
            
            view = MessageView(text: ~search.title, primary: delegate.primary, radius: HomeLayout.roundedGenericActionsViewRadius,
                               view: SelectorView(keys: search.keysName.map({ ~$0 }) , values: search.keys.map({ $0.rawValue })))
            self.selectorViews.append((view as! MessageView<SelectorView<String>>).view)
            (view as! MessageView<SelectorView<String>>).view.delegate = self
            return view
        }
        
        last = self.container.topAnchor
        if extra != nil {
            addElementToContainer(LeftCurvedTitleView(text: ~"general.general", primaryColor: delegate.primary, addTopCorner: false), margin: 0.0)
        }
        if let search = G.searchParameter, search.keys.count > 1 {
            addElementToContainer(searchViewForSearchParamater(search))
        }
        while index < G.parameters.count {
            if G.parameters[index].selectorInlineWithNextElement {
                addDoubleElementsToContainer(viewForParameter(G.parameters[index]), viewForParameter(G.parameters[index &+ 1]))
                index &+= 2
            }
            else {
                addElementToContainer(viewForParameter(G.parameters[index]))
                index &+= 1
            }
        }
        if let extra = extra {
            switch extra {
            case .project(_):
                let states = IntraUserProject.Status.allCases
                let statesKeys: [String] = states.map({ ~$0.key })
                let view: MessageView<SelectorView<IntraUserProject.Status>>
                
                addElementToContainer(LeftCurvedTitleView(text: ~"general.projects", primaryColor: delegate.primary, addTopCorner: false), margin: 0.0)
                view = MessageView(text: ~"general.status", primary: delegate.primary, radius: HomeLayout.roundedGenericActionsViewRadius,
                                   view: SelectorView(keys: statesKeys, values: states, selectedIndex: nil, selectNoneString: selectNone))
                view.view.setPrimary(delegate.primary)
                view.view.delegate = self
                self.selectorViews.append(view.view)
                addElementToContainer(view)
            case .expertise(let expertiseId):
                let expertises: Array<IntraExpertise> = HomeApiResources.expertises.values.map({ $0 })
                let names = expertises.map(\.name)
                let index = expertises.firstIndex(where: { $0.id == expertiseId }) ?? 0
                let view: MessageView<SelectorView<IntraExpertise>>
                
                addElementToContainer(LeftCurvedTitleView(text: ~"title.expertises", primaryColor: delegate.primary, addTopCorner: false), margin: 0.0)
                view = MessageView(text: ~"title.expertise", primary: delegate.primary, radius: HomeLayout.roundedGenericActionsViewRadius,
                                   view: SelectorView(keys: names, values: expertises, selectedIndex: index, selectNoneString: nil))
                view.view.setPrimary(delegate.primary)
                view.view.delegate = self
                self.selectorViews.append(view.view)
                addElementToContainer(view)
            case .title(let title):
                let names = HomeApiResources.titles.map(\.name)
                let index = HomeApiResources.titles.firstIndex(where: { $0.id == title.id }) ?? 0
                let view: MessageView<SelectorView<IntraTitle>>
                
                addElementToContainer(LeftCurvedTitleView(text: ~"title.titles", primaryColor: delegate.primary, addTopCorner: false), margin: 0.0)
                view = MessageView(text: ~"title.title", primary: delegate.primary, radius: HomeLayout.roundedGenericActionsViewRadius,
                                 view: SelectorView(keys: names, values: unsafeBitCast(HomeApiResources.titles, to: [IntraTitle].self), selectedIndex: index, selectNoneString: nil))
                view.view.setPrimary(delegate.primary)
                view.view.delegate = self
                self.selectorViews.append(view.view)
                addElementToContainer(view)
            case .group(let group):
                let names = HomeApiResources.groups.map(\.name)
                let index = HomeApiResources.groups.firstIndex(where: { $0.id == group.id }) ?? 0
                let view: MessageView<SelectorView<IntraGroup>>
                
                addElementToContainer(LeftCurvedTitleView(text: ~"title.groups", primaryColor: delegate.primary, addTopCorner: false), margin: 0.0)
                view = MessageView(text: ~"title.group", primary: delegate.primary, radius: HomeLayout.roundedGenericActionsViewRadius,
                                   view: SelectorView(keys: names, values: unsafeBitCast(HomeApiResources.groups, to: [IntraGroup].self), selectedIndex: index, selectNoneString: nil))
                view.view.setPrimary(delegate.primary)
                view.view.delegate = self
                self.selectorViews.append(view.view)
                addElementToContainer(view)
            case .achievement(let achievement):
                let names = HomeApiResources.achievements.map(\.name)
                let index = HomeApiResources.achievements.firstIndex(where: { $0.id == achievement.id }) ?? 0
                let view: MessageView<SelectorView<IntraUserAchievement>>
                
                addElementToContainer(LeftCurvedTitleView(text: ~"title.achievements", primaryColor: delegate.primary, addTopCorner: false), margin: 0.0)
                view = MessageView(text: ~"title.achievement", primary: delegate.primary, radius: HomeLayout.roundedGenericActionsViewRadius,
                                   view: SelectorView(keys: names, values: unsafeBitCast(HomeApiResources.achievements, to: [IntraUserAchievement].self), selectedIndex: index, selectNoneString: nil))
                view.view.setPrimary(delegate.primary)
                view.view.delegate = self
                self.selectorViews.append(view.view)
                addElementToContainer(view)
            case .eventCampus:
                let keys = HomeApiResources.campus.map({ $0.name })
                let view: MessageView<SelectorView<IntraCampus>>
                var selectedIndex: Int = HomeApiResources.campus.firstIndex(where: { $0.id == App.userCampus.campus_id }) ?? 0
                let cursusView: MessageView<SelectorView<IntraCursus>>
                
                addElementToContainer(LeftCurvedTitleView(text: ~"sort.location", primaryColor: delegate.primary, addTopCorner: false), margin: 0.0)
                view = MessageView(text: ~"field.primary-campus", primary: delegate.primary, radius: HomeLayout.roundedGenericActionsViewRadius,
                                   view: SelectorView(keys: keys, values: unsafeBitCast(HomeApiResources.campus, to: [IntraCampus].self),
                                                      selectedIndex: selectedIndex, selectNoneString: selectNone))
                view.view.setPrimary(delegate.primary)
                view.view.delegate = self
                self.selectorViews.append(view.view)
                addElementToContainer(view)
                if let cursus = App.userCursus {
                    selectedIndex = HomeApiResources.cursus.firstIndex(where: { $0.id == cursus.cursus_id }) ?? 0
                }
                else {
                    selectedIndex = 0
                }
                cursusView = MessageView(text: ~"profil.info.cursus", primary: delegate.primary, radius: HomeLayout.roundedGenericActionsViewRadius,
                                         view: SelectorView(keys: HomeApiResources.cursus.map({ $0.name }), values: unsafeBitCast(HomeApiResources.cursus, to: [IntraCursus].self),
                                                            selectedIndex: selectedIndex, selectNoneString: selectNone))
                cursusView.view.setPrimary(delegate.primary)
                cursusView.view.delegate = self
                self.selectorViews.append(cursusView.view)
                addElementToContainer(cursusView)
            case .coalitions(let coalition, let bloc):
                let view: MessageView<SelectorView<IntraCoalition>>
                
                addElementToContainer(LeftCurvedTitleView(text: ~"title.coalitions", primaryColor: delegate.primary, addTopCorner: false), margin: 0.0)
                view = MessageView(text: ~"title.coalitions", primary: delegate.primary, radius: HomeLayout.roundedGenericActionsViewRadius,
                                   view: SelectorView(keys: bloc.coalitions.map({ $0.name }), values: bloc.coalitions, selectedIndex: bloc.coalitions.firstIndex(where: { $0.id == coalition.id }) ?? 0))
                view.view.setPrimary(delegate.primary)
                view.view.delegate = self
                self.selectorViews.append(view.view)
                addElementToContainer(view)
            case .achievementCampus:
                let value = App.userCampus.campus_id
                let view: MessageView<SelectorView<IntraCampus>>
                let selectedIndex: Int = (HomeApiResources.campus.firstIndex(where: { $0.id == value }) ?? 0)
               
                view = MessageView(text: ~"field.primary-campus", primary: delegate.primary, radius: HomeLayout.roundedGenericActionsViewRadius,
                                   view: SelectorView(keys: HomeApiResources.campus.map({ $0.name }), values: unsafeBitCast(HomeApiResources.campus, to: [IntraCampus].self),
                                                      selectedIndex: selectedIndex, selectNoneString: selectNone))
                view.view.setPrimary(delegate.primary)
                view.view.delegate = self
                self.selectorViews.append(view.view)
                addElementToContainer(LeftCurvedTitleView(text: ~"field.primary-campus", primaryColor: delegate.primary, addTopCorner: false), margin: 0.0)
                addElementToContainer(view)
            case .notionCursus:
                let view: MessageView<SelectorView<IntraUserCursus>>
                let index = App.user.cursus_users.firstIndex(of: App.userCursus) ?? 0
                
                view = MessageView(text: ~"profil.info.cursus", primary: delegate.primary, radius: HomeLayout.roundedGenericActionsViewRadius,
                                   view: SelectorView(keys: App.user.cursus_users.map({ $0.cursus.name }), values: App.user.cursus_users, selectedIndex: index))
                view.view.setPrimary(delegate.primary)
                view.view.delegate = self
                self.selectorViews.append(view.view)
                addElementToContainer(LeftCurvedTitleView(text: ~"profil.info.cursus", primaryColor: delegate.primary, addTopCorner: false), margin: 0.0)
                addElementToContainer(view)
            }
        }
        last.constraint(equalTo: self.container.bottomAnchor).isActive = true
    }
    required init() { fatalError("init() has not been implemented") }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private var needUpdate: Bool = false
    private var lastParameters: [String: Any]? = nil
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.lastParameters = self.parameters
    }
    
    func selectorSelect<E>(_ selector: SelectorView<E>) {
        let view: UIView
        let offset = G.searchParameter != nil && G.searchParameter!.keys.count > 1 ? 1 : 0
        
        if offset == 1, self.selectorViews[0] == selector {
            self.needUpdate = true
            return
        }
        else {
            view = self.selectorViews[G.parameters.count &+ offset]
        }
        switch self.extra! {
        case .project(_):
            return
        case .expertise(_):
            self.delegate.adjustableParametersProviderExtraValueSelected((view as! SelectorView<IntraExpertise>).value.name,
                                                                         newRoute: .expertisesWithExpertiseIdUsers((view as! SelectorView<IntraExpertise>).value.id))
        case .title(_):
            self.delegate.adjustableParametersProviderExtraValueSelected((view as! SelectorView<IntraTitle>).value.name,
                                                                         newRoute: .titlesWithTitleIdUsers((view as! SelectorView<IntraTitle>).value.id))
        case .group(_):
            self.delegate.adjustableParametersProviderExtraValueSelected((view as! SelectorView<IntraGroup>).value.name,
                                                                         newRoute: .groupsWithGroupIdUsers((view as! SelectorView<IntraGroup>).value.id))
        case .achievement(_):
            self.delegate.adjustableParametersProviderExtraValueSelected((view as! SelectorView<IntraUserAchievement>).value.name,
                                                                         newRoute: .achievementsWithAchievementIdUsers((view as! SelectorView<IntraUserAchievement>).value.id))
        case .eventCampus:
            let campusView = self.selectorViews[G.parameters.count &+ offset] as! SelectorView<IntraCampus>
            let cursusView = self.selectorViews[G.parameters.count &+ offset &+ 1] as! SelectorView<IntraCursus>
            let route: HomeApi.Routes
            
            if campusView.value == nil {
                if cursusView.value == nil {
                    route = .events
                }
                else {
                    route = .cursusWithCursusIdEvents(cursusView.value.id)
                }
            }
            else {
                if cursusView.value == nil {
                    route = .campusWithCampusIdEvents(campusView.value.id)
                }
                else {
                    route = .campusWithCampusIdCursusWithCursusIdEvents(campusView.value.id, cursusView.value.id)
                }
            }
            self.delegate.adjustableParametersProviderExtraValueSelected(~"title.events", newRoute: route)
        case .achievementCampus:
            if let id = (view as! SelectorView<IntraCampus>).value?.id {
                self.delegate.adjustableParametersProviderExtraValueSelected(~"title.achievements", newRoute: .campusWithCampusIdAchievements(id))
            }
            else {
                self.delegate.adjustableParametersProviderExtraValueSelected(~"title.achievements", newRoute: .achievements)
            }
        case .coalitions(_, _):
            self.delegate.adjustableParametersProviderExtraValueSelected(~"title.coalitions", newRoute: .coalitionsWithCoalitionIdUsers((view as! SelectorView<IntraCoalition>).value.id))
            self.primaryChanged((view as! SelectorView<IntraCoalition>).value.uicolor)
        case .notionCursus:
            unowned(unsafe) let value = (view as! SelectorView<IntraUserCursus>).value!
            
            self.delegate.adjustableParametersProviderExtraValueSelected(value.cursus.name, newRoute: .cursusWithCursusIdNotions(value.cursus_id))
        }
        self.needUpdate = true
    }
    
    var parameters: [String: Any] {
        
        var parameters: [String: Any] = G.defaultParameters
        var view: UIView
        var index = 0
        let searchText: String
        
        if let search = G.searchParameter {
            searchText = self.delegate[keyPath: search.textGetter]
            if search.keys.count > 1 {
                if searchText.count > 0 {
                    parameters[(self.selectorViews[0] as! SelectorView<String>).value] = searchText
                }
                index &+= 1
            }
            else {
                if searchText.count > 0 {
                    parameters[search.keys[0]] = searchText
                }
            }
        }
        for parameter in G.parameters {
            view = self.selectorViews[index]
            switch parameter.selectorType {
            case .string:
                parameters[parameter.key] = (view as! SelectorView<String>).value
            case .stringAscDesc(_):
                if let value = (view as! AscDescContainerView<SelectorView<String>>).selector.value {
                    switch (view as! AscDescContainerView<SelectorView<String>>).ascDescSelector.value! {
                    case .asc:
                        parameters[parameter.key] = value
                    case .desc:
                        parameters[parameter.key] = "-\(value)"
                    }
                }
            case .int:
                parameters[parameter.key] = (view as! SelectorView<Int>).value
            case .campus:
                parameters[parameter.key] = (view as! SelectorView<IntraCampus>).value?.id
            case .boolean:
                parameters[parameter.key] = (view as! SelectorView<Bool>).value
            case .date:
                parameters[parameter.key] = (view as! DateSelectorView).date?.toString(.apiShortFormat)
            }
            index &+= 1
        }
        if let extra = self.extra {
            switch extra {
            case .project(_):
                parameters["filter[status]"] = (self.selectorViews[index] as! SelectorView<IntraUserProject.Status>).value?.rawValue
                break
            default:
                break
            }
        }
        return parameters
    }
    
    func closeButtonTapped() {
        let completion: (() -> Void)?
        let newParameters = self.parameters
        
        if let last = self.lastParameters, newParameters.isContentEqual(last), self.needUpdate == false {
            completion = nil
        }
        else {
            completion = {
                self.delegate.adjustableParametersProviderParametersUpdated(newParameters)
            }
        }
        self.needUpdate = false
        self.dismiss(animated: true, completion: completion)
    }
    
    private func primaryChanged(_ primary: UIColor) {
        for view in self.container.subviews where view is LeftCurvedTitleView {
            (view as! LeftCurvedTitleView).update(with: (view as! LeftCurvedTitleView).text!, primaryColor: primary, animate: false)
        }
        for selectorView in self.selectorViews {
            switch selectorView {
            case let view as SelectorView<String>:
                view.setPrimary(primary)
                (view.superview as! MessageView<SelectorView<String>>).primary = primary
            case let view as AscDescContainerView<SelectorView<String>>:
                view.selector.setPrimary(primary)
                view.ascDescSelector.setPrimary(primary)
                (view.superview as! MessageView<AscDescContainerView<SelectorView<String>>>).primary = primary
            case let view as SelectorView<Int>:
                view.setPrimary(primary)
                (view.superview as! MessageView<SelectorView<Int>>).primary = primary
            case let view as SelectorView<IntraCampus>:
                view.setPrimary(primary)
                (view.superview as! MessageView<SelectorView<IntraCampus>>).primary = primary
            case let view as SelectorView<IntraCoalition>:
                view.setPrimary(primary)
                (view.superview as! MessageView<SelectorView<IntraCoalition>>).primary = primary
            case let view as SelectorView<Bool>:
                view.setPrimary(primary)
                (view.superview as! MessageView<SelectorView<Bool>>).primary = primary
            case let view as DateSelectorView:
                view.setPrimary(primary)
                (view.superview as! MessageView<DateSelectorView>).primary = primary
            default:
                #if DEBUG
                print("AdjustableParametersProviderViewController", #function, "unsupported view type", selectorView)
                #endif
            }
        }
        for action in self.header.actions where action.asset == .actionShare {
            action.primary = primary
        }
    }
    
    final private class AscDescContainerView<G: UIView>: BasicUIView {
        
        let ascDescSelector: SelectorView<Parameter.SelectorType.AscDesc>
        let selector: G
        
        init(_ view: G, ascDesc: Parameter.SelectorType.AscDesc) {
            self.ascDescSelector = SelectorView(keys: [~"sort.options.ascending", ~"sort.options.descending"], values: [.asc, .desc], selectedIndex: ascDesc == .asc ? 0 : 1)
            self.selector = view
            super.init()
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else {
                return
            }
            
            self.addSubview(self.selector)
            self.selector.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            self.selector.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            self.selector.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            self.addSubview(self.ascDescSelector)
            self.ascDescSelector.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            self.ascDescSelector.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            self.ascDescSelector.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            self.ascDescSelector.leadingAnchor.constraint(equalTo: self.selector.trailingAnchor, constant: HomeLayout.smargin).isActive = true
            self.ascDescSelector.widthAnchor.constraint(equalTo: self.selector.widthAnchor).isActive = true
        }
    }
        
    @objc private func export(sender: UITapGestureRecognizer) {
        
        func share() {
            self.present(UIActivityViewController(activityItems: [self.delegate.adjustableParametersProviderWillExport()], applicationActivities: nil), animated: true)
        }
        
        DynamicAlert(.noneWithPrimary(self.delegate.primary), contents: [.title(~"export.title"), .text(~"export.description")], actions: [.normal(~"general.cancel", nil), .highligth(~"general.generate", share)])
    }
}
