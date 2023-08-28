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

protocol LoginHandlerDelegate: AnyObject {
    
    func loginHandlerSuccessfullyLogin(user: IntraUser, coalitions: ContiguousArray<IntraCoalition>, cookies: Cookies)
    func loginHandlerAbandonLogin()
}

final class LoginHandler: HomeViewController, WKNavigationDelegate {
    
    private let topBlurView: BasicUIVisualEffectView
    private let backButtonContainer: BasicUIView
    private let backButtonLabel: BasicUILabel
    private let stateLabel: VibrancyView<BasicUILabel>
    
    private let webView: WKWebView
    private unowned(unsafe) let loginDelegate: LoginHandlerDelegate
    
    private var user: IntraUser! = nil
    private var coalitions: ContiguousArray<IntraCoalition>! = nil
    private var cookie: Bool = false
    
    init(loginDelegate: LoginHandlerDelegate) async {
        let config: WKWebViewConfiguration
        let request = HomeApi.oauthAuthorizePath.request
        
        config = WKWebViewConfiguration()
        config.processPool = WKProcessPool()
        self.topBlurView = .init()
        self.backButtonContainer = BasicUIView()
        self.backButtonContainer.backgroundColor = HomeDesign.primaryDefault.withAlphaComponent(HomeDesign.alphaLowLayer)
        self.backButtonContainer.layer.cornerRadius = HomeLayout.corner
        self.backButtonContainer.layer.masksToBounds = true
        self.backButtonLabel = BasicUILabel(text: ~"general.cancel")
        self.backButtonLabel.font = HomeLayout.fontSemiBoldMedium
        self.backButtonLabel.textAlignment = .center
        self.backButtonLabel.textColor = HomeDesign.primaryDefault
        self.stateLabel = .init(effect: self.topBlurView.effect, view: .init(text: request.url!.host!))
        self.stateLabel.view.textAlignment = .right
        self.stateLabel.view.font = HomeLayout.fontSemiBoldTitle
        self.webView = WKWebView(frame: UIScreen.main.bounds, configuration: config)
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        await Cookies.clearWebsiteData(targettingWebView: self.webView)
        self.webView.load(request)
        self.loginDelegate = loginDelegate
        super.init()
        self.modalPresentationStyle = .fullScreen
        self.webView.navigationDelegate = self
        self.webView.scrollView.contentInsetAdjustmentBehavior = .never
        self.view.addSubview(self.webView)
        self.webView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.view.addSubview(self.topBlurView)
        self.topBlurView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.topBlurView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.topBlurView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.topBlurView.heightAnchor.constraint(equalToConstant: App.window!.safeAreaInsets.top + 40.0).isActive = true
        self.backButtonContainer.isUserInteractionEnabled = true
        self.backButtonContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LoginHandler.backButtonTapped)))
        self.topBlurView.contentView.addSubview(self.backButtonContainer)
        self.backButtonContainer.leadingAnchor.constraint(equalTo: self.topBlurView.contentView.leadingAnchor, constant: HomeLayout.margin).isActive = true
        self.backButtonContainer.bottomAnchor.constraint(equalTo: self.topBlurView.contentView.bottomAnchor, constant: -HomeLayout.smargin).isActive = true
        self.backButtonContainer.addSubview(self.backButtonLabel)
        self.backButtonLabel.centerXAnchor.constraint(equalTo: self.backButtonContainer.centerXAnchor).isActive = true
        self.backButtonLabel.centerYAnchor.constraint(equalTo: self.backButtonContainer.centerYAnchor).isActive = true
        self.backButtonLabel.leadingAnchor.constraint(equalTo: self.backButtonContainer.leadingAnchor, constant: HomeLayout.margin).isActive = true
        self.backButtonLabel.topAnchor.constraint(equalTo: self.backButtonContainer.topAnchor, constant: HomeLayout.dmargin).isActive = true
        self.topBlurView.contentView.addSubview(self.stateLabel)
        self.stateLabel.trailingAnchor.constraint(equalTo: self.topBlurView.contentView.trailingAnchor, constant: -HomeLayout.margin).isActive = true
        self.stateLabel.centerYAnchor.constraint(equalTo: self.backButtonContainer.centerYAnchor).isActive = true
    }
    required init?(coder: NSCoder) { fatalError() }
    required init() { fatalError("init() has not been implemented") }
        
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        #if DEBUG
        print(#function, webView.url!.host!, webView.url!.path)
        print()
        #endif
        self.stateLabel.view.text = webView.url!.host!
        if webView.url!.absoluteString.hasPrefix("https://intra.42.fr/?code=") {
            self.codeReceived((webView.url!.query! as NSString).substring(from: 5))
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        #if DEBUG
        print(#function, webView.url!.host!, webView.url!.path)
        print()
        #endif
        if webView.url!.absoluteString.hasPrefix("https://profile.intra.42.fr") {
            self.cookie = true
            Task.init(priority: .userInitiated, operation: {
                do {
                    try await self.nextStep()
                }
                catch {
                    self.errorOccured(error: error as? HomeApi.RequestError)
                }
            })
        }
    }
    
    @MainActor private func errorOccured(error: HomeApi.RequestError?) {
        self.user = nil
        self.coalitions = nil
        self.cookie = false
        HomeDefaults.remove(.tokens)
        HomeDefaults.remove(.cookies)
        HomeDefaults.remove(.user)
        HomeDefaults.remove(.coalitions)
        if let error = error {
            DynamicAlert.presentWith(error: error)
            self.loginDelegate.loginHandlerAbandonLogin()
        }
    }
    
    private func codeReceived(_ code: String) {
        Task.init(priority: .userInitiated, operation: {
            do {
                
                @MainActor func updateState(_ text: String) {
                    self.stateLabel.view.text = text
                }
                
                try await HomeApi.auth(code)
                updateState("/v2/me")
                self.user = try await HomeApi.get(.me)
                updateState("/v2/coalitions")
                self.coalitions = try await HomeApi.get(.usersWithUserIdCoalitions(user.id))
                try await self.nextStep()
            }
            catch {
                self.errorOccured(error: error as? HomeApi.RequestError)
            }
        })
    }
    
    @MainActor private func nextStep() async throws {
        guard self.cookie && self.user != nil && self.coalitions != nil else {
            return
        }
        
        self.stateLabel.view.text = "verifying cookies ..."
        if let cookies = await Cookies(httpCookies: await Cookies.readWebsiteCookies(targettingWebView: self.webView), verifyingWithUser: self.user) {
            HomeDefaults.save(cookies, forKey: .cookies)
            HomeDefaults.save(user, forKey: .user)
            HomeDefaults.save(coalitions, forKey: .coalitions)
            self.loginDelegate.loginHandlerSuccessfullyLogin(user: self.user, coalitions: self.coalitions, cookies: cookies)
        }
        else {
            throw HomeApi.RequestError(status: .internal, path: "https://profile.intra.42.fr", data: nil, parameters: nil, serverMessage: "cookies are invalid")
        }
    }
    
    @objc private func backButtonTapped() {
        self.loginDelegate.loginHandlerAbandonLogin()
    }
}

final class LoginViewController: HomeViewController, LoginHandlerDelegate {
    
    private let background: BasicUIImageView
    private let logoCenter: BasicUIView
    private let logo42: BasicUIImageView
    
    private let loginButton: LoginButton
    
    private let conditionsLabel: BasicUILabel
    private let sourceCodeLabel: BasicUILabel
    
    private unowned let animatedCoalitionsBloc: IntraBloc
    private var animatedCoalitionsBlocIndex: Int
    private var animatedCoalitionsBlocTask: Task<(), Never>!
    
    required init() {
        self.background = BasicUIImageView(asset: .coalitionDefaultBackground)
        self.logoCenter = BasicUIView()
        self.logo42 = .init(asset: .appIconBig)
        self.logo42.contentMode = .scaleAspectFit
        self.logo42.tintColor = HomeDesign.white
        self.logo42.translatesAutoresizingMaskIntoConstraints = false

        self.loginButton = LoginButton()
        
        self.conditionsLabel = BasicUILabel(attribute: NSAttributedString.init(string: ~"login.cgu", attributes: [
                                                                                .underlineStyle: NSUnderlineStyle.single.rawValue,
                                                                                .font: HomeLayout.fontThinMedium,
                                                                                .foregroundColor: HomeDesign.white]))
        self.sourceCodeLabel = BasicUILabel(attribute: NSAttributedString.init(string: ~"settings.extra.code", attributes: [
                                                                                .underlineStyle: NSUnderlineStyle.single.rawValue,
                                                                                .font: HomeLayout.fontThinMedium,
                                                                                .foregroundColor: HomeDesign.white]))
        self.animatedCoalitionsBloc = HomeApiResources.blocs.first(where: { $0.campus_id == 1 })!
        self.animatedCoalitionsBlocIndex = self.animatedCoalitionsBloc.coalitions.firstIndex(where: { $0.name == "The Federation" }) ?? 0
        self.animatedCoalitionsBlocTask = nil
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
        
        self.view.addSubview(self.loginButton)
        self.loginButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        self.loginButton.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: HomeLayout.margind).isActive = true
        self.loginButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        self.view.addSubview(self.logoCenter)
        self.logoCenter.bottomAnchor.constraint(equalTo: self.loginButton.topAnchor, constant: -HomeLayout.margin).isActive = true
        self.logoCenter.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: HomeLayout.margin).isActive = true
        self.logoCenter.leadingAnchor.constraint(equalTo: self.loginButton.leadingAnchor).isActive = true
        self.logoCenter.trailingAnchor.constraint(equalTo: self.loginButton.trailingAnchor).isActive = true
        self.logoCenter.addSubview(self.logo42)
        self.logo42.centerYAnchor.constraint(equalTo: self.logoCenter.centerYAnchor).isActive = true
        self.logo42.centerXAnchor.constraint(equalTo: self.logoCenter.centerXAnchor).isActive = true
        self.logo42.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.70).isActive = true
        self.logo42.heightAnchor.constraint(equalTo: self.logo42.widthAnchor, multiplier: 1.0).isActive = true
        
        self.view.addSubview(self.conditionsLabel)
        self.conditionsLabel.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -HomeLayout.margin).isActive = true
        self.conditionsLabel.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -HomeLayout.margin).isActive = true
        self.view.addSubview(self.sourceCodeLabel)
        self.sourceCodeLabel.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: HomeLayout.margin).isActive = true
        self.sourceCodeLabel.bottomAnchor.constraint(equalTo: self.conditionsLabel.bottomAnchor).isActive = true
        
        self.loginButton.addTarget(self, action: #selector(LoginViewController.loginButtonTapped), for: .touchUpInside)
        self.conditionsLabel.isUserInteractionEnabled = true
        self.conditionsLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LoginViewController.termButtonTapped(sender:))))
        self.sourceCodeLabel.isUserInteractionEnabled = true
        self.sourceCodeLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LoginViewController.sourceCodeTapped(sender:))))
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.animatedCoalitionsBlocTask == nil {
            self.startAnimation()
        }
    }
    
    deinit {
        self.animatedCoalitionsBlocTask?.cancel()
    }
    
    private func startAnimation() {
        self.animatedCoalitionsBlocTask = .init(operation: { [weak self] in
            do {
                func animate() async throws {
                    guard let `self` = self else { return }
                    let image: UIImage
                    let coalition = await self.animatedCoalitionsBloc.coalitions[self.animatedCoalitionsBlocIndex]
                    
                    if let coalitionImage = HomeResources.storageCoalitionsImages.get(coalition) {
                        image = coalitionImage
                    }
                    else if let (_, coalitionImage) = await HomeResources.storageCoalitionsImages.obtain(coalition) {
                        image = coalitionImage
                    }
                    else {
                        image = UIImage.Assets.coalitionDefaultBackground.image
                    }
                    
                    @MainActor func applyChange() {
                        HomeAnimations.transitionLong(withView: self.background, {
                            self.background.image = image
                            self.loginButton.backgroundColor = coalition.uicolor
                        })
                        self.animatedCoalitionsBlocIndex &+= 1
                        if self.animatedCoalitionsBlocIndex >= self.animatedCoalitionsBloc.coalitions.count {
                            self.animatedCoalitionsBlocIndex = 0
                        }
                    }
                    await applyChange()
                    try await Task.sleep(nanoseconds: 5_000_000_000)
                    try await animate()
                }
                try await Task.sleep(nanoseconds: 1_000_000_000)
                try await animate()
            }
            catch {
                #if DEBUG
                print(#function, error)
                #endif
            }
        })
    }
    
    @objc private func termButtonTapped(sender: UITapGestureRecognizer) {
        self.present(SafariWebView(URL(string: "https://signin.intra.42.fr/legal")!, primaryColor: self.loginButton.backgroundColor!), animated: true, completion: nil)
    }
    @objc private func sourceCodeTapped(sender: UITapGestureRecognizer) {
        var actions: [DynamicActionsSheet.Action] = [.title(~"github.title"), .text(~"github.text")]
        
        actions += DynamicActionsSheet.actionsForWebLink("https://github.com/horiz0n-zero/42-Home", parentViewController: self)
        DynamicActionsSheet(actions: actions, primary: self.loginButton.backgroundColor!)
    }
    
    private var handler: LoginHandler? = nil
    
    @MainActor @objc private func loginButtonTapped() {
        Task {
            self.loginButton.isUserInteractionEnabled = false
            self.loginButton.backgroundColor = self.loginButton.backgroundColor!.withAlphaComponent(HomeDesign.alphaLow)
            self.handler = await LoginHandler(loginDelegate: self)
            self.present(self.handler!, animated: true)
        }
    }
    
    func loginHandlerSuccessfullyLogin(user: IntraUser, coalitions: ContiguousArray<IntraCoalition>, cookies: Cookies) {
        HomeApi.cookies = cookies
        App.setApp(user: user, coalitions: coalitions)
        self.dismissToRootController(animated: true)
        self.animatedCoalitionsBlocTask?.cancel()
        self.animatedCoalitionsBlocTask = nil
    }
    func loginHandlerAbandonLogin() {
        self.loginButton.isUserInteractionEnabled = true
        self.loginButton.backgroundColor = self.loginButton.backgroundColor?.withAlphaComponent(1.0)
        self.handler!.dismiss(animated: true)
        self.handler = nil
    }
}

extension LoginViewController {
    
    final class LoginTextFieldUpperText: BasicUILabel {
        
        @frozen enum Text: String {
            case login = "general.login"
            case passwd = "general.passwd"
        }
        init(_ text: Text) {
            super.init(text: (~text.rawValue).lowercased())
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
