// home42/Clusters.swift
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
import SwiftDate

protocol ClustersBaseViewController: HomeViewController {
    
    func focusOnClusterView(with host: String, animated: Bool) -> Bool
    func peopleConnected(_ people: People) -> IntraClusterLocation?
    func peoplesUpdated(_ peoples: Dictionary<String, People>)
}

final class ClustersViewController: HomeViewController, ClustersBaseViewController {
    
    private var clusterView: ClustersView?
    
    required init() {
        do {
            let description = try ClustersView.readDescription(forCampus: App.userCampus)
            
            self.clusterView = ClustersView(description, campus: App.userCampus, primary: HomeDesign.primary, true)
        }
        catch {
            #if DEBUG
                print(error)
            #endif
            self.clusterView = nil
        }
        super.init()
        if let clusterView = self.clusterView {
            self.view.addSubview(clusterView)
            clusterView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            clusterView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
            clusterView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
            clusterView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        }
        else {
            DynamicAlert(contents: [.title(~"clusters.unavailable"), .text("id: \(App.userCampus.campus_id)")],
                         actions: [.normal(~"general.ok", nil), HomeGuides.alertActionLink(self)])
        }
    }
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.clusterView?.viewWillDisappear()
    }
    @discardableResult func focusOnClusterView(with host: String, animated: Bool) -> Bool {
        return self.clusterView?.focusOnClusterView(with: host, animated: animated) ?? false
    }
    func peopleConnected(_ people: People) -> IntraClusterLocation? {
        return self.clusterView?.peopleConnected(people)
    }
    func peoplesUpdated(_ peoples: Dictionary<String, People>) {
        self.clusterView?.peoplesUpdated(peoples)
    }
}
final class ClustersSharedViewController: HomeViewController, ClustersBaseViewController {
    
    private let coalitionBackground: BasicUIImageView
    private let header: ControllerHeaderWithActionsView
    private let clusterView: ClustersView
    
    convenience init(campus: IntraUserCampus, coalition: IntraCoalition?) throws {
        let description = try ClustersView.readDescription(forCampus: campus)
        
        try self.init(description: description, campus: campus, coa: coalition)
    }
    convenience init(debugFile: String, campus: IntraUserCampus) throws {
        let description = try ClustersView.readDescription(debugFile: debugFile)
        
        try self.init(description: description, campus: campus, coa: App.userCoalition)
    }
    private init(description: ClustersView.ClusterDescription, campus: IntraUserCampus, coa: IntraCoalition?) throws {
        let primary: UIColor
        var needUpdateCoalitionBackground: Bool = false
        
        if let coalition = coa {
            if let background = HomeResources.storageCoalitionsImages.get(coalition) {
                self.coalitionBackground = BasicUIImageView(image: background)
            }
            else {
                self.coalitionBackground = BasicUIImageView(image: UIImage.Assets.coalitionDefaultBackground.image)
                needUpdateCoalitionBackground = true
            }
            primary = coalition.uicolor
        }
        else {
            primary = HomeDesign.primaryDefault
            self.coalitionBackground = BasicUIImageView(asset: .coalitionDefaultBackground)
        }
        self.header = ControllerHeaderWithActionsView(asset: .controllerClusters, title: ~"title.clusters", primary: primary)
        self.clusterView = ClustersView(description, campus: campus, primary: primary, false)
        super.init()
        if needUpdateCoalitionBackground {
            Task.init(priority: .userInitiated, operation: {
                if let (c, background) = await HomeResources.storageCoalitionsImages.obtain(coa!), c.id == coa!.id {
                    self.coalitionBackground.image = background
                }
            })
        }
        self.view.addSubview(self.coalitionBackground)
        self.coalitionBackground.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.coalitionBackground.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.coalitionBackground.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.coalitionBackground.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.view.addSubview(self.clusterView)
        self.clusterView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.clusterView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.clusterView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.clusterView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.view.addSubview(self.header)
        self.header.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.header.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.header.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
    }
    @available(*, unavailable) required init() { fatalError() }
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.clusterView.viewWillDisappear()
    }
    @discardableResult func focusOnClusterView(with host: String, animated: Bool) -> Bool {
        return self.clusterView.focusOnClusterView(with: host, animated: animated)
    }
    func peopleConnected(_ people: People) -> IntraClusterLocation? {
        return self.clusterView.peopleConnected(people)
    }
    func peoplesUpdated(_ peoples: Dictionary<String, People>) {
        self.clusterView.peoplesUpdated(peoples)
    }
}

