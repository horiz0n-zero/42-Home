// home42/HomeWords.swift
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
import SwiftDate
import UIKit

final class HomeWords: NSObject {
    
    static fileprivate var json: [String: String]!

    static func exist(_ language: IntraLanguage) -> Bool {
        let file = "/res/words/\(language.identifier).json"
        let path = Bundle.main.bundlePath.appending(file)
        
        return FileManager.default.fileExists(atPath: path)
    }
    
    static func configure(_ language: IntraLanguage) {
        let file: String = "res/words/\(language.identifier).json"
        let data: Data = try! Data(contentsOf: Bundle.main.bundleURL.appendingPathComponent(file))
        
        HomeWords.json = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: String]
        SwiftDate.defaultRegion = Region(calendar: Calendar.current, zone: Zones.current, locale: Locales.init(rawValue: language.identifier) ?? Locales.current)
    }
    
    #if DEBUG
    static func _debugTryAllLanguages() {
        let refLanguage = HomeApiResources.languages.first(where: { $0.identifier == "fr" })!
        let allKeys: [String]
        
        HomeWords.configure(refLanguage)
        allKeys = Array(Self.json.keys)
        for language in HomeApiResources.languages where HomeWords.exist(language) {
            print("--- testing ---", language.name, language.identifier)
            print()
            HomeWords.configure(language)
            for key in allKeys {
                print(key, language.identifier)
                print("=>", ~key)
            }
            print()
        }
    }
    #endif
}

extension String {
    
    static prefix func ~(_ localizedString: String) -> String {
        return HomeWords.json[localizedString]!
    }
}
