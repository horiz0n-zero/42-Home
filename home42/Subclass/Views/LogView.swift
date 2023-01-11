// home42/LogView.swift
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

final class LogView: BasicUIView, HomeWhiteContainerTableViewCellView {
    
    private let endIcon: BasicUIImageView
    private let endLabel: BasicUILabel
    private let startIcon: BasicUIImageView
    private let startLabel: BasicUILabel
    private let durationLabel: HomeInsetsLabel
    private let hostLabel: HomeInsetsLabel
    
    override init() {
        self.endIcon = BasicUIImageView(asset: .actionLogout)
        self.endIcon.tintColor = HomeDesign.actionRed.withAlphaComponent(HomeDesign.alphaLow)
        self.endLabel = BasicUILabel(text: "???")
        self.endLabel.font = HomeLayout.fontRegularMedium
        self.endLabel.textColor = HomeDesign.black
        self.endLabel.adjustsFontSizeToFitWidth = true
        self.startIcon = BasicUIImageView(asset: .actionLogin)
        self.startIcon.tintColor = HomeDesign.actionGreen.withAlphaComponent(HomeDesign.alphaLow)
        self.startLabel = BasicUILabel(text: "???")
        self.startLabel.font = HomeLayout.fontRegularMedium
        self.startLabel.textColor = HomeDesign.black
        self.startLabel.adjustsFontSizeToFitWidth = true
        self.durationLabel = HomeInsetsLabel(text: "???", inset: .init(width: HomeLayout.margin, height: HomeLayout.dmargin))
        self.durationLabel.backgroundColor = HomeDesign.primaryDefault.withAlphaComponent(HomeDesign.alphaLayer)
        self.durationLabel.layer.cornerRadius = HomeLayout.scorner
        self.durationLabel.layer.masksToBounds = true
        self.durationLabel.font = HomeLayout.fontBlackNormal
        self.durationLabel.textColor = HomeDesign.white
        self.hostLabel = HomeInsetsLabel(text: "???", inset: .init(width: HomeLayout.margin, height: HomeLayout.dmargin))
        self.hostLabel.backgroundColor = HomeDesign.primaryDefault.withAlphaComponent(HomeDesign.alphaLayer)
        self.hostLabel.layer.cornerRadius = HomeLayout.scorner
        self.hostLabel.layer.masksToBounds = true
        self.hostLabel.font = HomeLayout.fontBlackNormal
        self.hostLabel.textColor = HomeDesign.white
        self.hostLabel.adjustsFontSizeToFitWidth = true
        super.init()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview != nil else {
            return
        }
        
        self.addSubview(self.durationLabel)
        self.durationLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: HomeLayout.margin).isActive = true
        self.durationLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: HomeLayout.margin).isActive = true
        self.addSubview(self.hostLabel)
        self.hostLabel.leadingAnchor.constraint(equalTo: self.durationLabel.trailingAnchor, constant: HomeLayout.smargin).isActive = true
        self.hostLabel.centerYAnchor.constraint(equalTo: self.durationLabel.centerYAnchor).isActive = true
        self.hostLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -HomeLayout.margin).isActive = true
        self.addSubview(self.startIcon)
        self.startIcon.widthAnchor.constraint(equalToConstant: HomeLayout.smallActionButtonSize).isActive = true
        self.startIcon.heightAnchor.constraint(equalToConstant: HomeLayout.smallActionButtonSize).isActive = true
        self.startIcon.topAnchor.constraint(equalTo: self.durationLabel.bottomAnchor, constant: HomeLayout.margin).isActive = true
        self.startIcon.leadingAnchor.constraint(equalTo: self.durationLabel.leadingAnchor, constant: -2.0).isActive = true
        self.addSubview(self.startLabel)
        self.startLabel.leadingAnchor.constraint(equalTo: self.startIcon.trailingAnchor, constant: HomeLayout.smargin).isActive = true
        self.startLabel.centerYAnchor.constraint(equalTo: self.startIcon.centerYAnchor).isActive = true
        self.startLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.margin).isActive = true
        self.addSubview(self.endIcon)
        self.endIcon.widthAnchor.constraint(equalToConstant: HomeLayout.smallActionButtonSize).isActive = true
        self.endIcon.heightAnchor.constraint(equalToConstant: HomeLayout.smallActionButtonSize).isActive = true
        self.endIcon.topAnchor.constraint(equalTo: self.startIcon.bottomAnchor, constant: HomeLayout.dmargin).isActive = true
        self.endIcon.leadingAnchor.constraint(equalTo: self.durationLabel.leadingAnchor).isActive = true
        self.endIcon.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -HomeLayout.margin).isActive = true
        self.addSubview(self.endLabel)
        self.endLabel.leadingAnchor.constraint(equalTo: self.startIcon.trailingAnchor, constant: HomeLayout.smargin).isActive = true
        self.endLabel.centerYAnchor.constraint(equalTo: self.endIcon.centerYAnchor).isActive = true
        self.endLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.smargin).isActive = true
    }
    
    func update(with location: IntraClusterLocation, primary: UIColor = HomeDesign.primary, hideHost: Bool = false) {
        self.startLabel.text = location.beginDate.toString(.historicSmall)
        if location.end_at != nil {
            self.durationLabel.backgroundColor = HomeDesign.blueAccess.withAlphaComponent(HomeDesign.alphaLayer)
            self.durationLabel.text = location.beginDate.toStringDiffTime(to: location.endDate)
            self.endLabel.text = location.endDate.toString(.historicSmall)
        }
        else {
            self.durationLabel.backgroundColor = HomeDesign.greenSuccess.withAlphaComponent(HomeDesign.alphaLayer)
            self.durationLabel.text = location.beginDate.toStringDiffTime(to: Date())
            self.endLabel.text = ~"clusters.logged-in"
        }
        self.hostLabel.isHidden = hideHost
        self.hostLabel.text = location.host
        self.hostLabel.backgroundColor = primary
    }
}
