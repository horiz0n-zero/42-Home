
import Foundation
import UIKit

typealias IntraObject = NSObject & Codable

final class IntraUser: IntraObject {
    let id: Int
    let login: String
    let email: String!
    let phone: String!
    let displayname: String
    let correction_point: Int
    let campus_users: ContiguousArray<IntraUserCampus>
    let cursus_users: [IntraUserCursus]
    let projects_users: ContiguousArray<IntraUserProject>
    
    var primaryCampus: IntraUserCampus {
        return self.campus_users.first(where: { $0.is_primary }) ?? self.campus_users[0]
    }
    
    var primaryCursus: IntraUserCursus? {
        if let project = self.projects_users.sorted(by: { $0.createdAtDate > $1.createdAtDate }).first {
            return self.cursus_users.first(where: { project.cursus_ids.contains($0.cursus_id) }) ?? self.cursus_users.last
        }
        return self.cursus_users.last
    }
}

final class IntraUserProject: IntraObject {
    
    let id: Int
    let cursus_ids: [Int]

    let created_at: String!
    lazy var createdAtDate: Date = {
        return Date.fromIntraFormat(self.created_at)
    }()
}

final class IntraUserCursus: IntraObject {
    
    let id: Int
    let cursus_id: Int
    let has_coalition: Bool
    let level: CGFloat
}

final class IntraCampus: IntraObject {
    let id: Int
    let name: String
    let users_count: Int
    let country: String
    let city: String
    let website: String
}

final class IntraUserCampus: IntraObject {
    
    let campus_id: Int
    let is_primary: Bool
    
}

final class IntraCoalition: IntraObject {
    
    let id: Int
    let name: String
    let slug: String
    let image_url: String!
    let cover_url: String!
    let color: String
    lazy var uicolor: UIColor = {
        return UIColor.fromIntra(self.color)
    }()
    let score: Int
}
extension ContiguousArray where Element == IntraCoalition {
    
    
}
