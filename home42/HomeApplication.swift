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
    
    private func checkUpdate() {
        let currentVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let identifier = Bundle.main.infoDictionary!["CFBundleIdentifier"] as! String
        let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(identifier)")!
        
        struct ItunesLookup: Codable {
            let releaseDate: String
            let releaseNotes: String
            let version: String
        }
        struct ItunesLookupResult: Codable {
            let results: [ItunesLookup]
        }
        
        @MainActor func showAlert(_ lookup: ItunesLookup) {
            DynamicAlert(contents: [.text(lookup.releaseNotes)], actions: [.normal(~"general.ok", nil), .highligth(~"general.see", {
                self.open(URL(string: "https://apps.apple.com/fr/app/42-home/id1602117968")!)
            })])
        }
        
        func value(forVersion version: String) -> Int {
            var value = 0
            let numbers = version.split(separator: ".").map({ Int($0) }).compactMap({ $0 })
            
            if numbers.count > 0 {
                for index in 0 ..< numbers.count {
                    value *= 100
                    value += numbers[index]
                }
            }
            return value
        }
        
        Task {
            do {
                let (data, response) = try await HomeApi.urlSession.data(from: url)
                
                if (response as! HTTPURLResponse).statusCode == 200, let lookup = (try JSONDecoder.decoder.decode(ItunesLookupResult.self, from: data)).results.first {
                    if value(forVersion: currentVersion) < value(forVersion: lookup.version) {
                        showAlert(lookup)
                    }
                }
            }
            catch {
                #if DEBUG
                print(error)
                #endif
            }
        }
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
            self.checkUpdate()
        }
        else {
            self.user = nil
            self.coalitions = nil
            self.userCampus = nil
            self.userCursus = nil
            self.userCoalition = nil
            self.prepare()
            self.checkUpdate()
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
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return HomeDeeplinks.handle(url.absoluteString)
    }
    
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        HomeResources.clearCache()
    }
    
    var userLanguage: IntraLanguage {
        
        func defaultLanguage() -> IntraLanguage {
            let localIdentifier: String
            
            if #available(iOS 16, *) {
                localIdentifier = (Locale.current.regionCode ?? Locale.current.language.languageCode?.identifier ?? "en").lowercased()
            }
            else {
                localIdentifier = (Locale.current.regionCode ?? Locale.current.languageCode ?? "en").lowercased()
            }
            return HomeApiResources.languages.first(where: {
                $0.identifier == localIdentifier && HomeWords.exist($0)
            }) ?? HomeApiResources.languages.first(where: { $0.identifier == "en" })!
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
