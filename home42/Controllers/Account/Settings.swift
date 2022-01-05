//
//  Settings.swift
//  home42
//
//  Created by Antoine Feuerstein on 18/04/2021.
//

import Foundation
import UIKit
import SwiftUI

final class SettingsViewController: HomeViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let header: HeaderWithActionsView
    private let tableView: BasicUITableView
    private let sections: [SettingsViewController.Section]
    private let extraView: ExtraView
    
    required init() {
        self.header = HeaderWithActionsView(title: ~"TITLE_SETTINGS")
        self.tableView = BasicUITableView()
        self.tableView.sectionHeaderHeight = UITableView.automaticDimension
        self.tableView.estimatedSectionHeaderHeight = HomeLayout.leftCurvedTitleViewHeigth
        self.tableView.register(SectionTableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "header")
        self.tableView.register(RowBooleanTableViewCell.self, forCellReuseIdentifier: SettingsRowAvailable.boolean.rawValue)
        self.tableView.register(RowSelectorEnumTableViewCell<UserSettings.GraphicsTransitionDuration>.self, forCellReuseIdentifier: SettingsRowEnumAvailable.GraphicsTransitionDuration.rawValue)
        self.tableView.register(RowSelectorEnumTableViewCell<UserSettings.ParallaxForce>.self, forCellReuseIdentifier: SettingsRowEnumAvailable.ParallaxForce.rawValue)
        self.tableView.register(RowSelectorEnumTableViewCell<UserSettings.ClustersPlaceClassName>.self, forCellReuseIdentifier: SettingsRowEnumAvailable.ClustersPlaceClassName.rawValue)
        self.tableView.register(RowSelectorEnumTableViewCell<UserSettings.ClusterSearchViewSort>.self, forCellReuseIdentifier: SettingsRowEnumAvailable.ClusterSearchViewSort.rawValue)
        self.tableView.register(RowSelectorEnumTableViewCell<UserSettings.PeopleListViewControllerSort>.self, forCellReuseIdentifier: SettingsRowEnumAvailable.PeopleListViewControllerSort.rawValue)
        self.tableView.register(RowIntegerCounterTableViewCell.self, forCellReuseIdentifier: SettingsRowAvailable.integerCounter.rawValue)
        self.tableView.register(RowActionsTableViewCell.self, forCellReuseIdentifier: SettingsRowAvailable.actions.rawValue)
        self.tableView.register(RowCacheActionsTableViewCell.self, forCellReuseIdentifier: SettingsRowAvailable.cacheActions.rawValue)
        self.tableView.register(RowCustomizePeopleTableViewCell.self, forCellReuseIdentifier: SettingsRowAvailable.customizePeople.rawValue)
        self.sections = SettingsViewController.sections.filter({ section in
            return section.controllerIsHidden == false || section.controllerHiddenType.checkDefaultsValue()
        })
        self.extraView = ExtraView()
        super.init()
        self.view.backgroundColor = HomeDesign.white
        self.view.addSubview(self.header)
        self.header.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.header.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.header.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.view.addSubview(self.tableView)
        self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.tableView.topAnchor.constraint(equalTo: self.header.bottomAnchor).isActive = true
        self.view.addSubview(self.extraView)
        self.extraView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.extraView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.extraView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.extraView.topAnchor.constraint(equalTo: self.tableView.bottomAnchor).isActive = true
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        App.settings.save()
    }
    
    private struct Section {
        let titleKey: String
        let controllerIcon: UIImage.Assets?
        let controllerIsHidden: Bool
        let controllerHiddenType: HiddenViewController.Type!
        
        struct RowBoolean: SettingsRowData {
            let reuseIdentifier: String = SettingsRowAvailable.boolean.rawValue
            let descriptionKey: String
            let keypath: ReferenceWritableKeyPath<UserSettings, Bool>
            
            init(_ descriptionKey: String, keypath: ReferenceWritableKeyPath<UserSettings, Bool>) {
                self.descriptionKey = descriptionKey
                self.keypath = keypath
            }
        }
        struct RowSelectorEnum<G: SelectorViewSource>: SettingsRowData {
            let reuseIdentifier: String = {
                if G.self == UserSettings.ClustersPlaceClassName.self {
                    return SettingsRowEnumAvailable.ClustersPlaceClassName.rawValue
                }
                else if G.self == UserSettings.ClusterSearchViewSort.self {
                    return SettingsRowEnumAvailable.ClusterSearchViewSort.rawValue
                }
                else if G.self == UserSettings.PeopleListViewControllerSort.self  {
                    return SettingsRowEnumAvailable.PeopleListViewControllerSort.rawValue
                }
                else if G.self == UserSettings.GraphicsTransitionDuration.self {
                    return SettingsRowEnumAvailable.GraphicsTransitionDuration.rawValue
                }
                else {
                    return SettingsRowEnumAvailable.ParallaxForce.rawValue
                }
            }()
            let descriptionKey: String
            let keypath: ReferenceWritableKeyPath<UserSettings, G>
            
            init(_ descriptionKey: String, keypath: ReferenceWritableKeyPath<UserSettings, G>) {
                self.descriptionKey = descriptionKey
                self.keypath = keypath
            }
        }
        struct RowIntegerCounter: SettingsRowData {
            let reuseIdentifier: String = SettingsRowAvailable.integerCounter.rawValue
            let descriptionKey: String
            let keypath: ReferenceWritableKeyPath<UserSettings, Int>
            let min: Int
            let max: Int
            let step: Int
            
            init(_ descriptionKey: String, keypath: ReferenceWritableKeyPath<UserSettings, Int>, min: Int, max: Int, step: Int) {
                self.descriptionKey = descriptionKey
                self.keypath = keypath
                self.min = min
                self.max = max
                self.step = step
            }
        }
        struct RowActions: SettingsRowData {
            let reuseIdentifier: String = SettingsRowAvailable.actions.rawValue
            let descriptionKey: String
            
            struct Action {
                let selector: Selector
                let asset: UIImage.Assets
                let color: UIColor?
            }
            let actions: [RowActions.Action]
            
            init(_ descriptionKey: String, actions: [RowActions.Action]) {
                self.descriptionKey = descriptionKey
                self.actions = actions
            }
        }
        struct RowCacheActions: SettingsRowData {
            let reuseIdentifier: String = SettingsRowAvailable.cacheActions.rawValue
            let descriptionKey: String
            let directory: HomeResources.DocumentDirectory
            let actions: [RowActions.Action]
            
            init(_ descriptionKey: String, directory: HomeResources.DocumentDirectory, actions: [RowActions.Action]) {
                self.descriptionKey = descriptionKey
                self.directory = directory
                self.actions = actions
            }
        }
        struct RowCustomizePeople: SettingsRowData {
            let reuseIdentifier: String = SettingsRowAvailable.customizePeople.rawValue
            let descriptionKey: String
            let keypath: ReferenceWritableKeyPath<UserSettings, UIImage.Assets>
            let assets: [UIImage.Assets]
            let colorKeyPath: ReferenceWritableKeyPath<UserSettings, DecodableColor>
            let namePath: ReferenceWritableKeyPath<UserSettings, String>
            
            init(_ descriptionKey: String, keypath: ReferenceWritableKeyPath<UserSettings, UIImage.Assets>, assets: [UIImage.Assets],
                 colorKeyPath: ReferenceWritableKeyPath<UserSettings, DecodableColor>, namePath: ReferenceWritableKeyPath<UserSettings, String>) {
                self.descriptionKey = descriptionKey
                self.keypath = keypath
                self.assets = assets
                self.colorKeyPath = colorKeyPath
                self.namePath = namePath
            }
        }
        struct RowButton: SettingsRowData {
            let reuseIdentifier: String = SettingsRowAvailable.button.rawValue
            let descriptionKey: String
        }
        let rows: [SettingsRowData]
        
        init(_ titleKey: String, _ controllerIcon: UIImage.Assets?, _ controllerIsHidden: Bool = false, _ controllerHiddenType: HiddenViewController.Type! = nil, rows: [SettingsRowData]) {
            self.titleKey = titleKey
            self.controllerIcon = controllerIcon
            self.controllerIsHidden = controllerIsHidden
            self.controllerHiddenType = controllerHiddenType
            self.rows = rows
        }
    }
    static private let sections: [SettingsViewController.Section] = [
        .init("GENERAL", nil, rows: [
            Section.RowBoolean.init("SD_GENERAL_DEPTHCLOSE", keypath: \.depthCloseActivated),
            Section.RowIntegerCounter.init("SD_GENERAL_DEPTHCLOSE_VALUE", keypath: \.depthMinimum, min: 1, max: 30, step: 1)
        ]),
        .init("SETTINGS_TITLE_GRAPHICS", nil, rows: [
            Section.RowBoolean.init("SD_BLURPRIMARY_GRAPHICS", keypath: \.graphicsBlurPrimary),
            Section.RowSelectorEnum.init("SD_TRANSITION_DURATION", keypath: \.graphicsTransitionDuration),
            Section.RowBoolean.init("SD_BLURPRIMARY_TRANSITION", keypath: \.graphicsBlurPrimaryTransition),
            Section.RowBoolean.init("SD_BLUR_HEADER", keypath: \.graphicsBlurHeader),
            Section.RowBoolean.init("SD_USE_PARALLAX", keypath: \.graphicsUseParallax),
            Section.RowSelectorEnum.init("SD_PARALLAX_FORCE", keypath: \.graphicsParallaxForce)
        ]),
        .init("TITLE_PROFIL", nil, rows: [
            Section.RowBoolean.init("SD_SHOW_EVENTS", keypath: \.profilShowEvents),
            // Section.RowBoolean.init("SD_SHOW_CORRECTIONS", keypath: \.profilShowCorrections),
            // Section.RowIntegerCounter.init("SD_CORRECTIONS_COUNT", keypath: \.profilCorrectionsCount, min: 1, max: 8, step: 1),
            // Section.RowBoolean.init("SD_SHOW_LOGS", keypath: \.profilShowLogs),
            Section.RowBoolean.init("SD_SHOW_PARTNERSHIP", keypath: \.profilShowPartnerships)
        ]),
        .init("TITLE_CLUSTERS", .controllerClusters, rows: [
            Section.RowSelectorEnum.init("SD_PLACES", keypath: \.clustersPlaceClassName),
            Section.RowSelectorEnum.init("SD_CLUSTER_SEARCH_SORT", keypath: \.clusterSearchViewSort),
            Section.RowBoolean.init("SD_CLUSTER_SHOW_COUNTERS", keypath: \.clusterShowCounters),
            Section.RowBoolean.init("SD_CLUSTER_HIDE_PLACES_COUNTERS", keypath: \.clusterHidePlaceCounter),
            Section.RowBoolean.init("SD_CLUSTER_COUNTER_PREFER_TAKEN_PLACES", keypath: \.clusterCounterPreferTakenPlaces)
        ]),
        .init("TITLE_TRACKER", .controllerTracker, true, TrackerViewController.self, rows: [
            Section.RowBoolean.init("SD_CLUSTER_SHOW_HISTORIC", keypath: \.trackerShowLocationHistoric),
            Section.RowSelectorEnum.init("SD_PEOPLES_SORT", keypath: \.peopleListViewControllerSort),
            Section.RowBoolean.init("SD_PEOPLES_WARN", keypath: \.peopleWarnWhenRemove),
            Section.RowBoolean.init("SD_PEOPLES_E1_AVAILABLE", keypath: \.peopleExtraList1Available),
            Section.RowCustomizePeople.init("SD_PEOPLES_E1_ICON", keypath: \.peopleExtraList1Icon, assets: People.assets, colorKeyPath: \.peopleExtraList1Color, namePath: \.peopleExtraList1Name),
            Section.RowBoolean.init("SD_PEOPLES_E2_AVAILABLE", keypath: \.peopleExtraList2Available),
            Section.RowCustomizePeople.init("SD_PEOPLES_E2_ICON", keypath: \.peopleExtraList2Icon, assets: People.assets, colorKeyPath: \.peopleExtraList2Color, namePath: \.peopleExtraList2Name)
        ]),
        .init("TITLE_EVENTS", .controllerEvents, rows: [
            Section.RowBoolean.init("SD_WARN_SUB", keypath: \.eventsWarnSubscription)
        ]),
        .init("TITLE_ELEARNING", .controllerElearning, rows: [
            Section.RowBoolean.init("SD_ELEARNING_HD", keypath: \.elearningHD)
        ]),
        /*.init("TITLE_CORRECTIONS", .controllerCorrections, true, CorrectionsViewController.self, rows: [
        
        ]),*/
        .init("TITLE_GRAPH", .controllerGraph, rows: [
            Section.RowBoolean.init("SD_GRAPH_ADD_COLOR_TO_CARD", keypath: \.graphMixColor),
            Section.RowBoolean.init("SD_GRAPH_PREFER_BLACK_THEME", keypath: \.graphPreferDarkTheme)
        ]),
        .init("SETTINGS_TITLE_CACHES", nil, rows: [
            Section.RowCacheActions.init("SD_CACHE_PROFIL", directory: .logins, actions: [
                .init(selector: #selector(RowCacheActionsTableViewCell.removeHandler(gesture:)), asset: .actionTrash, color: HomeDesign.redError),
                .init(selector: #selector(RowCacheActionsTableViewCell.seeHandler(gesture:)), asset: .actionSee, color: nil)
            ]),
            Section.RowCacheActions.init("SD_CACHE_COALITIONS", directory: .coalitions, actions: [
                .init(selector: #selector(RowCacheActionsTableViewCell.removeHandler(gesture:)), asset: .actionTrash, color: HomeDesign.redError),
                .init(selector: #selector(RowCacheActionsTableViewCell.seeHandler(gesture:)), asset: .actionSee, color: nil)
            ]),
            Section.RowCacheActions.init("SD_CACHE_SVG_COALITIONS", directory: .svgCoalitions, actions: [
                .init(selector: #selector(RowCacheActionsTableViewCell.removeHandler(gesture:)), asset: .actionTrash, color: HomeDesign.redError),
                .init(selector: #selector(RowCacheActionsTableViewCell.seeHandler(gesture:)), asset: .actionSee, color: nil)
            ]),
            Section.RowCacheActions.init("SD_CACHE_SVG_ACHIEVEMENTS", directory: .svgAchievements, actions: [
                .init(selector: #selector(RowCacheActionsTableViewCell.removeHandler(gesture:)), asset: .actionTrash, color: HomeDesign.redError),
                .init(selector: #selector(RowCacheActionsTableViewCell.seeHandler(gesture:)), asset: .actionSee, color: nil)
            ])
        ])
    ]
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].rows.count
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as! SectionTableViewHeaderFooterView
        let section = self.sections[section]
        
        view.update(with: ~section.titleKey, primaryColor: section.controllerIsHidden ? HomeDesign.gold : HomeDesign.primary)
        return view
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return HomeLayout.leftCurvedTitleViewHeigth
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = self.sections[indexPath.section].rows[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseIdentifier, for: indexPath)
        
        switch row {
        case let rowBoolean as Section.RowBoolean:
            (cell as! RowBooleanTableViewCell).update(with: rowBoolean)
        case let rowIntegerCounter as Section.RowIntegerCounter:
            (cell as! RowIntegerCounterTableViewCell).update(with: rowIntegerCounter)
        case let RowCustomizePeople as Section.RowCustomizePeople:
            (cell as! RowCustomizePeopleTableViewCell).update(with: RowCustomizePeople)
        case let rowActions as Section.RowActions:
            (cell as! RowActionsTableViewCell).update(with: rowActions, target: self)
        case let rowCacheActions as Section.RowCacheActions:
            (cell as! RowCacheActionsTableViewCell).update(with: rowCacheActions)
        case let clustersPlaceClassName as Section.RowSelectorEnum<UserSettings.ClustersPlaceClassName>:
            (cell as! RowSelectorEnumTableViewCell<UserSettings.ClustersPlaceClassName>).update(with: clustersPlaceClassName)
        case let clusterSearchViewSort as Section.RowSelectorEnum<UserSettings.ClusterSearchViewSort>:
            (cell as! RowSelectorEnumTableViewCell<UserSettings.ClusterSearchViewSort>).update(with: clusterSearchViewSort)
        case let PeopleListViewControllerSort as Section.RowSelectorEnum<UserSettings.PeopleListViewControllerSort>:
            (cell as! RowSelectorEnumTableViewCell<UserSettings.PeopleListViewControllerSort>).update(with: PeopleListViewControllerSort)
        case let parallaxForce as Section.RowSelectorEnum<UserSettings.ParallaxForce>:
            (cell as! RowSelectorEnumTableViewCell<UserSettings.ParallaxForce>).update(with: parallaxForce)
        case let graphicsTransitionDuration as Section.RowSelectorEnum<UserSettings.GraphicsTransitionDuration>:
            (cell as! RowSelectorEnumTableViewCell<UserSettings.GraphicsTransitionDuration>).update(with: graphicsTransitionDuration)
        default:
            break
        }
        return cell
    }
}

// MARK: -
fileprivate enum SettingsRowAvailable: String {
    case boolean
    case selectorEnum
    case integerCounter
    case actions
    case cacheActions
    case customizePeople
    case button
}
fileprivate enum SettingsRowEnumAvailable: String {
    case GraphicsTransitionDuration
    case ParallaxForce
    case ClustersPlaceClassName
    case ClusterSearchViewSort
    case PeopleListViewControllerSort
}
fileprivate protocol SettingsRowData {
    var descriptionKey: String { get }
    var reuseIdentifier: String { get }
}
fileprivate protocol SettingsRowView: UIView {
    associatedtype Value // unused?
    
    static func defaultView() -> Self
}
extension HomeSwitch: SettingsRowView {
    typealias Value = Bool
    
    static func defaultView() -> HomeSwitch {
        return HomeSwitch()
    }
}
extension SelectorView: SettingsRowView {
    typealias Value = E
    
    static func defaultView() -> SelectorView<E> {
        return SelectorView<E>(keys: [], values: [])
    }
}
extension ValueSelectorWithArrows: SettingsRowView {
    typealias Value = V
    
    static func defaultView() -> ValueSelectorWithArrows<V> {
        return ValueSelectorWithArrows<V>(min: 1, max: 3, step: 1, value: 1)
    }
}
extension BasicUIStackView: SettingsRowView {
    typealias Value = Swift.Void
    
    static func defaultView() -> BasicUIStackView {
        let view = BasicUIStackView()
        
        view.distribution = .fillEqually
        view.spacing = HomeLayout.smargin
        view.alignment = .fill
        view.axis = .horizontal
        return view
    }
}

// MARK: -
extension SettingsViewController {
    
    private class RowTableViewCell<G: SettingsRowView, V>: BasicUITableViewCell where G.Value == V {
        
        let borderView: BasicUIView
        let descriptionLabel: BasicUILabel
        let valueView: G

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            self.borderView = BasicUIView()
            self.borderView.layer.cornerRadius = HomeLayout.corner
            self.borderView.backgroundColor = HomeDesign.lightGray
            self.descriptionLabel = BasicUILabel(text: "???")
            self.descriptionLabel.font = HomeLayout.fontRegularMedium
            self.descriptionLabel.textColor = HomeDesign.black
            self.descriptionLabel.text = "???"
            self.descriptionLabel.numberOfLines = 0
            self.valueView = G.defaultView()
            super.init(style: style, reuseIdentifier: reuseIdentifier)
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }
            
            self.contentView.addSubview(self.borderView)
            self.borderView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: HomeLayout.margin).isActive = true
            self.borderView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: HomeLayout.margin).isActive = true
            self.borderView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -HomeLayout.margin).isActive = true
            self.contentView.addSubview(self.valueView)
            self.valueView.centerYAnchor.constraint(equalTo: self.borderView.bottomAnchor).isActive = true
            self.valueView.trailingAnchor.constraint(equalTo: self.borderView.trailingAnchor, constant: -HomeLayout.margin).isActive = true
            self.valueView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -HomeLayout.smargin).isActive = true
            self.borderView.addSubview(self.descriptionLabel)
            self.descriptionLabel.topAnchor.constraint(equalTo: self.borderView.topAnchor, constant: HomeLayout.margin).isActive = true
            self.descriptionLabel.leadingAnchor.constraint(equalTo: self.borderView.leadingAnchor, constant: HomeLayout.margin).isActive = true
            self.descriptionLabel.trailingAnchor.constraint(equalTo: self.borderView.trailingAnchor, constant: -HomeLayout.margin).isActive = true
            self.descriptionLabel.bottomAnchor.constraint(equalTo: self.valueView.topAnchor, constant: -HomeLayout.smargin).isActive = true
        }
    }
    
    // MARK: -
    final private class RowBooleanTableViewCell: RowTableViewCell<HomeSwitch, Bool>, HomeSwitchDelegate {
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            self.valueView.delegate = self
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        private var row: Section.RowBoolean!
        func update(with row: Section.RowBoolean) {
            self.row = row
            self.descriptionLabel.text = ~row.descriptionKey
            self.valueView.set(isOn: App.settings[keyPath: row.keypath], animated: false)
        }
        func switchValueChanged(switch: HomeSwitch) {
            App.settings[keyPath: self.row.keypath] = `switch`.isOn
        }
    }
    
    final private class RowSelectorEnumTableViewCell<G: SelectorViewSource>: RowTableViewCell<SelectorView<G>, G>, SelectorViewDelegate {
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            self.valueView.delegate = self
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        var row: Section.RowSelectorEnum<G>!
        func update(with row: Section.RowSelectorEnum<G>) {
            let value = App.settings[keyPath: row.keypath]
            
            self.row = row
            self.descriptionLabel.text = ~row.descriptionKey
            self.valueView.update(keys: G.allKeys.map({ ~$0 }), values: G.allValues, selectedIndex: G.allValues.firstIndex(where: { $0 == value }) ?? 0)
        }
        
        func selectorSelect<E>(_ selector: SelectorView<E>) {
            App.settings[keyPath: self.row.keypath] = unsafeBitCast(selector.value, to: G.self)
        }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }

            super.willMove(toSuperview: newSuperview)
            self.valueView.leadingAnchor.constraint(greaterThanOrEqualTo: self.borderView.leadingAnchor, constant: HomeLayout.margin).isActive = true
        }
    }
    
    final private class RowIntegerCounterTableViewCell: RowTableViewCell<ValueSelectorWithArrows<Int>, Int>, ValueSelectorWithArrowsDelegate {
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            self.valueView.delegate = self
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        var row: Section.RowIntegerCounter!
        func update(with row: Section.RowIntegerCounter) {
            self.row = row
            self.descriptionLabel.text = ~row.descriptionKey
            self.valueView.update(min: row.min, max: row.max, step: row.step, value: App.settings[keyPath: row.keypath])
        }
        
        func valueSelectorChanged() {
            App.settings[keyPath: self.row.keypath] = self.valueView.value
        }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }
            
            super.willMove(toSuperview: newSuperview)
            self.valueView.leadingAnchor.constraint(greaterThanOrEqualTo: self.borderView.leadingAnchor, constant: HomeLayout.margin).isActive = true
        }
    }
    
    final private class RowActionsTableViewCell: RowTableViewCell<BasicUIStackView, Swift.Void> {
    
        var row: Section.RowActions!
        func update(with row: Section.RowActions, target: SettingsViewController) {
            var recycledViews = self.valueView.arrangedSubviews as! [ActionButtonView]
            var actionView: ActionButtonView
            
            self.row = row
            self.descriptionLabel.text = ~row.descriptionKey
            for view in recycledViews {
                self.valueView.removeArrangedSubview(view)
            }
            for action in row.actions {
                if recycledViews.isEmpty == false {
                    actionView = recycledViews.removeFirst()
                    if let gestures = actionView.gestureRecognizers {
                        for gesture in gestures {
                            actionView.removeGestureRecognizer(gesture)
                        }
                    }
                    actionView.set(asset: action.asset, color: action.color ?? HomeDesign.primary)
                }
                else {
                    actionView = ActionButtonView(asset: action.asset, color: action.color ?? HomeDesign.primary)
                }
                actionView.addGestureRecognizer(UITapGestureRecognizer.init(target: target, action: action.selector))
                self.valueView.addArrangedSubview(actionView)
            }
        }
    }
    
    final private class RowCacheActionsTableViewCell: RowTableViewCell<BasicUIStackView, Swift.Void> {
        
        var row: Section.RowCacheActions!
        func update(with row: Section.RowCacheActions) {
            var recycledViews = self.valueView.arrangedSubviews as! [ActionButtonView]
            var actionView: ActionButtonView
            
            self.row = row
            self.descriptionLabel.text = ~row.descriptionKey
            for view in recycledViews {
                self.valueView.removeArrangedSubview(view)
            }
            for action in row.actions {
                if recycledViews.isEmpty == false {
                    actionView = recycledViews.removeFirst()
                    if let gestures = actionView.gestureRecognizers {
                        for gesture in gestures {
                            actionView.removeGestureRecognizer(gesture)
                        }
                    }
                    actionView.set(asset: action.asset, color: action.color ?? HomeDesign.primary)
                }
                else {
                    actionView = ActionButtonView(asset: action.asset, color: action.color ?? HomeDesign.primary)
                }
                actionView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: action.selector))
                self.valueView.addArrangedSubview(actionView)
            }
        }
        
        @objc func removeHandler(gesture: UITapGestureRecognizer) {
            DynamicAlert(contents: [.title(~"SETTINGS_TITLE_CACHES"), .text(~"CACHE_WILL_BE_DELETED_ALERT")], actions: [.normal(~"CANCEL", nil), .highligth(~"REMOVE", {
                switch self.row.directory {
                case .logins:
                    HomeResources.storageLoginImages.removeAllStoredFiles()
                    HomeResources.storageLoginImages.clearCache()
                case .coalitions:
                    HomeResources.storageCoalitionsImages.removeAllStoredFiles()
                    HomeResources.storageCoalitionsImages.clearCache()
                case .svgAchievements:
                    HomeResources.storageSVGAchievement.removeAllStoredFiles()
                    HomeResources.storageSVGAchievement.removeAllStoredFiles()
                case .svgCoalitions:
                    HomeResources.storageSVGCoalition.removeAllStoredFiles()
                    HomeResources.storageSVGCoalition.clearCache()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                    DynamicAlert(.none, contents: [.title(~"SETTINGS_TITLE_CACHES"), .text(~"CACHE_DELETED")], actions: [.normal(~"OK", nil)])
                })
            })])
        }
        
        @objc func seeHandler(gesture: UITapGestureRecognizer) {
            let seeCache: HomeViewController
            
            switch self.row.directory {
            case .logins:
                seeCache = SeeCacheImagesViewController(directory: .logins, style: .profil)
            case .coalitions:
                seeCache = SeeCacheImagesViewController(directory: self.row.directory, style: .landscapeCinema)
            case .svgAchievements, .svgCoalitions:
                seeCache = SeeCacheSVGsViewController(directory: self.row.directory, style: .square(count: 4.0))
            }
            (self.parentViewController as! HomeViewController).presentWithBlur(seeCache, completion: nil)
        }
    }
    
    final private class RowCustomizePeopleTableViewCell: RowTableViewCell<RowCustomizePeopleTableViewCell.ActionsSelector, People> {
        
        final class ActionsSelector: RoundedGenericActionsView<BasicUIImageView, ActionButtonView>, SettingsRowView {
            
            typealias Value = People
            
            static func defaultView() -> RowCustomizePeopleTableViewCell.ActionsSelector {
                return ActionsSelector(BasicUIImageView(asset: .actionPeople))
            }
            
            init(_ view: BasicUIImageView) {
                super.init(view, initialActions: [ActionButtonView(asset: .actionText, color: HomeDesign.primary),
                                                  ActionButtonView(asset: .actionBrush, color: HomeDesign.primary),
                                                  ActionButtonView(asset: .actionSelect, color: HomeDesign.primary)])
            }
            required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        }
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            for (index, selector) in [#selector(RowCustomizePeopleTableViewCell.selectName(gesture:)),
                                      #selector(RowCustomizePeopleTableViewCell.selectColor(gesture:)),
                                      #selector(RowCustomizePeopleTableViewCell.selectIcon(gesture:))].enumerated() {
                self.valueView.actionViews[index].isUserInteractionEnabled = true
                self.valueView.actionViews[index].addGestureRecognizer(UITapGestureRecognizer(target: self, action: selector))
            }
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        var row: Section.RowCustomizePeople!
        var color: UIColor = HomeDesign.primary
        
        func update(with row: Section.RowCustomizePeople) {
            self.row = row
            self.descriptionLabel.text = ~row.descriptionKey
            self.color = App.settings[keyPath: row.colorKeyPath].uiColor
            self.valueView.view.image = App.settings[keyPath: row.keypath].image
            self.valueView.view.tintColor = HomeDesign.white
            self.valueView.backgroundColor = self.color
        }
        
        @objc private func selectName(gesture: UITapGestureRecognizer) {
            let name = App.settings[keyPath: self.row.namePath]
            let newSelection: (String) -> () = { newName in
                App.settings[keyPath: self.row.namePath] = newName
            }
            
            DynamicAlert.init(.none,
                              contents: [.title(String(format: ~"RENAME_PEOPLE_LIST", name)), .textEditor(name)],
                              actions: [.normal(~"CANCEL", nil), .textEditor(newSelection)])
        }
        
        @objc private func selectIcon(gesture: UITapGestureRecognizer) {
            DynamicAlert(.none,
                         contents: [.icons(self.row.assets, self.row.assets.firstIndex(of: App.settings[keyPath: self.row.keypath]) ?? 0, HomeLayout.actionButtonSize)],
                         actions: [.normal(~"CANCEL", nil), .getIcon(~"SELECT", { _, asset in
                self.valueView.view.image = asset.image
                App.settings[keyPath: self.row.keypath] = asset
            })])
        }
        
        @objc private func selectColor(gesture: UITapGestureRecognizer) {
            let savedColor = self.color
            
            func reset() {
                self.color = savedColor
            }
            func apply() {
                App.settings[keyPath: self.row.colorKeyPath] = DecodableColor(color: self.color)
                self.valueView.backgroundColor = self.color
            }
            
            _ = withUnsafeMutablePointer(to: &self.color, { pointer in
                DynamicAlert(.none, contents: [.colorPicker(savedColor, pointer)], actions: [.normal(~"CANCEL", reset), .highligth(~"SELECT", apply)])
            })
        }
    }
}