final fileprivate class ClustersView: BasicUIView {
    
    private let clusterDescription: ClustersView.ClusterDescription
    private let campus: IntraUserCampus
    private let isMainController: Bool
    private let primary: UIColor
    
    private let floorSegment: ClusterSelectorView
    private let refreshButton: ActionButtonView
    private let scrollView: BasicUIScrollView
    private let searchField: SearchFieldView
    private let friendsButton: ActionButtonView
    private let extra1Button: ActionButtonView?
    private let extra2Button: ActionButtonView?
    
    private var clusterViews: Dictionary<CGPoint, ClusterView> = [:]
    private var clusterPillarViews: Dictionary<CGPoint, ClusterPillarView> = [:]
    
    private var viewsForHost: Array<Dictionary<String, ClusterView>> = []
    private var locations: Dictionary<String, IntraClusterLocation>!
    private var peoples: Dictionary<String, People> = [:]
    
    private var historicView: HistoricView? = nil
    private var searchView: SearchResultView? = nil
    
    init(_ clusterDescription: ClustersView.ClusterDescription, campus: IntraUserCampus, primary: UIColor, _ isMainController: Bool) {
        var leadingAction: NSLayoutXAxisAnchor
        let aeraTop: CGFloat
        let extraValues: [ClusterSelectorViewExtraValues]?
        let selectedIndex: Int
        let values = clusterDescription.floors.map({ $0.name })
        
        if isMainController {
            aeraTop = HomeLayout.safeAeraMain.top
        }
        else {
            aeraTop = HomeLayout.headerWithActionViewHeigth + HomeLayout.safeAera.top + HomeLayout.smargin
        }
        if campus.isUserMainCampus {
            extraValues = HomeDefaults.read(.clustersExtraValues)
            selectedIndex = HomeDefaults.read(.liveClusterFloor) ?? 0
        }
        else {
            extraValues = nil
            selectedIndex = 0
        }
        self.clusterDescription = clusterDescription
        self.primary = primary
        self.campus = campus
        self.isMainController = isMainController
        self.refreshButton = ActionButtonView(asset: .actionRefresh, color: primary)
        self.searchField = SearchFieldView(placeholder: ~"general.search")
        self.searchField.setPrimary(primary)
        if (clusterDescription.overrideSegmentUseScrollableSegment ?? false) {
            self.floorSegment = ClusterScrollableSegmentView(values: values, extraValues: extraValues, selectedIndex: selectedIndex, primary: primary)
        }
        else {
            self.floorSegment = ClusterSegmentView(values: values, extraValues: extraValues, selectedIndex: selectedIndex, primary: primary)
        }
        self.friendsButton = ActionButtonView(asset: .actionFriends, color: HomeDesign.actionGreen)
        self.friendsButton.isUserInteractionEnabled = true
        self.friendsButton.tag = People.ListType.friends.rawValue
        if let extra1 = App.settings.peopleExtraList1 {
            self.extra1Button = ActionButtonView(asset: extra1.icon, color: extra1.color)
            self.extra1Button!.tag = People.ListType.extraList1.rawValue
        }
        else {
            self.extra1Button = nil
        }
        if let extra2 = App.settings.peopleExtraList2 {
            self.extra2Button = ActionButtonView(asset: extra2.icon, color: extra2.color)
            self.extra2Button!.tag = People.ListType.extraList2.rawValue
        }
        else {
            self.extra2Button = nil
        }
        self.scrollView = BasicUIScrollView()
        super.init()
        self.addSubview(self.scrollView)
        self.addSubview(self.floorSegment)
        self.addSubview(self.searchField)
        self.addSubview(self.refreshButton)
        
        self.scrollView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        self.floorSegment.clusterSelectorDelegate = self
        self.floorSegment.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: HomeLayout.margin).isActive = true
        
        if App.settings.clusterShowCounters && !(clusterDescription.overrideSegmentUseScrollableSegment ?? false) {
            self.floorSegment.topAnchor.constraint(equalTo: self.topAnchor, constant: aeraTop + HomeLayout.margind).isActive = true
        }
        else {
            self.floorSegment.topAnchor.constraint(equalTo: self.topAnchor, constant: aeraTop + HomeLayout.margin).isActive = true
        }
        self.floorSegment.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -HomeLayout.margin).isActive = true
        
        leadingAction = self.floorSegment.leadingAnchor
        for (index, button) in [self.extra2Button,self.extra1Button,self.friendsButton].compactMap({$0}).enumerated() {
            self.addSubview(button)
            if index == 0 {
                button.leadingAnchor.constraint(equalTo: leadingAction).isActive = true
            }
            else {
                button.leadingAnchor.constraint(equalTo: leadingAction, constant: HomeLayout.dmargin).isActive = true
            }
            button.centerYAnchor.constraint(equalTo: self.searchField.centerYAnchor).isActive = true
            button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ClustersView.peopleButtonTapped(sender:))))
            leadingAction = button.trailingAnchor
        }
        self.searchField.delegate = self
        self.searchField.view.adjustsFontSizeToFitWidth = true
        self.searchField.topAnchor.constraint(equalTo: self.floorSegment.bottomAnchor, constant: HomeLayout.smargin).isActive = true
        self.searchField.leadingAnchor.constraint(equalTo: leadingAction, constant: HomeLayout.smargin).isActive = true
        self.refreshButton.trailingAnchor.constraint(equalTo: self.floorSegment.trailingAnchor).isActive = true
        self.refreshButton.centerYAnchor.constraint(equalTo: self.searchField.centerYAnchor).isActive = true
        self.refreshButton.leadingAnchor.constraint(equalTo: self.searchField.trailingAnchor, constant: HomeLayout.smargin).isActive = true
        self.refreshButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ClustersView.refreshLocations)))
        
        self.peoples = HomeDefaults.read(.peoples) ?? [:]
        self.peoples[App.user.login] = People.me
        if campus.isUserMainCampus {
            self.locations = HomeDefaults.read(.liveClusterLocations) ?? [:]
        }
        else {
            self.locations = [:]
        }
        self.locations.reserveCapacity(self.clusterDescription.elementsCount)
        self.generateClusterViews()
        self.configureClusterScrollView(aeraTop: aeraTop)
        self.refreshLocations()
        self.keyboardInterfaceSetup()
    }
    required init?(coder: NSCoder) { fatalError() }
    
    func viewWillDisappear() {
        if self.searchField.view.isFirstResponder {
            self.searchField.view.resignFirstResponder()
        }
        self.removeHistoricView()
    }
    
    final class ClusterDescription: IntraObject {
        
        let width: CGFloat
        let height: CGFloat
        let placeWidth: CGFloat
        let placeHeight: CGFloat
        let elementsCount: Int
        
        let overrideSegmentUseScrollableSegment: Bool?
        let overridePlaceRadius: CGFloat?
        
        struct Floor: Codable {
            
            let name: String
            let prefix: String
            let elementsCount: Int
            
            struct Place: Codable {
                let host: String
                let display: String
                let position: CGPoint
            }
            let places: [Place]
            let pillars: [CGPoint]
            let paths: [String]?
            let pathsTranslationX: CGFloat?
            let pathsTranslationY: CGFloat?
            
            lazy var cgPaths: [CGPath]? = {
                if let paths = self.paths {
                    return paths.map({
                        let path = try! CGPath.from(svgPath: $0)
                        var transform = CGAffineTransform(translationX: self.pathsTranslationX ?? 0.0, y: self.pathsTranslationY ?? 0.0).scaledBy(x: 1.0, y: -1.0)
                        
                        return path.copy(using: &transform)!
                    })
                }
                return nil
            }()
        }
        var floors: [Floor]
        
        struct Transition: Codable {
            
            let from: Int
            let to: Int
            
            struct Update: Codable {
                let position: CGPoint
                let display: String
            }
            let remove: [CGPoint]
            let add: [Floor.Place]
            let update: [Transition.Update]
            let pillarRemove: [CGPoint]
            let pillarAdd: [CGPoint]
        }
        let transitions: [Transition]
    }
    
    static func readDescription(debugFile file: String) throws -> ClusterDescription {
        let url = URL(string: file)!
        let data: Data
        
        _ = url.startAccessingSecurityScopedResource()
        data = try Data(contentsOf: url)
        url.stopAccessingSecurityScopedResource()
        return try JSONDecoder.decoder.decode(ClusterDescription.self, from: data)
    }
    
    static func readDescription(forCampus campus: IntraUserCampus) throws -> ClusterDescription {
        let file = "res/clusters/\(campus.campus_id).json"
        let data = try Data(contentsOf: HomeResources.applicationDirectory.appendingPathComponent(file))
        
        return try JSONDecoder.decoder.decode(ClusterDescription.self, from: data)
    }
    
    final private class ClusterContainer: BasicUIView {
        
        private unowned(unsafe) let clusterView: ClustersView
        
        init(_ clusterView: ClustersView, width: CGFloat, height: CGFloat) {
            self.clusterView = clusterView
            super.init()
            self.frame = .init(x: 0.0, y: 0.0, width: width, height: height)
            self.backgroundColor = .clear
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override func draw(_ rect: CGRect) {
            if let paths = self.clusterView.clusterDescription.floors[self.clusterView.floorSegment.selectedIndex].cgPaths, let ctx = UIGraphicsGetCurrentContext() {
                HomeDesign.lightGray.setFill()
                HomeDesign.lightGray.setStroke()
                for path in paths {
                    ctx.beginPath()
                    ctx.addPath(path)
                    ctx.closePath()
                    ctx.fillPath()
                }
            }
            super.draw(rect)
        }
    }
    
    private func generateClusterViews() {
        let container = ClusterContainer(self, width: self.clusterDescription.width, height: self.clusterDescription.height)
        var clusterView: ClusterView
        let clusterViewSize: CGSize = .init(width: self.clusterDescription.placeWidth, height: self.clusterDescription.placeHeight)
        var clusterPillarView: ClusterPillarView // unowned(unsafe) var where it's needed
        let type = App.settings.clustersPlaceClassType
        let pillarType = App.settings.clustersPillarClassType
        let colors: [CGColor] = People.ListType.allCases.map(\.color.cgColor)
        
        self.clusterViews.reserveCapacity(self.clusterDescription.floors[self.floorSegment.selectedIndex].elementsCount)
        self.scrollView.addSubview(container)
        container.topAnchor.constraint(equalTo: self.scrollView.topAnchor).isActive = true
        container.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor).isActive = true
        container.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor).isActive = true
        container.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor).isActive = true
        container.widthAnchor.constraint(equalToConstant: self.clusterDescription.width).isActive = true
        container.heightAnchor.constraint(equalToConstant: self.clusterDescription.height).isActive = true
        container.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ClustersView.scrollViewContentTapped)))
        
        for place in self.clusterDescription.floors[self.floorSegment.selectedIndex].places {
            clusterView = type.init(frame: .init(origin: place.position, size: clusterViewSize), display: place.display)
            if let location = self.locations[place.host] {
                if let people = self.peoples[location.user.login] {
                    clusterView.configure(location: location, color: colors[people.list.rawValue])
                }
                else {
                    clusterView.configure(location: location, color: nil)
                }
            }
            else {
                clusterView.configure(location: nil, color: nil)
            }
            container.addSubview(clusterView)
            self.clusterViews[place.position] = clusterView
        }
        for pillarPosition in self.clusterDescription.floors[self.floorSegment.selectedIndex].pillars {
            clusterPillarView = pillarType.init(frame: .init(origin: pillarPosition, size: clusterViewSize))
            container.addSubview(clusterPillarView)
            self.clusterPillarViews[pillarPosition] = clusterPillarView
        }
        
        Task.init(priority: .userInitiated, operation: {
            var clusterView: ClusterView
            
            for (index, floor) in self.clusterDescription.floors.enumerated() {
                self.viewsForHost.append(Dictionary<String, ClusterView>.init(minimumCapacity: floor.places.count))
                for place in floor.places {
                    if let view = self.clusterViews[place.position] {
                        self.viewsForHost[index][place.host] = view
                    }
                    else {
                        clusterView = type.init(frame: .init(origin: place.position, size: clusterViewSize),
                                                display: place.display)
                        self.clusterViews[place.position] = clusterView
                        self.viewsForHost[index][place.host] = clusterView
                    }
                }
            }
            if let radius = self.clusterDescription.overridePlaceRadius {
                for views in self.viewsForHost {
                    for (_, clusterView) in views {
                        clusterView.layer.cornerRadius = radius
                        clusterView.layer.masksToBounds = true
                    }
                }
            }
        })
    }
    
    private func configureClusterScrollView(aeraTop: CGFloat) {
        let offsetY = aeraTop + HomeLayout.roundedGenericActionsViewHeigth + HomeLayout.clusterSegmentHeigth + HomeLayout.margin * 4.0
        let width = UIScreen.main.bounds.width - (HomeLayout.safeAera.left + HomeLayout.safeAera.right)
        let height = UIScreen.main.bounds.height - (offsetY + HomeLayout.safeAera.bottom)
        let widthRatio = min(width, self.clusterDescription.width) / max(width, self.clusterDescription.width)
        let heightRatio = min(height, self.clusterDescription.height) / max(height, self.clusterDescription.height)
        let minZoom = max(widthRatio, heightRatio)
        
        self.scrollView.minimumZoomScale = minZoom
        self.scrollView.maximumZoomScale = minZoom * 15.0
        self.scrollView.zoomScale = 1.0
        self.scrollView.isScrollEnabled = true
        self.scrollView.delegate = self
        self.scrollView.contentInset = .init(top: offsetY, left: 0.0, bottom: 0.0, right: 0.0)
        self.scrollView.zoom(to: .init(origin: .zero, size: .init(width: width, height: height)), animated: false)
    }
    
    @objc private func refreshLocations() {
        guard self.refreshButton.isUserInteractionEnabled == true else {
            return
        }
        
        @MainActor func refreshEnded(floorSegmentValues values: [ClusterSelectorViewExtraValues]) {
            self.floorSegment.extraValues = values
            self.refreshButton.isUserInteractionEnabled = true
            self.refreshButton.stopRotate()
            if self.campus.isUserMainCampus {
                HomeDefaults.save(values, forKey: .clustersExtraValues)
            }
        }
        
        self.refreshButton.isUserInteractionEnabled = false
        self.refreshButton.startRotate()
        Task(priority: .high, operation: {
            let route: HomeApi.Routes = .campusWithCampusIdLocations(self.campus.campus_id)
            let sequence: HomeApi.RequestSequence<IntraClusterLocation> = .init(route: route, parameters: ["filter[active]": true])
            let oldLocationsSet = Set<IntraClusterLocation>.init(self.locations.values)
            let newLocationsSet: Set<IntraClusterLocation>
            var diffLocationsSet: Set<IntraClusterLocation>
            
            var valuesPlaceCount: Array<Int> = Array(repeating: 0, count: self.clusterDescription.floors.count)
            var valuesPeoplesCount: Array<Array<Int>> = Array(repeating: Array(repeating: 0, count: People.ListType.allCases.count), count: self.clusterDescription.floors.count)
            var values: [ClusterSelectorViewExtraValues] = []
            
            values.reserveCapacity(self.clusterDescription.floors.count)
            do {
                
                self.locations.removeAll()
                for try await newLocations in sequence {
                    self.incorporateLocations(newLocations)
                }
                
                newLocationsSet = Set<IntraClusterLocation>.init(self.locations.values)
                diffLocationsSet = oldLocationsSet.symmetricDifference(newLocationsSet)
                for location in newLocationsSet {
                    diffLocationsSet.remove(location)
                }
                for location in diffLocationsSet {
                    if let view = self.viewsForHost[self.floorSegment.selectedIndex][location.host] {
                        view.transition(location: nil, color: nil)
                    }
                }
                
                if let searchView = self.searchView {
                    searchView.updateSource()
                }
                for location in self.locations {
                    for index in 0 ..< self.clusterDescription.floors.count where location.key.hasPrefix(self.clusterDescription.floors[index].prefix) {
                        valuesPlaceCount[index] += 1
                        break
                    }
                    if let people = self.peoples[location.value.user.login] {
                        for index in 0 ..< self.clusterDescription.floors.count where location.key.hasPrefix(self.clusterDescription.floors[index].prefix) {
                            valuesPeoplesCount[index][people.list.rawValue] &+= 1
                            break
                        }
                    }
                }
                for index in 0 ..< self.clusterDescription.floors.count {
                    values.append(.init(placeAvailable: self.clusterDescription.floors[index].elementsCount,
                                        placeCount: self.clusterDescription.floors[index].elementsCount - valuesPlaceCount[index],
                                        friends: valuesPeoplesCount[index][People.ListType.friends.rawValue],
                                        extra1: valuesPeoplesCount[index][People.ListType.extraList1.rawValue],
                                        extra2: valuesPeoplesCount[index][People.ListType.extraList2.rawValue]))
                }
                if self.campus.isUserMainCampus {
                    HomeDefaults.save(self.locations, forKey: .liveClusterLocations)
                }
            }
            catch {
                DynamicAlert.presentWith(error: error as! HomeApi.RequestError)
            }
            refreshEnded(floorSegmentValues: values)
        })
    }
    
    @MainActor private func incorporateLocations(_ newLocations: ContiguousArray<IntraClusterLocation>) {
        for location in newLocations {
            if let view = self.viewsForHost[self.floorSegment.selectedIndex][location.host] {
                view.transition(location: location, color: self.peoples[location.user.login]?.list.color.cgColor)
            }
            self.locations[location.host] = location
        }
    }
    
    private func transitionToSelectedFloor() {
        
        let container = self.scrollView.subviews.first!
        let clusterViewSize: CGSize = .init(width: self.clusterDescription.placeWidth,
                                            height: self.clusterDescription.placeHeight)
        var clusterPillarView: ClusterPillarView
        let pillarType = App.settings.clustersPillarClassType
        let transition = self.clusterDescription.transitions.first(where: { $0.from == self.floorSegment.oldSelectedIndex && $0.to == self.floorSegment.selectedIndex })!
        let colors: [CGColor] = People.ListType.allCases.map(\.color.cgColor)
        var view: ClusterView
        
        for position in transition.remove {
            self.clusterViews.removeValue(forKey: position)?.removeFromSuperview()
        }
        for place in transition.add {
            view = self.viewsForHost[self.floorSegment.selectedIndex][place.host]!
            container.addSubview(view)
            self.clusterViews[place.position] = view
        }
        for update in transition.update {
            self.clusterViews[update.position]!.display = update.display
        }
        for (host, clusterView) in self.viewsForHost[self.floorSegment.selectedIndex] {
            if let location = self.locations[host] {
                if let people = self.peoples[location.user.login] {
                    clusterView.transition(location: location, color: colors[people.list.rawValue])
                }
                else {
                    clusterView.transition(location: location, color: nil)
                }
            }
            else {
                clusterView.transition(location: nil, color: nil)
            }
        }
        
        for pillarPosition in transition.pillarRemove {
            self.clusterPillarViews.removeValue(forKey: pillarPosition)?.removeFromSuperview()
        }
        for pillarPosition in transition.pillarAdd {
            clusterPillarView = pillarType.init(frame: .init(origin: pillarPosition, size: clusterViewSize))
            self.clusterPillarViews[pillarPosition] = clusterPillarView
            container.addSubview(clusterPillarView)
        }
        if self.clusterDescription.floors[self.floorSegment.oldSelectedIndex].paths != nil || self.clusterDescription.floors[self.floorSegment.selectedIndex].paths != nil {
            for view in self.scrollView.subviews where view is ClusterContainer {
                view.setNeedsDisplay()
                break
            }
        }
    }
}

