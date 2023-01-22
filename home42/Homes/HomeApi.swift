// home42/HomeApi.swift
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
import SwiftUI
import Swift
import _Concurrency
import SwiftDate

final class HomeApi: NSObject {
    
    static private let uid: String =           "CLIENT_ID"
    static private let secret: String =        "CLIENT_SECRET"
    static private let redirectURI: String =   "https://intra.42.fr"
    static private let scope: String =         "public+forum+projects+profile+elearning+tig"
    static private let authorizePath: String = "https://api.intra.42.fr/oauth/authorize?client_id=%@&redirect_uri=%@&response_type=code&scope=%@"
    static let oauthAuthorizePath: String = {
        return String(format: HomeApi.authorizePath, HomeApi.uid, HomeApi.redirectURI, HomeApi.scope)
    }()

    static let timeOut: TimeInterval = 20
    
    static let urlSession: URLSession = {
        let config = URLSessionConfiguration.ephemeral
        
        config.networkServiceType = .responsiveData
        config.allowsCellularAccess = true
        config.timeoutIntervalForRequest = HomeApi.timeOut
        config.timeoutIntervalForResource = HomeApi.timeOut
        return URLSession.init(configuration: config, delegate: nil, delegateQueue: nil)
    }()

    static private func urlRequest(method: String, path: String, params: [String: Any]?) -> URLRequest {
        var request: URLRequest
        var components: URLComponents!
            
        if let parameters = params {
            components = URLComponents(string: path)
            components.queryItems = parameters.map({ URLQueryItem.init(name: $0.key, value: "\($0.value)") })
            request = URLRequest(url: components.url!, timeoutInterval: HomeApi.timeOut)
        }
        else {
            request = path.request
        }
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(HomeApi.tokens.access, forHTTPHeaderField: "Authorization")
        // request.setValue("true", forHTTPHeaderField: "http_x_atom") // HTTP X Atom
        return request
    }
    
    static private func urlRequestWithBody(method: String, path: String, params: [String: Any]?) -> URLRequest {
        var request: URLRequest = path.request
        
        if let parameters = params, let body = try? JSONSerialization.data(withJSONObject: parameters, options: .fragmentsAllowed) {
            request.httpBody = body
        }
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(HomeApi.tokens.access, forHTTPHeaderField: "Authorization")
        return request
    }
    
    struct RequestError: CustomStringConvertible, Error {
        
        @frozen enum Status {
            case code(Int)
            case `internal`
            
            @frozen enum FlowError {
                case oauthRefreshFailure
                
                @frozen enum CookiesReason {
                    case unusableCookies
                    case javascriptError(Error)
                    case unexpectedRedirect(String)
                    case passwdIncorrect
                    case navigationError(Error)
                    case cancelled
                }
                case cookiesUpdate(CookiesReason)
            }
            case flowError(FlowError)
        }
        let status: Status
        let path: String
        let data: Data?
        let parameters: [String: Any]!
        let serverMessage: String
        
        var rootPath: String {
            if self.path.hasPrefix(HomeApi.apiRoot) {
                var tmp = self.path
                
                tmp.removeFirst(HomeApi.apiRoot.count)
                return tmp
            }
            return self.path
        }
        
        var description: String {
            let paramsJSON = self.parameters == nil ? "" : self.parameters.json
            
            switch self.status {
            case .code(let code):
                return "\(code) \(self.path)\n\(self.serverMessage)\n\(paramsJSON)"
            case .internal:
                return "internal error \(self.serverMessage) \(self.path)\n\(paramsJSON)"
            case .flowError(let details):
                switch details {
                case .cookiesUpdate(let reason):
                    switch reason {
                    case .passwdIncorrect:
                        return ~"login.error.passwd-incorrect"
                    case .cancelled:
                        return ~"login.reconnect"
                    default:
                        return "\(reason)"
                    }
                case .oauthRefreshFailure:
                    return "\(details) \(self.serverMessage) \(self.path)\n\(paramsJSON)"
                }
            }
        }
        
