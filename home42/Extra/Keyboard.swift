// home42/Keyboard.swift
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

protocol Keyboard: NSObjectProtocol {
    
    func keyboardWillShow(curve: UIView.AnimationCurve, duration: TimeInterval, frame: CGRect)
    func keyboardWillHide(curve: UIView.AnimationCurve, duration: TimeInterval, frame: CGRect)
    func keyboardWillChangeFrame(curve: UIView.AnimationCurve, duration: TimeInterval, frame: CGRect)
}
extension Keyboard {
    
    func keyboardInterfaceSetup() {
        let nc = NotificationCenter.default
        var tokenShow: NSObjectProtocol!
        var tokenHide: NSObjectProtocol!
        var tokenChange: NSObjectProtocol!
        
        tokenShow = nc.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: OperationQueue.main, using: { [weak self] notification in
            guard let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber,
                let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber,
                let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
                    return
            }
            
            if let `self` = self {
                self.keyboardWillShow(curve: UIView.AnimationCurve.init(rawValue: curve.intValue)!,
                                      duration: TimeInterval(duration.doubleValue),
                                      frame: frame.cgRectValue)
            }
            else {
                nc.removeObserver(tokenShow!)
            }
        })
        tokenHide = nc.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: OperationQueue.main, using: { [weak self] notification in
            guard let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber,
                let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber,
                let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
                    return
            }
            
            if let `self` = self {
                self.keyboardWillHide(curve: UIView.AnimationCurve.init(rawValue: curve.intValue)!,
                                      duration: TimeInterval(duration.doubleValue),
                                      frame: frame.cgRectValue)
            }
            else {
                nc.removeObserver(tokenHide!)
            }
        })
        tokenChange = nc.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: OperationQueue.main, using: { [weak self] not in
            guard let curve = not.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber,
                let duration = not.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber,
                let frame = not.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
                    return
            }
            
            if let `self` = self {
                self.keyboardWillChangeFrame(curve: UIView.AnimationCurve.init(rawValue: curve.intValue)!,
                                             duration: TimeInterval(duration.doubleValue),
                                             frame: frame.cgRectValue)
            }
            else {
                nc.removeObserver(tokenChange!)
            }
        })
    }
    
    @available(*, deprecated, message: "use ios 15 constraints instead")
    func keyboardElementIsVisible(on view: UIView, keyboardFrame: CGRect, margin: CGFloat = HomeLayout.margin) -> Bool {
        let distanceViewY = view.frame.origin.y + view.frame.height + margin
        
        return distanceViewY <= keyboardFrame.origin.y
    }
    @available(*, deprecated, message: "use ios 15 constraints instead")
    func keyboardElementBecomeVisible(on constraint: NSLayoutConstraint, view: UIView,
                                      keyboardFrame: CGRect, curve: UIView.AnimationCurve, duration: TimeInterval,
                                      margin: CGFloat = HomeLayout.margin) {
        let distanceViewY = view.frame.origin.y + view.frame.height + margin
        let diff = keyboardFrame.origin.y - distanceViewY
        
        UIView.animate(withDuration: duration, delay: 0.0, options: curve.animationOptions, animations: {
            constraint.constant = diff
            (view.superview ?? view).layoutIfNeeded()
        }, completion: nil)
    }
    @available(*, deprecated, message: "use ios 15 constraints instead")
    func keyboardElementResetToVisibleState(on constraint: NSLayoutConstraint, view: UIView,
                                            curve: UIView.AnimationCurve, duration: TimeInterval, constant: CGFloat = 0.0) {
        UIView.animate(withDuration: duration, delay: 0.0, options: curve.animationOptions, animations: {
            constraint.constant = constant
            (view.superview ?? view).layoutIfNeeded()
        }, completion: nil)
    }
}

extension UIView.AnimationCurve {
    
    var animationOptions: UIView.AnimationOptions {
        switch self {
        case .easeIn:
            return .curveEaseIn
        case .easeOut:
            return .curveEaseOut
        case .easeInOut:
            return .curveEaseInOut
        default:
            return .curveLinear
        }
    }
}
