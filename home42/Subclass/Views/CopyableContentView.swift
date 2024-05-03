// home42/CopyableContentView.swift
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

final class CopyableContentView: BasicUIView, TextOutputStream {
    
    private let headerView: BasicUIView
    private let titleLabel: BasicUILabel
    private let actionCopy: ActionButtonView
    private let actionShare: ActionButtonView
    var title: String {
        set {
            self.titleLabel.text = newValue.uppercased()
        }
        get {
            return self.titleLabel.text!
        }
    }
    private let textView: UITextView
    
    init(title: String, primaryColor: UIColor) {
        self.headerView = .init()
        self.headerView.backgroundColor = primaryColor
        self.titleLabel = BasicUILabel(text: title.uppercased())
        self.titleLabel.textColor = HomeDesign.white
        self.titleLabel.textAlignment = .left
        self.titleLabel.font = HomeLayout.fontSemiBoldTitle
        self.actionCopy = .init(asset: .actionText, color: HomeDesign.white)
        self.actionCopy.iconTintColor = primaryColor
        self.actionShare = .init(asset: .actionShare, color: HomeDesign.white)
        self.actionShare.iconTintColor = primaryColor
        self.textView = UITextView()
        self.textView.isEditable = false
        self.textView.isScrollEnabled = true
        self.textView.isSelectable = false
        self.textView.translatesAutoresizingMaskIntoConstraints = false
        self.textView.textAlignment = .left
        self.textView.backgroundColor = .clear
        self.textView.font = HomeLayout.fontRegularMedium
        self.textView.textColor = HomeDesign.black
        self.textView.contentInset = .init(top: HomeLayout.smargin, left: 0.0, bottom: HomeLayout.smargin, right: 0.0)
        super.init()
        self.backgroundColor = primaryColor.withAlphaComponent(HomeDesign.alphaLowLayer)
        self.layer.cornerRadius = HomeLayout.corner
        self.layer.masksToBounds = true
        self.actionCopy.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(actionCopyTapped)))
        self.actionShare.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(actionShareTapped)))
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview != nil else { return }
        
        self.addSubview(self.headerView)
        self.headerView.heightAnchor.constraint(equalToConstant: HomeLayout.terminalHeaderHeight).isActive = true
        self.headerView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.headerView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.headerView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.headerView.addSubview(self.titleLabel)
        self.titleLabel.centerYAnchor.constraint(equalTo: self.headerView.centerYAnchor).isActive = true
        self.titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: HomeLayout.margin).isActive = true
        
        self.headerView.addSubview(self.actionCopy)
        self.actionCopy.centerYAnchor.constraint(equalTo: self.titleLabel.centerYAnchor).isActive = true
        self.actionCopy.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.margin).isActive = true
        self.headerView.addSubview(self.actionShare)
        self.actionShare.centerYAnchor.constraint(equalTo: self.actionCopy.centerYAnchor).isActive = true
        self.actionShare.trailingAnchor.constraint(equalTo: self.actionCopy.leadingAnchor, constant: -HomeLayout.smargin).isActive = true
        self.actionShare.leadingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor, constant: HomeLayout.smargin).isActive = true
        
        self.addSubview(self.textView)
        self.textView.topAnchor.constraint(equalTo: self.headerView.bottomAnchor).isActive = true
        self.textView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: HomeLayout.dmargin).isActive = true
        self.textView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.smargin).isActive = true
        self.textView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    @objc private func actionCopyTapped() {
        UIPasteboard.general.string = self.textView.text!
        DynamicAlert(.none, contents: [.title(~"login-verifier.action.copy-success")], actions: [.normal(~"general.ok", nil)])
    }
    
    @objc private func actionShareTapped() {
        
    }
    
    func write(_ string: String) {
        self.textView.text += string
        self.textView.scrollRangeToVisible(NSMakeRange(self.textView.text!.count - 1, 1))
    }
    func clear() {
        self.textView.text = ""
    }
}
