//
//  LoginViews.swift
//  home42
//
//  Created by Antoine Feuerstein on 10/04/2021.
//

import Foundation
import UIKit
import WebKit
import SVGKit

final class LoginViewController: HomeViewController, UITextFieldDelegate, WKNavigationDelegate, Keyboard {
    
    private let background: BasicUIImageView
    private let logoCenter: BasicUIView
    private let logo42: SVGKFastImageView
    
    private let formContainer: BasicUIView
    private var formContainerCenterY: NSLayoutConstraint!
    private let loginLabel: BasicUILabel
    private let loginTextField: HomeLoginTextField
    private let passwdLabel: BasicUILabel
    private let passwdTextField: HomeLoginTextField
    private let loginButton: HomeLoginButton
    
    private let conditionsLabel: BasicUILabel
    
    required init() {
        self.background = BasicUIImageView(asset: .coalitionDefaultBackground)
        self.background.contentMode = .scaleAspectFill
        self.logoCenter = BasicUIView()
        self.logo42 = SVGKFastImageView(svgkImage: HomeResources.svgLogo42)
        self.logo42.contentMode = .center
        self.logo42.image.fillWith(color: HomeDesign.white)
        self.logo42.translatesAutoresizingMaskIntoConstraints = false
        
        self.formContainer = BasicUIView()
        self.formContainer.backgroundColor = .clear
        self.loginLabel = BasicUILabel(text: ~"LOGIN")
        self.loginLabel.textColor = HomeDesign.white
        self.loginLabel.font = HomeLayout.fontRegularNormal
        self.loginTextField = HomeLoginTextField()
        self.loginTextField.textContentType = .username
        self.loginTextField.returnKeyType = .next
        self.passwdLabel = BasicUILabel(text: ~"PASSWD")
        self.passwdLabel.textColor = HomeDesign.white
        self.passwdLabel.font = HomeLayout.fontRegularNormal
        self.passwdTextField = HomeLoginTextField()
        self.passwdTextField.textContentType = .password
        self.passwdTextField.isSecureTextEntry = true
        self.passwdTextField.returnKeyType = .done
        self.loginButton = HomeLoginButton()
        
        self.conditionsLabel = BasicUILabel(attribute: NSAttributedString.init(string: ~"CONDITIONS", attributes: [
                                                                                    .underlineStyle: NSUnderlineStyle.single.rawValue,
                                                                                        .font: HomeLayout.fontThinMedium,
                                                                                        .foregroundColor: HomeDesign.white]))
        super.init()
        self.modalPresentationStyle = .fullScreen
        self.view.addSubview(self.background)
        if App.settings.graphicsUseParallax {
            self.background.setUpParallaxEffect(usingAmout: App.settings.graphicsParallaxForce.rawValue)
            self.background.topAnchor.constraint(equalTo: self.view.topAnchor, constant: -App.settings.graphicsParallaxForce.rawValue).isActive = true
            self.background.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: App.settings.graphicsParallaxForce.rawValue).isActive = true
            self.background.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: -App.settings.graphicsParallaxForce.rawValue).isActive = true
            self.background.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: App.settings.graphicsParallaxForce.rawValue).isActive = true
        }
        else {
            self.background.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
            self.background.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
            self.background.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            self.background.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        }
        
        self.view.addSubview(self.formContainer)
        self.formContainerCenterY = self.formContainer.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        self.formContainerCenterY.isActive = true
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
        self.loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        self.loginTextField.delegate = self
        self.passwdTextField.delegate = self
        self.conditionsLabel.isUserInteractionEnabled = true
        self.conditionsLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(termButtonTapped(sender:))))
        self.keyboardInterfaceSetup()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.loginTextField {
            return self.passwdTextField.becomeFirstResponder()
        }
        self.loginButtonTapped()
        return self.passwdTextField.resignFirstResponder()
    }
    
    private func keyboardAdjust(curve: UIView.AnimationCurve, duration: TimeInterval, frame: CGRect) {
        let formPosY = self.formContainer.offsetFromYBottomOrigin(fromParent: self.view) + HomeLayout.margin
        let keyboardTopPosY = UIScreen.main.bounds.height - frame.height
        let diff: CGFloat = formPosY - keyboardTopPosY
        let duration = duration == 0.0 ? HomeAnimations.durationShort : duration
        
        if formPosY > keyboardTopPosY && self.formContainerCenterY.constant != -diff {
            UIView.animate(withDuration: duration, delay: 0.0, options: curve.animationOptions, animations: {
                self.formContainerCenterY.constant = -diff
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    func keyboardWillShow(curve: UIView.AnimationCurve, duration: TimeInterval, frame: CGRect) { self.keyboardAdjust(curve: curve, duration: duration, frame: frame) }
    func keyboardWillChangeFrame(curve: UIView.AnimationCurve, duration: TimeInterval, frame: CGRect) { self.keyboardAdjust(curve: curve, duration: duration, frame: frame) }
    func keyboardWillHide(curve: UIView.AnimationCurve, duration: TimeInterval, frame: CGRect) {
        if self.passwdTextField.isFirstResponder && self.formContainerCenterY.constant != 0.0 {
            UIView.animate(withDuration: duration == 0.0 ? HomeAnimations.durationShort : duration, delay: 0.0, options: curve.animationOptions, animations: {
                self.formContainerCenterY.constant = 0.0
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    @objc private func termButtonTapped(sender: UITapGestureRecognizer) {
        self.present(SafariWebView(URL(string: "https://signin.intra.42.fr/legal")!), animated: true, completion: nil)
    }
    
    @frozen private enum State: String {
        case connect   = "LOGIN_CONNECT"
        case waiting   = "LOGIN_WAITING"
        case signin    = "LOGIN_SIGNIN"
        case authorize = "LOGIN_AUTHORIZE"
        case loading   = "LOGIN_LOADING"
        case cookie    = "LOGIN_COOKIE"
    }
    private var state: State = .connect {
        didSet {
            self.loginButton.setAttributedTitle(.init(string: (~self.state.rawValue).uppercased(),
                                                      attributes: [.foregroundColor: HomeDesign.white, .font: HomeLayout.fontBoldTitle]), for: .normal)
        }
    }
    
    private var signinHandler: WKWebView? = nil
    private var newSigninHandler: WKWebView {
        let config: WKWebViewConfiguration
        let webview: WKWebView
        
        self.clearCache()
        self.cookies.removeAll()
        config = WKWebViewConfiguration()
        config.processPool = WKProcessPool()
        webview = WKWebView(frame: .zero, configuration: config)
        webview.navigationDelegate = self
        webview.load(HomeApi.oauthAuthorizePath.request)
        return webview
    }
    
    @objc private func loginButtonTapped() {
        guard let login = self.loginTextField.text, !login.isEmpty, let passwd = self.passwdTextField.text, !passwd.isEmpty else {
            if !self.loginTextField.text!.isEmpty || !self.passwdTextField.text!.isEmpty {
                DynamicAlert(contents: [.text(~"LOGIN_PASS_REQUIRED")], actions: [.normal(~"OK", nil)])
            }
            return
        }
        
        self.loginButton.isUserInteractionEnabled = false
        self.loginButton.backgroundColor = self.loginButton.backgroundColor?.withAlphaComponent(HomeDesign.alphaLayer)
        self.state = .waiting
        self.signinHandler = self.newSigninHandler
    }
    private func loginErrorOccured(_ description: String, apiError: HomeApi.RequestError? = nil) {
        if let error = apiError {
            DynamicAlert.presentWith(error: error)
        }
        else {
            DynamicAlert(contents: [.text(description)], actions: [.normal(~"OK", nil)])
        }
        self.signinHandler = nil
        self.loginButton.isUserInteractionEnabled = true
        self.loginButton.backgroundColor = self.loginButton.backgroundColor?.withAlphaComponent(1.0)
        self.state = .connect
        self.user = nil
        self.coalitions = nil
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
                    self.loginErrorOccured(~"LOGIN_PASS_INCORRECT")
                }
                else {
                    self.state = .signin
                }
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
        else if path.hasPrefix("https://profile.intra.42.fr") == false {
            self.loginErrorOccured(String(format: ~"BAD_REDIRECTION", path))
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
                self.user = try await HomeApi.get(.me)
                self.coalitions = try await HomeApi.get(.usersWithUserIdCoalitions(user.id))
                try await self.profilLoaded()
            }
            catch {
                self.loginErrorOccured("???", apiError: error as? HomeApi.RequestError)
            }
        })
    }
    
    @MainActor private func profilLoaded() async throws {
        guard self.state == .cookie && self.user != nil && self.coalitions != nil else { return }
        
        await self.readCookies()
        try await self.verifyCookies()
        App.setApp(user: user, coalitions: coalitions)
        self.dismiss(animated: true, completion: nil)
        HomeDefaults.save(user, forKey: .user)
        HomeDefaults.save(coalitions, forKey: .coalitions)
    }
    
    private var cookies: Set<String> = []
    @MainActor private func readCookies() async {
        self.filterCookies(await WKWebsiteDataStore.default().httpCookieStore.allCookies())
        if let cookies = HTTPCookieStorage.shared.cookies {
            self.filterCookies(cookies)
        }
    }
    private func filterCookies(_ cookies: [HTTPCookie]) {
        for cookie in cookies where cookie.name == HomeApi.cookieName {
            self.cookies.insert(cookie.value)
        }
        #if DEBUG
        print(#function, cookies.count, "total found: ", self.cookies.count)
        #endif
    }
    
    private func verifyCookies() async throws {
        var lastError: Error!
        let cursusId = self.user.primaryCursus?.cursus_id ?? 1
        let parameters: [String: Any] = ["login": self.user.login, "cursus_id": cursusId]
        
        for cookie in self.cookies {
            HomeApi.cookie = cookie
            do {
                let _: ContiguousArray<IntraNetGraphProject> = try await HomeApi.intranetRequest(.graph, parameters: parameters)
                
                return HomeDefaults.save(cookie, forKey: .cookie)
            }
            catch {
                #if DEBUG
                print(#function, error)
                #endif
                lastError = error
                continue
            }
        }
        if lastError != nil {
            throw lastError
        }
        throw HomeApi.RequestError(status: .internal, path: HomeApi.IntranetRoute.graph.path, data: nil, parameters: parameters, serverMessage: "???")
    }
    
    private func clearCache() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        URLCache.shared.removeAllCachedResponses()
        URLSession.shared.flush { // await 
            
        }
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
}

private extension LoginViewController {
    
    final class HomeLoginTextField: BasicUITextField {
        
        override init() {
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
        }
        required init?(coder: NSCoder) { fatalError("kill the noise - FUK UR MGMT ( NGHTMRE remix )") }

        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }

            self.heightAnchor.constraint(equalToConstant: HomeLayout.loginFormElementHeigth).isActive = true
        }
    }
    
    final class HomeLoginButton: BasicUIButton {
        
        override init() {
            super.init()
            self.setAttributedTitle(.init(string: (~"LOGIN_CONNECT").uppercased(), attributes: [.foregroundColor: HomeDesign.white, .font: HomeLayout.fontBoldTitle]), for: .normal)
            self.backgroundColor = HomeDesign.primaryDefault
            self.layer.cornerRadius = HomeLayout.dcorner
            self.layer.masksToBounds = true
        }
        required init?(coder: NSCoder) { fatalError("kill the noise - kill 4 the kids ( slander remix )") }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }
       
            self.heightAnchor.constraint(equalToConstant: HomeLayout.loginFormElementHeigth).isActive = true
        }
    }
}
