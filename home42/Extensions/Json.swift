// home42/Json.swift
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

extension JSONEncoder {
    
    static let encoder: JSONEncoder = {
        return JSONEncoder()
    }()
}

extension JSONDecoder {
    
    static let decoder: JSONDecoder = {
        return JSONDecoder()
    }()
    static func decode<G: Codable>(data: Data) async throws -> G {
        return try JSONDecoder.decoder.decode(G.self, from: data)
    }
}

extension Dictionary where Key == String {
    
    var json: String {
        return String(data: try! JSONSerialization.data(withJSONObject: self, options: .prettyPrinted),
                      encoding: String.Encoding.ascii)!
    }
}

extension Dictionary where Value: Any, Key == String {
    
    func isContentEqual(_ other: Dictionary<Key, Value>) -> Bool {
        if other.count != self.count {
            return false
        }
        for (otherKey, otherValue) in other {
            if let value = self[otherKey], type(of: value) == type(of: otherValue) {
                switch value {
                case is Int:
                    if (value as! Int) != (otherValue as! Int) {
                        return false
                    }
                case is String:
                    if (value as! String) != (otherValue as! String) {
                        return false
                    }
                default:
                    return false
                }
                continue
            }
            return false
        }
        return true
    }
}
