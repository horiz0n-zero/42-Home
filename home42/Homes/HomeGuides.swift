// home42/HomeGuides.swift
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

final class HomeGuides: NSObject {
        
    static func alertActionLink() -> DynamicAlert.Action {
        
        func showGuides() {
            App.mainController.presentWithBlur(GuidesViewController())
        }
        
        return .highligth(~"general.guide", showGuides)
    }
    
    static func alertShowGuides() {
        DynamicAlert(contents: [.text(~"clusters.campus-map-unavailable")],
                     actions: [.normal(~"general.ok", nil), HomeGuides.alertActionLink()])
    }
    
}
