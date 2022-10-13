// home42/IntraObject.swift
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
import SwiftDate

typealias IntraObject = NSObject & Codable

final class IntraUserInfo: IntraObject {
    
    let id: Int
    let login: String
    let image: IntraUser.Image
    
    init(id: Int, login: String, image: IntraUser.Image) {
        self.id = id
        self.login = login
        self.image = image
        super.init()
    }
    
    static func ==(lhs: IntraUserInfo, rhs: IntraUserInfo) -> Bool {
        return lhs.id == rhs.id
    }
    override func isEqual(_ object: Any?) -> Bool {
        return (object as! IntraUserInfo).id == self.id
    }
}

final class IntraUser: IntraObject {
    
    let id: Int
    let login: String
    let email: String!
    let phone: String!
    let displayname: String
    var correction_point: Int
    let location: String!
    let wallet: Int
    let pool_month: String!
    let pool_year: String!
    let titles_users: ContiguousArray<IntraTitleUser>
    let titles: ContiguousArray<IntraTitle>
    let cursus_users: [IntraUserCursus]
    let achievements: ContiguousArray<IntraUserAchievement>
    let expertises_users: ContiguousArray<IntraUserExpertise>
    let languages_users: ContiguousArray<IntraLanguageUser>
    let groups: [IntraGroup]
    let projects_users: ContiguousArray<IntraUserProject>
    let campus: ContiguousArray<IntraCampus>
    let campus_users: ContiguousArray<IntraUserCampus>
    let partnerships: ContiguousArray<IntraUserPartnership>
    let patroned: ContiguousArray<IntraPatron>
    let patroning: ContiguousArray<IntraPatron>
    let image: IntraUser.Image
    
    final class Image: IntraObject {
        let link: String!
        let versions: IntraUser.Image.Versions
        
        struct Versions: Codable {
            let large: String!
            let medium: String!
            let micro: String!
            let small: String!
        }
        
        var url: String {
            switch App.settings.cacheProfilQuality {
            case .small where self.versions.small != nil:
                return self.versions.small
            case .large where self.versions.large != nil:
                return self.versions.large
            case .medium where self.versions.medium != nil:
                return self.versions.medium
            case .micro where self.versions.micro != nil:
                return self.versions.micro
            default:
                return self.link
            }
        }
        var isValid: Bool {
            return self.link != nil && self.versions.small != nil
        }
    }
    
    var primaryCampus: IntraUserCampus {
        return self.campus_users.first(where: { $0.is_primary }) ?? self.campus_users[0]
    }
    
    func campus(forUserCampusId id: Int) -> IntraCampus {
        return self.campus.first(where: { $0.id == id })!
    }
    
    var primaryCursus: IntraUserCursus? {
        if let project = self.projects_users.sorted(by: { $0.createdAtDate > $1.createdAtDate }).first {
            return self.cursus_users.first(where: { project.cursus_ids.contains($0.cursus_id) }) ?? self.cursus_users.last
        }
        return self.cursus_users.last
    }
    
    var tags: [IntraGroup]? {
        if self.groups.count > 0 {
            if let contributorsGroups = HomeApiResources.contributors[self.login]?.groups {
                var newGroups = contributorsGroups.map({ IntraGroup($0) })
                
                newGroups.append(contentsOf: self.groups)
                return newGroups
            }
            return self.groups
        }
        if let groups = HomeApiResources.contributors[self.login]?.groups.map({ IntraGroup($0) }) {
            return groups
        }
        return nil
    }
}

final class IntraPatron: IntraObject {
    let id: Int
    let created_at: String
    lazy var createdAtDate: Date = {
        return Date.fromIntraFormat(self.created_at)
    }()
    let user_id: Int
    let godfather_id: Int
    let ongoing: Bool
}

final class IntraCampus: IntraObject {
    let id: Int
    let name: String
    let users_count: Int
    let country: String
    let city: String
    let website: String
}

final class IntraUserPartnership: IntraObject {
    let id: Int
    let name: String
    let difficulty: Int
    let partnerships_skills: [PartnershipSkill]
    
    final class PartnershipSkill: IntraObject {
        let id: Int
        let skill_id: Int
        let value: CGFloat
    }
}

final class IntraLanguage: IntraObject {
    let id: Int
    let name: String
    let identifier: String
    
