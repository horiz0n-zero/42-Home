// home42/UIColors.swift
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
import UIKit
import simd

extension UIColor {
    
    static func fromIntra(_ input: String) -> UIColor {
        let scanner: Scanner
        var string: String
        var value: UInt64 = 0
        
        if input.hasPrefix("#") {
            string = input
            string.removeFirst()
            scanner = Scanner(string: string)
        }
        else {
            scanner = Scanner(string: input)
        }
        if scanner.scanHexInt64(&value) {
            return UIColor(red: CGFloat((value & 0xFF0000) >> 16) / 255.0,
                         green: CGFloat((value & 0xFF00) >> 8) / 255.0,
                         blue:  CGFloat(value & 0xFF) / 255.0,
                         alpha: 1.0)
        }
        return HomeDesign.primaryDefault
    }
    
    var secondaryColor: UIColor {
        let ciColor = CIColor.init(color: self)
        var rgb: vector_float3 = vector3(Float(ciColor.red * 1.32), Float(ciColor.green) * 1.1, Float(ciColor.blue) * 1.45)
        
        if (rgb.x > 1.0 || rgb.y > 1.0 || rgb.z > 1.0) {
            rgb = simd_normalize(rgb);
        }
        return UIColor(red: CGFloat(rgb.x), green: CGFloat(rgb.y), blue: CGFloat(rgb.z), alpha: 1.0)
    }
    
    @available(*, deprecated, message: "doesn't work")
    static func mix(withLowAlphaColor lhs: UIColor, color rhs: UIColor) -> UIColor {
        let lrgba = CIColor(color: lhs)
        let rrgba = CIColor(color: rhs)
        
        return UIColor(red: ((lrgba.red * lrgba.alpha) + rrgba.red) * (1 - lrgba.alpha),
                       green: ((lrgba.green * lrgba.alpha) + rrgba.green) * (1 - lrgba.alpha),
                       blue: ((lrgba.blue * lrgba.alpha) + rrgba.blue) * (1 - lrgba.alpha),
                       alpha: rrgba.alpha)
    }
    
    /*
    var isLight: Bool {
        guard let components = cgColor.components,
            components.count >= 3 else { return false }
        let brightness = ((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000
        return !(brightness < 0.5)
    }
    
     var complementaryColor: UIColor {
         isLight ? darker : lighter
     }
     
     var lighter: UIColor {
         adjust(by: 1.35)
     }
     
     var darker: UIColor {
         adjust(by: 0.94)
     }
     
    func adjust(by percent: CGFloat) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return UIColor(hue: h, saturation: s, brightness: b * percent, alpha: a)
    }*/
    
}

struct DecodableColor: Codable {
    
    var uiColor: UIColor
    
    init(color: UIColor) {
        self.uiColor = color
    }
    
    private enum CodingKeys: String, CodingKey {
        case red
        case green
        case blue
        case alpha
    }
    
    public func encode(to encoder: Encoder) throws {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        var container = encoder.container(keyedBy: DecodableColor.CodingKeys.self)
        
        self.uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        try container.encode(red, forKey: .red)
        try container.encode(green, forKey: .green)
        try container.encode(blue, forKey: .blue)
        try container.encode(alpha, forKey: .alpha)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DecodableColor.CodingKeys.self)
        
        self.uiColor = .init(red: try container.decode(CGFloat.self, forKey: .red),
                             green: try container.decode(CGFloat.self, forKey: .green),
                             blue: try container.decode(CGFloat.self, forKey: .blue),
                             alpha: try container.decode(CGFloat.self, forKey: .alpha))
    }
}
