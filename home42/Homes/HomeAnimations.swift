// home42/HomeAnimations.swift
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

final class HomeAnimations: NSObject, UIViewControllerAnimatedTransitioning {
    
    static private var transitionDuration: TimeInterval = HomeAnimations.durationMedium
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return HomeAnimations.transitionDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewController(forKey: .from)!
        let toViewController = transitionContext.viewController(forKey: .to)!
        let containerView = transitionContext.containerView
        let effectView = UIVisualEffectView(effect: nil)
        let primaryBackground: BasicUIView! = App.settings.graphicsBlurPrimaryTransition ? BasicUIView() : nil
        let transitionDuration = self.transitionDuration(using: transitionContext)
        let fromView: UIView = transitionContext.view(forKey: .from) ?? fromViewController.view
        let toView: UIView = transitionContext.view(forKey: .to) ?? toViewController.view
        
        fromView.frame = transitionContext.initialFrame(for: fromViewController)
        toView.frame = transitionContext.finalFrame(for: toViewController)
        effectView.frame = fromView.frame
        fromView.alpha = 1.0
        toView.alpha = 0.0
        
        containerView.addSubview(toView)
        containerView.addSubview(effectView)
        if primaryBackground != nil {
            primaryBackground.frame = fromView.frame
            primaryBackground.backgroundColor = HomeDesign.primary.withAlphaComponent(HomeDesign.alphaLow)
            primaryBackground.alpha = 0.0
            containerView.addSubview(primaryBackground)
        }
        UIView.animate(withDuration: transitionDuration / 2.0, delay: 0.0, options: HomeAnimations.curve, animations: {
            fromView.alpha = 0.5
            toView.alpha = 0.5
            if primaryBackground != nil {
                primaryBackground.alpha = 1.0
            }
            effectView.effect = HomeDesign.blur
        }, completion: { _ in
            UIView.animate(withDuration: transitionDuration / 2.0, delay: 0.0, options: HomeAnimations.curve, animations: {
                fromView.alpha = 0.0
                toView.alpha = 1.0
                if primaryBackground != nil {
                    primaryBackground.alpha = 0.0
                }
                effectView.effect = nil
            }, completion: { _ in
                effectView.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        })
    }
    
    static let durationLigthSpeed: TimeInterval = 0.1
    static let durationQuick: TimeInterval = 0.2
    static let durationShort: TimeInterval = 0.4
    static let durationMedium: TimeInterval = 0.8
    static let durationLong: TimeInterval = 1.2
    static let durationLongLong: TimeInterval = 2.0
    
    static let curve: UIView.AnimationOptions = .curveEaseOut
    static let curveTransition: UIView.AnimationOptions = [HomeAnimations.curve, .transitionCrossDissolve]
    static let curveCG: CAMediaTimingFunction = CAMediaTimingFunction(name: .easeOut)
    
    static func animateLigthSpeed(_ animations: @escaping () -> (), completion: ((Bool) -> ())? = nil) {
        UIView.animate(withDuration: HomeAnimations.durationLigthSpeed, delay: 0.0, options: HomeAnimations.curve, animations: animations, completion: completion)
    }
    static func animateQuick(_ animations: @escaping () -> (), completion: ((Bool) -> ())? = nil) {
        UIView.animate(withDuration: HomeAnimations.durationQuick, delay: 0.0, options: HomeAnimations.curve, animations: animations, completion: completion)
    }
    static func animateShort(_ animations: @escaping () -> (), completion: ((Bool) -> ())? = nil) {
        UIView.animate(withDuration: HomeAnimations.durationShort, delay: 0.0, options: HomeAnimations.curve, animations: animations, completion: completion)
    }
    static func animateMedium(_ animations: @escaping () -> (), completion: ((Bool) -> ())? = nil) {
        UIView.animate(withDuration: HomeAnimations.durationMedium, delay: 0.0, options: HomeAnimations.curve, animations: animations, completion: completion)
    }
    static func animateLong(_ animations: @escaping () -> (), completion: ((Bool) -> ())? = nil) {
        UIView.animate(withDuration: HomeAnimations.durationLong, delay: 0.0, options: HomeAnimations.curve, animations: animations, completion: completion)
    }
    static func animateLongLong(_ animations: @escaping () -> (), completion: ((Bool) -> ())? = nil) {
        UIView.animate(withDuration: HomeAnimations.durationLongLong, delay: 0.0, options: HomeAnimations.curve, animations: animations, completion: completion)
    }
    
    static func transitionLigthSpeed(withView view: UIView, _ animations: @escaping () -> (), completion: ((Bool) -> ())? = nil) {
        UIView.transition(with: view, duration: HomeAnimations.durationLigthSpeed, options: HomeAnimations.curveTransition, animations: animations, completion: completion)
    }
    static func transitionQuick(withView view: UIView, _ animations: @escaping () -> (), completion: ((Bool) -> ())? = nil) {
        UIView.transition(with: view, duration: HomeAnimations.durationQuick, options: HomeAnimations.curveTransition, animations: animations, completion: completion)
    }
    static func transitionShort(withView view: UIView, _ animations: @escaping () -> (), completion: ((Bool) -> ())? = nil) {
        UIView.transition(with: view, duration: HomeAnimations.durationShort, options: HomeAnimations.curveTransition, animations: animations, completion: completion)
    }
    static func transitionMedium(withView view: UIView, _ animations: @escaping () -> (), completion: ((Bool) -> ())? = nil) {
        UIView.transition(with: view, duration: HomeAnimations.durationMedium, options: HomeAnimations.curveTransition, animations: animations, completion: completion)
    }
    static func transitionLong(withView view: UIView, _ animations: @escaping () -> (), completion: ((Bool) -> ())? = nil) {
        UIView.transition(with: view, duration: HomeAnimations.durationLong, options: HomeAnimations.curveTransition, animations: animations, completion: completion)
    }
    static func transitionLongLong(withView view: UIView, _ animations: @escaping () -> (), completion: ((Bool) -> ())? = nil) {
        UIView.transition(with: view, duration: HomeAnimations.durationLongLong, options: HomeAnimations.curveTransition, animations: animations, completion: completion)
    }
    
    static func prepare() {
        switch App.settings.graphicsTransitionDuration {
        case .durationQuick:
            HomeAnimations.transitionDuration = HomeAnimations.durationQuick
        case .durationShort:
            HomeAnimations.transitionDuration = HomeAnimations.durationShort
        case .durationMedium:
            HomeAnimations.transitionDuration = HomeAnimations.durationMedium
        case .durationLong:
            HomeAnimations.transitionDuration = HomeAnimations.durationLong
        case .durationLongLong:
            HomeAnimations.transitionDuration = HomeAnimations.durationLongLong
        }
    }
}

extension CALayer {
    
    @inlinable func basicAnimation<V>(keyPath: WritableKeyPath<CALayer, V>, value: V, duration: TimeInterval) {
        let keyString = NSExpression(forKeyPath: keyPath).keyPath
        let anim = CABasicAnimation(keyPath: keyString)
        var layer: CALayer = self
        
        anim.fromValue = self[keyPath: keyPath]
        anim.toValue = value
        anim.duration = duration
        layer[keyPath: keyPath] = value
        self.add(anim, forKey: keyString)
    }
}
