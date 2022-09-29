import Foundation
import SwiftUI
import WidgetKit

final class HomeWidgets: NSObject {
    
    @frozen enum Kind: String {
        case events = "widgetEvents"
        case clusterPeoples = "widgetClusterPeoples"
        case corrections = "widgetCorrections"
        
        var displayName: String {
            switch self {
            case .events:
                return "Evenements"
            case .clusterPeoples:
                return "Cluster"
            case .corrections:
                return "Corrections"
            }
        }
        var description: String {
            switch self {
            case .events:
                return "Evenement souscrit et a venir"
            case .clusterPeoples:
                return "Cluster desc"
            case .corrections:
                return "Corrections desc"
            }
        }
        var families: [WidgetFamily] {
            switch self {
            case .events:
                return [.systemMedium]
            case .clusterPeoples:
                return [.systemMedium]
            case .corrections:
                return [.systemMedium]
            }
        }
    }
    
    static var document: URL = {
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.horiz0n-zero.home42")!
    }()
    
    static var coalitionBackground: UIImage {
        return UIImage.Assets.coalitionDefaultBackground.image/*
        guard let user: IntraUser = HomeDefaults.read(.user),
              let coalitions: ContiguousArray<IntraCoalition> = HomeDefaults.read(.coalitions),
              let campus = user.primaryCampus, let cursus = user.primaryCursus,
              let coalition = coalitions.primaryCoalition(campus: campus, cursus: cursus) else {
            return UIImage.Assets.coalitionDefaultBackground.image
        }
        let imageUrl = Self.document.appendingPathComponent("images/coalitions/\(coalition.slug)")
        do {
            let data = try Data(contentsOf: imageUrl)
            
            return UIImage(data: data)!
        }
        catch {
            return UIImage.Assets.coalitionDefaultBackground.image
        }*/
    }
}
