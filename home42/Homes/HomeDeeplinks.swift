// home42/HomeDeeplinks.swift
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

final class HomeDeeplinks: NSObject {
    
    static private let scheme: String = "home42://"
    
    @frozen enum Path: String {
        case unlock
        case events
    }
    
    @frozen enum Parameter: String {
        case controller
        case data
        case id
    }
    
    static private let descriptions: [HomeDeeplinks.Path: [DeeplinkDescription]] = [
        .unlock: [
            .init([.init(.controller, .string, constraint: .string(CorrectionsViewController.id)),
                   .init(.data, .string)],
                  endpoint: #selector(MainViewController.deeplinkCorrectionsQRCode)),
            .init([.init(.controller, .string, constraint: .string(TrackerViewController.id)),
                   .init(.data, .string)],
                  endpoint: #selector(MainViewController.deeplinkTrackerQRCode))
        ],
        .events: [
            .init([.init(.id, .int, constraint: .required)],
                  endpoint: #selector(MainViewController.deeplinkEvents))
        ]
    ]
    private struct DeeplinkDescription {
        
        struct Parameter {
            let name: HomeDeeplinks.Parameter
            
            @frozen enum ValueType {
                case string
                case int
            }
            let type: ValueType
            
            @frozen enum Constraint {
                case string(String)
                case required
            }
            let constraint: Constraint?
            
            init(_ name: HomeDeeplinks.Parameter, _ type: ValueType, constraint: Constraint? = nil) {
                self.name = name
                self.type = type
                self.constraint = constraint
            }
        }
        let parameters: [Parameter]
        let endpoint: Selector
        
        init(_ parameters: [Parameter], endpoint: Selector) {
            self.parameters = parameters
            self.endpoint = endpoint
        }
    }
    
    @frozen enum Deeplink {
        /**
         - Parameters:
            - controller: the hidden controller "corrections" or "tracker"
            - data: the data to be verified by the controller for unlocking
         */
        case unlock(String, String)
        
        var absoluteString: String {
            switch self {
            case .unlock(let c, let d):
                return "\(HomeDeeplinks.scheme)\(HomeDeeplinks.Path.unlock.rawValue)?controller=\(c)&data=\(d)"
            }
        }
    }
    static func generate(_ using: Deeplink) -> String {
        return using.absoluteString
    }
    
    static func deeplink(from launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> String? {
        return (launchOptions?[UIApplication.LaunchOptionsKey.url] as? URL)?.absoluteString
    }
    
    @discardableResult static func handle(_ deeplink: String) -> Bool {
        if App.userLoggedIn == false {
            DynamicAlert(contents: [.text("deeplink.required-login")], actions: [.normal(~"general.ok", nil)])
            return false
        }
        if deeplink.hasPrefix("file://") && deeplink.hasSuffix(".42clusters") {
            App.mainController.openClustersDebugFile(deeplink)
            return true
        }
        guard let components = URLComponents(string: deeplink), let host = components.host, host.count > 0 else {
            DynamicAlert(contents: [.text("deeplink.malformed-url")], actions: [.normal(~"general.ok", nil)])
            return false
        }
        let queryItems = components.queryItems ?? []
        guard let path = HomeDeeplinks.Path(rawValue: host) else {
            DynamicAlert(contents: [.text("deeplink.unknow-url")], actions: [.normal(~"general.ok", nil)])
            return false
        }
        let descriptions: [DeeplinkDescription] = Self.descriptions[path]!
        var target: DeeplinkDescription?
        var parameters: [String: Any] = [:]
        
        func value(for key: String) -> String? {
            return queryItems.first(where: { $0.name == key })?.value
        }
        
        func extract(_ value: String, type: DeeplinkDescription.Parameter.ValueType) -> Any? {
            switch type {
            case .string:
                return value
            case .int:
                if let result = Int(value) {
                    return result
                }
                return nil
            }
        }
        
        for description in descriptions {
            parameters.removeAll()
            target = description
            for parameter in description.parameters {
                if let value = value(for: parameter.name.rawValue) {
                    if let r = extract(value, type: parameter.type) {
                        if let c = parameter.constraint, case .string(let name) = c, name != value {
                            target = nil
                            break
                        }
                        parameters[parameter.name.rawValue] = r
                    }
                    else {
                        target = nil
                        break
                    }
                }
                else if let c = parameter.constraint, case .required = c {
                    target = nil
                    break
                }
            }
            if target != nil {
                break
            }
        }
        if let description = target {
            App.mainController.perform(description.endpoint, with: parameters)
            return true
        }
        DynamicAlert(contents: [.text("deeplink.unknow-url")], actions: [.normal(~"general.ok", nil)])
        return false
    }
}
