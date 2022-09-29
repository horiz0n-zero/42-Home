// home42/UIView.swift
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

class BasicUIView: UIView {
    
    init() {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class HomePressableUIView: BasicUIView {
    
    var isPressed: Bool = false
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.isPressed = true
        HomeAnimations.animateLigthSpeed({
            self.transform = CGAffineTransform.init(scaleX: 0.95, y: 0.95)
        })
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.isPressed == true {
            self.isPressed = false
            HomeAnimations.animateLigthSpeed({
                self.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
            })
        }
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.isPressed == true {
            self.isPressed = false
            HomeAnimations.animateLigthSpeed({
                self.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
            })
        }
    }
}

class BasicInnerShadowedUIView: BasicUIView {
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
}

extension UIView {
    
    func parent<G: UIView>() -> G? {
        var target: UIView! = self.superview
        
        while (target != nil) {
            if let parent = target as? G {
                return parent
            }
            target = target.superview
        }
        return nil
    }
    
    func offsetFromYBottomOrigin(fromParent superview: UIView) -> CGFloat {
        var offset = self.frame.size.height
        var target: UIView = self
        
        while target.superview != nil && target.superview != superview {
            offset += target.bounds.origin.y
            target = target.superview!
        }
        offset += self.frame.origin.y
        return offset
    }
    
    var parentViewController: UIViewController? {
        var responder: UIResponder = self
    
        while responder is UIView && responder.next != nil {
            responder = responder.next!
        }
        return responder as? UIViewController
    }
    var parentHomeViewController: HomeViewController? {
        var responder: UIResponder = self
    
        while responder is UIView && responder.next != nil {
            responder = responder.next!
        }
        return responder as? HomeViewController
    }
    
    func renderImage() -> UIImage {
        let context: CGContext!
        let image: UIImage!
        
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        context = UIGraphicsGetCurrentContext()
        self.layer.render(in: context)
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
