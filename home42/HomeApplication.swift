// home42/HomeApplication.swift
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

import UIKit

internal var App: HomeApplication! = nil

final class HomeApplication: UIApplication, UIApplicationDelegate {
    
    lazy var window: UIWindow? = HomeApplication.AppUIWindow(frame: UIScreen.main.bounds)
    lazy var mainController = MainViewController()
    
    lazy var settings: UserSettings = HomeDefaults.read(.settings) ?? UserSettings()
    var user: IntraUser!
    var userLoggedIn: Bool {
        return self.user != nil
    }
    var coalitions: ContiguousArray<IntraCoalition>!
    var userCampus: IntraUserCampus!
    var userCursus: IntraUserCursus!
    var userCoalition: IntraCoalition!
    
    func setApp(user: IntraUser, coalitions: ContiguousArray<IntraCoalition>, logginUser: Bool = true) {
        self.user = user
        self.coalitions = coalitions
        self.userCampus = user.primaryCampus
        if !logginUser {
            self.prepare()
        }
        if let primaryCursus = user.primaryCursus {
            self.userCursus = primaryCursus
            if let coalition = coalitions.primaryCoalition(campus: self.userCampus, cursus: primaryCursus) {
                self.userCoalition = coalition
                HomeDesign.primary = coalition.uicolor
            }
            else {
                self.userCoalition = nil
            }
        }
        else {
            self.userCursus = nil
            self.userCoalition = nil
        }
        if logginUser {
            HomeWords.configure(self.userLanguage)
            self.mainController.login()
        }
    }
    
    func logout() {
        self.user = nil
        self.coalitions = nil
        self.userCampus = nil
        self.userCursus = nil
        self.userCoalition = nil
        HomeResources.clearCache()
        HomeDefaults.logout()
        HomeApi.tokens = nil
        HomeApi.cookies = nil
        self.mainController.logout()
        self.settings.logout()
    }
    
    private func prepare() {
        HomeApiResources.prepare()
        HomeAnimations.prepare()
        HomeWords.configure(self.userLanguage)
        _ = self.settings
    }
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        App = self
        self.window!.rootViewController = self.mainController
        if let user: IntraUser = HomeDefaults.read(.user), let coalitions: ContiguousArray<IntraCoalition> = HomeDefaults.read(.coalitions),
           let tokens: HomeApi.OAuthTokens = HomeDefaults.read(.tokens), let cookies: Cookies = HomeDefaults.read(.cookies) {
            HomeApi.tokens = tokens
            HomeApi.cookies = cookies
            self.setApp(user: user, coalitions: coalitions, logginUser: false)
            if let coalition = self.userCoalition {
                HomeResources.storageCoalitionsImages.forceCachingIfSaved(coalition)
            }
            self.mainController.login()
        }
        else {
            self.user = nil
            self.coalitions = nil
            self.userCampus = nil
            self.userCursus = nil
            self.userCoalition = nil
            self.prepare()
        }
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        self.window!.makeKeyAndVisible()
        if self.userLoggedIn == false {
            self.mainController.present(LoginViewController(), animated: false, completion: nil)
        }
        if let deeplink = HomeDeeplinks.deeplink(from: launchOptions) {
            HomeDeeplinks.handle(deeplink)
        }
        return true
    }
    
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return HomeDeeplinks.handle(url.absoluteString)
    }
    
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        HomeResources.clearCache()
    }
    
    var userLanguage: IntraLanguage {
        
        func defaultLanguage() -> IntraLanguage {
            let localIdentifier: String
            
            if #available(iOS 16, *) {
                localIdentifier = Locale.current.language.languageCode?.identifier ?? "en"
            }
            else {
                localIdentifier = Locale.current.languageCode ?? "en"
            }
            return HomeApiResources.languages.first(where: { $0.identifier == localIdentifier }) ?? HomeApiResources.languages.first(where: { $0.identifier == "en" })!
        }
        
        if let language: IntraLanguage = HomeDefaults.read(.language) {
            return language
        }
        if let user = App.user, let language = user.languages_users.first(where: { $0.position == 1 }) {
            return HomeApiResources.languages.first(where: { $0.id == language.language_id }) ?? defaultLanguage()
        }
        return defaultLanguage()
    }
    
    final private class AppUIWindow: UIWindow {
        
        override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
            if motion == .motionShake && App.userLoggedIn {
                HomeCafards.generateReport()
            }
        }
    }
}