// MARK: -
private extension SettingsViewController {
    
    final class ExtraView: BasicUIView {
        
        private let code: ExtraButton = .init(asset: .settingsCode, text: ~"SETTINGS_EXTRA_CODE")
        private let cafards: ExtraButton = .init(asset: .settingsCafard, text: ~"SETTINGS_EXTRA_CAFARDS")
        private let donations: ExtraButton = .init(asset: .settingsDonation, text: ~"SETTINGS_EXTRA_DONATIONS")
        private let credits: ExtraButton = .init(asset: .actionSee, text: ~"SETTINGS_EXTRA_CREDITS")
        
        final private class ExtraButton: HomePressableUIView {
            
            private let icon: BasicUIImageView
            private let label: BasicUILabel
            
            init(asset: UIImage.Assets, text: String) {
                self.icon = BasicUIImageView(image: asset.image)
                self.icon.tintColor = HomeDesign.white
                self.label = BasicUILabel(text: text)
                self.label.adjustsFontSizeToFitWidth = true
                self.label.font = HomeLayout.fontBoldMedium
                self.label.textColor = HomeDesign.white
                self.label.textAlignment = .center
                super.init()
                self.isUserInteractionEnabled = true
                self.backgroundColor = HomeDesign.black
                self.layer.cornerRadius = HomeLayout.corner
            }
            required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
            