    @available(*, unavailable, message: """
                Doesn't work; don't use this or fix the issue.
                The intra return Language Code not Region Code;
                the function work with Region Code; Catalan or JA identifier doesn't return the right flag.
                """)
    var countryFlag: String {
        let flagBase = UnicodeScalar("🇦").value - UnicodeScalar("A").value
        let prefix = self.identifier.prefix(2) // split('_').last
        let flag = prefix.uppercased().unicodeScalars.compactMap({ UnicodeScalar(flagBase + $0.value)?.description }).joined()
        
        return flag
    }
}

final class IntraLanguageUser: IntraObject {
    let language_id: Int
    let position: Int
    
    var language: IntraLanguage {
        return HomeApiResources.languages.first(where: { $0.id == self.language_id }) ?? HomeApiResources.languages[0]
    }
}

final class IntraTitleUser: IntraObject {
    let id: Int
    let selected: Bool
    let title_id: Int
}

final class IntraTitle: IntraObject {
    let id: Int
    let name: String
}

final class IntraUserCampus: IntraObject {
    
    let campus_id: Int
    let is_primary: Bool
    
    var localCampus: IntraCampus? {
        for campus in HomeApiResources.campus where campus.id == self.campus_id {
            return campus
        }
        return nil
    }
    
    init(campus: IntraCampus) {
        self.campus_id = campus.id
        self.is_primary = true
        super.init()
    }
}

final class IntraUserProject: IntraObject {
    
    let id: Int
    let current_team_id: Int!
    let cursus_ids: [Int]
    let project: ProjectInfo
    final class ProjectInfo: IntraObject {
        let parent_id: Int!
        let id: Int
        let slug: String
        let name: String
    }
    let final_mark: Int!
    let occurrence: Int
    @frozen enum Status: String, Codable, CaseIterable {
        case inProgress           = "in_progress"
        case creatingGroup        = "creating_group"
        case searchingGroup       = "searching_a_group"
        case finished             = "finished"
        case waitingToStart       = "waiting_to_start"
        case waitingForCorrection = "waiting_for_correction"
        case parent               = "parent"
        
        var priority: Int {
            switch self {
            case .waitingForCorrection:
                return 1
            case .inProgress:
                return 2
            case .creatingGroup, .searchingGroup, .waitingToStart:
                return 3
            case .finished, .parent:
                return 4
            }
        }
        var key: String {
            switch self {
            case .waitingForCorrection, .waitingToStart:
                return "project.status.waiting"
            case .creatingGroup:
                return "project.status.group.creating"
            case .searchingGroup:
                return "project.status.group.searching"
            case .inProgress:
                return "project.status.in-progress"
            case .finished, .parent:
                return "project.status.ended"
            }
        }
    }
    let status: IntraUserProject.Status
    let marked: Bool
    let created_at: String!
    lazy var createdAtDate: Date = {
        return self.created_at == nil ? Date() : Date.fromIntraFormat(self.created_at)
    }()
    let marked_at: String!
    lazy var markedAtDate: Date = {
        return Date.fromIntraFormat(self.marked_at)
    }()
    
    var markColor: UIColor {
        switch self.status {
        case .parent, .creatingGroup, .inProgress, .searchingGroup, .waitingForCorrection:
                return HomeDesign.blueAccess
        default:
            return IntraUserProject.finalMarkColor(self.final_mark ?? 100)
        }
    }
    
    static func finalMarkColor(_ mark: Int) -> UIColor {
        switch mark {
        case 0 ..< 75:
            return HomeDesign.redError
        case 75 ... 124:
            return HomeDesign.greenSuccess
        default:
            return HomeDesign.gold
        }
    }
}

final class IntraProject: IntraObject {
    
    let id: Int
    let name: String
    // let slug: String
    // let parent_id: Int!
    let exam: Bool
    let parent: IntraProjectInfo?
    
    let cursus: ContiguousArray<IntraCursus>
    let skills: ContiguousArray<IntraSkill>!
    // let videos: [IntraUser] empty...
    let children: ContiguousArray<IntraProjectInfo>
    var childrenProjects: ContiguousArray<IntraProject> {
        var projects = ContiguousArray<IntraProject>()
        
        projects.reserveCapacity(self.children.count)
        for child in self.children {
            for project in HomeApiResources.projects where project.id == child.id {
                projects.append(project)
                break
            }
        }
        return projects
    }
    // let attachments: [IntraUser] empty...
    let project_sessions: [IntraProjectSession]
}

final class IntraProjectInfo: IntraObject {
    
    let id: Int
    // let slug: String
    let name: String
}

final class IntraProjectSession: IntraObject {
    
