//
//  CGPoint.swift
//  home42
//
//  Created by Antoine Feuerstein on 21/05/2021.
//

import Foundation
import UIKit

extension CGPoint {
    
    @_transparent func distance(_ to: CGPoint) -> CGFloat {
        return sqrt(pow(self.x - to.x, 2.0) + pow(self.y - to.y, 2.0))
    }
}

extension CGPoint: Hashable {
    
    static func ==(lhs: CGPoint, rhs: CGPoint) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.x)
        hasher.combine(self.y)
    }
}
