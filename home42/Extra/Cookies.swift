// home42/Cookies.swift
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
import WebKit
import SwiftDate

final class Cookies: IntraObject {
    
    static private let intraSessionProductionKey: String = "_intra_42_session_production"
    var intraSessionProduction: String! = nil
    var intraSessionProductionHTTPCookie: HTTPCookie! = nil
    static private let userIdKey: String = "user.id"
    let userId: String
    let userIdHTTPCookie: HTTPCookie
    
    var requiredUpdate: Bool {
        return self.intraSessionProductionHTTPCookie.expiresDate!.compare(.isEarlier(than: Date()))
    }

    private struct CodableCookie: Codable {
        
        private let name: String
        private let value: String
        private let domain: String?
        private let expires: Date?
        private let path: String?
        private let port: String?
        private let secure: Bool?
        
        init?(cookie: HTTPCookie) {
            if let properties = cookie.properties, let name = properties[.name] as? String, let value = properties[.value] as? String {
                self.name = name
                self.value = value
                self.domain = properties[.domain] as? String
                self.expires = cookie.expiresDate
                self.path = properties[.path] as? String
                self.port = properties[.port] as? String
                self.secure = properties[.secure] as? Bool
            }
            else {
                return nil
            }
        }
        
        var httpCookie: HTTPCookie {
            var properties: [HTTPCookiePropertyKey: Any] = [.name: self.name, .value: self.value]
            
            if let domain = self.domain {
                properties[.domain] = domain
            }
            if let expires = self.expires {
                properties[.expires] = expires
            }
            if let path = self.path {
                properties[.path] = path
            }
            if let port = self.port {
                properties[.port] = port
            }
            if let secure = self.secure {
                properties[.secure] = secure
            }
            return HTTPCookie(properties: properties)!
        }
    }
    
    init?(httpCookies: ContiguousArray<HTTPCookie>, verifyingWithUser user: IntraUser) async {
        let intraSessionProductionCookies = httpCookies.filter({ $0.name == Cookies.intraSessionProductionKey }).reversed()
        let userIdCookies = httpCookies.filter({ $0.name == Cookies.userIdKey })
        
        if intraSessionProductionCookies.count == 0 || userIdCookies.count == 0 {
            return nil
        }
        self.userIdHTTPCookie = userIdCookies.last!
        self.userId = "\(Cookies.userIdKey)=\(self.userIdHTTPCookie.value)"
        super.init()
        HomeApi.cookies = self
        for cookie in intraSessionProductionCookies {
            self.intraSessionProductionHTTPCookie = cookie
            self.intraSessionProduction = "\(Cookies.intraSessionProductionKey)=\(cookie.value)"
            do {
                let _: IntraNetShortUserDescription = try await HomeApi.intranetRequest(.user(user.login))
                return
            }
            catch {
                #if DEBUG
                print(#function, #line, error)
                #endif
            }
        }
        HomeApi.cookies = nil
        return nil
    }
    
    init(from decoder: Decoder) throws {
        var array = try decoder.unkeyedContainer()
        var httpCookies: ContiguousArray<HTTPCookie> = []
        
        while array.isAtEnd == false {
            httpCookies.append(try array.decode(CodableCookie.self).httpCookie)
        }
        self.intraSessionProductionHTTPCookie = Cookies.filterCookies(forCookieNamed: Cookies.intraSessionProductionKey, cookies: httpCookies)!
        self.intraSessionProduction = "\(Cookies.intraSessionProductionKey)=\(self.intraSessionProductionHTTPCookie.value)"
        self.userIdHTTPCookie = Cookies.filterCookies(forCookieNamed: Cookies.userIdKey, cookies: httpCookies)!
        self.userId = "\(Cookies.userIdKey)=\(self.userIdHTTPCookie.value)"
        super.init()
    }
    
    func encode(to encoder: Encoder) throws {
        var array = encoder.unkeyedContainer()
        
        for cookie in [self.intraSessionProductionHTTPCookie, self.userIdHTTPCookie].map({ CodableCookie(cookie: $0) }) {
            try array.encode(cookie)
        }
    }
    
    final private class RefreshManager: NSObject, LoginHandlerDelegate {
        
        private let continuation: UnsafeContinuation<Cookies, Error>
        private var handler: LoginHandler!
        
        init(continuation: UnsafeContinuation<Cookies, Error>) {
            self.continuation = continuation
            super.init()
            _ = Unmanaged.passRetained(self)
            Task {
                self.handler = await LoginHandler(loginDelegate: self)
                await App.mainController.presentWithBlur(self.handler)
            }
        }
        
        func loginHandlerSuccessfullyLogin(user: IntraUser, coalitions: ContiguousArray<IntraCoalition>, cookies: Cookies) {
            self.continuation.resume(returning: cookies)
            self.handler.dismiss(animated: true)
            _ = Unmanaged.passUnretained(self).autorelease()
        }
        
        func loginHandlerAbandonLogin() {
            self.continuation.resume(throwing: HomeApi.RequestError.canceled())
            self.handler.dismiss(animated: true)
            _ = Unmanaged.passUnretained(self).autorelease()
        }
    }
    
    @MainActor static func refreshRequiredCookies() async throws -> Cookies {
        return try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<Cookies, Error>) in
            DispatchQueue.main.async {
                
                func cancel() {
                    continuation.resume(throwing: HomeApi.RequestError.canceled())
                }
                func ok() {
                    _ = RefreshManager(continuation: continuation)
                }
                
                DynamicAlert(contents: [.text(~"login.reconnect")], actions: [.normal(~"general.cancel", cancel), .highligth(~"general.ok", ok)])
            }
        }
    }
   
    static func filterCookies<G: Sequence>(forCookieNamed name: String, cookies: G) -> HTTPCookie? where G.Element == HTTPCookie {
        for cookie in cookies where cookie.name == name {
            return cookie
        }
        return nil
    }
    
    @MainActor static func readWebsiteCookies(targettingWebView: WKWebView? = nil) async -> ContiguousArray<HTTPCookie> {
        let dataStore = targettingWebView?.configuration.websiteDataStore ?? WKWebsiteDataStore.default()
        let dataStoreCookies = await dataStore.httpCookieStore.allCookies()
        var cookies: ContiguousArray<HTTPCookie> = []
        
        if let storageCookies = HTTPCookieStorage.shared.cookies {
            cookies.reserveCapacity(storageCookies.count + dataStoreCookies.count)
            cookies.append(contentsOf: dataStoreCookies)
            cookies.append(contentsOf: storageCookies)
        }
        else {
            cookies.reserveCapacity(dataStoreCookies.count)
            cookies.append(contentsOf: dataStoreCookies)
        }
        #if DEBUG
        print(#function, cookies.map(\.name))
        #endif
        return cookies
    }
    
    @MainActor static func clearWebsiteData(targettingWebView: WKWebView? = nil) async {
        let dataStore: WKWebsiteDataStore = targettingWebView?.configuration.websiteDataStore ?? WKWebsiteDataStore.default()
        let records = await dataStore.dataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes())
        
        #if DEBUG
        print(#function)
        #endif
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        URLCache.shared.removeAllCachedResponses()
        await URLSession.shared.flush()
        for record in records {
            await dataStore.removeData(ofTypes: record.dataTypes, for: [record])
        }
    }
}

