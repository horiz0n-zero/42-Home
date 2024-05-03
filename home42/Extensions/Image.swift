// home42/Image.swift
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

extension UIImage {
    
    @frozen enum Assets: String, Codable {
        
        case svg42 = "svg_42"
        case svgFactionless = "svg_factionless"
        
        case coalitionDefaultBackground = "background_default"
        case defaultLoginAnonym = "login_default_anonym"
        case defaultLogin = "login_default"
        
        case trophy = "trophy"
        case settingsAppIcon = "settings_app_icon"
        case appIconBig = "app_icon_big"
        
        case actionClose    = "action_close"
        case actionPeople   = "action_people"
        case actionPeopleKo = "action_people_ko"
        case actionPeopleSunglass = "action_people_sunglass"
        case actionPeopleBore = "action_people_bore"
        case actionPeopleUnhappy = "action_people_unhappy"
        case actionPeopleHunger = "action_people_hunger"
        case actionPeopleHypnotic = "action_people_hypnotic"
        case actionPeopleNeutral = "action_people_neutral"
        case actionPeopleHumorist = "action_people_humorist"
        case actionPeopleForced = "action_people_forced"
        case actionAdd      = "action_add"
        case actionEnemies  = "action_enemies"
        case actionFriends  = "action_friends"
        case actionRefresh  = "action_refresh"
        case actionSearch   = "action_search"
        case actionLogin    = "action_login"
        case actionLogout   = "action_logout"
        case actionSee      = "action_see"
        case actionSettings = "action_settings"
        case actionSelect   = "action_select"
        case actionLock     = "action_lock"
        case actionUnlock   = "action_unlock"
        case actionArrowLeft = "action_arrow_left"
        case actionArrowRight = "action_arrow_right"
        case actionInfo       = "action_info"
        case actionAddFriends = "action_friends_add"
        case actionAddEnemies = "action_enemies_add"
        case actionWarning    = "action_warning"
        case actionValidate   = "action_validate"
        case actionGraphArrow = "action_graph_arrow"
        case actionHistoric = "action_historic"
        case actionGraph = "action_graph"
        case actionCloseAll = "action_close_all"
        case actionTrash = "action_trash"
        case actionBrush = "action_brush"
        case actionText = "action_text"
        case actionLocation = "action_location"
        case actionFeedbacks = "action_feedbacks"
        case actionShare = "action_share"
        case actionCalendar = "action_calendar"
        case actionImport = "action_import"
        
        case controllerMystere  = "controller_mystere"
        case controllerClusters = "controller_clusters"
        case controllerElearning = "controller_elearning"
        case controllerEvents = "controller_events"
        case controllerCorrections = "controller_corrections"
        case controllerResearch = "controller_research"
        case controllerTracker = "controller_tracker"
        case controllerGraph = "controller_graph"
        case controllerCompanies = "controller_companies"
        case controllerShop = "controller_shop"
        case controllerUtilites = "controller_utilities"
        
        case settingsDonation = "settings_donation"
        case settingsCafard = "settings_cafard"
        case settingsCode = "settings_code"
        case settingsWeb = "settings_web"
        case settingsMore = "settings_more"
        case settingsGuides = "settings_guide"
        case settingsTestflight = "settings_testflight"
        
        case extraAppFacetime = "extra_app_facetime"
        case extraAppFiles = "extra_app_files"
        case extraAppMessage = "extra_app_message"
        case extraAppPhoto = "extra_app_photo"
        case extraAppPlan = "extra_app_plan"
        case extraAppSafari = "extra_app_safari"
        
        case starsFull = "stars_full"
        case starsEmpty = "stars_empty"
        
        var image: UIImage {
            return UIImage(named: self.rawValue)!
        }
        var safeImage: UIImage? {
            return UIImage(named: self.rawValue)
        }
    }
}
