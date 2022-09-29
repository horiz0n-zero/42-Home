// home42/AntenneView.swift
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

final class AntenneView: BasicUIImageView {
    
    private static let breakImages: Array<UIImage> = {
        return [UIImage(named: "antenne_break_1")!, UIImage(named: "antenne_break_2")!]
    }()
    private static let workImages: Array<UIImage> = {
        return [UIImage(named: "antenne_work_1")!, UIImage(named: "antenne_work_2")!, UIImage(named: "antenne_work_3")!]
    }()
    private let animatedImageView: BasicUIImageView
    
    var isBreak: Bool {
        didSet {
            if oldValue != self.isBreak {
                if isBreak {
                    self.animatedImageView.image = AntenneView.breakImages[0]
                    self.animatedImageView.animationImages = AntenneView.breakImages
                }
                else {
                    self.animatedImageView.image = AntenneView.workImages[0]
                    self.animatedImageView.animationImages = AntenneView.workImages
                }
                self.animatedImageView.animationDuration = HomeAnimations.durationShort * TimeInterval(self.animatedImageView.animationImages!.count)
            }
        }
    }
    var isAntenneAnimating: Bool {
        didSet {
            if self.isAntenneAnimating && self.animatedImageView.isAnimating == false {
                self.animatedImageView.startAnimating()
            }
            else if self.isAntenneAnimating == false && self.animatedImageView.isAnimating {
                self.animatedImageView.stopAnimating()
            }
        }
    }
    
    init(isBreak: Bool, isAntenneAnimating: Bool = false, backgroundColor: UIColor = HomeDesign.white, foregroundColor: UIColor = HomeDesign.black) {
        if isBreak {
            self.animatedImageView = BasicUIImageView(image: AntenneView.breakImages[0])
            self.animatedImageView.animationImages = AntenneView.breakImages
        }
        else {
            self.animatedImageView = BasicUIImageView(image: AntenneView.workImages[0])
            self.animatedImageView.animationImages = AntenneView.workImages
        }
        self.animatedImageView.animationDuration = HomeAnimations.durationShort * TimeInterval(self.animatedImageView.animationImages!.count)
        self.animatedImageView.animationRepeatCount = 0
        self.isBreak = isBreak
        self.isAntenneAnimating = isAntenneAnimating
        super.init(image: UIImage(named: "antenne")!)
        self.tintColor = foregroundColor
        self.layer.cornerRadius = HomeLayout.corner
        self.layer.masksToBounds = true
        self.backgroundColor = backgroundColor
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview != nil else { return }
        
        self.addSubview(self.animatedImageView)
        self.animatedImageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.animatedImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.animatedImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.animatedImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        if self.isAntenneAnimating {
            self.animatedImageView.startAnimating()
        }
    }
    
    override func removeFromSuperview() {
        self.isAntenneAnimating = false
        super.removeFromSuperview()
    }
    
    deinit {
        if self.isAnimating {
            self.stopAnimating()
        }
    }
}

final class AntenneBlurredView: BasicUIVisualEffectView {
    
    let antenne: AntenneView
    
    init(isBreak: Bool, isAntenneAnimating: Bool = false) {
        self.antenne = AntenneView(isBreak: isBreak, isAntenneAnimating: isAntenneAnimating, backgroundColor: UIColor.clear, foregroundColor: HomeDesign.white)
        super.init(effect: HomeDesign.blur)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview != nil else { return }
        
        self.contentView.addSubview(self.antenne)
        self.antenne.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        self.antenne.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        self.antenne.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        self.antenne.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        self.layer.cornerRadius = self.antenne.layer.cornerRadius
        self.layer.masksToBounds = self.antenne.layer.masksToBounds
    }
}

protocol AntenneTableViewCell: BasicUITableViewCell {
    var antenne: AntenneView { get }
}

final class AntenneWhiteTableViewCell: BasicUITableViewCell, AntenneTableViewCell {
    
    let antenne: AntenneView = AntenneView(isBreak: false, isAntenneAnimating: true)
    
    override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview != nil else { return }
        
        self.contentView.addSubview(self.antenne)
        self.antenne.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: HomeLayout.margin).isActive = true
        self.antenne.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -HomeLayout.margin).isActive = true
        self.antenne.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true
        self.antenne.heightAnchor.constraint(equalToConstant: HomeLayout.antenneViewSize).isActive = true
        self.antenne.widthAnchor.constraint(equalToConstant: HomeLayout.antenneViewSize).isActive = true
    }
}

final class AntenneBlurTableViewCell: BasicUITableViewCell, AntenneTableViewCell {
    
    let antenne: AntenneView = AntenneView(isBreak: false, isAntenneAnimating: true, backgroundColor: UIColor.clear, foregroundColor: HomeDesign.white)
    private let blurBackground = BasicUIVisualEffectView(effect: HomeDesign.blur)
    
    override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview != nil else { return }
        
        self.contentView.addSubview(self.blurBackground)
        self.contentView.addSubview(self.antenne)
        self.antenne.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: HomeLayout.margin).isActive = true
        self.antenne.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -HomeLayout.margin).isActive = true
        self.antenne.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true
        self.antenne.heightAnchor.constraint(equalToConstant: HomeLayout.antenneViewSize).isActive = true
        self.antenne.widthAnchor.constraint(equalToConstant: HomeLayout.antenneViewSize).isActive = true
        self.blurBackground.topAnchor.constraint(equalTo: self.antenne.topAnchor).isActive = true
        self.blurBackground.bottomAnchor.constraint(equalTo: self.antenne.bottomAnchor).isActive = true
        self.blurBackground.leadingAnchor.constraint(equalTo: self.antenne.leadingAnchor).isActive = true
        self.blurBackground.trailingAnchor.constraint(equalTo: self.antenne.trailingAnchor).isActive = true
        self.blurBackground.layer.cornerRadius = self.antenne.layer.cornerRadius
        self.blurBackground.layer.masksToBounds = self.antenne.layer.masksToBounds
    }
}