extension ClustersView: UIScrollViewDelegate, ClusterSelectorViewDelegate {
    
    func clusterSegmentViewSelect(_ segmentView: ClusterSelectorView) {
        self.transitionToSelectedFloor()
        if self.campus.isUserMainCampus {
            HomeDefaults.save(segmentView.selectedIndex, forKey: .liveClusterFloor)
        }
    }
    func clusterSegmentViewPeopleCounterSelect(_ segmentView: ClusterSelectorView, listType: People.ListType) { }
    func clusterSegmentViewPlacesCounterSelect(_ segmentView: ClusterSelectorView) { }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.scrollView.subviews.first
    }
    @objc private func scrollViewContentTapped(gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: gesture.view)
        
        func tryInteractionForHost(_ host: String, title: String, user: IntraUserInfo?) {
            guard self.searchView == nil else {
                return
            }
            
            func showHistoricView() {
                if let historicView = self.historicView {
                    historicView.update(host: host, title: title, user: user)
                }
                else {
                    self.addHistoricView(host, title: title, user: user, campus: self.campus)
                }
            }
            
            if App.settings.trackerShowLocationHistoric && TrackerViewController.checkDefaultsValue() {
                showHistoricView()
            }
            else if let user = user {
                let profil = ProfilViewController()
                
                Task.init(priority: .userInitiated, operation: {
                    await profil.setupWithUser(user.login, id: user.id)
                })
                self.parentHomeViewController?.presentWithBlur(profil)
            }
        }
        
        if let view = self.clusterViews.values.first(where: { $0.point(inside: $0.convert(location, from: gesture.view!), with: nil) }) {
            let title = self.clusterDescription.floors[self.floorSegment.selectedIndex].prefix + view.display
            
            if let place = self.clusterDescription.floors[self.floorSegment.selectedIndex].places.first(where: { $0.display == view.display }) {
                tryInteractionForHost(place.host, title: title, user: view.location?.user)
            }
            else {
                tryInteractionForHost(title, title: title, user: view.location?.user)
            }
        }
    }
    
    func peoplesUpdated(_ peoples: Dictionary<String, People>) {
        let colors: [CGColor] = People.ListType.allCases.map(\.color.cgColor)
        var valuesPlaceCount: Array<Int> = Array(repeating: 0, count: self.clusterDescription.floors.count)
        var valuesPeoplesCount: Array<Array<Int>> = Array(repeating: Array(repeating: 0, count: People.ListType.allCases.count), count: self.clusterDescription.floors.count)
        var values: [ClusterSelectorViewExtraValues] = []
        
        self.peoples = peoples
        self.peoples[App.user.login] = People.me
        for (host, clusterView) in self.viewsForHost[self.floorSegment.selectedIndex] {
            if let location = self.locations[host] {
                if let people = self.peoples[location.user.login] {
                    clusterView.transition(location: location, color: colors[people.list.rawValue])
                }
                else {
                    clusterView.transition(location: location, color: nil)
                }
            }
            else {
                clusterView.transition(location: nil, color: nil)
            }
        }
        
        values.reserveCapacity(self.clusterDescription.floors.count)
        for location in self.locations {
            for index in 0 ..< self.clusterDescription.floors.count where location.key.hasPrefix(self.clusterDescription.floors[index].prefix) {
                valuesPlaceCount[index] += 1
                break
            }
            if let people = self.peoples[location.value.user.login] {
                for index in 0 ..< self.clusterDescription.floors.count where location.key.hasPrefix(self.clusterDescription.floors[index].prefix) {
                    valuesPeoplesCount[index][people.list.rawValue] &+= 1
                    break
                }
            }
        }
        for index in 0 ..< self.clusterDescription.floors.count {
            values.append(.init(placeAvailable: self.clusterDescription.floors[index].elementsCount,
                                placeCount: self.clusterDescription.floors[index].elementsCount - valuesPlaceCount[index],
                                friends: valuesPeoplesCount[index][People.ListType.friends.rawValue],
                                extra1: valuesPeoplesCount[index][People.ListType.extraList1.rawValue],
                                extra2: valuesPeoplesCount[index][People.ListType.extraList2.rawValue]))
        }
        self.floorSegment.extraValues = values
        if self.campus.isUserMainCampus {
            HomeDefaults.save(values, forKey: .clustersExtraValues)
        }
    }
    
    @objc private func peopleButtonTapped(sender: UITapGestureRecognizer) {
        let vc = PeopleListViewController(with: .init(rawValue: sender.view!.tag)!)
        
        vc.cluster = self.parentViewController as? ClustersBaseViewController
        self.parentHomeViewController?.presentWithBlur(vc, completion: nil)
    }
    
    func peopleConnected(_ people: People) -> IntraClusterLocation? {
        return self.locations.first(where: { $1.user.id == people.id })?.value
    }
        
    @discardableResult func focusOnClusterView(with host: String, animated: Bool = true) -> Bool {
        for index in 0 ..< self.clusterDescription.floors.count {
            if let view = self.viewsForHost[index][host] {
                if index != self.floorSegment.selectedIndex {
                    self.floorSegment.setSelectedIndex(index)
                    self.transitionToSelectedFloor()
                }
                self.scrollView.zoom(to: view.frame, animated: animated)
                return true
            }
        }
        return false
    }
}

