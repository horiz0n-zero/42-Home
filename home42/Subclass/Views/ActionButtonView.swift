// home42/ActionButtonView.swift
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

final class ActionButtonView: HomePressableUIView {
    
    var asset: UIImage.Assets
    private let icon: BasicUIImageView
    private let shadowView: BasicUIView
    
    override var isUserInteractionEnabled: Bool {
        didSet {
            if self.isUserInteractionEnabled {
                self.alpha = 1.0
            }
            else {
                self.alpha = HomeDesign.alphaMiddle
            }
        }
    }
    
    init(asset: UIImage.Assets, color: UIColor) {
        self.asset = asset
        self.icon = BasicUIImageView(asset: asset)
        self.icon.tintColor = HomeDesign.white
        self.shadowView = BasicUIView()
        self.shadowView.backgroundColor = color
        self.shadowView.layer.cornerRadius = HomeLayout.actionButtonIconRadius
        self.shadowView.layer.borderWidth = HomeLayout.borders
        self.shadowView.layer.borderColor = color.withAlphaComponent(HomeDesign.alphaLayer).cgColor
        self.shadowView.layer.shadowColor = color.cgColor
        self.shadowView.layer.shadowOffset = .init(width: 0.0, height: HomeLayout.border)
        self.shadowView.layer.shadowRadius = HomeLayout.border
        self.shadowView.layer.shadowOpacity = 0.5
        super.init()
        self.isUserInteractionEnabled = true
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    var primary: UIColor {
        get {
            return self.shadowView.backgroundColor!
        }
        set {
            self.shadowView.backgroundColor = newValue
            self.shadowView.layer.borderColor = newValue.withAlphaComponent(HomeDesign.alphaLayer).cgColor
            self.shadowView.layer.shadowColor = newValue.cgColor
        }
    }
    var iconTintColor: UIColor {
        get {
            return self.icon.tintColor
        }
        set {
            self.icon.tintColor = newValue
        }
    }
    func removeBorderWidth() {
        self.shadowView.layer.borderWidth = 0
    }
    
    func `switch`(asset: UIImage.Assets, color: UIColor) {
        self.asset = asset
        HomeAnimations.transitionLigthSpeed(withView: self, {
            self.icon.image = asset.image
            self.shadowView.backgroundColor = color
            self.shadowView.layer.borderColor = color.withAlphaComponent(HomeDesign.alphaLayer).cgColor
            self.shadowView.layer.shadowColor = color.cgColor
        })
    }
    
    func `set`(asset: UIImage.Assets, color: UIColor) {
        self.asset = asset
        self.icon.image = asset.image
        self.shadowView.backgroundColor = color
        self.shadowView.layer.borderColor = color.withAlphaComponent(HomeDesign.alphaLayer).cgColor
        self.shadowView.layer.shadowColor = color.cgColor
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview != nil else { return }
        
        self.addSubview(self.shadowView)
        self.shadowView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.shadowView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.shadowView.heightAnchor.constraint(equalToConstant: HomeLayout.actionButtonIconSize).isActive = true
        self.shadowView.widthAnchor.constraint(equalToConstant: HomeLayout.actionButtonIconSize).isActive = true
        self.addSubview(self.icon)
        self.icon.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.icon.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.icon.heightAnchor.constraint(equalToConstant: HomeLayout.actionButtonIconSize).isActive = true
        self.icon.widthAnchor.constraint(equalToConstant: HomeLayout.actionButtonIconSize).isActive = true
        self.heightAnchor.constraint(equalToConstant: HomeLayout.actionButtonSize).isActive = true
        self.widthAnchor.constraint(equalToConstant: HomeLayout.actionButtonSize).isActive = true
    }
    
    static private let rotateKey = "transform.rotation.z"
    func startRotate() {
        let animation = CABasicAnimation(keyPath: ActionButtonView.rotateKey)
        
        animation.toValue = CGFloat.pi * 2.0
        animation.duration = HomeAnimations.durationLong
        animation.repeatCount = .infinity
        self.icon.layer.add(animation, forKey: ActionButtonView.rotateKey)
    }
    func stopRotate() {
        self.icon.layer.removeAnimation(forKey: ActionButtonView.rotateKey)
    }
}

// MARK: -
class ActionActivityIndicatorButtonView: HomePressableUIView {
    