    let id: Int
    let max_people: Int!
    let solo: Bool!
    // let project_id: Int
    let difficulty: Int!
    let cursus_id: Int!
    let campus_id: Int!
    //let is_subscriptable: Bool
    let scales: [IntraProjectSessionScale]
}

final class IntraProjectSessionScale: IntraObject {
    
    let id: Int
    let correction_number: Int
    let is_primary: Bool
}

final class IntraGroup: IntraObject {
    
    let id: Int
    //let kind: String!
    let name: String
    
    init(_ contributorGroup: HomeApiResources.Contributor.Group) {
        self.id = -1
        //self.kind = nil
        self.name = contributorGroup
        super.init()
    }
    
    var isLocal: Bool {
        return self.id == -1
    }
    var color: UIColor {
        if self.isLocal {
            return HomeDesign.gold
        }
        return HomeDesign.black
    }
    var textColor: UIColor {
        return HomeDesign.white
    }
}

final class IntraUserExpertise: IntraObject {
    
    let expertise_id: Int
    let value: Int
}

final class IntraExpertise: IntraObject {
    
    let id: Int
    let kind: String
    let name: String
}

final class IntraUserAchievement: IntraObject {
    
    let id: Int
    let achievementDescription: String
    let image: String!
    let name: String
    let nbr_of_success: Int!
    let visible: Bool
    
    var image_url: String {
        return "https://cdn.intra.42.fr/" + self.image.replacingOccurrences(of: "/uploads/", with: "")
    }
    
    @frozen enum CodingKeys: String, CodingKey {
        case id = "id"
        case achievementDescription = "description"
        case image = "image"
        case name = "name"
        case nbr_of_success = "nbr_of_success"
        case visible = "visible"
    }
}

final class IntraUserCursus: IntraObject {
    
    let id: Int
    let cursus_id: Int
    let has_coalition: Bool
    let level: CGFloat
    let cursus: IntraCursus
    let skills: [IntraUserSkill]
    let blackholed_at: String!
    lazy var blackholedAt: Date? = {
        return self.blackholed_at == nil ? nil : Date.fromIntraFormat(self.blackholed_at)
    }()
}

final class IntraCursus: IntraObject {
    
    let id: Int
    let name: String
    // let slug: String
}

final class IntraSkill: IntraObject {
    
    let id: Int
    let name: String
}

final class IntraUserSkill: IntraObject {
    
    let id: Int
    let level: CGFloat
    let name: String
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
    
    func primaryCoalition(campus: IntraUserCampus, cursus: IntraUserCursus) -> IntraCoalition? {
        if let bloc = HomeApiResources.blocs.first(where: { $0.campus_id == campus.campus_id && $0.cursus_id == cursus.cursus_id }) {
            return self.first(where: { coalition in
                bloc.coalitions.contains(where: { blocCoalition in blocCoalition.id == coalition.id })
            })
        }
        return nil
    }
}

final class IntraEvent: IntraObject {
    
    let id: Int
    let begin_at: String
    lazy var beginDate: Date = {
        return Date.fromIntraFormat(self.begin_at)
    }()
    let end_at: String
    lazy var endDate: Date = {
        return Date.fromIntraFormat(self.end_at)
    }()
    @frozen enum Kind: String, Codable {
        case exam = "exam"
        case association = "association"
        case speedWorking = "speed_working"
        case conference = "conference"
        case event = "event"
        case workshop = "workshop"
        case challenge = "challenge"
        case hackathon = "hackathon"
        case pedago = "pedago"
        case meet = "meet"
        case meetUp = "meet_up"
        case piscine = "piscine"
        case extern = "extern"
        case partnership = "partnership"
        case other = "other"
    }
    let kind: IntraEvent.Kind
    lazy var kindKey: String = {
        switch self.kind {
        case .exam:
            return "event.kind.exam"
        case .association:
            return "event.kind.asso"
        case .speedWorking:
            return "event.kind.speedworking"
        case .conference:
            return "event.kind.conference"
        case .event:
            return "event.kind.event"
        case .workshop:
            return "event.kind.workshop"
        case .challenge:
            return "event.kind.challenge"
        case .hackathon:
            return "event.kind.hackathon"
        case .pedago:
            return "event.kind.pedago"
        case .meet:
            return "event.kind.meet"
        case .meetUp:
            return "event.kind.meet-up"
        case .piscine:
            return "general.piscine"
        case .extern:
            return "event.kind.extern"
        case .partnership:
            return "event.kind.partnership"
        case .other:
            return "event.kind.other"
        }
    }()
    lazy var uicolor: UIColor = {
        switch self.kind {
        case .exam, .hackathon, .piscine:
            return HomeDesign.eventColorT1
        case .association:
            return HomeDesign.eventColorT5
        case .speedWorking, .workshop:
            return HomeDesign.eventColorT2
        case .conference, .pedago:
            return HomeDesign.eventColorT7
        case .event, .other, .extern:
            return HomeDesign.eventColorT9
        case .partnership:
            return HomeDesign.eventColorT8
        case .challenge:
            return HomeDesign.eventColorT0
        case .meet, .meetUp:
            return HomeDesign.eventColorT4
        }
    }()
    let location: String!
    let max_people: Int!
    let nbr_subscribers: Int
    let name: String
    let eventDescription: String
    