extension ClustersView: SearchFieldViewDelegate, Keyboard {
    
    func searchFieldTextUpdated(_ searchField: SearchFieldView) { self.searchView?.updateSource() }
    func searchFieldBeginEditing(_ searchField: SearchFieldView) { }
    func searchFieldEndEditing(_ searchField: SearchFieldView) { }
    
    func keyboardWillHide(curve: UIView.AnimationCurve, duration: TimeInterval, frame: CGRect) {
        self.removeSearchView(curve: curve, duration: duration, frame: frame)
    }
    func keyboardWillChangeFrame(curve: UIView.AnimationCurve, duration: TimeInterval, frame: CGRect) { }
    func keyboardWillShow(curve: UIView.AnimationCurve, duration: TimeInterval, frame: CGRect) {
        guard self.searchView == nil else {
            return
        }
        let view = SearchResultView(view: self)
        
        self.addSubview(view)
        view.topAnchor.constraint(equalTo: self.searchField.bottomAnchor, constant: HomeLayout.smargin).isActive = true
        view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: HomeLayout.margin).isActive = true
        view.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.margin).isActive = true
        view.bottomAnchor.constraint(equalTo: self.bottomAnchor,
                                     constant: -(HomeLayout.smargin + frame.height)).isActive = true
        view.present(with: duration == 0.0 ? HomeAnimations.durationShort : duration, curve: curve)
        self.searchView = view
    }
    
    @objc private func removeSearchView(curve: UIView.AnimationCurve, duration: TimeInterval, frame: CGRect) {
        guard let view = self.searchView else {
            return
        }
        
        if self.searchField.view.isFirstResponder {
            self.searchField.view.resignFirstResponder()
        }
        view.remove { _ in
            view.removeFromSuperview()
            self.searchView = nil
        }
    }
    
    final private class SearchResultView: HomePresentableVisualEffectView, UITableViewDataSource, UITableViewDelegate {
        
        private var elements: ContiguousArray<IntraClusterLocation>
        private let tableView: BasicUITableView
        private let peopleColors: [CGColor]
        private unowned(unsafe) let view: ClustersView
        
        init(view: ClustersView) {
            self.elements = ContiguousArray<IntraClusterLocation>.init(view.locations.values)
            self.elements.sort(by: App.settings.clusterSearchViewSort.sortFunction)
            self.tableView = BasicUITableView()
            self.peopleColors = People.ListType.allCases.map(\.color.cgColor)
            self.view = view
            super.init()
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.backgroundColor = .clear
            self.tableView.contentInset = .init(top: HomeLayout.margin, left: 0.0,
                                                bottom: HomeLayout.margin, right: 0.0)
            self.tableView.register(UserSearchTableViewCell.self, forCellReuseIdentifier: "cell")
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }

            self.contentView.addSubview(self.tableView)
            self.tableView.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
            self.tableView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
            self.tableView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
            self.tableView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        }
        
        final private class UserSearchTableViewCell: HomeWhiteContainerTableViewCell<UserSearchTableViewCell.View> {
            
            final class View: BasicUIView, HomeWhiteContainerTableViewCellView {
                fileprivate let icon: UserProfilIconView
                fileprivate let loginLabel: BasicUILabel
                fileprivate let locationLabel: HomeInsetsLabel
                
                override init() {
                    self.icon = UserProfilIconView()
                    self.icon.layer.shadowRadius = HomeLayout.smargin
                    self.icon.layer.shadowOffset = .zero
                    self.loginLabel = BasicUILabel(text: "???")
                    self.loginLabel.font = HomeLayout.fontSemiBoldMedium
                    self.loginLabel.textColor = HomeDesign.black
                    self.loginLabel.adjustsFontSizeToFitWidth = true
                    self.locationLabel = HomeInsetsLabel(text: "???", inset: .init(width: HomeLayout.margin, height: HomeLayout.dmargin))
                    self.locationLabel.backgroundColor = HomeDesign.primary.withAlphaComponent(HomeDesign.alphaLayer)
                    self.locationLabel.layer.cornerRadius = HomeLayout.scorner
                    self.locationLabel.layer.masksToBounds = true
                    self.locationLabel.font = HomeLayout.fontBlackNormal
                    self.locationLabel.textColor = HomeDesign.white
                    super.init()
                }
                required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
                
                override func willMove(toSuperview newSuperview: UIView?) {
                    super.willMove(toSuperview: newSuperview)
                    self.addSubview(self.locationLabel)
                    self.locationLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.smargin).isActive = true
                    self.locationLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
                    self.addSubview(self.icon)
                    self.icon.setSize(HomeLayout.userProfilIconMainHeigth, HomeLayout.userProfilIconMainRadius)
                    self.icon.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: HomeLayout.smargin).isActive = true
                    self.icon.topAnchor.constraint(equalTo: self.topAnchor, constant: HomeLayout.smargin).isActive = true
                    self.icon.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -HomeLayout.smargin).isActive = true
                    self.addSubview(self.loginLabel)
                    self.loginLabel.leadingAnchor.constraint(equalTo: self.icon.trailingAnchor, constant: HomeLayout.margin).isActive = true
                    self.loginLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
                    self.loginLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.locationLabel.leadingAnchor, constant: -HomeLayout.smargin).isActive = true
                }
            }
        }
        
        func updateSource() {
            let input = self.view.searchField.text
            
            self.elements = ContiguousArray<IntraClusterLocation>.init(self.view.locations.values)
            self.elements.sort(by: App.settings.clusterSearchViewSort.sortFunction)
            if input.count != 0 {
                self.elements.removeAll(where: { !$0.user.login.contains(input) })
            }
            self.tableView.reloadSections(IndexSet(integer: 0), with: .fade)
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return self.elements.count
        }
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UserSearchTableViewCell
            let location = self.elements[indexPath.row]
            
            cell.view.icon.update(with: location.user)
            if let people = self.view.peoples[location.user.login] {
                cell.view.icon.layer.shadowOpacity = 1.0
                cell.view.icon.layer.shadowColor = people.list.color.cgColor
            }
            else {
                cell.view.icon.layer.shadowOpacity = 0.0
            }
            cell.view.locationLabel.text = location.host
            cell.view.loginLabel.text = location.user.login
            return cell
        }
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let location = self.elements[indexPath.row]
            
            self.view.searchField.view.resignFirstResponder()
            if self.view.focusOnClusterView(with: location.host) == false {
                
                func seeUser() {
                    let vc = ProfilViewController()
                    
                    Task.init(priority: .userInitiated, operation: {
                        await vc.setupWithUser(location.user.login, id: location.user.id)
                    })
                    App.mainController.controller.presentWithBlur(vc)
                }
                
                DynamicAlert(contents: [.text(String(format: ~"clusters.nofocus-for-host", location.user.login, location.host))], actions: [.normal(~"general.ok", nil), .highligth(~"title.profil", seeUser)])
            }
        }
    }
}

