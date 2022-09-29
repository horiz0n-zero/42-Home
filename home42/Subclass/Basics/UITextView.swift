// home42/UITextView.swift
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

class BasicUITextView: UITextView {
        
    init() {
        super.init(frame: .zero, textContainer: nil)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.tintColor = HomeDesign.primary
        self.backgroundColor = .clear
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.isScrollEnabled = floor(self.sizeThatFits(CGSize.init(width: rect.width, height: .infinity)).height) > floor(rect.height)
    }
}