    var canSubscribe: Bool {
        return self.max_people == nil || self.nbr_subscribers < self.max_people
    }
    
    @frozen enum CodingKeys: String, CodingKey {
        case id = "id"
        case begin_at = "begin_at"
        case end_at = "end_at"
        case kind = "kind"
        case location = "location"
        case max_people = "max_people"
        case nbr_subscribers = "nbr_subscribers"
        case name = "name"
        case eventDescription = "description"
    }
}

final class IntraUserEvent: IntraObject {
    
    let event_id: Int
    let id: Int
    let event: IntraEvent
}

final class IntraBlock: IntraObject {
    
    let id: Int
    let campus_id: Int
    let cursus_id: Int
    // let squad_size: Int
    var coalitions: [IntraCoalition]
}

final class IntraScaleTeam: IntraObject {
    
    let id: Int
    let comment: String!
    let feedback: String!
    let feedbacks: [IntraScaleTeamFeedback]!
    let correcteds: [IntraUserInfo]
    let corrector: IntraUserInfo!
    let final_mark: Int!
    let flag: IntraScaleTeamFlag!
    let team: IntraScaleTeamInfo
    let begin_at: String
    lazy var beginAtDate: Date = {
        return Date.fromIntraFormat(self.begin_at)
    }()
    let filled_at: String!
    lazy var filledAtDate: Date = {
        return Date.fromIntraFormat(self.filled_at)
    }()
    
    var associatedProject: IntraProject? {
        return HomeApiResources.projects.first(where: { $0.id == self.team.project_id })
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case comment
        case feedback
        case feedbacks
        case correcteds
        case corrector
        case final_mark
        case flag
        case team
        case begin_at
        case filled_at
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: IntraScaleTeam.CodingKeys.self)
        
        self.id = try container.decode(Int.self, forKey: .id)
        self.comment = try container.decodeIfPresent(String.self, forKey: .comment)
        self.feedback = try container.decodeIfPresent(String.self, forKey: .feedback)
        self.feedbacks = try container.decodeIfPresent([IntraScaleTeamFeedback].self, forKey: .feedbacks)
        self.correcteds = try container.decode([IntraUserInfo].self, forKey: .correcteds)
        if let _ = try? container.decode(String.self, forKey: .corrector) {
            self.corrector = nil
        }
        else {
            self.corrector = try container.decode(IntraUserInfo.self, forKey: .corrector)
        }
        self.final_mark = try container.decodeIfPresent(Int.self, forKey: .final_mark)
        self.flag = try container.decodeIfPresent(IntraScaleTeamFlag.self, forKey: .flag)
        self.team = try container.decode(IntraScaleTeamInfo.self, forKey: .team)
        self.begin_at = try container.decode(String.self, forKey: .begin_at)
        self.filled_at = try container.decodeIfPresent(String.self, forKey: .filled_at)
    }
}

final class IntraScaleTeamFlag: IntraObject {
    
    let id: Int
    let name: String
    let positive: Bool
}

final class IntraScaleTeamInfo: IntraObject {
    
    let id: Int
    let project_session_id: Int
    let project_id: Int
    let name: String
    let status: String
}

final class IntraScaleTeamFeedback: IntraObject {
    let rating: Int
    let comment: String
}

final class IntraProjectSlot: IntraObject {
    
    let id: Int
    let begin_at: String
    lazy var beginDate: Date = {
        return Date.fromIntraFormat(self.begin_at)
    }()
    let end_at: String!
    lazy var endDate: Date = {
        return Date.fromIntraFormat(self.end_at)
    }()
    let scale_team: IntraScaleTeam!
    let user: String
}

final class IntraClusterLocation: IntraObject {
    
