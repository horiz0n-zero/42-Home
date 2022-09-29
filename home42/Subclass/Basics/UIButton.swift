// home42/UIButton.swift
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

class BasicUIButton: UIButton {
    
    init() {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    init(text: String) {
        super.init(frame: .zero)
        self.setAttributedTitle(.init(string: text, attributes: [.foregroundColor: HomeDesign.white, .font: HomeLayout.fontSemiBoldMedium]), for: .normal)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = HomeDesign.primary
        self.layer.cornerRadius = HomeLayout.scorner
        self.layer.masksToBounds = true
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
