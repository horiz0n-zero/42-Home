//
//  HomeWords.swift
//  home42
//
//  Created by Antoine Feuerstein on 10/04/2021.
//

import Foundation
import SwiftDate

final class HomeWords: NSObject {
    
    static let codes = ["FR", "EN"]
    static func set(code: String) {
        
        func loadWordsFile(file: String) {
            let jsonFile = try! Data(contentsOf: HomeResources.applicationDirectory.appendingPathComponent(file))
            
            HomeWords.json = try! JSONSerialization.jsonObject(with: jsonFile, options: .allowFragments) as! [String: String]
        }
        
        if let index = HomeWords.codes.firstIndex(of: code.uppercased()) {
            loadWordsFile(file: "res/words/" + HomeWords.codes[index] + ".json")
        }
        else {
            loadWordsFile(file: "res/words/" + HomeWords.codes[0] + ".json")
        }
        SwiftDate.defaultRegion = Region(calendar: Calendar.current, zone: Zones.current, locale: Locales.init(rawValue: code.lowercased())!)
    }
    
    static fileprivate var json: [String: String]!
}

extension String {
    
    static prefix func ~(_ localizedString: String) -> String {
        return HomeWords.json[localizedString]!
    }
}
