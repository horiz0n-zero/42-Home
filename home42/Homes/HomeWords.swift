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
}

extension String {
    
    static prefix func ~(_ localizedString: String) -> String {
        return HomeWords.json[localizedString]!
    }
}
