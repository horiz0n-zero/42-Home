// home42/HomeDesign.swift
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

final class HomeDesign: NSObject {
    
    static let primaryDefault = UIColor(red:30.0/255.0, green:186.0/255.0, blue:187.0/255.0, alpha: 1.0)
    static var primary = HomeDesign.primaryDefault
    
    static let black = UIColor(red:30.0/255.0, green:30.0/255.0, blue:40.0/255.0, alpha: 1.0)
    static let blackLayer = HomeDesign.black.withAlphaComponent(HomeDesign.alphaLayer)
    
    static let white = UIColor(red:1.0, green:1.0, blue:1.0, alpha: 1.0)
    static let blackGray = UIColor(red: 81.0/255.0, green: 81.0/255.0, blue: 103.0/255.0, alpha: 1.0)
    static let gray = UIColor(red:210.0/255.0, green:210.0/255.0, blue:220.0/255.0, alpha: 1.0)
    static let grayLayer = HomeDesign.gray.withAlphaComponent(HomeDesign.alphaLayer)
    static let lightGray = UIColor(red:240.0/255.0, green:240.0/255.0, blue:250.0/255.0, alpha: 1.0)
    
    static let actionRed = UIColor.init(red: 1.0, green: 94.0/255.0, blue: 88.0/255.0, alpha: 1.0)
    static let actionOrange = UIColor.init(red: 1.0, green: 189.0/255.0, blue: 46.0/255.0, alpha: 1.0)
    static let actionGreen = UIColor.init(red: 42.0/255.0, green: 200.0/255.0, blue: 64.0/255.0, alpha: 1.0)
    
    @available(*, deprecated) static let actionYellow = UIColor.yellow
    @available(*, deprecated) static let actionBlue = UIColor.blue
    
    static let gold = UIColor(red:1.0, green:191.0/255.0, blue:0.0, alpha: 1.0)
    static let pink = UIColor(red:234.0/255.0, green:85.0/255.0, blue:184.0/255.0, alpha: 1.0)
    
    static let redError = UIColor(red:214.0/255.0, green:100.0/255.0, blue:113.0/255.0, alpha: 1.0)
    static let greenSuccess = UIColor(red:133.0/255.0, green:214.0/255.0, blue:100.0/255.0, alpha: 1.0)
    static let blueAccess = UIColor(red:100.0/255.0, green:162.0/255.0, blue:214.0/255.0, alpha: 1.0)
    
    static let eventColorT0 = UIColor(red: 234.0/255.0, green: 85.0/255.0, blue: 184.0/255.0, alpha: 1.0)
    static let eventColorT1 = UIColor(red: 234.0/255.0, green: 85.0/255.0, blue: 98.0/255.0, alpha: 1.0)
    static let eventColorT2 = UIColor(red: 234.0/255.0, green: 160.0/255.0, blue: 85.0/255.0, alpha: 1.0)
    static let eventColorT3 = UIColor(red: 222.0/255.0, green: 234.0/255.0, blue: 85.0/255.0, alpha: 1.0)
    static let eventColorT4 = UIColor(red: 135.0/255.0, green: 234.0/255.0, blue: 85.0/255.0, alpha: 1.0)
    static let eventColorT5 = UIColor(red: 85.0/255.0, green: 234.0/255.0, blue: 122.0/255.0, alpha: 1.0)
    static let eventColorT6 = UIColor(red: 85.0/255.0, green: 234.0/255.0, blue: 209.0/255.0, alpha: 1.0)
    static let eventColorT7 = UIColor(red: 85.0/255.0, green: 172.0/255.0, blue: 234.0/255.0, alpha: 1.0)
    static let eventColorT8 = UIColor(red: 85.0/255.0, green: 85.0/255.0, blue: 234.0/255.0, alpha: 1.0)
    static let eventColorT9 = UIColor(red: 172.0/255.0, green: 85.0/255.0, blue: 234.0/255.0, alpha: 1.0)
    
    static let keyboardAppearance = UIKeyboardAppearance.dark
    static let blur: UIVisualEffect = UIBlurEffect(style: .dark)
    
    static let alphaLowLayer: CGFloat = 0.10
    static let alphaLow: CGFloat = 0.30
    static let alphaMiddle: CGFloat = 0.50
    static let alphaLayer: CGFloat = 0.65
}