    private let icon: BasicUIImageView
    private let activityIndicator: BasicUIActivityIndicatorView
    private let shadowView: BasicUIView
    
    override var isUserInteractionEnabled: Bool {
        didSet {
            if self.isUserInteractionEnabled {
                self.alpha = 1.0
            }
            else {
                self.alpha = HomeDesign.alphaMiddle
            }
        }
    }
    
    init(primary: UIColor, asset: UIImage.Assets) {
        self.icon = BasicUIImageView(asset: asset)
        self.icon.tintColor = HomeDesign.white
        self.activityIndicator = BasicUIActivityIndicatorView(primary: HomeDesign.white)
        self.shadowView = BasicUIView()
        self.shadowView.backgroundColor = primary
        self.shadowView.layer.cornerRadius = HomeLayout.actionButtonIconRadius
        self.shadowView.layer.borderWidth = HomeLayout.borders
        self.shadowView.layer.borderColor = primary.withAlphaComponent(HomeDesign.alphaLayer).cgColor
        self.shadowView.layer.shadowColor = primary.cgColor
        self.shadowView.layer.shadowOffset = .init(width: 0.0, height: HomeLayout.border)
        self.shadowView.layer.shadowRadius = HomeLayout.border
        self.shadowView.layer.shadowOpacity = 0.5
        super.init()
        self.isUserInteractionEnabled = true
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var primary: UIColor {
        get {
            return self.shadowView.backgroundColor!
        }
        set {
            self.shadowView.backgroundColor = newValue
            self.shadowView.layer.borderColor = newValue.withAlphaComponent(HomeDesign.alphaLayer).cgColor
            self.shadowView.layer.shadowColor = newValue.cgColor
        }
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview != nil else { return }
        
        self.addSubview(self.shadowView)
        self.shadowView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.shadowView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.shadowView.heightAnchor.constraint(equalToConstant: HomeLayout.actionButtonIconSize).isActive = true
        self.shadowView.widthAnchor.constraint(equalToConstant: HomeLayout.actionButtonIconSize).isActive = true
        self.addSubview(self.icon)
        self.icon.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.icon.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.icon.heightAnchor.constraint(equalToConstant: HomeLayout.actionButtonIconSize).isActive = true
        self.icon.widthAnchor.constraint(equalToConstant: HomeLayout.actionButtonIconSize).isActive = true
        self.heightAnchor.constraint(equalToConstant: HomeLayout.actionButtonSize).isActive = true
        self.widthAnchor.constraint(equalToConstant: HomeLayout.actionButtonSize).isActive = true
        self.addSubview(self.activityIndicator)
        self.activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.activityIndicator.widthAnchor.constraint(equalTo: self.icon.widthAnchor).isActive = true
        self.activityIndicator.heightAnchor.constraint(equalTo: self.icon.heightAnchor).isActive = true
    }
    
    func `set`(_ icon: UIImage.Assets, color: UIColor) {
        self.icon.image = icon.image
        self.primary = color
        self.icon.isHidden = false
        self.activityIndicator.stopAnimating()
    }
    
    func setIndicator(_ color: UIColor) {
        self.icon.isHidden = true
        self.primary = color
        self.activityIndicator.startAnimating()
    }
}

final class ActionWebDataActivityIndicatorButtonView: ActionActivityIndicatorButtonView {
    