        var isCancelled: Bool { // need a reflexion on this
            switch self.status {
            case .internal where self.data == nil && self.serverMessage == "cancelled":
                return true
            default:
                return false
            }
        }
        
        init(status: Status, path: String, data: Data?, parameters: [String: Any]!, serverMessage: String) {
            self.status = status
            self.path = path
            self.data = data
            self.parameters = parameters
            self.serverMessage = serverMessage
        }
        
        init(decodingError: DecodingError, status: Status, path: String, data: Data?, parameters: [String: Any]!) {
            self.status = status
            self.path = path
            self.data = data
            self.parameters = parameters
            switch decodingError {
            case .typeMismatch(let key, let value):
                self.serverMessage = "\(key).\(value.codingPath) typeMismatch."
            case .valueNotFound(let key, let value):
                self.serverMessage = "\(key).\(value.codingPath) valueNotFound."
            case .keyNotFound(let key, let value):
                self.serverMessage = "\(key).\(value.codingPath) keyNotFound."
            case .dataCorrupted(let key):
                self.serverMessage = "\(key) dataCorrupted."
            @unknown default:
                self.serverMessage = String(describing: decodingError)
            }
        }
        init(cookiesReason: Status.FlowError.CookiesReason) {
            self.status = .flowError(.cookiesUpdate(cookiesReason))
            self.path = ""
            self.data = nil
            self.parameters = [:]
            self.serverMessage = ""
        }
    }
}

// MARK: oauth
extension HomeApi {

    typealias DataTaskAsyncReturnType = (data: Data, response: URLResponse)
    
    struct OAuthTokens: Codable {
        let access: String
        let refresh: String
        let expire: TimeInterval
        let expireDate: Date
        
        @frozen enum CodingKeys: String, CodingKey {
            case access = "access_token"
            case refresh = "refresh_token"
            case expire = "expires_in"
            case expireDate = "expires_date"
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let accessToken = try container.decode(String.self, forKey: .access)
            
            self.access = "Bearer " + accessToken
            self.refresh = try container.decode(String.self, forKey: .refresh)
            self.expire = try container.decode(TimeInterval.self, forKey: .expire)
            if let date = try container.decodeIfPresent(Date.self, forKey: .expireDate) {
                self.expireDate = date
            }
            else {
                self.expireDate = Date.init(timeIntervalSinceNow: self.expire)
            }
        }
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: OAuthTokens.CodingKeys.self)
            
