//
//  Clusters.swift
//  home42
//
//  Created by Antoine Feuerstein on 16/04/2021.
//

import Foundation
import UIKit
import CryptoKit
import SwiftDate
import AVFAudio

final class ClustersViewController: HomeViewController {
    
    @frozen private enum State {
        case unused
        case preparingCampus
        case incompatibleCampus
        case workingCampus
        
        var viewsAvailable: Bool {
            switch self {
            case .preparingCampus, .workingCampus:
                return true
            default:
                return false
            }
        }
    }
    private var state: State = .unused
    private var clusterDescription: ClusterDescription!
    
    // MARK: -
    private let floorSegment: ClusterSegmentView
    private let refreshButton: ActionButtonView
    
    private let searchField: SearchFieldView
    private let friendsButton: ActionButtonView
    private let extra1Button: ActionButtonView?
    private let extra2Button: ActionButtonView?
    
    private let scrollView: BasicUIScrollView

    private var historicView: HistoricView? = nil
    private var historicViewBottom: NSLayoutConstraint! = nil
    private var searchView: SearchResultView? = nil
    private var searchViewBottom: NSLayoutConstraint! = nil
    
    // MARK: -
    required init() {
        var leadingAction: NSLayoutXAxisAnchor
        
        do {
            let clusterDescriptionData = try Data(contentsOf: HomeResources.applicationDirectory.appendingPathComponent("res/clusters/\(App.userCampus.campus_id).json"))
            
            self.clusterDescription = try JSONDecoder.decoder.decode(ClusterDescription.self, from: clusterDescriptionData)
            self.state = .preparingCampus
            self.floorSegment = ClusterSegmentView(values: self.clusterDescription.floors.map({ $0.name }), extraValues: HomeDefaults.read(.clustersExtraValues),
                                                   selectedIndex: HomeDefaults.read(.liveClusterFloor) ?? 0)
        }
        catch {
            #if DEBUG
                print(error)
            #endif
            self.state = .incompatibleCampus
            DynamicAlert(contents: [.title(~"NONEXISTENT_CLUSTER"), .text("id: \(App.userCampus.campus_id)")],
                         actions: [.normal(~"OK", nil), HomeGuides.alertActionLink(.addCluster)])
            self.floorSegment = ClusterSegmentView(values: ["???"], extraValues: nil, selectedIndex: 0)
        }
        
        self.refreshButton = ActionButtonView(asset: .actionRefresh, color: HomeDesign.primary)
        self.searchField = SearchFieldView(placeholder: ~"SEARCH")
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
        self.scrollView.backgroundColor = UIColor.clear
        super.init()
        self.view.addSubview(self.scrollView)
        self.scrollView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        self.view.addSubview(self.floorSegment)
        self.floorSegment.delegate = self
        self.floorSegment.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: HomeLayout.margin).isActive = true
        if App.settings.clusterShowCounters {
            self.floorSegment.topAnchor.constraint(equalTo: self.view.topAnchor, constant: App.safeAeraMain.top + HomeLayout.margind).isActive = true
        }
        else {
            self.floorSegment.topAnchor.constraint(equalTo: self.view.topAnchor, constant: App.safeAeraMain.top + HomeLayout.margin).isActive = true
        }
        self.floorSegment.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -HomeLayout.margin).isActive = true
        
        self.view.addSubview(self.searchField)
        leadingAction = self.floorSegment.leadingAnchor
        for (index, button) in [self.extra2Button, self.extra1Button, self.friendsButton].compactMap({ $0 }).enumerated() {
            self.view.addSubview(button)
            if index == 0 {
                button.leadingAnchor.constraint(equalTo: leadingAction).isActive = true
            }
            else {
                button.leadingAnchor.constraint(equalTo: leadingAction, constant: HomeLayout.dmargin).isActive = true
            }
            button.centerYAnchor.constraint(equalTo: self.searchField.centerYAnchor).isActive = true
            button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ClustersViewController.peopleButtonTapped(sender:))))
            leadingAction = button.trailingAnchor
        }
        self.searchField.delegate = self
        self.searchField.view.adjustsFontSizeToFitWidth = true
        self.searchField.topAnchor.constraint(equalTo: self.floorSegment.bottomAnchor, constant: HomeLayout.smargin).isActive = true
        self.searchField.leadingAnchor.constraint(equalTo: leadingAction, constant: HomeLayout.smargin).isActive = true
        self.view.addSubview(self.refreshButton)
        self.refreshButton.trailingAnchor.constraint(equalTo: self.floorSegment.trailingAnchor).isActive = true
        self.refreshButton.centerYAnchor.constraint(equalTo: self.searchField.centerYAnchor).isActive = true
        self.refreshButton.leadingAnchor.constraint(equalTo: self.searchField.trailingAnchor, constant: HomeLayout.smargin).isActive = true
        self.refreshButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ClustersViewController.refreshLocations)))
        
        self.keyboardInterfaceSetup()
        
        if case .preparingCampus = self.state {
            self.peoples = HomeDefaults.read(.peoples) ?? [:]
            self.peoples[App.user.login] = People.me
            if let liveClusterLocations: Dictionary<String, IntraClusterLocation> = HomeDefaults.read(.liveClusterLocations) {
                self.locations = liveClusterLocations
            }
            else {
                self.locations = [:]
            }
            self.locations.reserveCapacity(self.clusterDescription.elementsCount)
            self.generateClusterViews()
            self.configureClusterScrollView()
            self.state = .workingCampus
            self.refreshLocations()
        }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: -
    private var clusterViews: Dictionary<CGPoint, ClusterView> = [:]
    private var clusterPillarViews: Dictionary<CGPoint, ClusterPillarView> = [:]
    
    private var viewsForHost: Array<Dictionary<String, ClusterView>> = []
    private var locations: Dictionary<String, IntraClusterLocation>!
    private var peoples: Dictionary<String, People> = [:]
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.searchField.view.isFirstResponder {
            self.searchField.view.resignFirstResponder()
        }
        self.removeHistoricView()
    }
    
    // MARK: -
    @objc private func peopleButtonTapped(sender: UITapGestureRecognizer) {
        self.presentWithBlur(PeopleListViewController(with: .init(rawValue: sender.view!.tag)!), completion: nil)
    }
}