    @frozen enum State {
        case waiting
        case inProgress
        case errorOccurred
        case done
    }
    var state: ActionWebDataActivityIndicatorButtonView.State = .waiting {
        didSet {
            HomeAnimations.transitionQuick(withView: self, {
                switch self.state {
                case .waiting:
                    self.set(.actionClose, color: HomeDesign.redError)
                case .inProgress:
                    self.setIndicator(HomeDesign.blueAccess)
                case .errorOccurred:
                    self.set(.actionRefresh, color: HomeDesign.redError)
                case .done:
                    self.set(.actionValidate, color: HomeDesign.greenSuccess)
                }
            }, completion: nil)
        }
    }
    
    init() {
        super.init(primary: HomeDesign.redError, asset: .actionClose)
        self.isUserInteractionEnabled = true
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

final class SmallActionButtonView: HomePressableUIView {
    
    var asset: UIImage.Assets
    private let icon: BasicUIImageView
    private let shadowView: BasicUIView
    
    override var isUserInteractionEnabled: Bool {
        didSet {
            if self.isUserInteractionEnabled {
                self.alpha = 1.0
            }
            else {
                self.alpha = HomeDesign.alphaMiddle
            }
        }
    }
    
    init(asset: UIImage.Assets, color: UIColor) {
        self.asset = asset
        self.icon = BasicUIImageView(asset: asset)
        self.icon.tintColor = HomeDesign.white
        self.shadowView = BasicUIView()
        self.shadowView.backgroundColor = color
        self.shadowView.layer.cornerRadius = HomeLayout.scorner
        self.shadowView.layer.borderWidth = HomeLayout.borders
        self.shadowView.layer.borderColor = color.withAlphaComponent(HomeDesign.alphaLayer).cgColor
        self.shadowView.layer.shadowColor = color.cgColor
        self.shadowView.layer.shadowOffset = .init(width: 0.0, height: HomeLayout.border)
        self.shadowView.layer.shadowRadius = HomeLayout.border
        self.shadowView.layer.shadowOpacity = 0.5
        super.init()
        self.isUserInteractionEnabled = true
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var primary: UIColor {
        get {
            return self.shadowView.backgroundColor!
        }
        set {
            self.shadowView.backgroundColor = newValue
            self.shadowView.layer.borderColor = newValue.withAlphaComponent(HomeDesign.alphaLayer).cgColor
            self.shadowView.layer.shadowColor = newValue.cgColor
        }
    }
    var iconTintColor: UIColor {
        get {
            return self.icon.tintColor
        }
        set {
            self.icon.tintColor = newValue
        }
    }
    
    func `switch`(asset: UIImage.Assets, color: UIColor) {
        self.asset = asset
        HomeAnimations.transitionLigthSpeed(withView: self, {
            self.icon.image = asset.image
            self.shadowView.backgroundColor = color
            self.shadowView.layer.borderColor = color.withAlphaComponent(HomeDesign.alphaLayer).cgColor
            self.shadowView.layer.shadowColor = color.cgColor
        })
    }
    func `set`(asset: UIImage.Assets, color: UIColor) {
        self.asset = asset
        self.icon.image = asset.image
        self.shadowView.backgroundColor = color
        self.shadowView.layer.borderColor = color.withAlphaComponent(HomeDesign.alphaLayer).cgColor
        self.shadowView.layer.shadowColor = color.cgColor
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview != nil else { return }
        
        self.addSubview(self.shadowView)
        self.shadowView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.shadowView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.shadowView.heightAnchor.constraint(equalToConstant: HomeLayout.smallActionButtonIconSize).isActive = true
        self.shadowView.widthAnchor.constraint(equalToConstant: HomeLayout.smallActionButtonIconSize).isActive = true
        self.addSubview(self.icon)
        self.icon.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.icon.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.icon.heightAnchor.constraint(equalToConstant: HomeLayout.smallActionButtonIconSize).isActive = true
        self.icon.widthAnchor.constraint(equalToConstant: HomeLayout.smallActionButtonIconSize).isActive = true
        self.heightAnchor.constraint(equalToConstant: HomeLayout.smallActionButtonSize).isActive = true
        self.widthAnchor.constraint(equalToConstant: HomeLayout.smallActionButtonSize).isActive = true
    }
}