            try container.encode(self.access.replacingOccurrences(of: "Bearer ", with: ""), forKey: .access)
            try container.encode(self.refresh, forKey: .refresh)
            try container.encode(self.expire, forKey: .expire)
            try container.encode(self.expireDate, forKey: .expireDate)
        }
    }
    static var tokens: OAuthTokens!
    
    static func auth(_ code: String) async throws {
        var request = HomeApi.Routes.token.path.request
        let ret: DataTaskAsyncReturnType
        
        request.httpMethod = "POST"
        request.httpBody = try! JSONSerialization.data(withJSONObject: [
            "grant_type": "authorization_code",
            "client_id": HomeApi.uid,
            "client_secret": HomeApi.secret,
            "code": code,
            "scope": HomeApi.scope,
            "redirect_uri": HomeApi.redirectURI
        ])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            ret = try await HomeApi.urlSession.data(for: request)
            if (200 ... 299).contains((ret.response as! HTTPURLResponse).statusCode) {
                do {
                    HomeApi.tokens = try JSONDecoder.decoder.decode(OAuthTokens.self, from: ret.data)
                    HomeDefaults.save(HomeApi.tokens, forKey: .tokens)
                }
                catch {
                    throw HomeApi.RequestError(decodingError: error as! DecodingError, status: .code((ret.response as! HTTPURLResponse).statusCode),
                                               path: HomeApi.Routes.token.path, data: nil, parameters: nil)
                }
            }
            else {
                throw HomeApi.RequestError(status: .code((ret.response as! HTTPURLResponse).statusCode), path: HomeApi.Routes.token.path, data: ret.data, parameters: nil,
                                           serverMessage: String(data: ret.data, encoding: .utf8) ?? "no serveur message received")
            }
        }
        catch {
            throw HomeApi.RequestError.init(status: .internal, path: HomeApi.Routes.token.path, data: nil, parameters: nil, serverMessage: error.localizedDescription)
        }
    }
    
    private actor OAuthRefreshManager {
        
        private(set) var isRefreshing: Bool = false
        private var continuations: [UnsafeContinuation<(), Error>] = []
        
        func addContinuation(_ continuation: UnsafeContinuation<(), Error>) {
            self.continuations.append(continuation)
        }
        
        func startRefreshing() {
            self.isRefreshing = true
        }
        func endRefreshing() {
            self.isRefreshing = false
            for continuation in self.continuations {
                continuation.resume()
            }
            self.continuations.removeAll()
        }
        func endRefreshingWithError(error: Error) {
            self.isRefreshing = false
            for continuation in self.continuations {
                continuation.resume(throwing: error)
            }
            self.continuations.removeAll()
        }
    }
    static private let oauthRefreshManager: OAuthRefreshManager = OAuthRefreshManager()
    
    static private func asyncAuthRefresh() async throws {
        if await HomeApi.oauthRefreshManager.isRefreshing {
            return try await withUnsafeThrowingContinuation { continuation in
                Task.init(priority: .userInitiated, operation: { await HomeApi.oauthRefreshManager.addContinuation(continuation) })
            }
        }
        else {
            await HomeApi.oauthRefreshManager.startRefreshing()
        }
        let url = "https://api.intra.42.fr/oauth/token"
        var request = url.request
        let parameters = ["grant_type": "refresh_token", "refresh_token": HomeApi.tokens.refresh]
        var ret: DataTaskAsyncReturnType!
        let requestError: HomeApi.RequestError
        
        request.httpMethod = "POST"
        request.httpBody = try! JSONSerialization.data(withJSONObject: parameters)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            ret = try await HomeApi.urlSession.data(for: request)
            HomeApi.tokens = try JSONDecoder.decoder.decode(OAuthTokens.self, from: ret.data)
            HomeDefaults.save(HomeApi.tokens, forKey: .tokens)
            await HomeApi.oauthRefreshManager.endRefreshing()
        }
        catch {
            #if DEBUG
                if ret != nil {
                    if let json = try? JSONSerialization.jsonObject(with: ret.data, options: .allowFragments) as? [String: Any] {
                        print(json.json)
                    }
                    else {
                        print(String(data: ret.data, encoding: .utf8) ?? ret.data)
                    }
                }
                else {
                    print(error.localizedDescription)
                }
            #endif
            if let decodingError = error as? DecodingError {
                requestError = .init(decodingError: decodingError, status: .flowError(.oauthRefreshFailure), path: url, data: nil, parameters: parameters)
            }
            else {
                requestError = .init(status: .flowError(.oauthRefreshFailure), path: url, data: nil, parameters: parameters, serverMessage: error.localizedDescription)
            }
            throw requestError
        }
    }
}

// MARK: REQUESTS
extension HomeApi {
    
    static private func request(method: String, path: String, params: [String: Any]?) async throws -> Int {
        
        let request: URLRequest = HomeApi.urlRequest(method: method, path: path, params: params)
        let ret: DataTaskAsyncReturnType
        let serverErrorMessage: String
        
        #if DEBUG
        print(method, path, params ?? "[:]")
        #endif
        if HomeApi.tokens.expireDate <= Date() {
            try await HomeApi.asyncAuthRefresh()
        }
        do {
            ret = try await HomeApi.urlSession.data(for: request)
            if (200 ... 299).contains((ret.response as! HTTPURLResponse).statusCode) {
                return (ret.response as! HTTPURLResponse).statusCode
            }
            else {
                serverErrorMessage = String(data: ret.data, encoding: .utf8) ?? "no serveur message received"
                throw HomeApi.RequestError(status: .code((ret.response as! HTTPURLResponse).statusCode), path: path, data: ret.data, parameters: params,
                                           serverMessage: serverErrorMessage)
            }
        }
        catch {
            if error is HomeApi.RequestError {
                throw error
            }
            throw HomeApi.RequestError(status: .internal, path: path, data: nil, parameters: params, serverMessage: error.localizedDescription)
        }
    }
    
