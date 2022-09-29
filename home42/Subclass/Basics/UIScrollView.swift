// home42/UIScrollView.swift
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

class BasicUIScrollView: UIScrollView {
    
    init() {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
    }
    required init?(coder: NSCoder) { fatalError("Dance cult Holograpic") }
}

extension UIScrollView {
    
    func setScrollIndicatorColor(_ color: UIColor) {
        for subview in self.subviews {
            if subview is UIImageView {
                subview.backgroundColor = color
            }
        }
    }
}
