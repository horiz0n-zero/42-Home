// home42/UIActivityIndicatorView.swift
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

final class BasicUIActivityIndicatorView: UIActivityIndicatorView {
    
    var primary: UIColor {
        get { return self.color }
        set { self.color = newValue }
    }
    
    init(primary: UIColor = HomeDesign.primary) {
        super.init(style: .medium)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.color = primary
        self.hidesWhenStopped = true
    }
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
