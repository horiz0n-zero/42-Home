// home42/HomeTelephony.swift
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

final class HomeTelephony: NSObject {
    
    static func call(_ number: String) {
        let telPrompt = URL(string: "telprompt://\(number)")!
        
        if UIApplication.shared.canOpenURL(telPrompt) {
            UIApplication.shared.open(telPrompt, options: [:], completionHandler: nil)
        }
        else {
            UIApplication.shared.open(URL(string: "tel://\(number)")!, options: [:], completionHandler: nil)
        }
    }
    
    static func message(_ number: String) {
        UIApplication.shared.open(URL(string: "sms://\(number)")!, options: [:], completionHandler: nil)
    }
}