// MARK: Read cluster representation and load it
extension ClustersViewController: UIScrollViewDelegate, ClusterSegmentViewDelegate {
    
    final private class ClusterDescription: IntraObject {
        
        let width: CGFloat
        let height: CGFloat
        let placeWidth: CGFloat
        let placeHeight: CGFloat
        let elementsCount: Int
        
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
        }
        let floors: [Floor]
        
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

    private func generateClusterViews() {
        let container: BasicUIView = BasicUIView()
        var clusterView: ClusterView
        let clusterViewSize: CGSize = .init(width: self.clusterDescription.placeWidth, height: self.clusterDescription.placeHeight)
        var clusterPillarView: ClusterPillarView
        let type = App.settings.clustersPlaceClassType
        let pillarType = App.settings.clustersPillarClassType
        let colors: [CGColor] = People.ListType.allCases.map(\.color.cgColor)
        
        self.clusterViews.reserveCapacity(self.clusterDescription.floors[self.floorSegment.selectedIndex].elementsCount)
        container.frame = .init(origin: .zero, size: .init(width: self.clusterDescription.width, height: self.clusterDescription.height))
        self.scrollView.addSubview(container)
        container.topAnchor.constraint(equalTo: self.scrollView.topAnchor).isActive = true
        container.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor).isActive = true
        container.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor).isActive = true
        container.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor).isActive = true
        container.widthAnchor.constraint(equalToConstant: self.clusterDescription.width).isActive = true
        container.heightAnchor.constraint(equalToConstant: self.clusterDescription.height).isActive = true
        container.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(scrollViewContentTapped)))
        
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
                        clusterView = type.init(frame: .init(origin: place.position, size: clusterViewSize), display: place.display)
                        self.clusterViews[place.position] = clusterView
                        self.viewsForHost[index][place.host] = clusterView
                    }
                }
            }
        })
    }
    
    func clusterSegmentViewSelect(_ segmentView: ClusterSegmentView) {
        self.transitionToSelectedFloor()
        HomeDefaults.save(segmentView.selectedIndex, forKey: .liveClusterFloor)
    }
    func clusterSegmentViewPeopleCounterSelect(_ segmentView: ClusterSegmentView, listType: People.ListType) {
        
    }
    func clusterSegmentViewPlacesCounterSelect(_ segmentView: ClusterSegmentView) {
        
    }
    
    private func transitionToSelectedFloor() {
        
        let container = self.scrollView.subviews.first!
        let clusterViewSize: CGSize = .init(width: self.clusterDescription.placeWidth, height: self.clusterDescription.placeHeight)
        var clusterPillarView: ClusterPillarView
        let pillarType = App.settings.clustersPillarClassType
        let transition = self.clusterDescription.transitions.first(where: { $0.from == self.floorSegment.oldSelectedIndex && $0.to == self.floorSegment.selectedIndex })!
        let colors: [CGColor] = People.ListType.allCases.map(\.color.cgColor)
        
        for position in transition.remove {
            self.clusterViews.removeValue(forKey: position)?.removeFromSuperview()
        }
        for place in transition.add {
            container.addSubview(self.viewsForHost[self.floorSegment.selectedIndex][place.host]!)
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
    }
    
    @objc private func refreshLocations() {
        guard self.refreshButton.isUserInteractionEnabled == true && self.state.viewsAvailable else {
            return
        }
        
        @MainActor @Sendable func refreshEnded(floorSegmentValues values: [ClusterSegmentView.ExtraValues]) {
            self.floorSegment.extraValues = values
            self.refreshButton.isUserInteractionEnabled = true
            self.refreshButton.stopRotate()
            HomeDefaults.save(values, forKey: .clustersExtraValues)
        }
        
        self.refreshButton.isUserInteractionEnabled = false
        self.refreshButton.startRotate()
        Task(priority: .high, operation: {
            let route: HomeApi.Routes = .campusWithCampusIdLocations(App.userCampus.campus_id)
            let sequence: HomeApi.RequestSequence<IntraClusterLocation> = .init(route: route, parameters: ["filter[active]": true])
            let oldLocationsSet = Set<IntraClusterLocation>.init(self.locations.values)
            let newLocationsSet: Set<IntraClusterLocation>
            var diffLocationsSet: Set<IntraClusterLocation>
            
            var valuesPlaceCount: Array<Int> = Array(repeating: 0, count: self.clusterDescription.floors.count)
            var valuesPeoplesCount: Array<Array<Int>> = Array(repeating: Array(repeating: 0, count: People.ListType.allCases.count), count: self.clusterDescription.floors.count)
            var values: [ClusterSegmentView.ExtraValues] = []
            
            values.reserveCapacity(self.clusterDescription.floors.count)
            do {
                
                self.locations.removeAll()
                for try await newLocations in sequence {
                    self.incorporateLocations(newLocations)
                }
                
                newLocationsSet = Set<IntraClusterLocation>.init(self.locations.values)
                diffLocationsSet = oldLocationsSet.symmetricDifference(newLocationsSet) // other way ?
                for location in newLocationsSet {
                    diffLocationsSet.remove(location)
                }
                for location in diffLocationsSet {
                    if let view = self.viewsForHost[self.floorSegment.selectedIndex][location.host] {
                        view.transition(location: nil, color: nil)
                    }
                }
                
                if let searchView = searchView {
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
                HomeDefaults.save(self.locations, forKey: .liveClusterLocations)
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
    
    func peoplesUpdated(_ peoples: Dictionary<String, People>) {
        let colors: [CGColor] = People.ListType.allCases.map(\.color.cgColor)
        var valuesPlaceCount: Array<Int> = Array(repeating: 0, count: self.clusterDescription.floors.count)
        var valuesPeoplesCount: Array<Array<Int>> = Array(repeating: Array(repeating: 0, count: People.ListType.allCases.count), count: self.clusterDescription.floors.count)
        var values: [ClusterSegmentView.ExtraValues] = []
        
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
        HomeDefaults.save(values, forKey: .clustersExtraValues)
    }
    
    func peopleConnected(_ people: People) -> IntraClusterLocation? {
        return self.locations.first(where: { $1.user.id == people.id })?.value
    }
    
    @discardableResult func focusOnClusterView(with host: String, animated: Bool = true) -> Bool {
        guard self.state.viewsAvailable else {
            return false
        }
        
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
    
    @objc private func scrollViewContentTapped(gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: gesture.view)
        
        func tryInteractionForHost(_ host: String, user: IntraUserInfo?) {
            guard self.searchView == nil else {
                return
            }
            
            func showHistoricView() {
                if let historicView = self.historicView {
                    historicView.update(host: host, user: user)
                }
                else {
                    self.addHistoricView(host, user: user)
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
                self.presentWithBlur(profil, completion: nil)
            }
        }
        
        if let view = self.clusterViews.values.first(where: { $0.point(inside: $0.convert(location, from: gesture.view!), with: nil) }) {
            tryInteractionForHost(self.clusterDescription.floors[self.floorSegment.selectedIndex].prefix + view.display, user: view.location?.user)
        }
    }
    
    // MARK: -
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.scrollView.subviews.first
    }
    func configureClusterScrollView() {
        let offsetY = App.safeAeraMain.top + HomeLayout.roundedGenericActionsViewHeigth + HomeLayout.clusterSegmentHeigth + HomeLayout.margin * 4.0
        let width = UIScreen.main.bounds.width - (App.safeAera.left + App.safeAera.right)
        let height = UIScreen.main.bounds.height - (offsetY + App.safeAera.bottom)
        let widthRatio = min(width, self.clusterDescription.width) / max(width, self.clusterDescription.width)
        let heightRatio = min(height, self.clusterDescription.height) / max(height, self.clusterDescription.height)
        let minZoom = max(widthRatio, heightRatio)
        
        self.scrollView.minimumZoomScale = minZoom
        self.scrollView.maximumZoomScale = minZoom * 15.0
        self.scrollView.zoomScale = 1.0 // self.scrollView.maximumZoomScale // doesn't work
        self.scrollView.isScrollEnabled = true
        self.scrollView.delegate = self
        self.scrollView.contentInset = .init(top: offsetY, left: 0.0, bottom: 0.0, right: 0.0)
        self.scrollView.zoom(to: .init(origin: .zero, size: .init(width: width, height: height)), animated: false)
    }
}

// MARK: search
extension ClustersViewController: SearchFieldViewDelegate, Keyboard {
    
    final private class SearchResultView: HomePresentableVisualEffectView, UITableViewDataSource, UITableViewDelegate {
        
        private var elements: ContiguousArray<IntraClusterLocation>
        private let tableView: BasicUITableView
        private let peopleColors: [CGColor]
        private unowned(unsafe) let clusterViewController: ClustersViewController
        
        init(clusterViewController: ClustersViewController) {
            self.elements = ContiguousArray<IntraClusterLocation>.init(clusterViewController.locations.values)
            self.elements.sort(by: App.settings.clusterSearchViewSort.sortFunction)
            self.tableView = BasicUITableView()
            self.peopleColors = People.ListType.allCases.map(\.color.cgColor)
            self.clusterViewController = clusterViewController
            super.init()
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.backgroundColor = .clear
            self.tableView.contentInset = .init(top: HomeLayout.margin, left: 0.0, bottom: HomeLayout.margin, right: 0.0)
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
            let input = self.clusterViewController.searchField.text
            
            self.elements = ContiguousArray<IntraClusterLocation>.init(clusterViewController.locations.values)
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
            
            cell.view.icon.update(with: location.user.login)
            if let people = self.clusterViewController.peoples[location.user.login] {
                cell.view.icon.layer.shadowOpacity = Float(HomeDesign.alphaLayer)
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
            
            self.clusterViewController.searchField.view.resignFirstResponder()
            if self.clusterViewController.focusOnClusterView(with: location.host) == false {
                DynamicAlert(contents: [.text(String(format: ~"CLUSTER_NOFOCUS_FOR_HOST", location.user.login, location.host))], actions: [.normal(~"I_UNDERSTAND", nil)])
            }
        }
    }
    
    func searchFieldTextUpdated(_ searchField: SearchFieldView) {
        if let searchView = self.searchView {
            searchView.updateSource()
        }
    }
    func searchFieldBeginEditing(_ searchField: SearchFieldView) { }
    
    func searchFieldEndEditing(_ searchField: SearchFieldView) { }
    
    func keyboardWillShow(curve: UIView.AnimationCurve, duration: TimeInterval, frame: CGRect) {
        self.addSearchView(curve: curve, duration: duration, frame: frame)
    }
    func keyboardWillHide(curve: UIView.AnimationCurve, duration: TimeInterval, frame: CGRect) {
        self.removeSearchView(curve: curve, duration: duration, frame: frame)
    }
    func keyboardWillChangeFrame(curve: UIView.AnimationCurve, duration: TimeInterval, frame: CGRect) { }
    
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
            self.searchViewBottom = nil
        }
    }
    
    private func addSearchView(curve: UIView.AnimationCurve, duration: TimeInterval, frame: CGRect) {
        guard self.searchView == nil else { return }
        let view = SearchResultView(clusterViewController: self)
        
        self.view.addSubview(view)
        view.topAnchor.constraint(equalTo: self.searchField.bottomAnchor, constant: HomeLayout.smargin).isActive = true
        view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: HomeLayout.margin).isActive = true
        view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -HomeLayout.margin).isActive = true
        self.searchViewBottom = view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -(HomeLayout.smargin + frame.height))
        self.searchViewBottom.isActive = true
        self.view.layoutIfNeeded()
        view.present(with: duration == 0.0 ? HomeAnimations.durationShort : duration, curve: curve)
        self.searchView = view
    }
}

// MARK: historic
extension ClustersViewController {
    
    final private class HistoricView: HomePresentableVisualEffectView {
        
        private let hostLabel: BasicUILabel
        let closeButton: ActionButtonView
        private let tableView: GenericSingleInfiniteRequestTableView<UserLocationLogTableViewCell, IntraClusterLocation>
        
        init(host: String, user: IntraUserInfo?) {
            self.hostLabel = BasicUILabel(text: host)
            self.hostLabel.font = HomeLayout.fontSemiBoldTitle
            self.hostLabel.textColor = HomeDesign.white
            self.hostLabel.adjustsFontSizeToFitWidth = true
            self.closeButton = ActionButtonView(asset: .actionClose, color: HomeDesign.actionRed)
            self.tableView = .init(.campusWithCampusIdLocations(App.userCampus.campus_id), parameters: ["filter[host]": host, "sort": "-begin_at"])
            self.tableView.backgroundColor = UIColor.clear
            super.init()
            self.tableView.block = self.selectLocation
            self.tableView.nextPage()
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }
            self.contentView.addSubview(self.closeButton)
            self.closeButton.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: HomeLayout.margin).isActive = true
            self.closeButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -HomeLayout.margin).isActive = true
            self.contentView.addSubview(self.hostLabel)
            self.hostLabel.centerYAnchor.constraint(equalTo: self.closeButton.centerYAnchor).isActive = true
            self.hostLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: HomeLayout.margin).isActive = true
            self.hostLabel.trailingAnchor.constraint(equalTo: self.closeButton.leadingAnchor, constant: -HomeLayout.margin).isActive = true
            self.contentView.addSubview(self.tableView)
            self.tableView.topAnchor.constraint(equalTo: self.closeButton.bottomAnchor, constant: HomeLayout.margin).isActive = true
            self.tableView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
            self.tableView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
            self.tableView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        }
        
        func update(host: String, user: IntraUserInfo?) {
            self.hostLabel.text = host
            self.tableView.restart(with: ["filter[host]": host, "sort": "-begin_at"])
        }
        
        private func selectLocation(_ location: IntraClusterLocation) {
            let profil = ProfilViewController()
            
            Task.init(priority: .userInitiated, operation: {
                await profil.setupWithUser(location.user.login, id: location.user.id)
            })
            (self.parentViewController as! HomeViewController).presentWithBlur(profil)
        }
    }
    
    final class UserLocationLogTableViewCell: HomeWhiteContainerTableViewCell<UserLocationLogTableViewCell.View>, GenericSingleInfiniteRequestCell {
        
        final class View: BasicUIView, HomeWhiteContainerTableViewCellView {
            fileprivate let icon: UserProfilIconView
            fileprivate let loginLabel: BasicUILabel
            fileprivate let startLabel: BasicUILabel
            fileprivate let durationLabel: HomeInsetsLabel
            
            override init() {
                self.icon = UserProfilIconView()
                self.icon.layer.shadowRadius = HomeLayout.smargin
                self.icon.layer.shadowOffset = .zero
                self.loginLabel = BasicUILabel(text: "???")
                self.loginLabel.font = HomeLayout.fontSemiBoldMedium
                self.loginLabel.textColor = HomeDesign.black
                self.loginLabel.adjustsFontSizeToFitWidth = true
                self.startLabel = BasicUILabel(text: "???")
                self.startLabel.font = HomeLayout.fontRegularMedium
                self.startLabel.textColor = HomeDesign.black
                self.startLabel.adjustsFontSizeToFitWidth = true
                self.durationLabel = HomeInsetsLabel(text: "???", inset: .init(width: HomeLayout.margin, height: HomeLayout.dmargin))
                self.durationLabel.backgroundColor = HomeDesign.primaryDefault.withAlphaComponent(HomeDesign.alphaLayer)
                self.durationLabel.layer.cornerRadius = HomeLayout.scorner
                self.durationLabel.layer.masksToBounds = true
                self.durationLabel.font = HomeLayout.fontBlackNormal
                self.durationLabel.textColor = HomeDesign.white
                super.init()
            }
            required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
            
            override func willMove(toSuperview newSuperview: UIView?) {
                guard newSuperview != nil else { return }
                super.willMove(toSuperview: newSuperview)
                self.addSubview(self.durationLabel)
                self.durationLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.smargin).isActive = true
                self.durationLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: HomeLayout.smargin).isActive = true
                self.addSubview(self.icon)
                self.icon.setSize(HomeLayout.userProfilIconHistoricHeigth, HomeLayout.userProfilIconHistoricRadius)
                self.icon.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: HomeLayout.smargin).isActive = true
                self.icon.topAnchor.constraint(equalTo: self.topAnchor, constant: HomeLayout.smargin).isActive = true
                self.addSubview(self.loginLabel)
                self.loginLabel.leadingAnchor.constraint(equalTo: self.icon.trailingAnchor, constant: HomeLayout.margin).isActive = true
                self.loginLabel.centerYAnchor.constraint(equalTo: self.icon.centerYAnchor).isActive = true
                self.loginLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -HomeLayout.smargin).isActive = true
                self.addSubview(self.startLabel)
                self.startLabel.leadingAnchor.constraint(equalTo: self.icon.leadingAnchor).isActive = true
                self.startLabel.topAnchor.constraint(equalTo: self.icon.bottomAnchor, constant: HomeLayout.smargin).isActive = true
                self.startLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.smargin).isActive = true
                self.startLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -HomeLayout.smargin).isActive = true
            }
        }
        
        func fill(with element: IntraClusterLocation) {
            if let cluster = App.mainController.controller as? ClustersViewController, let people = cluster.peoples[element.user.login] {
                self.view.icon.layer.shadowColor = people.list.color.cgColor
                self.view.icon.layer.shadowOpacity = Float(HomeDesign.alphaLayer)
            }
            else {
                self.view.icon.layer.shadowOpacity = 0.0
            }
            self.view.icon.update(with: element.user.login)
            self.view.loginLabel.text = element.user.login
            self.view.startLabel.text = element.beginDate.toString(.historicSmall)
            if element.end_at != nil {
                self.view.durationLabel.backgroundColor = HomeDesign.blueAccess.withAlphaComponent(HomeDesign.alphaLayer)
                self.view.durationLabel.text = element.beginDate.toStringDiffTime(to: element.endDate)
            }
            else {
                self.view.durationLabel.backgroundColor = HomeDesign.greenSuccess.withAlphaComponent(HomeDesign.alphaLayer)
                self.view.durationLabel.text = element.beginDate.toStringDiffTime(to: Date())
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
            self.historicViewBottom = nil
            self.searchField.isUserInteractionEnabled = true
        }
    }
    
    private func addHistoricView(_ host: String, user: IntraUserInfo?) {
        guard self.historicView == nil else { return }
        let view = HistoricView(host: host, user: user)
        
        self.searchField.isUserInteractionEnabled = false
        self.view.addSubview(view)
        view.topAnchor.constraint(equalTo: self.searchField.bottomAnchor, constant: HomeLayout.margin).isActive = true
        view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: HomeLayout.margin).isActive = true
        view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -HomeLayout.margin).isActive = true
        self.historicViewBottom = view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -(App.safeAeraMain.bottom + HomeLayout.margin))
        self.historicViewBottom.isActive = true
        view.present { _ in
            view.closeButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ClustersViewController.removeHistoricView)))
        }
        self.historicView = view
    }
}
