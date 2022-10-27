// home42/Login.swift
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

final class LoginViewController: HomeViewController, UITextFieldDelegate, WKNavigationDelegate {
    
    private let background: BasicUIImageView
    private let logoCenter: BasicUIView
    private let logo42: BasicUIImageView
    
    private let formContainer: BasicUIView
    private var formContainerCenterY: NSLayoutConstraint!
    private let loginLabel: LoginTextFieldUpperText
    private let loginTextField: LoginTextField
    private let passwdLabel: LoginTextFieldUpperText
    private let passwdTextField: LoginTextField
    private let loginButton: LoginButton
    
    private let conditionsLabel: BasicUILabel
    
    required init() {
        self.background = BasicUIImageView(asset: .coalitionDefaultBackground)
        self.logoCenter = BasicUIView()
        self.logo42 = .init(asset: .svg42)
        self.logo42.contentMode = .center
        self.logo42.tintColor = HomeDesign.white
        self.logo42.translatesAutoresizingMaskIntoConstraints = false
        
        self.formContainer = BasicUIView()
        self.formContainer.backgroundColor = .clear
        self.loginLabel = LoginTextFieldUpperText(.login)
        self.loginTextField = LoginTextField(.login)
        self.passwdLabel = LoginTextFieldUpperText(.passwd)
        self.passwdTextField = LoginTextField(.passwd)
        self.loginButton = LoginButton()
        
        self.conditionsLabel = BasicUILabel(attribute: NSAttributedString.init(string: ~"login.cgu", attributes: [
                                                                                    .underlineStyle: NSUnderlineStyle.single.rawValue,
                                                                                        .font: HomeLayout.fontThinMedium,
                                                                                        .foregroundColor: HomeDesign.white]))
        super.init()
        self.modalPresentationStyle = .fullScreen
        self.view.addSubview(self.background)
        if App.settings.graphicsUseParallax {
            self.background.setUpParallaxEffect(usingAmout: App.settings.graphicsParallaxForce.rawValue)
            self.background.setUpParallaxConstraint(usingParent: self.view)
        }
        else {
            self.background.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
            self.background.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
            self.background.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            self.background.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        }
        
        self.view.addSubview(self.formContainer)
        self.formContainerCenterY = self.formContainer.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        self.formContainerCenterY.priority = .defaultLow
        self.formContainerCenterY.isActive = true
        self.formContainer.bottomAnchor.constraint(lessThanOrEqualTo: self.view.keyboardLayoutGuide.topAnchor, constant: -HomeLayout.margin).isActive = true
        self.formContainer.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.formContainer.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: HomeLayout.margind).isActive = true
        self.formContainer.addSubview(self.loginLabel)
        self.loginLabel.leadingAnchor.constraint(equalTo: self.formContainer.leadingAnchor, constant: HomeLayout.dmargin).isActive = true
        self.loginLabel.topAnchor.constraint(equalTo: self.formContainer.topAnchor).isActive = true
        self.formContainer.addSubview(self.loginTextField)
        self.loginTextField.leadingAnchor.constraint(equalTo: self.formContainer.leadingAnchor).isActive = true
        self.loginTextField.trailingAnchor.constraint(equalTo: self.formContainer.trailingAnchor).isActive = true
        self.loginTextField.topAnchor.constraint(equalTo: self.loginLabel.bottomAnchor, constant: HomeLayout.dmargin).isActive = true
        self.formContainer.addSubview(self.passwdLabel)
        self.passwdLabel.leadingAnchor.constraint(equalTo: self.formContainer.leadingAnchor, constant: HomeLayout.dmargin).isActive = true
        self.passwdLabel.topAnchor.constraint(equalTo: self.loginTextField.bottomAnchor, constant: HomeLayout.margins).isActive = true
        self.formContainer.addSubview(self.passwdTextField)
        self.passwdTextField.leadingAnchor.constraint(equalTo: self.formContainer.leadingAnchor).isActive = true
        self.passwdTextField.trailingAnchor.constraint(equalTo: self.formContainer.trailingAnchor).isActive = true
        self.passwdTextField.topAnchor.constraint(equalTo: self.passwdLabel.bottomAnchor, constant: HomeLayout.dmargin).isActive = true
        self.formContainer.addSubview(self.loginButton)
        self.loginButton.leadingAnchor.constraint(equalTo: self.formContainer.leadingAnchor).isActive = true
        self.loginButton.trailingAnchor.constraint(equalTo: self.formContainer.trailingAnchor).isActive = true
        self.loginButton.topAnchor.constraint(equalTo: self.passwdTextField.bottomAnchor, constant: HomeLayout.margind).isActive = true
        self.loginButton.bottomAnchor.constraint(equalTo: self.formContainer.bottomAnchor).isActive = true
        
