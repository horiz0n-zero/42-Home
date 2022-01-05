//
//  Image.swift
//  home42
//
//  Created by Antoine Feuerstein on 16/04/2021.
//

import Foundation
import UIKit

extension UIImage {
    
    @frozen enum Assets: String, Codable {
        case coalitionDefaultBackground = "background_default"
        case defaultLoginAnonym = "login_default_anonym"
        case defaultLogin = "login_default"
        
        case trophy = "trophy"
        case settingsAppIcon = "settings_app_icon"
        
        case actionClose    = "action_close"
        case actionPeople   = "action_people"
        case actionAdd      = "action_add"
        case actionEnemies  = "action_enemies"
        case actionFriends  = "action_friends"
        case actionRefresh  = "action_refresh"
        case actionSearch   = "action_search"
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
        
        case settingsDonation = "settings_donation"
        case settingsCafard = "settings_cafard"
        case settingsCode = "settings_code"
        case settingsWeb = "settings_web"
        
        case extraAppFacetime = "extra_app_facetime"
        case extraAppFiles = "extra_app_files"
        case extraAppMessage = "extra_app_message"
        case extraAppPhoto = "extra_app_photo"
        case extraAppPlan = "extra_app_plan"
        case extraAppSafari = "extra_app_safari"
        
        var image: UIImage {
            return UIImage(named: self.rawValue)!
        }
        var safeImage: UIImage? {
            return UIImage(named: self.rawValue)
        }
    }
}
