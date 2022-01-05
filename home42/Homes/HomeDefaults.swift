//
//  HomeDefaults.swift
//  home42
//
//  Created by Antoine Feuerstein on 10/04/2021.
//

import Foundation
import UIKit
import SecureDefaults
import SwiftUI

final class HomeDefaults: NSObject {
    
    static private let secure: SecureDefaults = {
        let defaults = SecureDefaults.shared
        
        if defaults.isKeyCreated == false {
            defaults.password = UIDevice.current.identifierForVendor?.uuidString ?? "42"
        }
        return defaults
    }()
    
    static func jsonRepresentation() -> String {
        var data: Any?
        var result: String = ""
        var jsonObjects: Any
        
        for (index, key) in HomeDefaults.Key.allCases.enumerated() {
            data = HomeDefaults.secure.object(forKey: key.rawValue)
            
            func append(value: String) {
                if index + 1 >= HomeDefaults.Key.allCases.count {
                    result += "\"\(key.rawValue)\": \(value)\n"
                }
                else {
                    result += "\"\(key.rawValue)\": \(value),\n"
                }
            }
            
            if let data = data {
                switch data {
                case is Bool:
                    append(value: data as! Bool ? "true" : "false")
                case is Int:
                    append(value: "\(data as! Int)")
                case is String:
                    append(value: data as! String)
                case is Date:
                    append(value: (data as! Date).toString(.fullReadable))
                case is Data:
                    do {
                        jsonObjects = try JSONSerialization.jsonObject(with: data as! Data, options: .allowFragments)
                        if let array = jsonObjects as? Array<[String: Any]> {
                            append(value: array.map({ $0.json }).joined(separator: "\n"))
                        }
                        else if let dico = jsonObjects as? [String: Any] {
                            append(value: dico.json)
                        }
                        else {
                            //
                        }
                    }
                    catch {
                        #if DEBUG
                        print("HomeDefaults", #function, "data corrupted:", type(of: data))
                        #endif
                    }
                case is [String: Any]:
                    append(value: (data as! [String: Any]).json)
                default:
                    #if DEBUG
                    print("HomeDefaults", #function, "unknow type:", type(of: data))
                    #endif
                }
            }
            else {
                append(value: "nil")
            }
        }
        return result
    }
    
    static func logout() {
        HomeDefaults.remove(.user)
        HomeDefaults.remove(.coalitions)
        HomeDefaults.remove(.controller)
        HomeDefaults.remove(.tokens)
        HomeDefaults.remove(.cookie)
        HomeDefaults.remove(.controller)
        HomeDefaults.remove(.userEvents)
    }
    
    @frozen enum Key: String, CaseIterable {
        case liveClusterFloor
        case clustersExtraValues
        case controller
        
        case tokens
        case cookie
        
        case user
        case coalitions
        case settings
        
        
        case userEvents
        
        case peoples
        case liveClusterLocations
    }
        
    static func save(_ element: Bool, forKey key: HomeDefaults.Key) {
        HomeDefaults.secure.set(element, forKey: key.rawValue)
    }
    static func save<V: Comparable & Numeric>(_ element: V, forKey key: HomeDefaults.Key) {
        HomeDefaults.secure.set(element, forKey: key.rawValue)
    }
    static func save(_ element: String, forKey key: HomeDefaults.Key) {
        HomeDefaults.secure.set(element, forKey: key.rawValue)
    }
    static func save(_ element: String, forRawKey rawKey: String) {
        HomeDefaults.secure.set(element, forKey: rawKey)
    }
    static func save(_ element: Date, forKey key: HomeDefaults.Key) {
        HomeDefaults.secure.set(element, forKey: key.rawValue)
    }
    static func save<G: Encodable>(_ element: G, forKey key: HomeDefaults.Key) {
        do {
            HomeDefaults.secure.set(try JSONEncoder.encoder.encode(element), forKey: key.rawValue)
        }
        catch {
            #if DEBUG
            print("HomeDefaults", #function, type(of: element), error)
            #endif
        }
    }
    
    static func read(_ key: HomeDefaults.Key) -> Bool? {
        return HomeDefaults.secure.bool(forKey: key.rawValue)
    }
    static func read<V: Comparable & Numeric>(_ key: HomeDefaults.Key) -> V? {
        return HomeDefaults.secure.object(forKey: key.rawValue) as? V
    }
    static func read(_ key: HomeDefaults.Key) -> String? {
        return HomeDefaults.secure.string(forKey: key.rawValue)
    }
    static func read(_ rawKey: String) -> String? {
        return HomeDefaults.secure.string(forKey: rawKey)
    }
    static func read(_ key: HomeDefaults.Key) -> Date? {
        return HomeDefaults.secure.object(forKey: key.rawValue) as? Date
    }
    static func read<G: Decodable>(_ key: HomeDefaults.Key) -> G? {
        if let data = HomeDefaults.secure.object(forKey: key.rawValue) as? Data {
            return try? JSONDecoder.decoder.decode(G.self, from: data)
        }
        return nil
    }
    
    static func remove(_ key: HomeDefaults.Key) {
        HomeDefaults.secure.removeObject(forKey: key.rawValue)
    }
    static func remove(_ rawKey: String) {
        HomeDefaults.secure.removeObject(forKey: rawKey)
    }
}

final class UserSettings: IntraObject { 
    
    var depthCloseActivated: Bool
    var depthMinimum: Int
    
    // MARK: - Graphics
    var graphicsBlurPrimary: Bool
    var graphicsBlurPrimaryTransition: Bool
    var graphicsBlurHeader: Bool
    var graphicsUseParallax: Bool
    @frozen enum ParallaxForce: CGFloat, Codable, SelectorViewSource, CaseIterable {
        case light = 12.0
        case medium = 30.0
        case high = 50.0
        
        static let allKeys: [String] = ["SD_PARALLAX_LIGHT", "SD_PARALLAX_MEDIUM", "SD_GRAPHICS_HIGH"]
        static let allValues: [UserSettings.ParallaxForce] = UserSettings.ParallaxForce.allCases
    }
    var graphicsParallaxForce: ParallaxForce
    
    @frozen enum GraphicsTransitionDuration: Int, Codable, SelectorViewSource, CaseIterable {
        case durationQuick
        case durationShort
        case durationMedium
        case durationLong
        case durationLongLong
        
        static let allKeys: [String] = ["SD_GRAPHICS_TD_QUICK", "SD_GRAPHICS_TD_SHORT", "SD_GRAPHICS_TD_MEDIUM", "SD_GRAPHICS_TD_LONG", "SD_GRAPHICS_TD_LONGLONG"]
        static let allValues: [UserSettings.GraphicsTransitionDuration] = allCases
    }
    var graphicsTransitionDuration: GraphicsTransitionDuration {
        didSet {
            HomeAnimations.prepare()
        }
    }
    // MARK: - Profil
    var profilShowLogs: Bool
    var profilShowCorrections: Bool
    var profilCorrectionsCount: Int
    var profilShowEvents: Bool
    var profilShowPartnerships: Bool
    
    // MARK: - Cluster
    @frozen enum ClustersPlaceClassName: String, Codable, SelectorViewSource {
    
        case classicRectangular = "classicR"
        case classicCurved = "classicC"
        case clearRectangular = "clearR"
        case clearCurved = "clearC"
        case blurredRectangular = "blurredR"
        case blurredCurved = "blurredC"
        
        static var allValues: [ClustersPlaceClassName] = [.classicRectangular, .classicCurved,
                                                          .clearRectangular, .clearCurved,
                                                          .blurredRectangular, .blurredCurved]
        static let allKeys: [String] = ["CLUSTERS_PLACE_NAME_SQUARED", "CLUSTERS_PLACE_NAME_CURVED",
                                        "CLUSTERS_PLACE_NAME_CLEAR_SQUARED", "CLUSTERS_PLACE_NAME_CLEAR_CURVED",
                                        "CLUSTERS_PLACE_NAME_BLURRED_SQUARED", "CLUSTERS_PLACE_NAME_BLURRED_CURVED"]
    }
    var clustersPlaceClassName: ClustersPlaceClassName
    var clustersPlaceClassType: ClusterView.Type {
        switch self.clustersPlaceClassName {
        case .classicCurved:
            return ClusterViewClassicCurved.self
        case .classicRectangular:
            return ClusterViewClassicRectangular.self
        case .clearCurved:
            return ClusterViewClearCurved.self
        case .clearRectangular:
            return ClusterViewClearRectangular.self
        case .blurredCurved:
            return ClusterViewBlurredCurved.self
        case .blurredRectangular:
            return ClusterViewBlurredRectangular.self
        }
    }
    var clustersPillarClassType: ClusterPillarView.Type {
        switch self.clustersPlaceClassName {
        case .classicCurved, .clearCurved, .blurredCurved:
            return ClusterPillarViewCurved.self
        case .classicRectangular, .clearRectangular, .blurredRectangular:
            return ClusterPillarViewRectangular.self
        }
    }
    @frozen enum ClusterSearchViewSort: String, Codable, SelectorViewSource {
        case host
        case beginDate
        case login
        case id
        
        static var allKeys: [String] = ["HOST", "CLUSTER_CONNECTED_AT", "LOGIN", "ID"]
        static var allValues: [ClusterSearchViewSort] = [ClusterSearchViewSort.host, ClusterSearchViewSort.beginDate, ClusterSearchViewSort.login, ClusterSearchViewSort.id]
        
        var sortFunction: (IntraClusterLocation, IntraClusterLocation) -> Bool {
            switch self {
            case .host:
                return { $0.host > $1.host }
            case .beginDate:
                return { $0.beginDate < $1.beginDate }
            case .login:
                return { $0.user.login < $1.user.login }
            case .id:
                return { $0.user.id < $1.user.id }
            }
        }
    }
    var clusterSearchViewSort: ClusterSearchViewSort
    var clusterShowCounters: Bool
    var clusterHidePlaceCounter: Bool
    var clusterCounterPreferTakenPlaces: Bool
    
    var eventsWarnSubscription: Bool
    
    var elearningHD: Bool
    
    var graphMixColor: Bool
    var graphPreferDarkTheme: Bool
    
    var trackerShowLocationHistoric: Bool
    
    @frozen enum PeopleListViewControllerSort: String, Codable, SelectorViewSource {
        case createdAt
        case login
        case id
        
        static var allKeys: [String] = ["CREATED_AT", "LOGIN", "ID"]
        static var allValues: [PeopleListViewControllerSort] = [PeopleListViewControllerSort.createdAt, PeopleListViewControllerSort.login, PeopleListViewControllerSort.id]
        
        var sortFunction: (People, People) -> Bool {
            switch self {
            case .createdAt:
                return { $0.createdAt > $1.createdAt }
            case .login:
                return { $0.login < $1.login }
            case .id:
                return { $0.id < $1.id }
            }
        }
    }
    var peopleListViewControllerSort: PeopleListViewControllerSort
    var peopleWarnWhenRemove: Bool
    struct PeopleExtraList {
        let icon: UIImage.Assets
        let color: UIColor
        let name: String
    }
    var peopleExtraList1Available: Bool
    var peopleExtraList1Icon: UIImage.Assets
    var peopleExtraList1Color: DecodableColor
    var peopleExtraList1Name: String
    var peopleExtraList1: PeopleExtraList? {
        if self.peopleExtraList1Available {
            return PeopleExtraList(icon: self.peopleExtraList1Icon, color: self.peopleExtraList1Color.uiColor, name: self.peopleExtraList1Name)
        }
        return nil
    }
    
    var peopleExtraList2Available: Bool
    var peopleExtraList2Icon: UIImage.Assets
    var peopleExtraList2Color: DecodableColor
    var peopleExtraList2Name: String
    var peopleExtraList2: PeopleExtraList? {
        if self.peopleExtraList2Available {
            return PeopleExtraList(icon: self.peopleExtraList2Icon, color: self.peopleExtraList2Color.uiColor, name: self.peopleExtraList2Name)
        }
        return nil
    }
    
    override init() {
        self.depthCloseActivated = true
        self.depthMinimum = 5
        
        self.graphicsBlurPrimary = true
        self.graphicsBlurPrimaryTransition = false
        self.graphicsBlurHeader = true
        self.graphicsUseParallax = true
        self.graphicsParallaxForce = .medium
        self.graphicsTransitionDuration = .durationMedium
        
        self.profilShowLogs = false
        self.profilShowCorrections = false
        self.profilCorrectionsCount = 3
        self.profilShowEvents = true
        self.profilShowPartnerships = true
        
        self.clustersPlaceClassName = .classicCurved
        self.clusterSearchViewSort = .host
        self.clusterShowCounters = true
        self.clusterHidePlaceCounter = false
        self.clusterCounterPreferTakenPlaces = false
        
        self.eventsWarnSubscription = true
        
        self.elearningHD = false
        
        self.graphMixColor = true
        self.graphPreferDarkTheme = false
        
        self.trackerShowLocationHistoric = true
        
        self.peopleListViewControllerSort = .createdAt
        self.peopleWarnWhenRemove = true
        self.peopleExtraList1Available = false
        self.peopleExtraList1Icon = .actionAddFriends
        self.peopleExtraList1Color = .init(color: HomeDesign.gold)
        self.peopleExtraList1Name = "Extra 1"
        self.peopleExtraList2Available = false
        self.peopleExtraList2Icon = .actionAddFriends
        self.peopleExtraList2Color = .init(color: HomeDesign.gold)
        self.peopleExtraList2Name = "Extra 2"
        super.init()
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Self.CodingKeys.self)
        
        self.depthCloseActivated = (try? container.decode(Bool.self, forKey: .depthCloseActivated)) ?? true
        self.depthMinimum = (try? container.decode(Int.self, forKey: .depthMinimum)) ?? 5
        
        self.graphicsBlurPrimary = (try? container.decode(Bool.self, forKey: .graphicsBlurPrimary)) ?? true
        self.graphicsBlurPrimaryTransition = (try? container.decode(Bool.self, forKey: .graphicsBlurPrimaryTransition)) ?? false
        self.graphicsBlurHeader = (try? container.decode(Bool.self, forKey: .graphicsBlurHeader)) ?? true
        self.graphicsUseParallax = (try? container.decode(Bool.self, forKey: .graphicsUseParallax)) ?? true
        self.graphicsParallaxForce = (try? container.decode(ParallaxForce.self, forKey: .graphicsParallaxForce)) ?? .medium
        self.graphicsTransitionDuration = (try? container.decode(GraphicsTransitionDuration.self, forKey: .graphicsTransitionDuration)) ?? .durationMedium
        
        self.profilShowLogs = (try? container.decode(Bool.self, forKey: .profilShowLogs)) ?? false
        self.profilShowCorrections = (try? container.decode(Bool.self, forKey: .profilShowCorrections)) ?? false
        self.profilCorrectionsCount = (try? container.decode(Int.self, forKey: .profilCorrectionsCount)) ?? 3
        self.profilShowEvents = (try? container.decode(Bool.self, forKey: .profilShowEvents)) ?? true
        self.profilShowPartnerships = (try? container.decode(Bool.self, forKey: .profilShowPartnerships)) ?? true
        
        self.clustersPlaceClassName = (try? container.decode(ClustersPlaceClassName.self, forKey: .clustersPlaceClassName)) ?? .classicCurved
        self.clusterSearchViewSort = (try? container.decode(ClusterSearchViewSort.self, forKey: .clusterSearchViewSort)) ?? .host
        self.clusterShowCounters = (try? container.decode(Bool.self, forKey: .clusterShowCounters)) ?? true
        self.clusterHidePlaceCounter = (try? container.decode(Bool.self, forKey: .clusterHidePlaceCounter)) ?? false
        self.clusterCounterPreferTakenPlaces = (try? container.decode(Bool.self, forKey: .clusterCounterPreferTakenPlaces)) ?? false
        
        self.eventsWarnSubscription = (try? container.decode(Bool.self, forKey: .eventsWarnSubscription)) ?? true
        
        self.elearningHD = (try? container.decode(Bool.self, forKey: .elearningHD)) ?? false
        
        self.graphMixColor = (try? container.decode(Bool.self, forKey: .graphMixColor)) ?? true
        self.graphPreferDarkTheme = (try? container.decode(Bool.self, forKey: .graphPreferDarkTheme)) ?? false
        
        self.trackerShowLocationHistoric = (try? container.decode(Bool.self, forKey: .trackerShowLocationHistoric)) ?? true
        
        self.peopleListViewControllerSort = (try? container.decode(PeopleListViewControllerSort.self, forKey: .peopleListViewControllerSort)) ?? .createdAt
        self.peopleWarnWhenRemove = (try? container.decode(Bool.self, forKey: .peopleWarnWhenRemove)) ?? true
        self.peopleExtraList1Available = (try? container.decode(Bool.self, forKey: .peopleExtraList1Available)) ?? false
        self.peopleExtraList1Icon = (try? container.decode(UIImage.Assets.self, forKey: .peopleExtraList1Icon)) ?? .actionAddFriends
        self.peopleExtraList1Color = (try? container.decode(DecodableColor.self, forKey: .peopleExtraList1Color)) ?? .init(color: HomeDesign.gold)
        self.peopleExtraList1Name = (try? container.decode(String.self, forKey: .peopleExtraList1Name)) ?? "Extra 1"
        self.peopleExtraList2Available = (try? container.decode(Bool.self, forKey: .peopleExtraList2Available)) ?? false
        self.peopleExtraList2Icon = (try? container.decode(UIImage.Assets.self, forKey: .peopleExtraList2Icon)) ?? .actionAddFriends
        self.peopleExtraList2Color = (try? container.decode(DecodableColor.self, forKey: .peopleExtraList2Color)) ?? .init(color: HomeDesign.gold)
        self.peopleExtraList2Name = (try? container.decode(String.self, forKey: .peopleExtraList2Name)) ?? "Extra 2"
    }
    
    func save() {
        HomeDefaults.save(self, forKey: .settings)
    }
    func logout() {
        self.peopleExtraList1Available = false
        self.peopleExtraList2Available = false
        
    }
}
