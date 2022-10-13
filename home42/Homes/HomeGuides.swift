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
        
    static func alertActionLink(_ controller: HomeViewController) -> DynamicAlert.Action {
        
        func showGuides() {
            controller.presentWithBlur(GuidesViewController())
        }
        
        return .highligth(~"general.guide", showGuides)
    }
    
    static func alertShowGuides(_ controller: HomeViewController) {
        DynamicAlert(contents: [.text(~"clusters.campus-map-unavailable")],
                     actions: [.normal(~"general.ok", nil), HomeGuides.alertActionLink(controller)])
    }
    
}
