// home42/UIVisualEffectView.swift
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

class BasicUIVisualEffectView: UIVisualEffectView {
    
    override init(effect: UIVisualEffect?) {
        super.init(effect: effect)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    init() {
        super.init(effect: HomeDesign.blur)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

class HomePresentableVisualEffectView: UIVisualEffectView {
    
    init() {
        super.init(effect: nil)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layer.cornerRadius = HomeLayout.corner
        self.layer.masksToBounds = true
        self.contentView.alpha = 0.0
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func present(with duration: TimeInterval, curve: UIView.AnimationCurve, completion: ((Bool) -> ())? = nil) {
        UIView.transition(with: self.contentView, duration: duration, options: curve.animationOptions, animations: {
            self.contentView.alpha = 1.0
        }, completion: nil)
        UIView.animate(withDuration: duration, delay: 0.0, options: curve.animationOptions, animations: {
            self.effect = HomeDesign.blur
        }, completion: completion)
    }
    
    func present(completion: ((Bool) -> ())? = nil) {
        HomeAnimations.transitionShort(withView: self.contentView, {
            self.contentView.alpha = 1.0
        }, completion: nil)
        HomeAnimations.animateShort({
            self.effect = HomeDesign.blur
        }, completion: completion)
    }
    
    func remove(completion: ((Bool) -> ())? = nil) {
        HomeAnimations.transitionShort(withView: self.contentView, {
            self.contentView.alpha = 0.0
        }, completion: nil)
        HomeAnimations.animateShort({
            self.effect = nil
        }, completion: completion)
    }
}
