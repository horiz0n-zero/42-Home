//
//  GradientView.swift
//  home42
//
//  Created by Antoine Feuerstein on 22/08/2021.
//

import Foundation
import UIKit

final class GradientView: BasicUIView {
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
 
    var colors: [CGColor]? {
        get {
            return (self.layer as! CAGradientLayer).colors as? [CGColor]
        }
        set {
            (self.layer as! CAGradientLayer).colors = newValue
        }
    }
    var startPoint: CGPoint {
        get {
            return (self.layer as! CAGradientLayer).startPoint
        }
        set {
            (self.layer as! CAGradientLayer).endPoint = newValue
        }
    }
    var endPoint: CGPoint {
        get {
            return (self.layer as! CAGradientLayer).endPoint
        }
        set {
            (self.layer as! CAGradientLayer).endPoint = newValue
        }
    }
}
