//
//  AppDelegate.swift
//  home42
//
//  Created by Antoine Feuerstein on 10/04/2021.
//

import UIKit

internal var App: HomeApplication! = nil

final class HomeApplication: UIApplication, UIApplicationDelegate {
    
    lazy var window: UIWindow? = HomeApplication.AppUIWindow(frame: UIScreen.main.bounds)
    lazy var mainController = MainViewController()
    
    lazy var safeAera: UIEdgeInsets = {
        return self.window!.safeAreaInsets
    }()
    lazy var safeAeraMain: UIEdgeInsets = {
        return .init(top: self.window!.safeAreaInsets.top + HomeLayout.mainSelectionSize + HomeLayout.margin * 2.0 + HomeLayout.smargin,
                     left: self.window!.safeAreaInsets.left,
                     bottom: self.window!.safeAreaInsets.bottom,
                     right: self.window!.safeAreaInsets.right)
    }()
    
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
        HomeApi.cookie = nil
        self.mainController.logout()
        self.settings.logout()
    }
    
    private func prepare() {
        HomeWords.set(code: "FR")
        _ = self.settings
        HomeApiResources.prepare()
        HomeAnimations.prepare()
    }
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        App = self
        self.window!.rootViewController = self.mainController
        if let user: IntraUser = HomeDefaults.read(.user), let coalitions: ContiguousArray<IntraCoalition> = HomeDefaults.read(.coalitions),
           let tokens: HomeApi.OAuthTokens = HomeDefaults.read(.tokens), let cookie: String = HomeDefaults.read(.cookie) {
            HomeApi.tokens = tokens
            HomeApi.cookie = cookie
            self.prepare()
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
        return true
    }
    
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        HomeResources.clearCache()
    }
    
    final private class AppUIWindow: UIWindow {
        
        override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
            if motion == .motionShake && App.userLoggedIn {
                HomeCafards.generateReport()
            }
        }
    }
}
