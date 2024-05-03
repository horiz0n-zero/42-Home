// home42/Settings.swift
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

final class SettingsViewController: HomeViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let header: HeaderWithActionsView
    private let tableView: BasicUITableView
    private let sections: [SettingsViewController.Section]
    private let extraView: ExtraView
    
    required init() {
        self.header = HeaderWithActionsView(title: ~"title.settings")
        self.tableView = BasicUITableView()
        self.tableView.sectionHeaderHeight = UITableView.automaticDimension
        self.tableView.estimatedSectionHeaderHeight = HomeLayout.leftCurvedTitleViewHeigth
        self.tableView.register(SectionTableViewHeaderFooterViewWithIcon.self, forHeaderFooterViewReuseIdentifier: "header")
        self.tableView.register(RowBooleanTableViewCell.self, forCellReuseIdentifier: SettingsRowAvailable.boolean.rawValue)
        self.tableView.register(RowLanguageSelectorTableViewCell.self, forCellReuseIdentifier: SettingsRowAvailable.language.rawValue)
        self.tableView.register(RowSelectorEnumTableViewCell<UserSettings.GraphicsTransitionDuration>.self, forCellReuseIdentifier: SettingsRowEnumAvailable.GraphicsTransitionDuration.rawValue)
        self.tableView.register(RowSelectorEnumTableViewCell<UserSettings.ParallaxForce>.self, forCellReuseIdentifier: SettingsRowEnumAvailable.ParallaxForce.rawValue)
        self.tableView.register(RowSelectorEnumTableViewCell<UserSettings.ClustersPlaceClassName>.self, forCellReuseIdentifier: SettingsRowEnumAvailable.ClustersPlaceClassName.rawValue)
        self.tableView.register(RowSelectorEnumTableViewCell<UserSettings.ClusterSearchViewSort>.self, forCellReuseIdentifier: SettingsRowEnumAvailable.ClusterSearchViewSort.rawValue)
        self.tableView.register(RowSelectorEnumTableViewCell<UserSettings.PeopleListViewControllerSort>.self, forCellReuseIdentifier: SettingsRowEnumAvailable.PeopleListViewControllerSort.rawValue)
        self.tableView.register(RowSelectorEnumTableViewCell<UserSettings.ProfilImageQuality>.self, forCellReuseIdentifier: SettingsRowEnumAvailable.ProfilImageQuality.rawValue)
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
        let icon: UIImage.Assets
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
                else if G.self == UserSettings.ProfilImageQuality.self {
                    return SettingsRowEnumAvailable.ProfilImageQuality.rawValue
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
        
        struct RowLanguage: SettingsRowData {
            let reuseIdentifier: String = SettingsRowAvailable.language.rawValue
            let descriptionKey: String
            
            init(_ descriptionKey: String) {
                self.descriptionKey = descriptionKey
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
        struct RowCustomizeOptionalPeople: SettingsRowData {
            let reuseIdentifier: String = SettingsRowAvailable.customizePeople.rawValue
            let descriptionKey: String
            let keypath: ReferenceWritableKeyPath<UserSettings, UIImage.Assets?>
            let assets: [UIImage.Assets]
            let colorKeyPath: ReferenceWritableKeyPath<UserSettings, DecodableColor?>
            let namePath: ReferenceWritableKeyPath<UserSettings, String?>
            
            init(_ descriptionKey: String, keypath: ReferenceWritableKeyPath<UserSettings, UIImage.Assets?>, assets: [UIImage.Assets],
                 colorKeyPath: ReferenceWritableKeyPath<UserSettings, DecodableColor?>, namePath: ReferenceWritableKeyPath<UserSettings, String?>) {
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
        
        init(_ titleKey: String, _ icon: UIImage.Assets, _ controllerIsHidden: Bool = false, _ controllerHiddenType: HiddenViewController.Type! = nil, rows: [SettingsRowData]) {
            self.titleKey = titleKey
            self.icon = icon
            self.controllerIsHidden = controllerIsHidden
            self.controllerHiddenType = controllerHiddenType
            self.rows = rows
        }
    }
    static private let sections: [SettingsViewController.Section] = [
        .init("title.languages", .actionText, rows: [
            Section.RowLanguage.init("settings.desc.languages")
        ]),
        .init("title.people", .actionPeople, rows: [
            Section.RowCustomizeOptionalPeople.init("settings.desc.peoples.custom", keypath: \.peopleCustomIcon, assets: People.assets, colorKeyPath: \.peopleCustomColor, namePath: \.peopleCustomName),
            Section.RowCustomizePeople.init("settings.desc.peoples.e1.icon", keypath: \.peopleExtraList1Icon, assets: People.assets, colorKeyPath: \.peopleExtraList1Color, namePath: \.peopleExtraList1Name),
            Section.RowBoolean.init("settings.desc.peoples.e1.active", keypath: \.peopleExtraList1Available),
            Section.RowCustomizePeople.init("settings.desc.peoples.e2.icon", keypath: \.peopleExtraList2Icon, assets: People.assets, colorKeyPath: \.peopleExtraList2Color, namePath: \.peopleExtraList2Name),
            Section.RowBoolean.init("settings.desc.peoples.e2.active", keypath: \.peopleExtraList2Available)
        ]),
        .init("title.profil", .actionSee, rows: [
            Section.RowBoolean.init("settings.desc.show.events", keypath: \.profilShowEvents),
            Section.RowBoolean.init("settings.desc.show.corrections", keypath: \.profilShowCorrections),
            Section.RowIntegerCounter.init("settings.desc.corrections-count", keypath: \.profilCorrectionsCount, min: 1, max: 8, step: 1),
            Section.RowBoolean.init("settings.desc.show.logs", keypath: \.profilShowLogs),
            Section.RowBoolean.init("settings.desc.show.partnership", keypath: \.profilShowPartnerships)
        ]),
        .init("title.clusters", .controllerClusters, rows: [
            Section.RowSelectorEnum.init("settings.desc.cluster.places", keypath: \.clustersPlaceClassName),
            Section.RowSelectorEnum.init("settings.desc.clusters.sort", keypath: \.clusterSearchViewSort),
            Section.RowBoolean.init("settings.desc.counter-show", keypath: \.clusterShowCounters),
            Section.RowBoolean.init("settings.desc.counter-hide", keypath: \.clusterHidePlaceCounter),
            Section.RowBoolean.init("settings.desc.cluster.counter-prefer", keypath: \.clusterCounterPreferTakenPlaces)
        ]),
        .init("title.graphics", .actionBrush, rows: [
            Section.RowBoolean.init("settings.desc.graphics.blurprimary", keypath: \.graphicsBlurPrimary),
            Section.RowSelectorEnum.init("settings.desc.transition-duration", keypath: \.graphicsTransitionDuration),
            Section.RowBoolean.init("settings.desc.transition-blurprimary", keypath: \.graphicsBlurPrimaryTransition),
            Section.RowBoolean.init("settings.desc.blur-header", keypath: \.graphicsBlurHeader),
            Section.RowBoolean.init("settings.desc.parallax", keypath: \.graphicsUseParallax),
            Section.RowSelectorEnum.init("settings.desc.parallax-force", keypath: \.graphicsParallaxForce)
        ]),
        .init("title.tracker", .controllerTracker, true, TrackerViewController.self, rows: [
            Section.RowBoolean.init("settings.desc.cluster.show", keypath: \.trackerShowLocationHistoric),
            Section.RowSelectorEnum.init("settings.desc.peoples.sort", keypath: \.peopleListViewControllerSort),
            Section.RowBoolean.init("settings.desc.peoples.warn", keypath: \.peopleWarnWhenRemove),
            Section.RowBoolean.init("settings.desc.logs", keypath: \.trackerShowLocationOnLogCell)
        ]),
        .init("title.events", .controllerEvents, rows: [
            Section.RowBoolean.init("settings.desc.event.confirm", keypath: \.eventsWarnSubscription)
        ]),
        .init("title.elearning", .controllerElearning, rows: [
            Section.RowBoolean.init("settings.desc.elearning-use-hd", keypath: \.elearningHD)
        ]),
        /*.init("title.corrections", .controllerCorrections, true, CorrectionsViewController.self, rows: [
        ]),*/
        .init("title.graph", .controllerGraph, rows: [
            Section.RowBoolean.init("settings.desc.graph.mix-color", keypath: \.graphMixColor),
            Section.RowBoolean.init("settings.desc.graph.nightmode", keypath: \.graphPreferDarkTheme)
        ]),
        .init("title.caches", .actionTrash, rows: [
            Section.RowSelectorEnum.init("settings.desc.cache.profil-quality", keypath: \.cacheProfilQuality),
            Section.RowCacheActions.init("settings.desc.cache.profil", directory: .logins, actions: [
                .init(selector: #selector(RowCacheActionsTableViewCell.removeHandler(gesture:)),
                      asset: .actionTrash, color: HomeDesign.redError),
                .init(selector: #selector(RowCacheActionsTableViewCell.seeHandler(gesture:)),
                      asset: .actionSee, color: nil)
            ]),
            Section.RowCacheActions.init("settings.desc.cache.coalitions", directory: .coalitions, actions: [
                .init(selector: #selector(RowCacheActionsTableViewCell.removeHandler(gesture:)),
                      asset: .actionTrash, color: HomeDesign.redError),
                .init(selector: #selector(RowCacheActionsTableViewCell.seeHandler(gesture:)),
                      asset: .actionSee, color: nil)
            ]),
            Section.RowCacheActions.init("settings.desc.cache.coalitions", directory: .svgCoalitions, actions: [
                .init(selector: #selector(RowCacheActionsTableViewCell.removeHandler(gesture:)),
                      asset: .actionTrash, color: HomeDesign.redError),
                .init(selector: #selector(RowCacheActionsTableViewCell.seeHandler(gesture:)),
                      asset: .actionSee, color: nil)
            ]),
            Section.RowCacheActions.init("settings.desc.cache.achievement", directory: .svgAchievements, actions: [
                .init(selector: #selector(RowCacheActionsTableViewCell.removeHandler(gesture:)),
                      asset: .actionTrash, color: HomeDesign.redError),
                .init(selector: #selector(RowCacheActionsTableViewCell.seeHandler(gesture:)),
                      asset: .actionSee, color: nil)
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
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as! SectionTableViewHeaderFooterViewWithIcon
        let section = self.sections[section]
        
        view.update(with: ~section.titleKey, icon: section.icon.image, primaryColor: section.controllerIsHidden ? HomeDesign.gold : HomeDesign.primary)
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
        case let rowCustomizePeople as Section.RowCustomizePeople:
            (cell as! RowCustomizePeopleTableViewCell).update(with: rowCustomizePeople)
        case let rowCustomizeOptionalPeople as Section.RowCustomizeOptionalPeople:
            (cell as! RowCustomizePeopleTableViewCell).update(with: rowCustomizeOptionalPeople)
        case let rowActions as Section.RowActions:
            (cell as! RowActionsTableViewCell).update(with: rowActions, target: self)
        case let rowCacheActions as Section.RowCacheActions:
            (cell as! RowCacheActionsTableViewCell).update(with: rowCacheActions)
        case let rowLangue as Section.RowLanguage:
            (cell as! RowLanguageSelectorTableViewCell).update(with: rowLangue)
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
        case let profilImageQuality as Section.RowSelectorEnum<UserSettings.ProfilImageQuality>:
            (cell as! RowSelectorEnumTableViewCell<UserSettings.ProfilImageQuality>).update(with: profilImageQuality)
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
    case language
}
fileprivate enum SettingsRowEnumAvailable: String {
    case GraphicsTransitionDuration
    case ParallaxForce
    case ClustersPlaceClassName
    case ClusterSearchViewSort
    case PeopleListViewControllerSort
    case ProfilImageQuality
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
    
    static func defaultView() -> Self {
        return unsafeDowncast(SelectorView<E>(keys: [], values: []), to: Self.self)
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
    
    final private class RowLanguageSelectorTableViewCell: RowTableViewCell<RowLanguageSelectorTableViewCell.EnumView, String> {
        
        final class EnumView: RoundedGenericActionsView<BasicUILabel, ActionButtonView>, SettingsRowView {
            typealias Value = String
            
            init() {
                let selectButton = ActionButtonView(asset: .actionSelect, color: HomeDesign.primary)
                let language = App.userLanguage
                
                super.init(BasicUILabel(text: language.name), initialActions: [selectButton])
                self.view.adjustsFontSizeToFitWidth = true
                self.view.textColor = HomeDesign.black
                selectButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(EnumView.selectButtonTapped(sender:))))
            }
            required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
            
            @objc private func selectButtonTapped(sender: UITapGestureRecognizer) {
                let languages = HomeApiResources.languages.filter({ HomeWords.exist($0) }).sorted(by: { $0.name < $1.name })
                let index = languages.firstIndex(where: { $0.id == App.userLanguage.id }) ?? 0
                
                func selectLanguage(_ index: Int, _ language: IntraLanguage) {
                    HomeDefaults.save(language, forKey: .language)
                    HomeWords.configure(language)
                    self.parentHomeViewController?.dismissToRootController(animated: true) {
                        App.mainController.controllerReload()
                    }
                }
                
                DynamicAlert.init(contents: [.advancedSelector(.languages, languages, index)],
                                  actions: [.normal(~"general.cancel", nil), .getAdvancedSelector(unsafeBitCast(selectLanguage, to: ((Int, Any) -> Void).self))])
            }
            
            static func defaultView() -> Self {
                return Self.init()
            }
        }
        
        func update(with row: Section.RowLanguage) {
            self.descriptionLabel.text = ~row.descriptionKey
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
            DynamicAlert(contents: [.title(~"title.caches"), .text(~"cache.delete")], actions: [.normal(~"general.cancel", nil), .highligth(~"general.remove", {
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
                    DynamicAlert(.none, contents: [.title(~"title.caches"), .text(~"cache.deleted")], actions: [.normal(~"general.ok", nil)])
                })
            })])
        }
        
        @objc func seeHandler(gesture: UITapGestureRecognizer) {
            let seeCache: HomeViewController
            
            switch self.row.directory {
            case .logins:
                seeCache = SeeCacheViewController(storage: HomeResources.storageLoginImages,
                                                  style: .profil)
            case .coalitions:
                seeCache = SeeCacheViewController(storage: HomeResources.storageCoalitionsImages,
                                                  style: .landscapeCinema)
            case .svgAchievements:
                seeCache = SeeCacheViewController(storage: HomeResources.storageSVGAchievement,
                                                  style: .square(count: 4.0))
            case .svgCoalitions:
                seeCache = SeeCacheViewController(storage: HomeResources.storageSVGCoalition,
                                                  style: .square(count: 4.0))
            }
            self.parentHomeViewController?.presentWithBlur(seeCache, completion: nil)
        }
    }
    
    final private class RowCustomizePeopleTableViewCell: BasicUITableViewCell {
        
        private let titleView: PeopleCurvedView
        private let borderView: BasicUIView
        private let valueView: BasicUIStackView
        private let descriptionLabel: BasicUILabel

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            let actionText = ActionButtonView(asset: .actionText, color: HomeDesign.primary)
            let actionBrush = ActionButtonView(asset: .actionBrush, color: HomeDesign.primary)
            let actionSelect = ActionButtonView(asset: .actionSelect, color: HomeDesign.primary)
            
            self.titleView = .init(asset: .actionPeople, text: "???", primaryColor: HomeDesign.primary, addTopCorner: false)
            self.borderView = BasicUIView()
            self.borderView.layer.cornerRadius = HomeLayout.corner
            self.borderView.backgroundColor = HomeDesign.lightGray
            self.borderView.layer.masksToBounds = true
            self.valueView = .init()
            self.valueView.axis = .horizontal
            self.valueView.alignment = .fill
            self.valueView.spacing = HomeLayout.smargin
            self.valueView.distribution = .fillEqually
            self.valueView.addArrangedSubview(actionText)
            self.valueView.addArrangedSubview(actionBrush)
            self.valueView.addArrangedSubview(actionSelect)
            self.descriptionLabel = BasicUILabel(text: "???")
            self.descriptionLabel.font = HomeLayout.fontRegularMedium
            self.descriptionLabel.textColor = HomeDesign.black
            self.descriptionLabel.text = "???"
            self.descriptionLabel.numberOfLines = 0
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            for (index, selector) in [#selector(Self.selectName(gesture:)), #selector(Self.selectColor(gesture:)), #selector(Self.selectIcon(gesture:))].enumerated() {
                (self.valueView.arrangedSubviews as! [ActionButtonView])[index].isUserInteractionEnabled = true
                (self.valueView.arrangedSubviews as! [ActionButtonView])[index].addGestureRecognizer(UITapGestureRecognizer(target: self, action: selector))
            }
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }
            
            self.contentView.addSubview(self.borderView)
            self.borderView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: HomeLayout.margin).isActive = true
            self.borderView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: HomeLayout.margin).isActive = true
            self.borderView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -HomeLayout.margin).isActive = true
            self.borderView.addSubview(self.titleView)
            self.titleView.topAnchor.constraint(equalTo: self.borderView.topAnchor).isActive = true
            self.titleView.leadingAnchor.constraint(equalTo: self.borderView.leadingAnchor).isActive = true
            self.titleView.trailingAnchor.constraint(equalTo: self.borderView.trailingAnchor).isActive = true
            self.contentView.addSubview(self.valueView)
            self.valueView.centerYAnchor.constraint(equalTo: self.borderView.bottomAnchor).isActive = true
            self.valueView.trailingAnchor.constraint(equalTo: self.borderView.trailingAnchor, constant: -HomeLayout.margin).isActive = true
            self.valueView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -HomeLayout.smargin).isActive = true
            self.borderView.addSubview(self.descriptionLabel)
            self.descriptionLabel.topAnchor.constraint(equalTo: self.titleView.bottomAnchor, constant: HomeLayout.margin).isActive = true
            self.descriptionLabel.leadingAnchor.constraint(equalTo: self.borderView.leadingAnchor, constant: HomeLayout.margin).isActive = true
            self.descriptionLabel.trailingAnchor.constraint(equalTo: self.borderView.trailingAnchor, constant: -HomeLayout.margin).isActive = true
            self.descriptionLabel.bottomAnchor.constraint(equalTo: self.valueView.topAnchor, constant: -HomeLayout.smargin).isActive = true
        }
        
        private var row: Section.RowCustomizePeople!
        private var rowOptional: Section.RowCustomizeOptionalPeople!
        private var color: UIColor = HomeDesign.primary
        
        func update(with row: Section.RowCustomizePeople) {
            self.row = row
            self.rowOptional = nil
            self.color = App.settings[keyPath: row.colorKeyPath].uiColor
            self.titleView.update(with: App.settings[keyPath: row.keypath], text: App.settings[keyPath: row.namePath], primaryColor: self.color)
            self.descriptionLabel.text = ~row.descriptionKey
        }
        func update(with row: Section.RowCustomizeOptionalPeople) {
            self.row = nil
            self.rowOptional = row
            self.descriptionLabel.text = ~row.descriptionKey
            self.color = App.settings[keyPath: row.colorKeyPath]?.uiColor ?? People.ListType.friends.color
            self.titleView.update(with: App.settings[keyPath: row.keypath] ?? People.ListType.friends.asset, text: App.settings[keyPath: row.namePath] ?? People.ListType.friends.title, primaryColor: self.color)
            self.descriptionLabel.text = ~row.descriptionKey
        }
        
        private func updateTitle() {
            if let row = self.row {
                self.update(with: row)
            }
            else {
                self.update(with: self.rowOptional)
            }
        }
        
        @objc private func selectName(gesture: UITapGestureRecognizer) {
            let name: String
            let newSelection: (String) -> ()
            
            if let row = self.row {
                name = App.settings[keyPath: self.row.namePath]
                newSelection = { newName in
                    App.settings[keyPath: self.row.namePath] = newName
                    self.updateTitle()
                }
            }
            else {
                name = App.settings[keyPath: self.rowOptional.namePath] ?? People.ListType.friends.title
                newSelection = { newName in
                    App.settings[keyPath: self.rowOptional.namePath] = newName
                    self.updateTitle()
                }
            }
            DynamicAlert.init(.none, contents: [.title(String(format: ~"peoples.rename", name)), .textEditor(name)], actions: [.normal(~"general.cancel", nil), .textEditor(newSelection)])
        }
        
        @objc private func selectIcon(gesture: UITapGestureRecognizer) {
            let asset: UIImage.Assets
            let assets: [UIImage.Assets]
            let block: (Int, UIImage.Assets) -> ()
            
            if let row = self.row {
                asset = App.settings[keyPath: row.keypath]
                assets = row.assets
                block = { _, asset in
                    App.settings[keyPath: self.row.keypath] = asset
                    self.updateTitle()
                }
            }
            else {
                asset = App.settings[keyPath: self.rowOptional.keypath] ?? People.ListType.friends.asset
                assets = self.rowOptional.assets
                block = { _, asset in
                    App.settings[keyPath: self.rowOptional.keypath] = asset
                    self.updateTitle()
                }
            }
            DynamicAlert(.none, contents: [.icons(assets, assets.firstIndex(of: asset) ?? 0, HomeLayout.actionButtonSize)], actions: [.normal(~"general.cancel", nil), .getIcon(~"general.select", block)])
        }
        
        @objc private func selectColor(gesture: UITapGestureRecognizer) {
            let savedColor = self.color
            
            func reset() {
                self.color = savedColor
            }
            
            func apply() {
                if let row = self.row {
                    App.settings[keyPath: row.colorKeyPath] = DecodableColor(color: self.color)
                }
                else {
                    App.settings[keyPath: self.rowOptional.colorKeyPath] = DecodableColor(color: self.color)
                }
                self.updateTitle()
            }
            
            _ = withUnsafeMutablePointer(to: &self.color, { pointer in
                DynamicAlert(.none, contents: [.colorPicker(savedColor, pointer)], actions: [.normal(~"general.cancel", reset), .highligth(~"general.select", apply)])
            })
        }
    }
}

