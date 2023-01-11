// home42/MessageView.swift
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

final class MessageView<G: UIView>: BasicUIView {
    
    private let label: BasicUILabel
    var primary: UIColor {
        didSet {
            self.backgroundColor = self.primary.withAlphaComponent(HomeDesign.alphaLowLayer)
        }
    }
    let view: G
    
    init(text: String, primary: UIColor, radius: CGFloat, view: G) {
        self.label = BasicUILabel(text: text)
        self.label.font = HomeLayout.fontSemiBoldMedium
        self.label.textColor = HomeDesign.black
        self.label.adjustsFontSizeToFitWidth = true
        self.primary = primary
        self.view = view
        super.init()
        self.backgroundColor = primary.withAlphaComponent(HomeDesign.alphaLowLayer)
        self.layer.cornerRadius = radius
    }
    required init?(coder: NSCoder) { fatalError("chill soulchef") }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview != nil else { return }
        
        self.addSubview(self.view)
        self.addSubview(self.label)
        self.view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -HomeLayout.dmargin).isActive = true
        self.view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: HomeLayout.dmargin).isActive = true
        self.view.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.dmargin).isActive = true
        self.label.bottomAnchor.constraint(equalTo: self.view.topAnchor, constant: -HomeLayout.dmargin).isActive = true
        self.label.topAnchor.constraint(equalTo: self.topAnchor, constant: HomeLayout.dmargin).isActive = true
        self.label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: HomeLayout.margin).isActive = true
        self.label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.dmargin).isActive = true
    }
}
