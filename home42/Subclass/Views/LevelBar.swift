// home42/LevelBar.swift
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

final class Level21Bar: BasicUIView {
    
    private let gradient: GradientView
    private var gradientTrailing: NSLayoutConstraint!
    private let label: HomeInsetsLabel
    private let labelWhite: HomeInsetsLabel
    private var labelLeading: NSLayoutConstraint!
    private var labelWhiteLeading: NSLayoutConstraint!
    
    override init() {
        self.gradient = GradientView()
        self.gradient.startPoint = .init(x: 0.0, y: 0.0)
        self.gradient.endPoint = .init(x: 1.0, y: 0.0)
        self.gradient.clipsToBounds = true
        self.label = HomeInsetsLabel(text: "0.00", inset: .init(width: HomeLayout.margin, height: 0.0))
        self.label.font = HomeLayout.fontMonospacedBlackMedium
        self.label.textColor = HomeDesign.primaryDefault
        self.labelWhite = HomeInsetsLabel(text: "0.00", inset: .init(width: HomeLayout.margin, height: 0.0))
        self.labelWhite.font = HomeLayout.fontMonospacedBlackMedium
        self.labelWhite.textColor = HomeDesign.lightGray
        super.init()
        self.backgroundColor = self.labelWhite.textColor
        self.layer.cornerRadius = HomeLayout.corner
        self.layer.maskedCorners = [.layerMaxXMaxYCorner]
        self.layer.masksToBounds = true
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview != nil else { return }
        
        self.heightAnchor.constraint(equalToConstant: HomeLayout.level21BarHeigth).isActive = true
        self.addSubview(self.label)
        self.addSubview(self.gradient)
        self.gradient.addSubview(self.labelWhite)
        self.gradient.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.gradient.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.gradient.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.gradientTrailing = self.gradient.trailingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0.0)
        self.gradientTrailing.isActive = true
        
        self.label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.labelLeading = self.label.leadingAnchor.constraint(equalTo: self.gradient.trailingAnchor)
        self.labelLeading.priority = .defaultLow
        self.labelLeading.isActive = true
        self.label.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor, constant: HomeLayout.smargin).isActive = true
        self.label.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor).isActive = true
        
        self.labelWhite.centerYAnchor.constraint(equalTo: self.gradient.centerYAnchor).isActive = true
        self.labelWhiteLeading = self.labelWhite.leadingAnchor.constraint(equalTo: self.gradient.trailingAnchor)
        self.labelWhiteLeading.priority = .defaultLow
        self.labelWhiteLeading.isActive = true
        self.labelWhite.leadingAnchor.constraint(greaterThanOrEqualTo: self.gradient.leadingAnchor, constant: HomeLayout.smargin).isActive = true
        self.labelWhite.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor).isActive = true
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let newConstant = (rect.width * self.progress)
        
        if self.gradientTrailing.constant != newConstant {
            HomeAnimations.animateLongLong({
                self.gradientTrailing.constant = newConstant
                self.label.textColor = self.primary
                self.layoutIfNeeded()
            }, completion: nil)
            self.labelTransition(newConstant: newConstant)
        }
    }
    
    private var timerLevel: CGFloat = 0.0
    private var timer: Timer! = nil
    private func labelTransition(newConstant: CGFloat) {
        let duration = HomeAnimations.durationLongLong
        let interval: CGFloat = 0.02
        let count = Int(duration / interval)
        var index: Int = 0
        let current = CGFloat(Double(self.label.text!) ?? 0.0)
        let diff = self.level - current
        
        func execute(timer: Timer) {
            index &+= 1
            self.label.text = String(format: "%.2f", current + (CGFloat(index) / CGFloat(count)) * diff)
            self.labelWhite.text = self.label.text
            if index >= count {
                timer.invalidate()
                self.timer = nil
            }
        }
        
        if let oldTimer = self.timer {
            if self.timerLevel == self.level {
                return
            }
            oldTimer.invalidate()
        }
        self.timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: execute(timer:))
        self.timerLevel = self.level
    }
    
    private var primary: UIColor!
    private var level: CGFloat = 0.0
    private var progress: CGFloat = 0.0
    
    func update(with level: CGFloat, primary: UIColor) {
        var newProgress = level / 21.0
            
        if newProgress > 1.0 {
            newProgress = 1.0
        }
        if self.gradient.colors == nil {
            self.gradient.colors = [primary.cgColor, primary.secondaryColor.cgColor]
        }
        else {
            let animation = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.colors))
            let colors = [primary.cgColor, primary.secondaryColor.cgColor]
            
            animation.fromValue = self.gradient.colors
            animation.toValue = colors
            animation.duration = HomeAnimations.durationLongLong
            animation.timingFunction = HomeAnimations.curveCG
            self.gradient.layer.add(animation, forKey: "colors")
            self.gradient.colors = colors
        }
        self.progress = newProgress
        self.level = level
        self.primary = primary
        if newProgress == 0.0 {
            self.label.textColor = primary
        }
        self.setNeedsDisplay()
    }
}
