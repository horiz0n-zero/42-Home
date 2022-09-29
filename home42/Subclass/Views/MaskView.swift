// home42/MaskView.swift
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

final class CoalitionMaskView<G: UIView>: BasicUIView {
    
    let view: G
    let backgroundView: BasicUIImageView
    
    var coalition: IntraCoalition? {
        @available(*, unavailable) get { return nil }
        set {
            self.setCoalition(newValue)
        }
    }
    
    init(_ view: G, coalition: IntraCoalition? = App.userCoalition) {
        self.view = view
        self.backgroundView = BasicUIImageView(asset: .coalitionDefaultBackground)
        self.backgroundView.layer.masksToBounds = true
        super.init()
        self.setCoalition(coalition)
    }
    required init?(coder: NSCoder) { fatalError() }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview != nil else {
            return
        }
        
        self.addSubview(self.view)
        self.view.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.view.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.view.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.view.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.addSubview(self.backgroundView)
        self.backgroundView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.backgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.backgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.layer.mask = self.view.layer
    }
    
    private func setCoalition(_ coalition: IntraCoalition?) {
        if let coalition = coalition {
            if let image = HomeResources.storageCoalitionsImages.get(coalition) {
                self.backgroundView.image = image
            }
            else {
                Task.init(priority: .userInitiated, operation: {
                    if let image = await HomeResources.storageCoalitionsImages.obtain(coalition)?.1 {
                        self.backgroundView.image = image
                    }
                })
            }
        }
        else {
            self.backgroundView.image = UIImage.Assets.coalitionDefaultBackground.image
        }
    }
}