// MARK: -
private extension SettingsViewController {
    
    final private class ExtraView: BasicUIView {
        
        private let code: ExtraButton = .init(asset: .settingsCode, text: ~"settings.extra.code")
        private let cafards: ExtraButton = .init(asset: .settingsCafard, text: ~"settings.extra.cafards")
        private let guides: ExtraButton = .init(asset: .settingsGuides, text: ~"settings.extra.guides")
        private let credits: ExtraButton = .init(asset: .settingsMore, text: ~"settings.extra.credits")
        
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
            self.guides.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ExtraView.extraButtonTapped(sender:))))
            self.credits.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ExtraView.extraButtonTapped(sender:))))
        }
        required init?(coder: NSCoder) { fatalError("The Fugees - Fu-Gee-La") }
        
        @objc private func extraButtonTapped(sender: UITapGestureRecognizer) {
            switch sender.view! {
            case self.code:
                if App.user.id == 20091 {
                    HiddenViewController.presentActionSheetForQRCodes("https://github.com/horiz0n-zero/42-Home", parentViewController: self.parentViewController!)
                }
                else {
                    var actions: [DynamicActionsSheet.Action] = [.title(~"github.title"), .text(~"github.text")]
                    
                    func openTestflight() {
                        App.open("https://testflight.apple.com/join/MHJO6atU".url, options: [:], completionHandler: nil)
                    }
                    
                    actions += DynamicActionsSheet.actionsForWebLink("https://github.com/horiz0n-zero/42-Home", parentViewController: self.parentViewController!)
                    actions += [.separatorWithPrimary(HomeDesign.black),
                               .title(~"testflight.title"), .text(~"testflight.desc"),
                               .normal(~"general.open", .settingsTestflight, openTestflight)]
                    DynamicActionsSheet(actions: actions, primary: HomeDesign.primary)
                }
            case self.cafards:
                DynamicAlert(.primary(~"settings.extra.cafards"),
                             contents: [.imageWithPrimary(.settingsCafard, 50.0, HomeDesign.black),
                                        .title(~"cafards.generate-title"),
                                        .separator(HomeDesign.black),
                                        .text(~"cafards.how-to")],
                             actions: [.normal(~"general.ok", nil)])
            case self.guides:
                (self.parentViewController as! SettingsViewController).presentWithBlur(GuidesViewController(), completion: nil)
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
            self.addSubview(self.guides)
            self.guides.topAnchor.constraint(equalTo: self.code.bottomAnchor, constant: HomeLayout.margin).isActive = true
            self.guides.leadingAnchor.constraint(equalTo: self.code.leadingAnchor).isActive = true
            self.addSubview(self.credits)
            self.credits.topAnchor.constraint(equalTo: self.guides.topAnchor).isActive = true
            self.credits.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.margin).isActive = true
            self.guides.widthAnchor.constraint(equalTo: self.credits.widthAnchor).isActive = true
            self.guides.trailingAnchor.constraint(equalTo: self.credits.leadingAnchor, constant: -HomeLayout.margin).isActive = true
            self.guides.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -(HomeLayout.safeAera.bottom + HomeLayout.margin)).isActive = true
        }
    }
}
