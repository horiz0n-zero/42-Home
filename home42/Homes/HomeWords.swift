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
    
    static private let codes: Dictionary<String, String> = [
        "en": "res/words/en.json",
        "fr": "res/words/fr.json"
    ]
    static fileprivate var json: [String: String]!

    static func configure(_ language: IntraLanguage) {
        let file: String
        let data: Data
        
        if let codeFile = Self.codes[language.identifier] {
            file = codeFile
        }
        else {
            file = Self.codes["en"]!
        }
        data = try! Data(contentsOf: Bundle.main.bundleURL.appendingPathComponent(file))
        HomeWords.json = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: String]
        SwiftDate.defaultRegion = Region(calendar: Calendar.current, zone: Zones.current, locale: Locales.init(rawValue: language.identifier) ?? Locales.current)
    }
}

extension String {
    
    static prefix func ~(_ localizedString: String) -> String {
        return HomeWords.json[localizedString]!
    }
}