        self.view.addSubview(self.logoCenter)
        self.logoCenter.bottomAnchor.constraint(equalTo: self.formContainer.topAnchor, constant: -HomeLayout.margin).isActive = true
        self.logoCenter.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: HomeLayout.margin).isActive = true
        self.logoCenter.leadingAnchor.constraint(equalTo: self.formContainer.leadingAnchor).isActive = true
        self.logoCenter.trailingAnchor.constraint(equalTo: self.formContainer.trailingAnchor).isActive = true
        self.logoCenter.addSubview(self.logo42)
        self.logo42.centerYAnchor.constraint(equalTo: self.logoCenter.centerYAnchor).isActive = true
        self.logo42.centerXAnchor.constraint(equalTo: self.logoCenter.centerXAnchor).isActive = true
        
        
        self.view.addSubview(self.conditionsLabel)
        self.conditionsLabel.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -HomeLayout.margin).isActive = true
        self.conditionsLabel.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -HomeLayout.margin).isActive = true
        
        self.formContainer.isUserInteractionEnabled = true
        self.loginButton.addTarget(self, action: #selector(LoginViewController.loginButtonTapped), for: .touchUpInside)
        self.loginTextField.delegate = self
        self.passwdTextField.delegate = self
        self.conditionsLabel.isUserInteractionEnabled = true
        self.conditionsLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LoginViewController.termButtonTapped(sender:))))
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.loginTextField {
            return self.passwdTextField.becomeFirstResponder()
        }
        self.loginButtonTapped()
        return self.passwdTextField.resignFirstResponder()
    }

    @objc private func termButtonTapped(sender: UITapGestureRecognizer) {
        self.present(SafariWebView(URL(string: "https://signin.intra.42.fr/legal")!), animated: true, completion: nil)
    }
    
    @frozen private enum State: String {
        case connect   = "login.state.connect"
        case waiting   = "login.state.waiting"
        case signin    = "login.state.signin"
        case signin2FA = "terminal.waiting"
        case authorize = "login.state.authorize"
        case loading   = "login.state.loading"
        case cookie    = "login.state.cookies"
    }
    private var state: State = .connect {
        didSet {
            self.loginButton.setAttributedTitle(.init(string: (~self.state.rawValue).uppercased(),
                                                      attributes: [.foregroundColor: HomeDesign.white, .font: HomeLayout.fontBoldTitle]), for: .normal)
        }
    }
    
    private var signinHandler: WKWebView? = nil
    
    @objc private func loginButtonTapped() {
        guard let login = self.loginTextField.text, !login.isEmpty, let passwd = self.passwdTextField.text, !passwd.isEmpty else {
            if !self.loginTextField.text!.isEmpty || !self.passwdTextField.text!.isEmpty {
                DynamicAlert(contents: [.text(~"login.error.passwd-required")], actions: [.normal(~"general.ok", nil)])
            }
            return
        }
        guard self.loginButton.isUserInteractionEnabled == true else {
            return
        }
        
        @Sendable @MainActor func newSigninHandler() async -> WKWebView {
            let config: WKWebViewConfiguration
            let webview: WKWebView
            
            config = WKWebViewConfiguration()
            config.processPool = WKProcessPool()
            webview = WKWebView(frame: .zero, configuration: config)
            await Cookies.clearWebsiteData(targettingWebView: webview)
            webview.navigationDelegate = self
            webview.load(HomeApi.oauthAuthorizePath.request)
            /*self.view.addSubview(webview)
            webview.translatesAutoresizingMaskIntoConstraints = false
            webview.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
            webview.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            webview.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
            webview.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true*/
            return webview
        }
        
        if self.passwdTextField.isFirstResponder {
            _ = self.passwdTextField.resignFirstResponder()
        }
        else if self.loginTextField.isFirstResponder {
            _ = self.loginTextField.resignFirstResponder()
        }
        self.loginButton.isUserInteractionEnabled = false
        self.loginButton.backgroundColor = self.loginButton.backgroundColor?.withAlphaComponent(HomeDesign.alphaLayer)
        self.state = .waiting
        Task.init(priority: .userInitiated, operation: {
            self.signinHandler = await newSigninHandler()
        })
    }
    private func loginErrorOccured(_ description: String, apiError: HomeApi.RequestError? = nil, showAlert: Bool = true) {
        if showAlert {
            if let error = apiError {
                DynamicAlert.presentWith(error: error)
            }
            else {
                DynamicAlert(contents: [.text(description)], actions: [.normal(~"general.ok", nil)])
            }
        }
        self.signinHandler = nil
        self.loginButton.isUserInteractionEnabled = true
        self.loginButton.backgroundColor = self.loginButton.backgroundColor?.withAlphaComponent(1.0)
        self.state = .connect
        self.user = nil
        self.coalitions = nil
        HomeDefaults.remove(.tokens)
        HomeDefaults.remove(.cookies)
        HomeDefaults.remove(.user)
        HomeDefaults.remove(.coalitions)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        func javascriptError(_ object: Any?, error: Error?) {
            if let error = error {
                DispatchQueue.main.async {
                    self.loginErrorOccured(error.localizedDescription)
                }
            }
        }
        
        #if DEBUG
        print(self.state, #function)
        print(webView.url!.host!, webView.url!.path)
        print()
        #endif
        switch self.state {
        case .signin:
            let login = String(format: "document.getElementById(\"user_login\").value = \"%@\";", self.loginTextField.text!)
            let passw = String(format: "document.getElementById(\"user_password\").value = \"%@\";", self.passwdTextField.text!)
            
            webView.evaluateJavaScript(login, completionHandler: javascriptError(_:error:))
            webView.evaluateJavaScript(passw, completionHandler: javascriptError(_:error:))
            webView.evaluateJavaScript("document.querySelector(\'[name=\"commit\"]\').click();", completionHandler: javascriptError(_:error:))
        case .signin2FA:
            let style: DynamicAlert.Style
            
            func tryCode(code: String) {
                let codeJS = "document.getElementById(\"users_code\").value = \"\(code)\""
                let commitJS = "document.querySelector(\'[name=\"commit\"]\').click();"
                
                webView.evaluateJavaScript(codeJS, completionHandler: javascriptError(_:error:))
                webView.evaluateJavaScript(commitJS, completionHandler: javascriptError(_:error:))
            }
            
            func cancelAuthentification() {
                self.loginErrorOccured(~"general.error", showAlert: false)
            }
            
            if !webView.url!.absoluteString.contains("new") {
                style = .withPrimary(~"general.error", HomeDesign.redError)
            }
            else {
                style = .primary(~"general.warning")
            }
            DynamicAlert(style, contents: [.title("Intra 2FA"), .textEditor("")], actions: [.normal(~"general.cancel", cancelAuthentification), .textEditor(tryCode(code:))])
        case .authorize:
            webView.evaluateJavaScript("document.forms[0].submit();", completionHandler: javascriptError(_:error:))
        default:
            if webView.url!.absoluteString.hasPrefix("https://profile.intra.42.fr") {
                self.state = .cookie
                Task.init(priority: .userInitiated, operation: {
                    do {
                        try await self.profilLoaded()
                    }
                    catch {
                        if error is HomeApi.RequestError {
                            self.loginErrorOccured("???", apiError: error as? HomeApi.RequestError)
                        }
                        else {
                            self.loginErrorOccured(error.localizedDescription, apiError: nil)
                        }
                    }
                })
            }
        }
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        let path = webView.url!.absoluteString
        
        #if DEBUG
        print(self.state, #function)
        print(webView.url!.host!, webView.url!.path)
        print()
        #endif
        if path.hasPrefix("https://signin.intra.42.fr/users/sign_in") {
            DispatchQueue.main.async {
                if self.state == .signin {
                    self.loginErrorOccured(~"login.error.passwd-incorrect")
                }
                else {
                    self.state = .signin
                }
            }
        }
        else if path.hasPrefix("https://signin.intra.42.fr/intra_otp_sessions") {
            DispatchQueue.main.async {
                self.state = .signin2FA
            }
        }
        else if path.hasPrefix("https://api.intra.42.fr/oauth/authorize") {
            DispatchQueue.main.async {
                self.state = .authorize
            }
        }
        else if path.hasPrefix("https://intra.42.fr/?code=") {
            DispatchQueue.main.async {
                self.state = .loading
                self.codeReceived((webView.url!.query! as NSString).substring(from: 5))
            }
        }
        else if path.hasPrefix("https://profile.intra.42.fr") == false { // must clear old cookies catch before redirect
            self.loginErrorOccured(String(format: ~"login.error.unexpected-redirection", path))
        }
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.loginErrorOccured(error.localizedDescription)
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.loginErrorOccured(error.localizedDescription)
    }
    
    private var user: IntraUser!
    private var coalitions: ContiguousArray<IntraCoalition>!
    private func codeReceived(_ code: String) {
        Task.init(priority: .userInitiated, operation: {
            do {
                try await HomeApi.auth(code)
                #if false
                self.user = try await HomeApi.get(.userWithId(128443))
                self.coalitions = try await HomeApi.get(.usersWithUserIdCoalitions(128443))
                #else
                self.user = try await HomeApi.get(.me)
                self.coalitions = try await HomeApi.get(.usersWithUserIdCoalitions(user.id))
                #endif
                try await self.profilLoaded()
            }
            catch {
                self.loginErrorOccured("???", apiError: error as? HomeApi.RequestError)
            }
        })
    }
    
    @MainActor private func profilLoaded() async throws {
        guard self.state == .cookie && self.user != nil && self.coalitions != nil else { return }
        
        if let cookies = await Cookies(httpCookies: await Cookies.readWebsiteCookies(targettingWebView: self.signinHandler), verifyingWithUser: self.user) {
            App.setApp(user: user, coalitions: coalitions)
            self.dismiss(animated: true, completion: nil)
            HomeDefaults.save(cookies, forKey: .cookies)
            HomeDefaults.save(user, forKey: .user)
            HomeDefaults.save(coalitions, forKey: .coalitions)
        }
        else {
            throw HomeApi.RequestError(status: .internal, path: "https://profile.intra.42.fr", data: nil, parameters: nil, serverMessage: "cookies are invalid")
        }
    }
}

extension LoginViewController {
    
    final class LoginTextFieldUpperText: BasicUILabel {
        
        @frozen enum Text: String {
            case login = "general.login"
            case passwd = "general.passwd"
        }
        init(_ text: Text) {
            super.init(text: ~text.rawValue)
            self.textColor = HomeDesign.white
            self.font = HomeLayout.fontRegularNormal
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }
            
            self.heightAnchor.constraint(equalToConstant: 16.0).isActive = true
        }
    }
    
    final class LoginTextField: BasicUITextField {
        
        @frozen enum Config {
            case login
            case passwd
        }
        
        init(_ config: LoginTextField.Config) {
            super.init()
            self.backgroundColor = HomeDesign.blackLayer
            self.tintColor = HomeDesign.primaryDefault
            self.textColor = HomeDesign.white
            self.textAlignment = .center
            self.keyboardAppearance = HomeDesign.keyboardAppearance
            self.layer.cornerRadius = HomeLayout.dcorner
            self.layer.borderWidth = HomeLayout.border
            self.layer.borderColor = HomeDesign.primaryDefault.cgColor
            self.font = HomeLayout.fontSemiBoldMedium
            switch config {
            case .login:
                self.textContentType = .username
                self.returnKeyType = .next
            case .passwd:
                self.textContentType = .password
                self.isSecureTextEntry = true
                self.returnKeyType = .done
            }
        }
        required init?(coder: NSCoder) { fatalError("kill the noise - FUK UR MGMT ( NGHTMRE remix )") }

        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }

            self.heightAnchor.constraint(equalToConstant: HomeLayout.loginFormElementHeigth).isActive = true
        }
    }
    
    final class LoginButton: BasicUIButton {
        
        init(title: String, color: UIColor) {
            super.init()
            self.setAttributedTitle(.init(string: title.uppercased(), attributes: [.foregroundColor: HomeDesign.white, .font: HomeLayout.fontBoldTitle]), for: .normal)
            self.backgroundColor = color
            self.layer.cornerRadius = HomeLayout.dcorner
            self.layer.masksToBounds = true
        }
        
        override init() {
            super.init()
            self.setAttributedTitle(.init(string: (~"login.state.connect").uppercased(), attributes: [.foregroundColor: HomeDesign.white, .font: HomeLayout.fontBoldTitle]), for: .normal)
            self.backgroundColor = HomeDesign.primaryDefault
            self.layer.cornerRadius = HomeLayout.dcorner
            self.layer.masksToBounds = true
        }
        required init?(coder: NSCoder) { fatalError("kill the noise - kill 4 the kids ( slander remix )") }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }
       
            self.heightAnchor.constraint(equalToConstant: HomeLayout.loginFormElementHeigth).isActive = true
        }
        
        func reset() {
            self.setAttributedTitle(.init(string: (~"login.state.connect").uppercased(), attributes: [.foregroundColor: HomeDesign.white, .font: HomeLayout.fontBoldTitle]), for: .normal)
        }
    }
}
