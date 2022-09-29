// home42/UIPageControl.swift
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

final class BasicUIPageControl: UIPageControl {
    
    init() {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func trySettingCustomBlur(_ effect: UIVisualEffect) {
        func search(_ view: UIView) {
            if let visualEffectView = view as? UIVisualEffectView {
                visualEffectView.effect = effect
                return
            }
            else {
                for subview in view.subviews {
                    search(subview)
                }
            }
        }
        search(self)
    }
}
