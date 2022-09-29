// home42/WebView.swift
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
import SafariServices

final class SafariWebView: SFSafariViewController {
    
    init(_ url: URL, addUserCookies: Bool = true, primaryColor: UIColor = HomeDesign.primary) {
        super.init(url: url, configuration: SFSafariViewController.Configuration())
        self.preferredControlTintColor = primaryColor
    }
}

final class WebViewDataContainerDecoder: DynamicController {
    
    private let contentView = BasicUIView()
    private let textView = BasicUITextView()
    
    private let closeButton = ActionButtonView(asset: .actionClose, color: HomeDesign.actionRed)
    private let reportButton = ActionButtonView(asset: .settingsCafard, color: HomeDesign.actionOrange)
    private let error: HomeApi.RequestError
    
    @discardableResult init(data: Data, error: HomeApi.RequestError) {
        self.error = error
        super.init()
        
        self.view.addSubview(contentView)
        contentView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        contentView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: HomeLayout.margind).isActive = true
        contentView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: HomeLayout.margind).isActive = true
        contentView.layer.cornerRadius = HomeLayout.corner
        contentView.backgroundColor = HomeDesign.white
        contentView.addSubview(textView)
        textView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: HomeLayout.margin).isActive = true
        textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: HomeLayout.margin).isActive = true
        textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -HomeLayout.margin).isActive = true
        textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -HomeLayout.margin).isActive = true
        if let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) {
            textView.text = String(data: try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted), encoding: .utf8)
        }
        else if let string = String(data: data, encoding: .utf8) {
            textView.text = string
        }
        else {
            textView.text = String(describing: data)
        }
        textView.isEditable = false
        textView.isScrollEnabled = true
        self.view.addSubview(self.closeButton)
        self.closeButton.centerYAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        self.closeButton.centerXAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        self.closeButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(WebViewDataContainerDecoder.closeButtonTapped(sender:))))
        self.view.addSubview(self.reportButton)
        self.reportButton.centerYAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        self.reportButton.trailingAnchor.constraint(equalTo: self.closeButton.leadingAnchor, constant: -HomeLayout.smargin).isActive = true
        self.reportButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(WebViewDataContainerDecoder.reportButtonTapped(sender:))))
        self.present()
        #if DEBUG
        print(self.textView.text!)
        print(error.description)
        #endif
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    required init() { fatalError("init() has not been implemented") }
    
    override func present() {
        self.contentView.alpha = 0.0
        self.closeButton.alpha = 0.0
        self.reportButton.alpha = 0.0
        super.present()
        HomeAnimations.animateShort({
            self.contentView.alpha = 1.0
            self.closeButton.alpha = 1.0
            self.reportButton.alpha = 1.0
            self.background.effect = HomeDesign.blur
        })
    }
    override func remove(isFinish: Bool = true) {
        HomeAnimations.animateShort({
            self.contentView.alpha = 0.0
            self.closeButton.alpha = 0.0
            self.reportButton.alpha = 0.0
            self.background.effect = nil
        }, completion: super.remove(isFinish:))
    }
    
    @objc private func reportButtonTapped(sender: UITapGestureRecognizer) {
        HomeCafards.generateReport(apiJSONText: self.textView.text!, apiJSONError: self.error) {
            self.remove()
        }
    }
    
    @objc private func closeButtonTapped(sender: UITapGestureRecognizer) {
        self.remove()
    }
}
