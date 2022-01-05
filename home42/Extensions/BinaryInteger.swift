//
//  BinaryInteger.swift
//  home42
//
//  Created by Antoine Feuerstein on 15/05/2021.
//

import Foundation
import UIKit

fileprivate let scoreFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    
    formatter.numberStyle = .decimal
    formatter.usesGroupingSeparator = true
    formatter.groupingSeparator = " "
    return formatter
}()

extension BinaryInteger {
    
    var scoreFormatted: String {
        return scoreFormatter.string(from: NSNumber(integerLiteral: Int(self)))!
    }
}