            override func willMove(toSuperview newSuperview: UIView?) {
                guard newSuperview != nil else { return }
                
                self.addSubview(self.icon)
                self.icon.widthAnchor.constraint(equalToConstant: HomeLayout.actionButtonIconSize).isActive = true
                self.icon.heightAnchor.constraint(equalToConstant: HomeLayout.actionButtonIconSize).isActive = true
                self.icon.topAnchor.constraint(equalTo: self.topAnchor, constant: HomeLayout.smargin).isActive = true
                self.icon.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: HomeLayout.smargin).isActive = true
                self.icon.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -HomeLayout.smargin).isActive = true
                self.addSubview(self.label)
                self.label.leadingAnchor.constraint(equalTo: self.icon.trailingAnchor, constant: HomeLayout.smargin).isActive = true
                self.label.centerYAnchor.constraint(equalTo: self.icon.centerYAnchor).isActive = true
                self.label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.smargin).isActive = true
            }
        }
        
        override init() {
            super.init()
            self.code.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ExtraView.extraButtonTapped(sender:))))
            self.cafards.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ExtraView.extraButtonTapped(sender:))))
            self.donations.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ExtraView.extraButtonTapped(sender:))))
            self.credits.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ExtraView.extraButtonTapped(sender:))))
        }
        required init?(coder: NSCoder) { fatalError("The Fugees - Fu-Gee-La") }
        
        @objc private func extraButtonTapped(sender: UITapGestureRecognizer) {
            switch sender.view! {
            case self.code:
                let link = "https://github.com/horiz0n-zero/42-Home"
                
                func openWeb() {
                    self.parentViewController.present(SafariWebView(link.url), animated: true, completion: nil)
                }
                func openSafari() {
                    App.open(link.url, options: [:], completionHandler: nil)
                }
                func copy() {
                    UIPasteboard.general.string = link
                }
                
                DynamicActionsSheet(actions: [.normal(~"OPEN_WEB_LINK", .actionSee, openWeb),
                                              .normal(~"OPEN_WEB_LINK_SAFARI", .actionSee, openSafari),
                                              .normal(~"COPY", .actionSee, copy)], primary: HomeDesign.primary)
            case self.cafards:
                DynamicAlert(.primary(~"SETTINGS_EXTRA_CAFARDS"),
                             contents: [.imageWithPrimary(.settingsCafard, 50.0, HomeDesign.black),
                                        .title(~"CAFARDS_GENERATE_TITLE"),
                                        .separator(HomeDesign.black),
                                        .text(~"CAFARDS_HOW_TO")],
                             actions: [.normal(~"OK", nil)])
            case self.donations:
                (self.parentViewController as! SettingsViewController).presentWithBlur(DonationsViewController(), completion: nil)
            case self.credits:
                (self.parentViewController as! SettingsViewController).presentWithBlur(CreditsViewController(), completion: nil)
            default:
                break
            }
        }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }
            let separator = BasicUIView()
            
            separator.backgroundColor = HomeDesign.primary
            self.addSubview(separator)
            separator.heightAnchor.constraint(equalToConstant: HomeLayout.border).isActive = true
            separator.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            separator.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            separator.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            self.addSubview(self.code)
            self.code.topAnchor.constraint(equalTo: self.topAnchor, constant: HomeLayout.margin).isActive = true
            self.code.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: HomeLayout.margin).isActive = true
            self.addSubview(self.cafards)
            self.cafards.topAnchor.constraint(equalTo: self.code.topAnchor).isActive = true
            self.cafards.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.margin).isActive = true
            self.code.trailingAnchor.constraint(equalTo: self.cafards.leadingAnchor, constant: -HomeLayout.margin).isActive = true
            self.code.widthAnchor.constraint(equalTo: self.cafards.widthAnchor).isActive = true
            self.addSubview(self.donations)
            self.donations.topAnchor.constraint(equalTo: self.code.bottomAnchor, constant: HomeLayout.margin).isActive = true
            self.donations.leadingAnchor.constraint(equalTo: self.code.leadingAnchor).isActive = true
            self.addSubview(self.credits)
            self.credits.topAnchor.constraint(equalTo: self.donations.topAnchor).isActive = true
            self.credits.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.margin).isActive = true
            self.donations.widthAnchor.constraint(equalTo: self.credits.widthAnchor).isActive = true
            self.donations.trailingAnchor.constraint(equalTo: self.credits.leadingAnchor, constant: -HomeLayout.margin).isActive = true
            self.donations.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -(App.safeAera.bottom + HomeLayout.margin)).isActive = true
        }
    }
}
