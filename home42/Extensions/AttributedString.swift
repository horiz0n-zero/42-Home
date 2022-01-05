//
//  AttributedString.swift
//  home42
//
//  Created by Antoine Feuerstein on 17/04/2021.
//

import Foundation
import UIKit

extension NSAttributedString {
    
    static func from(strings: [String], _ attributes: [[NSAttributedString.Key : Any]]) -> NSAttributedString {
        let attr = NSMutableAttributedString(string: strings.joined())
        var pos: Int = 0
        
        for (index, string) in strings.enumerated() {
            attr.addAttributes(attributes[index], range: NSMakeRange(pos, string.count))
            pos += string.count
        }
        return attr
    }
}
