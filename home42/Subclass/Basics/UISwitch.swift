// home42/UISwitch.swift
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

final class BasicUISwitch: UISwitch {
    
    var primary: UIColor {
        set { self.onTintColor = newValue }
        get { return self.onTintColor! }
    }
    
    init(isOn: Bool = false, primary: UIColor = HomeDesign.primary) {
        super.init(frame: .zero)
        self.onTintColor = primary
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

protocol HomeSwitchDelegate: AnyObject {
    func switchValueChanged(switch: HomeSwitch)
}

final class HomeSwitch: BasicUIView {
    
    weak var delegate: HomeSwitchDelegate? = nil
    
    func set(isOn: Bool, animated: Bool) {
        self.isOn = isOn
        if animated {
            self.isUserInteractionEnabled = false
            HomeAnimations.transitionQuick(withView: self, {
                self.updateState()
            }, completion: nil)
            HomeAnimations.animateQuick({
                self.updateBallConstraint()
                self.layoutIfNeeded()
            }, completion: { _ in
                self.isUserInteractionEnabled = true
            })
        }
        else {
            self.updateState()
            self.updateBallConstraint()
            self.setNeedsLayout()
        }
    }
    private(set) var isOn: Bool
    private var primary: UIColor
    
    private let onLabel: BasicUILabel
    private let offLabel: BasicUILabel
    
    static private let ballHeight: CGFloat = HomeLayout.switchHeigth - (HomeLayout.dmargin * 2.0)
    static private let ballRadius: CGFloat = HomeSwitch.ballHeight / 2.0
    private let ball: BasicUIView
    private var ballCenterX: NSLayoutConstraint!
    
    init(on: String = ~"general.on-state", off: String = ~"general.off-state", isOn: Bool = true, primary: UIColor = HomeDesign.primary) {
        self.onLabel = BasicUILabel(text: on)
        self.onLabel.textColor = HomeDesign.black
        self.onLabel.textAlignment = .center
        self.onLabel.font = HomeLayout.fontSemiBoldMedium
        self.offLabel = BasicUILabel(text: off)
        self.offLabel.textColor = HomeDesign.black
        self.offLabel.textAlignment = .center
        self.offLabel.font = HomeLayout.fontSemiBoldMedium
        self.ball = BasicUIView()
        self.ball.layer.cornerRadius = HomeSwitch.ballRadius
        self.ball.layer.shadowOffset = .zero
        self.ball.layer.shadowColor = HomeDesign.black.cgColor
        self.ball.layer.shadowRadius = HomeLayout.border
        self.ball.layer.shadowOpacity = Float(HomeDesign.alphaMiddle)
        self.isOn = isOn
        self.primary = primary
        super.init()
        self.layer.cornerRadius = HomeLayout.switchRadius
        self.layer.borderWidth = HomeLayout.border
        self.layer.borderColor = HomeDesign.primary.cgColor
        self.updateState()
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(HomeSwitch.tapGesture(sender:))))
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview != nil else { return }
        self.addSubview(self.onLabel)
        self.onLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: HomeLayout.smargin).isActive = true
        self.onLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.onLabel.trailingAnchor.constraint(greaterThanOrEqualTo: self.trailingAnchor, constant: -HomeLayout.switchHeigth).isActive = true
        self.addSubview(self.offLabel)
        self.offLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.smargin).isActive = true
        self.offLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.offLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor, constant: HomeLayout.switchHeigth).isActive = true
        self.addSubview(self.ball)
        self.ball.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.ball.widthAnchor.constraint(equalToConstant: HomeSwitch.ballHeight).isActive = true
        self.ball.heightAnchor.constraint(equalToConstant: HomeSwitch.ballHeight).isActive = true
        self.updateBallConstraint()
        self.heightAnchor.constraint(equalToConstant: HomeLayout.switchHeigth).isActive = true
    }
    
    private func updateBallConstraint() {
        if self.ballCenterX != nil {
            self.removeConstraint(self.ballCenterX)
        }
        if self.isOn {
            self.ballCenterX = self.ball.centerXAnchor.constraint(equalTo: self.onLabel.trailingAnchor, constant: HomeSwitch.ballRadius + HomeLayout.dmargin)
        }
        else {
            self.ballCenterX = self.ball.centerXAnchor.constraint(equalTo: self.offLabel.leadingAnchor, constant: -(HomeSwitch.ballRadius + HomeLayout.dmargin))
        }
        if self.ball.superview != nil {
            self.ballCenterX.isActive = true
        }
    }
    
    private func updateState() {
        if self.isOn {
            self.onLabel.alpha = 1.0
            self.offLabel.alpha = 0.0
            self.ball.backgroundColor = HomeDesign.white
            self.backgroundColor = self.primary
            self.onLabel.textColor = HomeDesign.white
        }
        else {
            self.onLabel.alpha = 0.0
            self.offLabel.alpha = 1.0
            self.ball.backgroundColor = HomeDesign.lightGray
            self.backgroundColor = HomeDesign.white
            self.offLabel.textColor = HomeDesign.black
        }
    }
    
    @objc private func tapGesture(sender: UITapGestureRecognizer) {
        self.isUserInteractionEnabled = false
        self.isOn = !self.isOn
        HomeAnimations.transitionQuick(withView: self, {
            self.updateState()
        }, completion: nil)
        HomeAnimations.animateQuick({
            self.updateBallConstraint()
            self.layoutIfNeeded()
        }, completion: { _ in
            self.isUserInteractionEnabled = true
        })
        self.delegate?.switchValueChanged(switch: self)
    }
}