extension ClustersView {
    
    final private class HistoricView: HomePresentableVisualEffectView {
        
        private let hostLabel: BasicUILabel
        let closeButton: ActionButtonView
        private let tableView: GenericSingleInfiniteRequestTableView<UserLocationLogTableViewCell, IntraClusterLocation>
        
        init(host: String, title: String, user: IntraUserInfo?, campus: IntraUserCampus) {
            self.hostLabel = BasicUILabel(text: title)
            self.hostLabel.font = HomeLayout.fontSemiBoldTitle
            self.hostLabel.textColor = HomeDesign.white
            self.hostLabel.adjustsFontSizeToFitWidth = true
            self.closeButton = ActionButtonView(asset: .actionClose, color: HomeDesign.actionRed)
            self.tableView = .init(.campusWithCampusIdLocations(campus.campus_id),
                                   parameters: ["filter[host]": host, "sort": "-begin_at"])
            self.tableView.backgroundColor = UIColor.clear
            super.init()
            self.tableView.block = self.selectLocation
            self.tableView.nextPage()
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }
            
            self.contentView.addSubview(self.closeButton)
            self.closeButton.topAnchor.constraint(equalTo: self.contentView.topAnchor,
                                                  constant: HomeLayout.margin).isActive = true
            self.closeButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor,
                                                       constant: -HomeLayout.margin).isActive = true
            self.contentView.addSubview(self.hostLabel)
            self.hostLabel.centerYAnchor.constraint(equalTo: self.closeButton.centerYAnchor).isActive = true
            self.hostLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor,
                                                    constant: HomeLayout.margin).isActive = true
            self.hostLabel.trailingAnchor.constraint(equalTo: self.closeButton.leadingAnchor,
                                                     constant: -HomeLayout.margin).isActive = true
            self.contentView.addSubview(self.tableView)
            self.tableView.topAnchor.constraint(equalTo: self.closeButton.bottomAnchor,
                                                constant: HomeLayout.margin).isActive = true
            self.tableView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
            self.tableView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
            self.tableView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        }
        
        func update(host: String, title: String, user: IntraUserInfo?) {
            self.hostLabel.text = title
            self.tableView.restart(with: ["filter[host]": host, "sort": "-begin_at"])
        }
        
        private func selectLocation(_ location: IntraClusterLocation) {
            let profil = ProfilViewController()
            
            Task.init(priority: .userInitiated, operation: {
                await profil.setupWithUser(location.user.login, id: location.user.id)
            })
            self.parentHomeViewController?.presentWithBlur(profil)
        }
        
        final class UserLocationLogTableViewCell: BasicUITableViewCell, GenericSingleInfiniteRequestCell {
            
            private let container: BasicUIView
            private let userIcon: UserProfilIconView
            private let userLogin: BasicUILabel
            private let logView: LogView
        
            override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
                self.container = BasicUIView()
                self.container.backgroundColor = HomeDesign.white
                self.container.layer.cornerRadius = HomeLayout.scorner
                self.container.layer.masksToBounds = true
                self.userIcon = UserProfilIconView()
                self.userIcon.layer.shadowOffset = .zero
                self.userIcon.layer.shadowRadius = HomeLayout.margins
                self.userLogin = BasicUILabel(text: "???")
                self.userLogin.font = HomeLayout.fontSemiBoldMedium
                self.userLogin.textColor = HomeDesign.black
                self.userLogin.adjustsFontSizeToFitWidth = true
                self.logView = LogView()
                super.init(style: style, reuseIdentifier: reuseIdentifier)
            }
            required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
            
            override func willMove(toSuperview newSuperview: UIView?) {
                guard newSuperview != nil else {
                    return
                }
                self.contentView.addSubview(self.container)
                self.container.topAnchor.constraint(equalTo: self.contentView.topAnchor,
                                                    constant: HomeLayout.smargin).isActive = true
                self.container.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor,
                                                        constant: HomeLayout.margin).isActive = true
                self.container.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor,
                                                         constant: -HomeLayout.margin).isActive = true
                self.container.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor,
                                                       constant: -HomeLayout.smargin).isActive = true
                self.container.addSubview(self.userIcon)
                self.userIcon.setSize(HomeLayout.userProfilIconHistoricHeigth, HomeLayout.userProfilIconHistoricRadius)
                self.userIcon.leadingAnchor.constraint(equalTo: self.container.leadingAnchor,
                                                       constant: HomeLayout.margin).isActive = true
                self.userIcon.topAnchor.constraint(equalTo: self.container.topAnchor,
                                                   constant: HomeLayout.margin).isActive = true
                self.container.addSubview(self.userLogin)
                self.userLogin.leadingAnchor.constraint(equalTo: self.userIcon.trailingAnchor,
                                                        constant: HomeLayout.smargin).isActive = true
                self.userLogin.centerYAnchor.constraint(equalTo: self.userIcon.centerYAnchor).isActive = true
                self.userLogin.trailingAnchor.constraint(equalTo: self.container.trailingAnchor,
                                                         constant: -HomeLayout.margin).isActive = true
                self.container.addSubview(self.logView)
                self.logView.topAnchor.constraint(equalTo: self.userIcon.bottomAnchor).isActive = true
                self.logView.leadingAnchor.constraint(equalTo: self.container.leadingAnchor).isActive = true
                self.logView.trailingAnchor.constraint(equalTo: self.container.trailingAnchor).isActive = true
                self.logView.bottomAnchor.constraint(equalTo: self.container.bottomAnchor).isActive = true
            }
            
            func fill(with element: IntraClusterLocation) {
                self.userIcon.update(with: element.user)
                self.userLogin.text = element.user.login
                self.logView.update(with: element)
            }
        }
    }

    @objc private func removeHistoricView() {
        guard let view = self.historicView else { return }
        
        if self.searchField.view.isFirstResponder {
            self.searchField.view.resignFirstResponder()
        }
        view.remove { _ in
            view.removeFromSuperview()
            self.historicView = nil
            self.searchField.isUserInteractionEnabled = true
        }
    }
    
    private func addHistoricView(_ host: String, title: String, user: IntraUserInfo?, campus: IntraUserCampus) {
        guard self.historicView == nil else { return }
        let view = HistoricView(host: host, title: title, user: user, campus: campus)
        
        self.searchField.isUserInteractionEnabled = false
        self.addSubview(view)
        view.topAnchor.constraint(equalTo: self.searchField.bottomAnchor, constant: HomeLayout.margin).isActive = true
        view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: HomeLayout.margin).isActive = true
        view.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.margin).isActive = true
        view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -(HomeLayout.safeAeraMain.bottom + HomeLayout.margin)).isActive = true
        
        view.present { _ in
            view.closeButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ClustersView.removeHistoricView)))
        }
        self.historicView = view
    }
}
