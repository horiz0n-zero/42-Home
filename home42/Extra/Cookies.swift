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
                let _: Dictionary<String, String> = try await HomeApi.intranetRequest(.locationStats(user.login))
                return
            }
            catch {
                #if DEBUG
                print(#function, #line, error.localizedDescription)
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
    
    // MARK: -
    private final class CookiesRefresherAlert: DynamicController, UITextFieldDelegate {
        
        private let container: CoalitionBackgroundWithParallaxImageView
        private let loginLabel: LoginViewController.LoginTextFieldUpperText
        private let loginTextField: LoginViewController.LoginTextField
        private let passwdLabel: LoginViewController.LoginTextFieldUpperText
        private let passwdTextField: LoginViewController.LoginTextField
        private let cancelButton: LoginViewController.LoginButton
        private let loginButton: LoginViewController.LoginButton
        
        private var cookiesRefresher: CookiesRefresher! = nil
        private let continuation: UnsafeContinuation<Cookies, Error>
        
        @discardableResult init(continuation: UnsafeContinuation<Cookies, Error>) {
            self.container = CoalitionBackgroundWithParallaxImageView()
            self.loginLabel = LoginViewController.LoginTextFieldUpperText(.login)
            self.loginTextField = LoginViewController.LoginTextField(.login)
            self.loginTextField.text = App.user.login
            self.passwdLabel = LoginViewController.LoginTextFieldUpperText(.passwd)
            self.passwdTextField = LoginViewController.LoginTextField(.passwd)
            self.cancelButton = LoginViewController.LoginButton(title: ~"general.cancel", color: HomeDesign.redError)
            self.loginButton = LoginViewController.LoginButton()
            self.continuation = continuation
            super.init()
            
            self.retainObject()
            if let backgroundPrimary = self.backgroundPrimary {
                backgroundPrimary.alpha = 0.0
                backgroundPrimary.backgroundColor = HomeDesign.primaryDefault.withAlphaComponent(HomeDesign.alphaLow)
            }
            self.view.addSubview(self.container)
            self.container.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).setPriority(.defaultLow).isActive = true
            self.container.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            self.container.bottomAnchor.constraint(lessThanOrEqualTo: self.view.keyboardLayoutGuide.topAnchor, constant: -HomeLayout.margin).isActive = true
            self.container.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: HomeLayout.margins).isActive = true
            self.container.clipsToBounds = true
            self.container.layer.cornerRadius = HomeLayout.corners
            self.container.addSubview(self.loginLabel)
            self.loginLabel.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: HomeLayout.margin + HomeLayout.dmargin).isActive = true
            self.loginLabel.topAnchor.constraint(equalTo: self.container.topAnchor, constant: HomeLayout.margin).isActive = true
            self.container.addSubview(self.loginTextField)
            self.loginTextField.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: HomeLayout.margin).isActive = true
            self.loginTextField.trailingAnchor.constraint(equalTo: self.container.trailingAnchor, constant: -HomeLayout.margin).isActive = true
            self.loginTextField.topAnchor.constraint(equalTo: self.loginLabel.bottomAnchor, constant: HomeLayout.dmargin).isActive = true
            self.container.addSubview(self.passwdLabel)
            self.passwdLabel.leadingAnchor.constraint(equalTo: self.loginLabel.leadingAnchor).isActive = true
            self.passwdLabel.topAnchor.constraint(equalTo: self.loginTextField.bottomAnchor, constant: HomeLayout.margin).isActive = true
            self.container.addSubview(self.passwdTextField)
            self.passwdTextField.leadingAnchor.constraint(equalTo: self.loginTextField.leadingAnchor).isActive = true
            self.passwdTextField.trailingAnchor.constraint(equalTo: self.loginTextField.trailingAnchor).isActive = true
            self.passwdTextField.topAnchor.constraint(equalTo: self.passwdLabel.bottomAnchor, constant: HomeLayout.dmargin).isActive = true
            self.container.addSubview(self.loginButton)
            self.loginButton.leadingAnchor.constraint(equalTo: self.loginTextField.leadingAnchor).isActive = true
            self.loginButton.trailingAnchor.constraint(equalTo: self.loginTextField.trailingAnchor).isActive = true
            self.loginButton.topAnchor.constraint(equalTo: self.passwdTextField.bottomAnchor, constant: HomeLayout.margins).isActive = true
            self.container.addSubview(self.cancelButton)
            self.cancelButton.leadingAnchor.constraint(equalTo: self.loginTextField.leadingAnchor).isActive = true
            self.cancelButton.trailingAnchor.constraint(equalTo: self.loginTextField.trailingAnchor).isActive = true
            self.cancelButton.topAnchor.constraint(equalTo: self.loginButton.bottomAnchor, constant: HomeLayout.margin).isActive = true
            self.cancelButton.bottomAnchor.constraint(equalTo: self.container.bottomAnchor, constant: -HomeLayout.margin).isActive = true
            
            self.container.isUserInteractionEnabled = true
            self.loginButton.addTarget(self, action: #selector(CookiesRefresherAlert.loginButtonTapped), for: .touchUpInside)
            self.cancelButton.addTarget(self, action: #selector(CookiesRefresherAlert.cancelButtonTapped), for: .touchUpInside)
            self.loginTextField.delegate = self
            self.passwdTextField.delegate = self
            
            self.present()
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        required init() { fatalError() }
        
        private func disableButtons() {
            self.loginButton.isUserInteractionEnabled = false
            self.loginButton.backgroundColor = self.loginButton.backgroundColor?.withAlphaComponent(HomeDesign.alphaLayer)
            self.cancelButton.isUserInteractionEnabled = false
            self.cancelButton.backgroundColor = self.cancelButton.backgroundColor?.withAlphaComponent(HomeDesign.alphaLayer)
        }
        private func enabledButtons() {
            self.loginButton.reset()
            self.loginButton.isUserInteractionEnabled = true
            self.loginButton.backgroundColor = self.loginButton.backgroundColor?.withAlphaComponent(1.0)
            self.cancelButton.isUserInteractionEnabled = true
            self.cancelButton.backgroundColor = self.cancelButton.backgroundColor?.withAlphaComponent(1.0)
        }
        
        @objc private func cancelButtonTapped() {
            self.continuation.resume(throwing: HomeApi.RequestError.init(cookiesReason: .cancelled))
            self.remove()
        }
        
        @objc private func loginButtonTapped() {
            guard let login = self.loginTextField.text, !login.isEmpty, let passwd = self.passwdTextField.text, !passwd.isEmpty else {
                if !self.loginTextField.text!.isEmpty || !self.passwdTextField.text!.isEmpty {
                    DynamicAlert(.withPrimary(~"general.error", HomeDesign.primaryDefault), contents: [.text(~"login.error.passwd-required")], actions: [.normal(~"general.ok", nil)])
                }
                return
            }
            
            if login != App.user.login {
                DynamicAlert(.withPrimary(~"general.error", HomeDesign.primaryDefault), contents: [.text(String(format: ~"login.error.login-not-identical", App.user.login))], actions: [.normal(~"general.ok", nil)])
                return
            }
            self.disableButtons()
            if self.cookiesRefresher == nil {
                self.cookiesRefresher = CookiesRefresher(delegate: self, login: login, passwd: passwd)
                Task.init(priority: .userInitiated, operation: {
                    await self.cookiesRefresher.start()
                })
            }
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            if textField == self.loginTextField {
                return self.passwdTextField.becomeFirstResponder()
            }
            self.loginButtonTapped()
            return self.passwdTextField.resignFirstResponder()
        }
                
        private func cookiesRefresherFailed(_ error: HomeApi.RequestError) {
            DispatchQueue.main.async {
                DynamicAlert.presentWith(error: error)
                self.enabledButtons()
                self.cookiesRefresher = nil
            }
        }
        private func cookiesRefresherSucceed(_ cookies: Cookies) {
            DispatchQueue.main.async {
                self.continuation.resume(returning: cookies)
                self.cookiesRefresher = nil
                self.remove()
            }
        }
        
        private final class CookiesRefresher: WKWebView, WKNavigationDelegate {
            
            private let login: String
            private let passwd: String
            private unowned(unsafe) let delegate: CookiesRefresherAlert
            
            init(delegate: CookiesRefresherAlert, login: String, passwd: String) {
                let config: WKWebViewConfiguration
                
                config = WKWebViewConfiguration()
                config.processPool = WKProcessPool()
                self.delegate = delegate
                self.login = login
                self.passwd = passwd
                super.init(frame: .zero, configuration: config)
                self.navigationDelegate = self
                self.updateStateDelegateText()
            }
            required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
            deinit {
                self.stopLoading()
            }
            
            @MainActor func start() async {
                await Cookies.clearWebsiteData()
                _ = self.load("https://signin.intra.42.fr/users/sign_in".request)
            }
            
            @Sendable func readCookies() async {
                guard let cookies = await Cookies(httpCookies: await Cookies.readWebsiteCookies(targettingWebView: self), verifyingWithUser: App.user) else {
                    return self.delegate.cookiesRefresherFailed(.init(cookiesReason: .unusableCookies))
                }
                
                self.delegate.cookiesRefresherSucceed(cookies)
            }
            
            @frozen private enum State: String {
                case loading = "login.state.waiting"
                case signin = "login.state.signin"
                case profil = "login.state.loading"
                case cookies = "login.state.cookies"
            }
            private var state: State = .loading {
                didSet {
                    self.updateStateDelegateText()
                }
            }
            private func updateStateDelegateText() {
                self.delegate.loginButton.setAttributedTitle(.init(string: (~self.state.rawValue).uppercased(),
                                                                   attributes: [.foregroundColor: HomeDesign.white, .font: HomeLayout.fontBoldTitle]),
                                                             for: .normal)
            }
            
            func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
                
                func javascriptError(_ object: Any?, error: Error?) {
                    if let error = error {
                        self.delegate.cookiesRefresherFailed(.init(cookiesReason: .javascriptError(error)))
                    }
                }
                
                #if DEBUG
                print("CookiesRefresher", self.state, #function)
                print("CookiesRefresher", webView.url!.host!, webView.url!.path)
                print()
                #endif
                switch self.state {
                case .loading:
                    let login = String(format: "document.getElementById(\"user_login\").value = \"%@\";", self.login)
                    let passw = String(format: "document.getElementById(\"user_password\").value = \"%@\";", self.passwd)
                    
                    webView.evaluateJavaScript(login, completionHandler: javascriptError(_:error:))
                    webView.evaluateJavaScript(passw, completionHandler: javascriptError(_:error:))
                    webView.evaluateJavaScript("document.querySelector(\'[name=\"commit\"]\').click();", completionHandler: javascriptError(_:error:))
                    self.state = .signin
                default:
                    if webView.url!.absoluteString.hasPrefix("https://profile.intra.42.fr") {
                        self.state = .cookies
                        Task.init(priority: .userInitiated, operation: self.readCookies)
                    }
                    else {
                        self.delegate.cookiesRefresherFailed(.init(cookiesReason: .unexpectedRedirect(webView.url!.absoluteString)))
                    }
                }
            }
            func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
                let path = webView.url!.absoluteString
                
                #if DEBUG
                print("CookiesRefresher", self.state, #function)
                print("CookiesRefresher", webView.url!.host!, webView.url!.path)
                print()
                #endif
                if path.hasPrefix("https://signin.intra.42.fr/users/sign_in") {
                    if self.state == .signin {
                        self.delegate.cookiesRefresherFailed(.init(cookiesReason: .passwdIncorrect))
                    }
                    else {
                        self.state = .signin
                    }
                }
                else if path.hasPrefix("https://profile.intra.42.fr") == false {
                    self.delegate.cookiesRefresherFailed(.init(cookiesReason: .unexpectedRedirect(webView.url!.absoluteString)))
                }
                else {
                    self.state = .profil
                }
            }
            func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
                self.delegate.cookiesRefresherFailed(.init(cookiesReason: .navigationError(error)))
            }
            func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
                self.delegate.cookiesRefresherFailed(.init(cookiesReason: .navigationError(error)))
            }
        }
        
        override func present() {
            self.container.alpha = 0.0
            super.present()
            HomeAnimations.animateShort({
                self.container.alpha = 1.0
                self.background.effect = HomeDesign.blur
                if let backgroundPrimary = self.backgroundPrimary {
                    backgroundPrimary.alpha = 1.0
                }
            }) { _ in
                self.passwdTextField.becomeFirstResponder()
            }
        }
        override func remove(isFinish: Bool = true) {
            HomeAnimations.animateShort({
                self.container.alpha = 0.0
                self.background.effect = nil
                if let backgroundPrimary = self.backgroundPrimary {
                    backgroundPrimary.alpha = 0.0
                }
            }, completion: super.remove(isFinish:))
        }
    }
    
    @MainActor static func refreshRequiredCookies() async throws -> Cookies {
        return try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<Cookies, Error>) in
            DispatchQueue.main.async {
                _ = CookiesRefresherAlert(continuation: continuation)
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

