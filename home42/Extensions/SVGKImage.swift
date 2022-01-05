//
//  SVGKImage.swift
//  home42
//
//  Created by Antoine Feuerstein on 17/04/2021.
//

import Foundation
import SVGKit

extension SVGKImage {
        
    func fillWith(color: UIColor) {
        let cgColor = color.cgColor
        
        func fillLayer(_ color: CGColor, layer: CALayer) {
            for sublayer in layer.sublayers! {
                if sublayer is CAShapeLayer {
                    (sublayer as! CAShapeLayer).fillColor = color
                }
                else if sublayer.sublayers != nil {
                    fillLayer(color, layer: sublayer)
                }
            }
        }
        if self.caLayerTree != nil && self.caLayerTree.sublayers != nil {
            fillLayer(cgColor, layer: self.caLayerTree)
        }
    }
}
