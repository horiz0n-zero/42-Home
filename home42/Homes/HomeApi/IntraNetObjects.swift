// home42/IntraNetObject.swift
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

extension HomeApi {
    
    static var cookies: Cookies!
  
    @frozen enum IntranetRoute {
        /// login, cursus_id, campus_id
        case graph
        /// param: login
        case locationStats(String)
        /// param: slug? -> 42cursus-computorv1
        /// team_id: 3808002, start: 2021-10-04, end: 2021-10-11
        case defenseSlots(String)
        /// team_id: oldTeamId
        case defense(String)
        /// param: slug, base64One, base64Two
        /// team_id:
        case getSlot(String, String, String)

        var path: String {
            switch self {
            case .graph:
                return "https://projects.intra.42.fr/project_data.json"
            case .locationStats(let login):
                return "https://profile.intra.42.fr/users/\(login)/locations_stats.json"
            case .defenseSlots(let slug):
                return "https://projects.intra.42.fr/projects/\(slug)/slots.json"
            case .defense(let slug):
                return "https://projects.intra.42.fr/projects/\(slug)/slots"
            case .getSlot(let slug, let ids, let teamId):
                return "https://projects.intra.42.fr/projects/\(slug)/slots/\(ids).json?team_id=\(teamId)"
            }
        }
        var method: String {
            switch self {
            case .getSlot(_, _, _):
                return "POST"
            default:
                return "GET"
            }
        }
    }
    
    static func intranetRequest<G: Codable>(_ route: IntranetRoute, parameters: [String: Any]? = nil) async throws -> G {
        var request: URLRequest
        var components: URLComponents!
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?.?.?"
        var ret: DataTaskAsyncReturnType!
        let serverErrorMessage: String
        let method = route.method
        
        if HomeApi.cookies.requiredUpdate {
            HomeApi.cookies = try await Cookies.refreshRequiredCookies()
            HomeDefaults.save(HomeApi.cookies, forKey: .cookies)
        }
        if let parameters = parameters {
            if method == "POST", let body = try? JSONSerialization.data(withJSONObject: parameters, options: .fragmentsAllowed) {
                request = URLRequest(url: route.path.url, timeoutInterval: HomeApi.timeOut)
                request.httpBody = body
            }
            else {
                components = URLComponents(string: route.path)
                components.queryItems = parameters.map({ URLQueryItem.init(name: $0.key, value: "\($0.value)") })
                request = URLRequest(url: components.url!, timeoutInterval: HomeApi.timeOut)
            }
        }
        else {
            request = URLRequest(url: route.path.url, timeoutInterval: HomeApi.timeOut)
        }
        request.httpMethod = method
        #if DEBUG
        print(HomeApi.cookies.intraSessionProduction!, method, route.path, parameters ?? "[:]")
        request.setValue("42Home \(appVersion)beta", forHTTPHeaderField: "User-Agent")
        #else
        request.setValue("42Home \(appVersion)", forHTTPHeaderField: "User-Agent")
        #endif
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(HomeApi.cookies.intraSessionProduction!, forHTTPHeaderField: "Cookie")
        do {
            ret = try await URLSession.init(configuration: URLSessionConfiguration.ephemeral).data(for: request, delegate: nil)
            if (200 ... 299).contains((ret.response as! HTTPURLResponse).statusCode) {
                do {
                    return try JSONDecoder.decoder.decode(G.self, from: ret.data)
                }
                catch {
                    throw HomeApi.RequestError(decodingError: error as! DecodingError, status: .code((ret.response as! HTTPURLResponse).statusCode),
                                               path: route.path, data: ret.data, parameters: parameters)
                }
            }
            else {
                serverErrorMessage = ret != nil ? String(data: ret.data, encoding: .utf8)! : "no serveur message received"
                throw HomeApi.RequestError(status: .code((ret.response as! HTTPURLResponse).statusCode), path: route.path, data: ret.data,
                                           parameters: parameters, serverMessage: serverErrorMessage)
            }
        }
        catch {
            if error is HomeApi.RequestError {
                throw error
            }
            throw HomeApi.RequestError(status: .internal, path: route.path, data: ret?.data, parameters: parameters, serverMessage: error.localizedDescription)
        }
    }
}

