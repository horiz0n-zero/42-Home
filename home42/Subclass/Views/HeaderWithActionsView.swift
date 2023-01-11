// home42/HeaderWithActionsView.swift
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

protocol HeaderWithActionsDelegate: AnyObject {
    
    func closeButtonTapped()
}

class HeaderWithActionsBase: BasicUIView {
    
    fileprivate let actionsStack: BasicUIStackView
    var actions: [ActionButtonView] {
        return self.actionsStack.arrangedSubviews as! [ActionButtonView]
    }
    
    var title: String { get { return "???" } set { } }
    
    init(actions: [ActionButtonView]?) {
        let closeAction = ActionButtonView(asset: .actionClose, color: HomeDesign.actionRed)
        let closeAllAction: ActionButtonView!
        
        self.actionsStack = BasicUIStackView()
        self.actionsStack.distribution = .fillEqually
        self.actionsStack.spacing = HomeLayout.smargin
        self.actionsStack.alignment = .fill
        self.actionsStack.axis = .horizontal
        if let actions = actions {
            for action in actions {
                self.actionsStack.addArrangedSubview(action)
            }
        }
        if App.settings.depthCloseActivated && HomeViewController.depth >= App.settings.depthMinimum {
            closeAllAction = ActionButtonView(asset: .actionCloseAll, color: HomeDesign.actionRed)
            self.actionsStack.addArrangedSubview(closeAllAction)
        }
        else {
            closeAllAction = nil
        }
        self.actionsStack.addArrangedSubview(closeAction)
        super.init()
        if closeAllAction != nil {
            closeAllAction.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(HeaderWithActionsBase.closeAllButtonTapped(sender:))))
        }
        closeAction.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(HeaderWithActionsBase.closeButtonTapped(sender:))))
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    @objc private func closeButtonTapped(sender: UITapGestureRecognizer) {
        guard let parent = self.parentViewController else {
            return
        }
        
        if let delegate = parent as? HeaderWithActionsDelegate {
            delegate.closeButtonTapped()
        }
        else {
            parent.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func closeAllButtonTapped(sender: UITapGestureRecognizer) {
        guard let parent = self.parentViewController else {
            return
        }
        
        if let delegate = parent as? HeaderWithActionsDelegate {
            delegate.closeButtonTapped()
        }
        else {
            (parent as! HomeViewController).dismissToRootController(animated: true)
        }
    }
}

final class HeaderWithActionsView: HeaderWithActionsBase {
    
    let titleLabel: BasicUILabel
    override var title: String {
        set {
            self.titleLabel.text = newValue
        }
        get {
            return self.titleLabel.text!
        }
    }
    
    init(title: String, actions: [ActionButtonView]? = nil) {
        self.titleLabel = BasicUILabel(text: title)
        self.titleLabel.font = HomeLayout.fontSemiBoldTitle
        self.titleLabel.textColor = HomeDesign.black
        self.titleLabel.adjustsFontSizeToFitWidth = true
        self.titleLabel.numberOfLines = 2
        super.init(actions: actions)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview != nil else { return }
        
        self.addSubview(self.actionsStack)
        self.actionsStack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.margin).isActive = true
        self.actionsStack.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -HomeLayout.smargin).isActive = true
        self.addSubview(self.titleLabel)
        self.titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: HomeLayout.margin).isActive = true
        self.titleLabel.centerYAnchor.constraint(equalTo: self.actionsStack.centerYAnchor).isActive = true
        self.titleLabel.trailingAnchor.constraint(equalTo: self.actionsStack.leadingAnchor, constant: -HomeLayout.smargin).isActive = true
        self.heightAnchor.constraint(equalToConstant: HomeLayout.headerWithActionViewHeigth + HomeLayout.safeAera.top).isActive = true
    }
}

final class CoalitionHeaderWithActionsView: HeaderWithActionsBase {
    
    private let imageView: BasicUIImageView
    private let titleLabel: BasicUILabel
    
    override var title: String {
        set {
            self.titleLabel.text = newValue
        }
        get {
            return self.titleLabel.text!
        }
    }
    
    init(coalition: IntraCoalition, actions: [ActionButtonView]? = nil) {
        self.imageView = BasicUIImageView(asset: .svgFactionless)
        self.imageView.tintColor = coalition.uicolor
        self.titleLabel = BasicUILabel(text: coalition.name)
        self.titleLabel.font = HomeLayout.fontSemiBoldTitle
        self.titleLabel.textColor = coalition.uicolor
        super.init(actions: actions)
        if let image = HomeResources.storageSVGCoalition.get(coalition) {
            self.imageView.image = image
        }
        else {
            Task.init(priority: .userInitiated, operation: {
                if let (coa, image) = await HomeResources.storageSVGCoalition.obtain(coalition), coa.id==coalition.id {
                    self.imageView.image = image
                }
                else {
                    self.imageView.image = UIImage.Assets.svgFactionless.image
                }
            })
        }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func setCoalition(_ coalition: IntraCoalition) {
        self.titleLabel.text = coalition.name
        self.titleLabel.textColor = coalition.uicolor
        self.imageView.tintColor = coalition.uicolor
        if let image = HomeResources.storageSVGCoalition.get(coalition) {
            self.imageView.image = image
        }
        else {
            Task.init(priority: .userInitiated, operation: {
                if let (coa, image) = await HomeResources.storageSVGCoalition.obtain(coalition), coa.id==coalition.id {
                    self.imageView.image = image
                }
                else {
                    self.imageView.image = UIImage.Assets.svgFactionless.image
                }
            })
        }
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview != nil else { return }
        
        self.addSubview(self.actionsStack)
        self.actionsStack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.margin).isActive = true
        self.actionsStack.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -HomeLayout.smargin).isActive = true
        self.addSubview(self.imageView)
        self.imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: HomeLayout.margin).isActive = true
        self.imageView.centerYAnchor.constraint(equalTo: self.actionsStack.centerYAnchor).isActive = true
        self.imageView.heightAnchor.constraint(equalToConstant: HomeLayout.coalitionHeaderIconSize).isActive = true
        self.imageView.widthAnchor.constraint(equalToConstant: HomeLayout.coalitionHeaderIconSize).isActive = true
        self.addSubview(self.titleLabel)
        self.titleLabel.leadingAnchor.constraint(equalTo: self.imageView.trailingAnchor, constant: HomeLayout.margin).isActive = true
        self.titleLabel.centerYAnchor.constraint(equalTo: self.actionsStack.centerYAnchor).isActive = true
        self.titleLabel.trailingAnchor.constraint(greaterThanOrEqualTo: self.actionsStack.leadingAnchor, constant: -HomeLayout.smargin).isActive = true
        self.heightAnchor.constraint(equalToConstant: HomeLayout.headerWithActionViewHeigth + HomeLayout.safeAera.top).isActive = true
    }
}

