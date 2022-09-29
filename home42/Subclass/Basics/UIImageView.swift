// home42/UIImageView.swift
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

class BasicUIImageView: UIImageView {
    
    override init(image: UIImage?) {
        super.init(image: image)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.contentMode = .scaleAspectFill
    }
    
    init(asset: UIImage.Assets) {
        super.init(image: asset.image)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.contentMode = .scaleAspectFill
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.contentMode = .scaleAspectFill
    }
    required init?(coder: NSCoder) { fatalError("Herobust WTF") }
    
    final func setUpParallaxEffect(usingAmout amount: CGFloat = 100.0) {
        let horizontal = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        let vertical = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        let group = UIMotionEffectGroup()
        
        horizontal.minimumRelativeValue = -amount
        horizontal.maximumRelativeValue = amount
        vertical.minimumRelativeValue = -amount
        vertical.maximumRelativeValue = amount
        group.motionEffects = [horizontal, vertical]
        self.addMotionEffect(group)
    }
    
    @inlinable final func setUpParallaxConstraint(usingParent view: UIView) {
        self.topAnchor.constraint(equalTo: view.topAnchor, constant: -App.settings.graphicsParallaxForce.rawValue).isActive = true
        self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: App.settings.graphicsParallaxForce.rawValue).isActive = true
        self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -App.settings.graphicsParallaxForce.rawValue).isActive = true
        self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: App.settings.graphicsParallaxForce.rawValue).isActive = true
    }
}

final class CoalitionBackgroundWithParallaxImageView: BasicUIView {
    
    private let background: BasicUIImageView
    
    @inlinable var image: UIImage {
        get {
            return self.background.image!
        }
        set {
            self.background.image = newValue
        }
    }
    
    override init() {
        self.background = .init(asset: .coalitionDefaultBackground)
        super.init()
    }
    required init?(coder: NSCoder) { fatalError("Herobust WTF Vip") }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview != nil else { return }
        
        self.addSubview(self.background)
        if App.settings.graphicsUseParallax {
            self.background.setUpParallaxEffect(usingAmout: App.settings.graphicsParallaxForce.rawValue)
            self.background.setUpParallaxConstraint(usingParent: self)
        }
        else {
            self.background.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            self.background.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            self.background.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            self.background.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        }
    }
}