final class IntraNetGraphProject: IntraObject {
    
    @frozen enum State: String, Codable {
        case unavailable
        case available
        case done
        case fail
        case inProgress = "in_progress"
        case notRecommended = "not_recommended"
    }
    @frozen enum Kind: String, Codable {
        case project
        case piscine
        case exam
        case partTime = "part_time"
        case bigProject = "big_project"
        case secondInternship = "second_internship"
        case firstInternship = "first_internship"
        case rush
    }
    
    let state: State
    var stateText: String {
        switch self.state {
        case .done, .fail:
            if let mark = self.finalMark {
                return "\(mark)"
            }
            return "100"
        case .unavailable:
            return ~"general.unavailable"
        case .available:
            return ~"general.available"
        case .inProgress:
            return ~"project.status.in-progress"
        case .notRecommended:
            return ~"project.status.not-recommended"
        }
    }
    var stateColor: UIColor {
        switch self.state {
        case .done:
            if self.finalMark != nil && self.finalMark >= 75 {
                return self.finalMark == 125 ? HomeDesign.gold : HomeDesign.greenSuccess
            }
            return HomeDesign.redError
        case .unavailable, .fail:
            return HomeDesign.redError
        case .inProgress, .available, .notRecommended:
            return HomeDesign.blueAccess
        }
    }
    let finalMark: Int!
    let id: Int
    let projectId: Int
    let rules: String!
    let kind: Kind
    let name: String
    let projectDescription: String
    let difficulty: Int
    let duration: String!
    
    let x: CGFloat
    let y: CGFloat
    final class Line: IntraObject {
        let parent_id: Int
        var points: [[CGFloat]]
    }
    let by: [Line]

    @frozen private enum CodingKeys: String, CodingKey {
        case state = "state"
        case finalMark = "final_mark"
        case id = "id"
        case projectId = "project_id"
        case rules = "rules"
        case kind = "kind"
        case name = "name"
        case projectDescription = "description"
        case difficulty = "difficulty"
        case duration = "duration"
        case x = "x"
        case y = "y"
        case by = "by"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: IntraNetGraphProject.CodingKeys.self)
        
        self.state = try container.decode(IntraNetGraphProject.State.self, forKey: .state)
        self.finalMark = try container.decodeIfPresent(Int.self, forKey: .finalMark)
        self.id = try container.decode(Int.self, forKey: .id)
        self.projectId = try container.decode(Int.self, forKey: .projectId)
        self.rules = try container.decodeIfPresent(String.self, forKey: .rules)
        self.kind = try container.decode(IntraNetGraphProject.Kind.self, forKey: .kind)
        self.name = try container.decode(String.self, forKey: .name)
        self.projectDescription = (try? container.decodeIfPresent(String.self, forKey: .projectDescription)) ?? ""
        self.difficulty = (try? container.decode(Int.self, forKey: .difficulty)) ?? 0
        self.duration = try container.decodeIfPresent(String.self, forKey: .duration)
        self.x = try container.decode(CGFloat.self, forKey: .x)
        self.y = try container.decode(CGFloat.self, forKey: .y)
        self.by = try container.decode([IntraNetGraphProject.Line].self, forKey: .by)
    }
}

final class IntraNetSlot: IntraObject {
    
    let ids: String
    var splitedIds: [String] {
        return self.ids.split(separator: ",").map({ String($0) })
    }
    let id: String
    let start: String
    lazy var startAtDate: Date = {
        return Date.fromIntraNetFormat(self.start)
    }()
    let end: String
    lazy var endAtDate: Date = {
        return Date.fromIntraNetFormat(self.start)
    }()
    let title: String

    func idsWith(duration: Int) -> String {
        var splited = self.splitedIds
        
        if duration >= splited.count {
            return self.ids
        }
        splited.removeLast(splited.count - duration)
        return splited.joined(separator: ",")
    }
}