final class ControllerHeaderWithActionsView: HeaderWithActionsBase {
    
    private let blurBackground: BasicUIVisualEffectView
    private let controllerIcon: ControllerIcon
    private let titleLabel: BasicUILabel
    override var title: String {
        set {
            self.titleLabel.text = newValue
        }
        get {
            return self.titleLabel.text!
        }
    }
    
    init(asset: UIImage.Assets, title: String, primary: UIColor, actions: [ActionButtonView]? = nil) {
        self.blurBackground = BasicUIVisualEffectView()
        self.controllerIcon = ControllerIcon(asset: asset, primary: primary)
        self.titleLabel = BasicUILabel(text: title)
        self.titleLabel.font = HomeLayout.fontSemiBoldTitle
        self.titleLabel.textColor = HomeDesign.white
        super.init(actions: actions)
        
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview != nil else { return }
        self.addSubview(self.blurBackground)
        self.blurBackground.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.blurBackground.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.blurBackground.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.blurBackground.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.addSubview(self.controllerIcon)
        self.controllerIcon.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: HomeLayout.margin).isActive = true
        self.controllerIcon.topAnchor.constraint(equalTo: self.topAnchor, constant: HomeLayout.safeAera.top + HomeLayout.smargin).isActive = true
        self.addSubview(self.actionsStack)
        self.actionsStack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.margin).isActive = true
        self.actionsStack.centerYAnchor.constraint(equalTo: self.controllerIcon.centerYAnchor).isActive = true
        self.addSubview(self.titleLabel)
        self.titleLabel.leadingAnchor.constraint(equalTo: self.controllerIcon.trailingAnchor, constant: HomeLayout.margin).isActive = true
        self.titleLabel.centerYAnchor.constraint(equalTo: self.actionsStack.centerYAnchor).isActive = true
        self.titleLabel.trailingAnchor.constraint(greaterThanOrEqualTo: self.actionsStack.leadingAnchor, constant: -HomeLayout.smargin).isActive = true
        self.heightAnchor.constraint(equalToConstant: HomeLayout.headerWithActionControllerViewHeigth + HomeLayout.safeAera.top).isActive = true
    }
    
    final private class ControllerIcon: BasicUIView {
        
        fileprivate let icon: BasicUIImageView
        
        init(asset: UIImage.Assets, primary: UIColor) {
            self.icon = BasicUIImageView(asset: asset)
            self.icon.tintColor = primary
            super.init()
            self.backgroundColor = HomeDesign.white
            self.layer.cornerRadius = HomeLayout.mainSelectionRadius
            self.layer.shadowColor = primary.cgColor
            self.layer.shadowOffset = .zero
            self.layer.shadowRadius = HomeLayout.margin
            self.layer.shadowOpacity = Float(HomeDesign.alphaLayer)
            self.isUserInteractionEnabled = true
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }
            
            self.addSubview(self.icon)
            self.icon.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            self.icon.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            self.icon.widthAnchor.constraint(equalToConstant: HomeLayout.mainSelectionIconSize).isActive = true
            self.icon.heightAnchor.constraint(equalToConstant: HomeLayout.mainSelectionIconSize).isActive = true
            self.heightAnchor.constraint(equalToConstant: HomeLayout.mainSelectionSize).isActive = true
            self.widthAnchor.constraint(equalToConstant: HomeLayout.mainSelectionSize).isActive = true
        }
    }
}

final class DarkBlurHeaderWithActionsView: BasicUIVisualEffectView {
    
    private let imageView: BasicUIImageView
    private let header: HeaderWithActionsView
    
    init(icon: UIImage.Assets, title: String, actions: [ActionButtonView]? = nil) {
        self.imageView = BasicUIImageView(asset: icon)
        self.imageView.tintColor = HomeDesign.white
        self.header = HeaderWithActionsView(title: title, actions: actions)
        self.header.titleLabel.textColor = HomeDesign.white
        super.init()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview != nil else { return }
        
        self.contentView.addSubview(self.imageView)
        self.contentView.addSubview(self.header)
        self.imageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor,
                                                constant: HomeLayout.margin).isActive = true
        self.imageView.heightAnchor.constraint(equalToConstant: HomeLayout.actionButtonIconSize).isActive = true
        self.imageView.widthAnchor.constraint(equalToConstant: HomeLayout.actionButtonIconSize).isActive = true
        self.imageView.centerYAnchor.constraint(equalTo: self.header.titleLabel.centerYAnchor).isActive = true
        self.header.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        self.header.leadingAnchor.constraint(equalTo: self.imageView.trailingAnchor,
                                             constant: -HomeLayout.smargin).isActive = true
        self.header.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        self.header.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
    }
}