    static private func request<G: Codable>(sendBody: Bool, method: String, path: String, params: [String: Any]?) async throws -> G {
        
        let request: URLRequest
        let ret: DataTaskAsyncReturnType
        let serverErrorMessage: String
        let element: G
        
        #if DEBUG
        print(method, path, params ?? "[:]")
        #endif
        if HomeApi.tokens.expireDate <= Date() {
            try await HomeApi.asyncAuthRefresh()
        }
        if sendBody {
            request = HomeApi.urlRequest(method: method, path: path, params: params) // wtf ???
        }
        else {
            request = HomeApi.urlRequest(method: method, path: path, params: params)
        }
        do {
            ret = try await HomeApi.urlSession.data(for: request)
            if (200 ... 299).contains((ret.response as! HTTPURLResponse).statusCode) {
                do {
                    element = try JSONDecoder.decoder.decode(G.self, from: ret.data)
                }
                catch {
                    throw HomeApi.RequestError(decodingError: error as! DecodingError, status: .code((ret.response as! HTTPURLResponse).statusCode),
                                               path: path, data: ret.data, parameters: params)
                }
            }
            else {
                serverErrorMessage = String(data: ret.data, encoding: .utf8) ?? "no serveur message received"
                throw HomeApi.RequestError(status: .code((ret.response as! HTTPURLResponse).statusCode), path: path, data: ret.data, parameters: params,
                                           serverMessage: serverErrorMessage)
            }
        }
        catch {
            if error is HomeApi.RequestError {
                throw error
            }
            throw HomeApi.RequestError(status: .internal, path: path, data: nil, parameters: params, serverMessage: error.localizedDescription)
        }
        return element
    }
    
    static func get<G: Codable>(_ route: HomeApi.Routes, params: [String: Any]? = nil) async throws -> G {
        return try await HomeApi.request(sendBody: false, method: "GET", path: route.path, params: params)
    }
    static func post<G: Codable>(_ route: HomeApi.Routes, params: [String: Any]? = nil) async throws -> G {
        return try await HomeApi.request(sendBody: true, method: "POST", path: route.path, params: params)
    }
    static func patch<G: Codable>(_ route: HomeApi.Routes, params: [String: Any]? = nil) async throws -> G {
        return try await HomeApi.request(sendBody: true, method: "PATCH", path: route.path, params: params)
    }
    static func put<G: Codable>(_ route: HomeApi.Routes, params: [String: Any]? = nil) async throws -> G {
        return try await HomeApi.request(sendBody: true, method: "PUT", path: route.path, params: params)
    }
    static func delete(_ route: HomeApi.Routes, params: [String: Any]? = nil) async throws -> Int {
        return try await HomeApi.request(method: "DELETE", path: route.path, params: params)
    }
}

// MARK: - Requests iterator
extension HomeApi {
    
    struct RequestSequence<G: Codable>: AsyncSequence {
        typealias Element = ContiguousArray<G>
        
        private let page: Int
        private let pageSize: Int
        private let route: HomeApi.Routes
        private let parameters: [String: Any]?
        
        init(page: Int = 1, pageSize: Int = 100, route: HomeApi.Routes, parameters: [String: Any]? = nil) {
            self.page = page
            self.pageSize = pageSize
            self.route = route
            self.parameters = parameters
        }
        
        func makeAsyncIterator() -> RequestSequenceAsyncIterator {
            return RequestSequenceAsyncIterator(page: self.page, pageSize: self.pageSize, route: self.route, extraParameters: self.parameters)
        }
        
        struct RequestSequenceAsyncIterator: AsyncIteratorProtocol {
            typealias Element = RequestSequence.Element
            
