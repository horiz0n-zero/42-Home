// home42/HomeDefaults.swift
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
import SecureDefaults
import SwiftUI
import SwiftDate

public final class HomeDefaults: NSObject {
    
    static private let secure: SecureDefaults = {
        let suiteName = "group.com.horiz0n-zero.home42"
        let defaults = SecureDefaults(suiteName: suiteName)!
        
        defaults.keychainAccessGroup = suiteName
        if defaults.isKeyCreated == false {
            defaults.password = UIDevice.current.identifierForVendor?.uuidString ?? "42"
        }
        return defaults
    }()
    
    static func jsonRepresentation() -> String {
        var data: Any?
        var result: String = ""
        var jsonObjects: Any
        
        for (index, key) in HomeDefaults.Key.allCases.enumerated() {
            data = HomeDefaults.secure.object(forKey: key.rawValue)
            
            func append(value: String) {
                if index + 1 >= HomeDefaults.Key.allCases.count {
                    result += "\"\(key.rawValue)\": \(value)\n"
                }
                else {
                    result += "\"\(key.rawValue)\": \(value),\n"
                }
            }
            
            if let data = data {
                switch data {
                case is Bool:
                    append(value: data as! Bool ? "true" : "false")
                case is Int:
                    append(value: "\(data as! Int)")
                case is String:
                    append(value: data as! String)
                case is Date:
                    append(value: (data as! Date).toString(.fullReadable))
                case is Data:
                    do {
                        jsonObjects = try JSONSerialization.jsonObject(with: data as! Data, options: .allowFragments)
                        if let array = jsonObjects as? Array<[String: Any]> {
                            append(value: array.map({ $0.json }).joined(separator: "\n"))
                        }
                        else if let dico = jsonObjects as? [String: Any] {
                            append(value: dico.json)
                        }
                        else {
                            //
                        }
                    }
                    catch {
                        #if DEBUG
                        print("HomeDefaults", #function, "data corrupted:", type(of: data))
                        #endif
                    }
                case is [String: Any]:
                    append(value: (data as! [String: Any]).json)
                default:
                    #if DEBUG
                    print("HomeDefaults", #function, "unknow type:", type(of: data))
                    #endif
                }
            }
            else {
                append(value: "nil")
            }
        }
        return result
    }
    
    static func logout() {
        HomeDefaults.remove(.user)
        HomeDefaults.remove(.coalitions)
        HomeDefaults.remove(.controller)
        HomeDefaults.remove(.tokens)
        HomeDefaults.remove(.cookies)
        HomeDefaults.remove(.controller)
        HomeDefaults.remove(.userEvents)
        HomeDefaults.remove(.language)
    }
    
    @frozen enum Key: String, CaseIterable {
        case liveClusterFloor
        case clustersExtraValues
        case controller
        
        case tokens
        case cookies
        
        case user
        case coalitions
        case settings
        
        case userEvents
        
        case peoples
        case liveClusterLocations
        
        case language
        case publicKey
    }
        
    static func save(_ element: Bool, forKey key: HomeDefaults.Key) {
        HomeDefaults.secure.set(element, forKey: key.rawValue)
    }
    static func save<V: Comparable & Numeric>(_ element: V, forKey key: HomeDefaults.Key) {
        HomeDefaults.secure.set(element, forKey: key.rawValue)
    }
    static func save(_ element: String, forKey key: HomeDefaults.Key) {
        HomeDefaults.secure.set(element, forKey: key.rawValue)
    }
    static func save(_ element: String, forRawKey rawKey: String) {
        HomeDefaults.secure.set(element, forKey: rawKey)
    }
    static func save(_ element: Date, forKey key: HomeDefaults.Key) {
        HomeDefaults.secure.set(element, forKey: key.rawValue)
    }
    static func save<G: Encodable>(_ element: G, forKey key: HomeDefaults.Key) {
        do {
            HomeDefaults.secure.set(try JSONEncoder.encoder.encode(element), forKey: key.rawValue)
        }
        catch {
            #if DEBUG
            print("HomeDefaults", #function, type(of: element), error)
            #endif
        }
    }
    
    static func read(_ key: HomeDefaults.Key) -> Bool? {
        return HomeDefaults.secure.bool(forKey: key.rawValue)
    }
    static func read<V: Comparable & Numeric>(_ key: HomeDefaults.Key) -> V? {
        return HomeDefaults.secure.object(forKey: key.rawValue) as? V
    }
    static func read(_ key: HomeDefaults.Key) -> String? {
        return HomeDefaults.secure.string(forKey: key.rawValue)
    }
    static func read(_ rawKey: String) -> String? {
        return HomeDefaults.secure.string(forKey: rawKey)
    }
    static func read(_ key: HomeDefaults.Key) -> Date? {
        return HomeDefaults.secure.object(forKey: key.rawValue) as? Date
    }
    static func read<G: Decodable>(_ key: HomeDefaults.Key) -> G? {
        if let data = HomeDefaults.secure.object(forKey: key.rawValue) as? Data {
            return try? JSONDecoder.decoder.decode(G.self, from: data)
        }
        return nil
    }
    
    static func remove(_ key: HomeDefaults.Key) {
        HomeDefaults.secure.removeObject(forKey: key.rawValue)
    }
    static func remove(_ rawKey: String) {
        HomeDefaults.secure.removeObject(forKey: rawKey)
    }
}