    let host: String
    let begin_at: String
    lazy var beginDate: Date = {
        return Date.fromIntraFormat(self.begin_at)
    }()
    let end_at: String!
    lazy var endDate: Date = {
        return Date.fromIntraFormat(self.end_at)
    }()
    let user: IntraUserInfo
    
    override var hash: Int {
        return self.host.hashValue
    }
    override func isEqual(_ object: Any?) -> Bool {
        return (object as! Self).host == self.host
    }
}

final class IntraEvaluationPointHistoric: IntraObject {
    
    let id: Int
    let scale_team_id: Int!
    let reason: String
    let created_at: String
    lazy var createdAtDate: Date = {
        return Date.fromIntraFormat(self.created_at)
    }()
    let total: Int
    let sum: Int
}

final class IntraNotion: IntraObject {
    
    let id: Int
    let name: String
    let slug: String
    final class IntraSubnotion: IntraObject {
        let id: Int
        let name: String
        let slug: String
    }
    let subnotions: [IntraSubnotion]
    final class IntraTag: IntraObject {
        let id: Int
        let name: String
        let kind: String
    }
    let tags: [IntraTag]
}

class IntraAttachment: IntraObject {
    
    @frozen enum AttachmentType: String, Codable {
        case video = "Video"
        case pdf = "Pdf"
        case link = "Link"
        
        var key: String {
            switch self {
            case .video:
                return "general.video"
            case .pdf:
                return "general.pdf"
            case .link:
                return "general.link"
            }
        }
    }
    
    let id: Int
    let type: IntraAttachment.AttachmentType
    let name: String
    
    @frozen enum CodingKeys: String, CodingKey {
        case id
        case name
        case type
    }
    @frozen enum CodingKeysOther: String, CodingKey {
        case title = "title"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: IntraAttachment.CodingKeys.self)
        
        self.id = try container.decode(Int.self, forKey: .id)
        self.type = try container.decode(IntraAttachment.AttachmentType.self, forKey: .type)
        if let name = try? container.decode(String.self, forKey: .name) {
            self.name = name
        }
        else {
            self.name = try decoder.container(keyedBy: IntraAttachment.CodingKeysOther.self).decode(String.self, forKey: .title)
        }
        super.init()
    }
}

final class IntraVideoAttachment: IntraAttachment {
    
    final class VideoUrl: IntraObject {
        let low_d: String
        let high_d: String?
        let thumbs: [String]
        let url: String
    }
    let duration: CGFloat
    let videoUrls: VideoUrl
    var videoUrl: String {
        if App.settings.elearningHD && self.videoUrls.high_d != nil {
            return self.videoUrls.high_d!
        }
        return self.videoUrls.low_d
    }
    
    @frozen private enum CodingKeys: String, CodingKey {
        case duration = "duration"
        case videoUrls = "urls"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: IntraVideoAttachment.CodingKeys.self)
        
        self.duration = try container.decode(CGFloat.self, forKey: .duration)
        self.videoUrls = try container.decode(IntraVideoAttachment.VideoUrl.self, forKey: .videoUrls)
        try super.init(from: decoder)
    }
}
final class IntraPDFAttachment: IntraAttachment {
    
    let url: String
    let thumb_url: String
    
    var pdfUrl: URL? {
        return URL(string: "https://cdn.intra.42.fr" + self.url.replacingOccurrences(of: "/uploads", with: ""))
    }
    
    @frozen private enum CodingKeys: String, CodingKey {
        case url = "url"
        case thumb_url = "thumb_url"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: IntraPDFAttachment.CodingKeys.self)
        
        self.url = try container.decode(String.self, forKey: .url)
        self.thumb_url = try container.decode(String.self, forKey: .thumb_url)
        try super.init(from: decoder)
    }
}
final class IntraLinkAttachment: IntraAttachment {
    
    let url: String
    
    @frozen private enum CodingKeys: String, CodingKey {
        case url = "url"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: IntraLinkAttachment.CodingKeys.self)
        
        self.url = try container.decode(String.self, forKey: .url)
        try super.init(from: decoder)
    }
}

final class IntraSubnotion: IntraObject {
    
    let id: Int
    let name: String
    let attachments: [IntraAttachment]
    