            private var page: Int
            private let pageSize: Int
            private let route: HomeApi.Routes
            private var parameters: [String: Any]
            private var ended: Bool = false
            
            init(page: Int = 1, pageSize: Int = 100, route: HomeApi.Routes, extraParameters: [String: Any]?) {
                self.page = page
                self.pageSize = pageSize
                self.route = route
                self.parameters = ["page[number]": page, "page[size]": pageSize]
                if let extraParameters = extraParameters {
                    for (key, value) in extraParameters {
                        self.parameters[key] = value
                    }
                }
            }
            
            mutating func next() async throws -> RequestSequence.Element? {
                guard self.ended == false else {
                    return nil
                }
                let elements: RequestSequence.Element
                
                elements = try await HomeApi.get(self.route, params: self.parameters)
                if elements.count == self.pageSize {
                    self.page &+= 1
                    self.parameters["page[number]"] = self.page
                }
                else {
                    self.ended = true
                }
                return elements
            }
        }
    }
}

// MARK: - Routes
extension HomeApi {
    
    static private let apiRoot = "https://api.intra.42.fr/v2/"
    
    @frozen enum Routes {
        case me
        case users
        case usersWithUserIdCoalitions(Int)
        case userWithId(Int)
        case userWithLogin(String)
        case blocs
        case blocsWithBlocIdScores(Int)
        case blocsWithBlocIdSquads(Int)
        case coalitionsWithCoalitionIdUsers(Int)
        case usersWithUserIdScaleTeamsAsCorrector(Int)
        case usersWithUserIdScaleTeamsAsCorrected(Int)
        case usersUserIdScaleTeams(Int)
        case meSlots
        case locations
        case campusWithCampusIdLocations(Int)
        case usersWithUserIdCorrectionPointHistorics(Int)
        case projectsWithProjectId(Int)
        case projectsWithProjectIdSlots(Int)
        case projectsWithProjectIdScaleTeams(Int)
        case projectsWithProjectIdUsers(Int)
        case expertisesWithExpertiseIdUsers(Int)
        case achievements
        case achievementsWithAchievementIdUsers(Int)
        case campusWithCampusIdAchievements(Int)
        case staff
        case groupsWithGroupIdUsers(Int)
        case scaleTeams
        case meScaleTeams
        case slots
        case projectSessionsWithProjectSessionIdScaleTeams(Int)
        case campusWithCampusIdEvents(Int)
        case campusWithCampusIdCursusWithCursusIdEvents(Int, Int)
        case usersWithUserIdLocations(Int)
        case cursusWithCursusIdNotions(Int)
        case campusWithCampusIdNotions(Int)
        case notions
        case notionsWithNotionIdSubnotions(Int)
        case subnotionsWithSubnotionId(Int)
        case campusWithCampusIdProducts(Int)
        case campusWithCampusIdCursusWithCursusIdExams(Int, Int)
        case usersWithUserIdEventsUsers(Int)
        case usersWithUserIdEvents(Int)
        case eventsWithEventIdUsers(Int)
        case eventsUsersWithId(Int)
        case eventsUsers
        case events
        case cursusWithCursusIdEvents(Int)
        case eventsWithEventIdFeedbacks(Int)
        case eventWithId(Int)
        case feedbacks
        case groups
        case projects
        case campus
        case campusWithCampusIdUsers(Int)
        case skills
        case campusWithCampusIdBroadcasts(Int)
        case transactions
        case usersWithUserIdTransactions(Int)
        case offers
        case attachments
        case projectsWithProjectIdAttachments(Int)
        case titlesWithTitleIdUsers(Int)
        case partnershipsWithPartnershipIdUsers(Int)
        case token
        case tokenInformation
        case test(String)
        
