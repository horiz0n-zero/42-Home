// home42/DynamicActionsSheet.swift
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

final class DynamicActionsSheet: DynamicController {
    
    @frozen enum Action {
        case title(String)
        case titleWithPrimary(String)
        case text(String)
        case textWithPrimary(String)
        case image(UIImage.Assets)
        case imageWithPrimary(UIImage.Assets, UIColor)
        case normal(String, UIImage.Assets, () -> ())
        case normalWithPrimary(String, UIImage.Assets, UIColor, () -> ())
        case telephony(String)
        case separator
        case separatorWithPrimary(UIColor)
    }
    
    private let container: BasicUIView
    private let cancelButton: DynamicActionsSheet.ButtonView
    private unowned(unsafe) let primary: UIColor
    
    @discardableResult init(actions: [DynamicActionsSheet.Action], primary: UIColor = HomeDesign.primary) {
        self.container = BasicUIView()
        self.cancelButton = DynamicActionsSheet.ButtonView(primary: primary, title: ~"general.cancel", asset: nil, block: nil)
        self.primary = primary
        super.init()
        var top = container.topAnchor
        
        if let backgroundPrimary = self.backgroundPrimary {
            backgroundPrimary.alpha = 0.0
            backgroundPrimary.backgroundColor = primary.withAlphaComponent(HomeDesign.alphaLow)
        }
        
        self.view.addSubview(self.cancelButton)
        self.cancelButton.backgroundColor = HomeDesign.white
        self.cancelButton.layer.cornerRadius = HomeLayout.corners
        self.cancelButton.layer.masksToBounds = true
        self.cancelButton.layer.borderColor = primary.cgColor
        self.cancelButton.layer.borderWidth = HomeLayout.border
        self.cancelButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -HomeLayout.margin).isActive = true
        self.cancelButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: HomeLayout.margins).isActive = true
        self.cancelButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -HomeLayout.margins).isActive = true
        
        self.view.insertSubview(self.container, belowSubview: self.cancelButton)
        self.container.layer.cornerRadius = HomeLayout.corners
        self.container.backgroundColor = HomeDesign.white
        self.container.leadingAnchor.constraint(equalTo: self.cancelButton.leadingAnchor).isActive = true
        self.container.trailingAnchor.constraint(equalTo: self.cancelButton.trailingAnchor).isActive = true
        self.container.bottomAnchor.constraint(equalTo: self.cancelButton.topAnchor, constant: -HomeLayout.margin).isActive = true
        
        func addActionView(_ view: UIView, margin: CGFloat = 0.0) {
            self.container.addSubview(view)
            view.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: margin).isActive = true
            view.trailingAnchor.constraint(equalTo: self.container.trailingAnchor, constant: -margin).isActive = true
            view.topAnchor.constraint(equalTo: top, constant: HomeLayout.margin).isActive = true
            top = view.bottomAnchor
        }
        
        func addImage(_ asset: UIImage.Assets, color: UIColor) {
            let image = asset.image
            let view = BasicUIImageView(image: image)
            
            view.tintColor = color
            self.container.addSubview(view)
            view.centerXAnchor.constraint(equalTo: self.container.centerXAnchor).isActive = true
            view.heightAnchor.constraint(equalToConstant: image.size.height).isActive = true
            view.widthAnchor.constraint(equalToConstant: image.size.width).isActive = true
            view.topAnchor.constraint(equalTo: top, constant: HomeLayout.margin).isActive = true
            top = view.bottomAnchor
        }
        
        func addLabel(text: String, color: UIColor, font: UIFont) {
            let label = BasicUILabel(text: text)
            
            label.textColor = color
            label.textAlignment = .center
            label.font = font
            label.numberOfLines = 0
            addActionView(label, margin: HomeLayout.margin)
        }
        
        func addSeparator(_ color: UIColor = primary) {
            let view = BasicUIView()
            
            view.backgroundColor = color
            view.layer.cornerRadius = HomeLayout.sborder
            addActionView(view, margin: HomeLayout.smargin)
            view.heightAnchor.constraint(equalToConstant: HomeLayout.border).isActive = true
        }
        
        for action in actions {
            switch action {
            case .title(let txt):
                addLabel(text: txt, color: HomeDesign.black, font: HomeLayout.fontSemiBoldTitle)
            case .titleWithPrimary(let txt):
                addLabel(text: txt, color: primary, font: HomeLayout.fontSemiBoldTitle)
            case .text(let txt):
                addLabel(text: txt, color: HomeDesign.black, font: HomeLayout.fontRegularMedium)
            case .textWithPrimary(let txt):
                addLabel(text: txt, color: primary, font: HomeLayout.fontRegularMedium)
            case .image(let asset):
                addImage(asset, color: primary)
            case .imageWithPrimary(let asset, let primaryColor):
                addImage(asset, color: primaryColor)
            case .normal(let title, let asset, let block):
                addActionView(DynamicActionsSheet.ButtonView(primary: primary, title: title, asset: asset, block: block))
            case .normalWithPrimary(let title, let asset, let primaryColor, let block):
                addActionView(DynamicActionsSheet.ButtonView(primary: primaryColor, title: title, asset: asset, block: block))
            case .telephony(let phoneNumber):
                addActionView(DynamicActionsSheet.ButtonView(primary: primary, title: ~"general.call", asset: .actionSettings, block: { HomeTelephony.call(phoneNumber) }))
                addSeparator()
                addActionView(DynamicActionsSheet.ButtonView(primary: primary, title: ~"general.message", asset: .actionSearch, block: { HomeTelephony.message(phoneNumber) }))
                addSeparator()
                addActionView(DynamicActionsSheet.ButtonView(primary: primary, title: ~"general.copy", asset: .actionAdd, block: { UIPasteboard.general.string = phoneNumber }))
            case .separator:
                addSeparator()
            case .separatorWithPrimary(let primary):
                addSeparator(primary)
            }
        }
        top.constraint(equalTo: self.container.bottomAnchor, constant: -HomeLayout.margin).isActive = true
        self.present()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    required init() { fatalError("init() has not been implemented") }
    
    // MARK: -
    override func present() {
        self.container.alpha = 0.0
        self.container.center = .init(x: 0.0, y: HomeLayout.dynamicActionsSheetButtonHeigth)
        self.cancelButton.center = .init(x: 0.0, y: HomeLayout.safeAeraMain.bottom + HomeLayout.dynamicActionsSheetButtonHeigth)
        super.present()
        HomeAnimations.animateShort({
            self.container.alpha = 1.0
            self.container.center = .zero
            self.cancelButton.center = .zero
            self.background.effect = HomeDesign.blur
            if let backgroundPrimary = self.backgroundPrimary {
                backgroundPrimary.alpha = 1.0
            }
        })
    }
    override func remove(isFinish: Bool = true) {
        HomeAnimations.animateShort({
            self.container.alpha = 0.0
            self.cancelButton.alpha = 0.0
            self.background.effect = nil
            if let backgroundPrimary = self.backgroundPrimary {
                backgroundPrimary.alpha = 0.0
            }
        }, completion: super.remove(isFinish:))
    }
    
    // MARK: -
    final private class ButtonView: BasicUIView {
        
        private var block: (() -> ())?
        private let label: BasicUILabel
        private let imageView: BasicUIImageView?
        
        init(primary: UIColor, title: String, asset: UIImage.Assets? = nil, block: (() -> ())? = nil) {
            self.block = block
            self.label = BasicUILabel(text: title)
            self.label.font = HomeLayout.fontSemiBoldTitle
            self.label.textColor = HomeDesign.black
            self.label.adjustsFontSizeToFitWidth = true
            self.label.numberOfLines = 2
            if let asset = asset {
                self.imageView = BasicUIImageView(asset: asset)
                self.imageView!.tintColor = primary
                self.imageView!.backgroundColor = primary.withAlphaComponent(HomeDesign.alphaLowLayer)
                self.imageView!.layer.cornerRadius = HomeLayout.corner
                self.imageView!.layer.masksToBounds = true
            }
            else {
                self.imageView = nil
                self.label.textAlignment = .center
            }
            super.init()
            self.isUserInteractionEnabled = true
            self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(DynamicActionsSheet.ButtonView.tapGestureReceived(sender:))))
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }
           
            self.heightAnchor.constraint(equalToConstant: HomeLayout.dynamicActionsSheetButtonHeigth).isActive = true
            if let imageView = self.imageView {
                self.addSubview(imageView)
                imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: HomeLayout.margin).isActive = true
                imageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
                imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
                imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
                self.addSubview(self.label)
                self.label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: HomeLayout.margin).isActive = true
                self.label.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
                self.label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.margin).isActive = true
            }
            else {
                self.addSubview(self.label)
                self.label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: HomeLayout.smargin).isActive = true
                self.label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
                self.label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.smargin).isActive = true
            }
        }
        
        @objc private func tapGestureReceived(sender: UITapGestureRecognizer) {
            let parent = self.parentViewController as! DynamicActionsSheet
            
            parent.remove()
            if let block = block {
                block()
            }
        }
    }
    
    // stack ?
    final private class Telephony: BasicUIView {
        
        init(phoneNumber: String) {
            super.init()
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        
    }
    
    static func presentWithWebLink(_ link: String, title: String? = nil, text: String? = nil, primary: UIColor,
                                   parentViewController: UIViewController) {
        
        var checkedLink: String = link
        var actions: [DynamicActionsSheet.Action] = []
        
        if link.hasPrefix("https://") == false && link.hasPrefix("http://") == false {
            checkedLink = "https://" + link
        }
        
        func openWeb() {
            parentViewController.present(SafariWebView(checkedLink.url), animated: true, completion: nil)
        }
        func openSafari() {
            App.open(checkedLink.url, options: [:], completionHandler: nil)
        }
        func copy() {
            UIPasteboard.general.string = checkedLink
        }
        
        if let title = title {
            actions.append(.title(title))
        }
        if let text = text {
            actions.append(.text(text))
        }
        actions.append(.normal(~"openweb-link", .settingsWeb, openWeb))
        actions.append(.normal(~"openweb-link-safari", .settingsWeb, openSafari))
        actions.append(.normal(~"general.copy", .settingsCode, copy))
        DynamicActionsSheet(actions: actions, primary: primary)
    }
}