    @frozen private enum CodingKeys: String, CodingKey {
        case id
        case name
        case attachments
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: IntraSubnotion.CodingKeys.self)
        var attachmentsUnkeyedContainer = try container.nestedUnkeyedContainer(forKey: .attachments)
        var attachmentsUnkeyedContainerArray = attachmentsUnkeyedContainer
        var attachments: [IntraAttachment] = []
        
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        
        if let count = attachmentsUnkeyedContainer.count {
            attachments.reserveCapacity(count)
            while !attachmentsUnkeyedContainer.isAtEnd {
                switch try attachmentsUnkeyedContainer.nestedContainer(keyedBy: IntraAttachment.CodingKeys.self).decode(IntraAttachment.AttachmentType.self, forKey: .type) {
                case .video:
                    attachments.append(try attachmentsUnkeyedContainerArray.decode(IntraVideoAttachment.self))
                case .pdf:
                    attachments.append(try attachmentsUnkeyedContainerArray.decode(IntraPDFAttachment.self))
                case .link:
                    attachments.append(try attachmentsUnkeyedContainerArray.decode(IntraLinkAttachment.self))
                }
            }
        }
        self.attachments = attachments
    }
}

final class IntraOffer: IntraObject {
    
    let id: Int
    let title: String
    let little_description: String
    let created_at: String
    lazy var createdAtDate: Date = {
        return Date.fromIntraFormat(self.created_at)
    }()
    let salary: String
    
    @frozen enum ContractType: String, Codable {
        case stage
        case freelance
        case cdi
        case cdi_partiel
        case cdd
        case cdd_partiel
        case apprentice_ship
        case stage_partiel
        
        var key: String {
            switch self {
            case .stage:
                return "contract.type.stage"
            case .freelance:
                return "contract.type.freelance"
            case .cdi:
                return "contract.type.cdi"
            case .cdi_partiel:
                return "contract.type.cdi-partiel"
            case .cdd:
                return "contract.type.cdd"
            case .cdd_partiel:
                return "contract.type.cdd-partiel"
            case .apprentice_ship:
                return "contract.type.apprentice-ship"
            case .stage_partiel:
                return "contract.type.stage-partiel"
            }
        }
    }
    
    let contract_type: ContractType
    // let company_id: Int
    let full_address: String
    let big_description: String
    let email: String
    
    var intraUrl: URL {
        return URL(string: "https://companies.intra.42.fr/en/offers/\(self.id)")!
    }
}

final class IntraProduct: IntraObject {
    
    let id: Int
    let name: String
    let productDescription: String
    let price: Int
    let quantity: Int!
    let is_unic: Bool!
    let image: String
    var imageUrl: String {
        return "https://cdn.intra.42.fr/\(self.image.replacingOccurrences(of: "/uploads/", with: ""))"
    }
    
    @frozen private enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case productDescription = "description"
        case price = "price"
        case quantity = "quantity"
        case is_unic = "is_uniq"
        case image = "image"
    }
    @frozen private enum ImageCodingKeys: String, CodingKey {
        case url
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: IntraProduct.CodingKeys.self)
        
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.productDescription = try container.decode(String.self, forKey: .productDescription)
        self.price = try container.decode(Int.self, forKey: .price)
        self.quantity = try container.decodeIfPresent(Int.self, forKey: .price)
        self.is_unic = try container.decodeIfPresent(Bool.self, forKey: .is_unic)
        self.image = try container.nestedContainer(keyedBy: IntraProduct.ImageCodingKeys.self,
                                                   forKey: .image).decode(String.self, forKey: .url)
    }
}

final class IntraFeedback: IntraObject {
    
    @frozen enum FeedbackableType: String, Codable {
        case event = "Event"
    }
    
    let id: Int
    let feedbackable_id: Int // parent? /X/feedbackable_id/feedback
    let feedbackable_type: FeedbackableType
    let rating: Int
    var ratingColor: UIColor {
        switch self.rating {
        case 0 ... 2:
            return HomeDesign.redError
        case 3:
            return HomeDesign.blueAccess
        default:
            return HomeDesign.greenSuccess
        }
    }
    let created_at: String
    lazy var createdAtDate: Date = {
        return Date.fromIntraFormat(self.created_at)
    }()
    let feedback_details: [IntraFeedbackDetail]
    let comment: String
    let user: IntraUserInfo
    
    final class IntraFeedbackDetail: IntraObject {
        @frozen enum Kind: String, Codable {
            case pertinent
            case quality
            case interesting
            case accuracy
        }
        let id: Int
        let kind: IntraFeedbackDetail.Kind
        let rate: Int
    }
}

final class IntraTokenInformation: IntraObject {
    
    let resource_owner_id: Int?
    let scopes: [String]
    let expires_in_seconds: Int
}