        var path: String {
            switch self {
            case .me:
                return HomeApi.apiRoot + "me"
            case .users:
                return HomeApi.apiRoot + "users"
            case .usersWithUserIdCoalitions(let id):
                return HomeApi.apiRoot + "users/\(id)/coalitions"
            case .userWithId(let id):
                return HomeApi.apiRoot + "users/\(id)"
            case .userWithLogin(let login):
                return HomeApi.apiRoot + "users/\(login)"
            case .blocs:
                return HomeApi.apiRoot + "blocs"
            case .blocsWithBlocIdScores(let id):
                return HomeApi.apiRoot + "blocs/\(id)/scores"
            case .blocsWithBlocIdSquads(let id):
                return HomeApi.apiRoot + "blocs/\(id)/squads"
            case .coalitionsWithCoalitionIdUsers(let id):
                return HomeApi.apiRoot + "coalitions/\(id)/users"
            case .usersWithUserIdScaleTeamsAsCorrector(let id):
                return HomeApi.apiRoot + "users/\(id)/scale_teams/as_corrector"
            case .usersWithUserIdScaleTeamsAsCorrected(let id):
                return HomeApi.apiRoot + "users/\(id)/scale_teams/as_corrected"
            case .usersUserIdScaleTeams(let id):
                return HomeApi.apiRoot + "users/\(id)/scale_teams"
            case .meSlots:
                return HomeApi.apiRoot + "me/slots"
            case .locations:
                return HomeApi.apiRoot + "locations"
            case .campusWithCampusIdLocations(let id):
                return HomeApi.apiRoot + "campus/\(id)/locations"
            case .usersWithUserIdCorrectionPointHistorics(let id):
                return HomeApi.apiRoot + "users/\(id)/correction_point_historics"
            case .projectsWithProjectId(let id):
                return HomeApi.apiRoot + "projects/\(id)"
            case .projectsWithProjectIdSlots(let id):
                return HomeApi.apiRoot + "projects/\(id)/slots"
            case .projectsWithProjectIdScaleTeams(let id):
                return HomeApi.apiRoot + "projects/\(id)/scale_teams"
            case .expertisesWithExpertiseIdUsers(let id):
                return HomeApi.apiRoot + "expertises/\(id)/users"
            case .achievements:
                return HomeApi.apiRoot + "achievements"
            case .achievementsWithAchievementIdUsers(let id):
                return HomeApi.apiRoot + "achievements/\(id)/users"
            case .campusWithCampusIdAchievements(let id):
                return HomeApi.apiRoot + "campus/\(id)/achievements"
            case .staff:
                return HomeApi.apiRoot + "staff"
            case .groupsWithGroupIdUsers(let id):
                return HomeApi.apiRoot + "groups/\(id)/users"
            case .scaleTeams:
                return HomeApi.apiRoot + "scale_teams"
            case .meScaleTeams:
                return HomeApi.apiRoot + "me/scale_teams"
            case .slots:
                return HomeApi.apiRoot + "slots"
            case .projectSessionsWithProjectSessionIdScaleTeams(let id):
                return HomeApi.apiRoot + "project_sessions/\(id)/scale_teams"
            case .campusWithCampusIdEvents(let id):
                return HomeApi.apiRoot + "campus/\(id)/events"
            case .campusWithCampusIdCursusWithCursusIdEvents(let campus, let cursus):
                return HomeApi.apiRoot + "campus/\(campus)/cursus/\(cursus)/events"
            case .usersWithUserIdLocations(let id):
                return HomeApi.apiRoot + "users/\(id)/locations"
            case .cursusWithCursusIdNotions(let id):
                return HomeApi.apiRoot + "cursus/\(id)/notions"
            case .campusWithCampusIdNotions(let id):
                return HomeApi.apiRoot + "campus/\(id)/notions"
            case .notions:
                return HomeApi.apiRoot + "notions"
            case .notionsWithNotionIdSubnotions(let id):
                return HomeApi.apiRoot + "notions/\(id)/subnotions"
            case .subnotionsWithSubnotionId(let id):
                return HomeApi.apiRoot + "subnotions/\(id)"
            case .campusWithCampusIdProducts(let id):
                return HomeApi.apiRoot + "campus/\(id)/products"
            case .projectsWithProjectIdUsers(let id):
                return HomeApi.apiRoot + "projects/\(id)/users"
            case .campusWithCampusIdCursusWithCursusIdExams(let campus, let cursus):
                return HomeApi.apiRoot + "campus/\(campus)/cursus/\(cursus)/exams"
            case .usersWithUserIdEventsUsers(let id):
                return HomeApi.apiRoot + "users/\(id)/events_users"
            case .usersWithUserIdEvents(let id):
                return HomeApi.apiRoot + "users/\(id)/events"
            case .eventsUsersWithId(let id):
                return HomeApi.apiRoot + "events_users/\(id)"
            case .eventsUsers:
                return HomeApi.apiRoot + "events_users"
            case .events:
                return HomeApi.apiRoot + "events"
            case .cursusWithCursusIdEvents(let id):
                return HomeApi.apiRoot + "cursus/\(id)/events"
            case .eventsWithEventIdFeedbacks(let id):
                return HomeApi.apiRoot + "events/\(id)/feedbacks"
            case .eventWithId(let id):
                return HomeApi.apiRoot + "events/\(id)"
            case .feedbacks:
                return HomeApi.apiRoot + "feedbacks"
            case .eventsWithEventIdUsers(let id):
                return HomeApi.apiRoot + "events/\(id)/users"
            case .groups:
                return HomeApi.apiRoot + "groups"
            case .projects:
                return HomeApi.apiRoot + "projects"
            case .campus:
                return HomeApi.apiRoot + "campus"
            case .campusWithCampusIdUsers(let id):
                return HomeApi.apiRoot + "campus/\(id)/users"
            case .skills:
                return HomeApi.apiRoot + "skills"
            case .campusWithCampusIdBroadcasts(let id):
                return HomeApi.apiRoot + "campus/\(id)/broadcasts"
            case .transactions:
                return HomeApi.apiRoot + "transactions"
            case .usersWithUserIdTransactions(let id):
                return HomeApi.apiRoot + "users/\(id)/transactions"
            case .offers:
                return HomeApi.apiRoot + "offers"
            case .attachments:
                return HomeApi.apiRoot + "attachments"
            case .projectsWithProjectIdAttachments(let id):
                return HomeApi.apiRoot + "projects/\(id)/attachments"
            case .titlesWithTitleIdUsers(let id):
                return HomeApi.apiRoot + "titles/\(id)/users"
            case .partnershipsWithPartnershipIdUsers(let id):
                return HomeApi.apiRoot + "partnerships/\(id)/users"
            case .token:
                return "https://api.intra.42.fr/oauth/token"
            case .tokenInformation:
                return "https://api.intra.42.fr/oauth/token/info"
            case .test(let test):
                return HomeApi.apiRoot + test
            }
        }
    }
}

// MARK: - Parameters
extension HomeApi {
    
    @frozen enum Parameter: String {
        case filterPoolYear = "filter[pool_year]"
        case filterPoolMonth = "filter[pool_month]"
        case filterPrimaryCampusId = "filter[primary_campus_id]"
        case filterCursusId = "filter[cursus_id]"
        case filterVisible = "filter[visible]"
        case filterFuture = "filter[future]"
        case filterRemote = "filter[remote]"
        case filterBeginAt = "filter[begin_at]"
        case filterEndAt = "filter[end_at]"
        case filterCreatedAt = "filter[created_at]"
        case filterUpdatedAt = "filter[updated_at]"
        case sort = "sort"
        case searchLogin = "search[login]"
        case searchName = "search[name]"
        case searchDescription = "search[description]"
        case searchLocation = "search[location]"
        case searchMaxPeople = "search[max_people]"
        case isAlumni = "alumni?"
        case isStaff = "staff?"
    }
}
extension Dictionary where Self.Key == String {
    
    subscript(_ parameter: HomeApi.Parameter) -> Self.Value? {
        get {
            return self[parameter.rawValue]
        }
        set {
            self[parameter.rawValue] = newValue
        }
    }
}
