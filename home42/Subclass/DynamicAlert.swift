// home42/DynamicAlert.swift
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
import SwiftUI
import CoreAudio
import simd
import MessageUI
import SwiftDate

final class DynamicAlert: DynamicController {
    
    @frozen enum Style {
        case none
        case noneWithPrimary(UIColor)
        case primary(String)
        case withPrimary(String, UIColor)
        case fullPrimary(String, UIColor)
        case event(IntraEvent)
        
        var primaryColor: UIColor {
            switch self {
            case .primary(_), .none:
                return HomeDesign.primary
            case .withPrimary(_, let color), .noneWithPrimary(let color), .fullPrimary(_, let color):
                return color
            case .event(let event):
                return event.uicolor
            }
        }
        var text: String {
            switch self {
            case .primary(let txt), .withPrimary(let txt, _), .fullPrimary(let txt, _):
                return txt
            case .event(let event):
                return event.name
            default:
                return "???"
            }
        }
    }
    @frozen enum Content {
        case title(String)
        case titleWithPrimary(String, UIColor)
        case text(String)
        case imageWithPrimary(UIImage.Assets, CGFloat, UIColor)
        case image(UIImage)
        case separator(UIColor = HomeDesign.black)
        case apiError(HomeApi.RequestError)
        case antenne(Bool)
        case roulette([String], Int)
        case advancedSelector(DynamicAlert.AdvancedSelectorViewType, [Any], Int)
        case icons([UIImage.Assets], Int, CGFloat)
        case code
        case slotInterval
        case colorPicker(UIColor, UnsafeMutablePointer<UIColor>)
        case usersSelector(IntraUserInfo?, (IntraUserInfo) -> ())
        case textEditor(String)
    }
    @frozen enum Action {
        case normal(String, (() -> ())? = nil)
        case highligth(String, (() -> ())? = nil)
        case getRoulette(String, (Int, String) -> ())
        case getAdvancedSelector((Any) -> ())
        case getIcon(String, (Int, UIImage.Assets) -> ())
        case getCode(String, (Int) -> ())
        case apiErrorJSON(Data, HomeApi.RequestError)
        
        case slotInterval((Date, Date) -> ())
        case textEditor((String) -> ())
        
        var isHighligth: Bool {
            switch self {
            case .highligth(_, _), .getCode(_, _), .getRoulette(_, _), .apiErrorJSON, .slotInterval(_), .getIcon(_, _), .textEditor(_), .getAdvancedSelector(_):
                return true
            default:
                return false
            }
        }
        var text: String {
            switch self {
            case .normal(let txt, _), .highligth(let txt, _), .getCode(let txt, _), .getRoulette(let txt, _), .getIcon(let txt, _):
                return txt
            case .slotInterval(_), .textEditor(_), .getAdvancedSelector(_):
                return ~"general.select"
            case .apiErrorJSON:
                return "JSON"
            }
        }
    }
    
    @discardableResult init(_ style: DynamicAlert.Style = .primary(~"general.warning"), contents: [Content], actions: [Action]) {
        super.init()
        
        let primaryColor = style.primaryColor
        let contentView = BasicUIView()
        let actionsStack = BasicUIStackView()
        var useKeyboard: Bool = false
        
        var topAnchor: NSLayoutYAxisAnchor!
        
        if let backgroundPrimary = self.backgroundPrimary {
            backgroundPrimary.alpha = 0.0
            backgroundPrimary.backgroundColor = primaryColor.withAlphaComponent(HomeDesign.alphaLow)
        }
        contentView.tag = 42
        self.view.addSubview(contentView)
        
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = HomeLayout.corners
        contentView.backgroundColor = HomeDesign.white
        switch style {
        case .none, .noneWithPrimary(_):
            topAnchor = contentView.topAnchor
        case .event(let event):
            let header = EventHeader(event: event)
            
            contentView.layer.borderWidth = HomeLayout.border
            contentView.layer.borderColor = event.uicolor.cgColor
            contentView.addSubview(header)
            header.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            header.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
            header.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
            topAnchor = header.bottomAnchor
        default:
            let header = BasicUILabel(text: style.text.uppercased())
            
            contentView.addSubview(header)
            if case .event(let event) = style {
                header.backgroundColor = event.uicolor
            }
            else if case .fullPrimary(_, let color) = style {
                header.backgroundColor = color
            }
            else {
                header.backgroundColor = HomeDesign.black
            }
            header.textColor = HomeDesign.white
            header.textAlignment = .center
            header.font = HomeLayout.fontBoldBigTitle
            header.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            header.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
            header.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
            header.heightAnchor.constraint(equalToConstant: HomeLayout.dynamicAlertHeaderHeigth).isActive = true
            topAnchor = header.bottomAnchor
        }
        
        for content in contents {
            switch content {
            case .title(let txt):
                let title = BasicUILabel(text: txt)
                
                title.font = HomeLayout.fontSemiBoldTitle
                title.textColor = HomeDesign.black
                title.textAlignment = .center
                title.numberOfLines = 0
                contentView.addSubview(title)
                title.topAnchor.constraint(equalTo: topAnchor, constant: HomeLayout.margins).isActive = true
                title.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: HomeLayout.smargin).isActive = true
                title.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -HomeLayout.smargin).isActive = true
                topAnchor = title.bottomAnchor
            case .titleWithPrimary(let txt, let primary):
                let title = BasicUILabel(text: txt)
                
                title.font = HomeLayout.fontSemiBoldTitle
                title.textColor = primary
                title.textAlignment = .center
                title.numberOfLines = 0
                contentView.addSubview(title)
                title.topAnchor.constraint(equalTo: topAnchor, constant: HomeLayout.margins).isActive = true
                title.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: HomeLayout.smargin).isActive = true
                title.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -HomeLayout.smargin).isActive = true
                topAnchor = title.bottomAnchor
            case .text(let txt):
                let title = TextView(text: txt, color: primaryColor)
                
                contentView.addSubview(title)
                title.topAnchor.constraint(equalTo: topAnchor, constant: HomeLayout.margins).isActive = true
                title.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: HomeLayout.smargin).isActive = true
                title.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -HomeLayout.smargin).isActive = true
                topAnchor = title.bottomAnchor
            case .imageWithPrimary(let asset, let height, let primary):
                let imageView = BasicUIImageView(asset: asset)
                
                imageView.tintColor = primary
                contentView.addSubview(imageView)
                imageView.topAnchor.constraint(equalTo: topAnchor, constant: HomeLayout.margins).isActive = true
                imageView.heightAnchor.constraint(equalToConstant: height).isActive = true
                imageView.widthAnchor.constraint(equalToConstant: height).isActive = true
                imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
                topAnchor = imageView.bottomAnchor
            case .image(let image):
                let imageView = BasicUIImageView(image: image)
                
                contentView.addSubview(imageView)
                imageView.topAnchor.constraint(equalTo: topAnchor, constant: HomeLayout.margins).isActive = true
                imageView.heightAnchor.constraint(equalToConstant: image.size.height).isActive = true
                imageView.widthAnchor.constraint(equalToConstant: image.size.width).isActive = true
                imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
                topAnchor = imageView.bottomAnchor
            case .separator(let color):
                let sep = BasicUIView()
                
                sep.backgroundColor = color
                sep.layer.cornerRadius = 1.0
                contentView.addSubview(sep)
                sep.topAnchor.constraint(equalTo: topAnchor, constant: HomeLayout.margins).isActive = true
                sep.heightAnchor.constraint(equalToConstant: 2.0).isActive = true
                sep.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: HomeLayout.margins).isActive = true
                sep.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -HomeLayout.margins).isActive = true
                topAnchor = sep.bottomAnchor
            case .apiError(let error):
                let title = BasicUILabel(text: "")
                
                switch error.status {
                case .internal, .flowError(_):
                    title.text = error.description
                case .code(let code):
                    let s1 = "\(code) "
                    let a1: [NSAttributedString.Key : Any]
                    let s2 = "\(error.rootPath)\n"
                    let a2: [NSAttributedString.Key : Any] = [.foregroundColor: HomeDesign.primary, .font: HomeLayout.fontSemiBoldMedium]
                    let s3 = error.serverMessage
                    let a3: [NSAttributedString.Key : Any] = [.foregroundColor: HomeDesign.black, .font: HomeLayout.fontRegularMedium]
                    
                    if (200 ... 299).contains(code) {
                        a1 = [.foregroundColor: HomeDesign.greenSuccess, .font: HomeLayout.fontBlackMedium]
                    }
                    else {
                        a1 = [.foregroundColor: HomeDesign.redError, .font: HomeLayout.fontBlackMedium]
                    }
                    title.attributedText = NSAttributedString.from(strings: [s1, s2, s3], [a1, a2, a3])
                }
                title.textAlignment = .center
                title.numberOfLines = 0
                contentView.addSubview(title)
                title.topAnchor.constraint(equalTo: topAnchor, constant: HomeLayout.margins).isActive = true
                title.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: HomeLayout.smargin).isActive = true
                title.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -HomeLayout.smargin).isActive = true
                topAnchor = title.bottomAnchor
            case .antenne(let isBreak):
                let antenne = AntenneView(isBreak: isBreak)
                
                contentView.addSubview(antenne)
                antenne.heightAnchor.constraint(equalToConstant: HomeLayout.antenneViewSize).isActive = true
                antenne.widthAnchor.constraint(equalToConstant: HomeLayout.antenneViewSize).isActive = true
                antenne.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
                antenne.topAnchor.constraint(equalTo: topAnchor, constant: HomeLayout.margins).isActive = true
                topAnchor = antenne.bottomAnchor
            case .advancedSelector(let type, let values, let index):
                let view: BasicUIView = type.view(primaryColor: primaryColor, values: values, index: index)
                
                DynamicAlert.advancedSelectorType = type
                DynamicAlert.advancedSelector = view
                contentView.addSubview(view)
                view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: HomeLayout.margin).isActive = true
                view.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
                view.topAnchor.constraint(equalTo: topAnchor, constant: HomeLayout.margins).isActive = true
                topAnchor = view.bottomAnchor
            case .roulette(let values, let index):
                let roulette = RouletteView(primary: primaryColor, values: values)
                
                DynamicAlert.rouletteView = roulette
                roulette.index = index
                contentView.addSubview(roulette)
                roulette.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: HomeLayout.margin).isActive = true
                roulette.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
                roulette.topAnchor.constraint(equalTo: topAnchor, constant: HomeLayout.margins).isActive = true
                topAnchor = roulette.bottomAnchor
            case .icons(let assets, let selectedIndex, let size):
                let icons = IconsView(primary: primaryColor, values: assets, size: size, selectedIndex: selectedIndex)
                
                DynamicAlert.iconsView = icons
                contentView.addSubview(icons)
                icons.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: HomeLayout.smargin).isActive = true
                icons.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
                icons.topAnchor.constraint(equalTo: topAnchor, constant: HomeLayout.margins).isActive = true
                topAnchor = icons.bottomAnchor
            case .code:
                let codeView = CodeView(maximum: 6)
                
                DynamicAlert.codeView = codeView
                contentView.addSubview(codeView)
                codeView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: HomeLayout.margins).isActive = true
                codeView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -HomeLayout.margins).isActive = true
                codeView.topAnchor.constraint(equalTo: topAnchor, constant: HomeLayout.margins).isActive = true
                codeView.heightAnchor.constraint(equalToConstant: HomeLayout.dynamicAlertCodeHeigth).isActive = true
                topAnchor = codeView.bottomAnchor
            case .slotInterval:
                let selector = SlotIntervalSelector()
                
                DynamicAlert.slotInterval = selector
                contentView.addSubview(selector)
                selector.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: HomeLayout.margins).isActive = true
                selector.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -HomeLayout.margins).isActive = true
                selector.topAnchor.constraint(equalTo: topAnchor, constant: HomeLayout.margins).isActive = true
                topAnchor = selector.bottomAnchor
            case .colorPicker(let color, let pointer):
                let colorPicker = ColorPicker(color: color, pointer: pointer)
                
                contentView.addSubview(colorPicker)
                colorPicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: HomeLayout.margin).isActive = true
                colorPicker.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
                colorPicker.topAnchor.constraint(equalTo: topAnchor, constant: HomeLayout.margins).isActive = true
                topAnchor = colorPicker.bottomAnchor
            case .usersSelector(let user, let block):
                let usersSelector = UsersSelector(user: user, primary: primaryColor, block: block)
                
                contentView.addSubview(usersSelector)
                usersSelector.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
                usersSelector.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
                usersSelector.topAnchor.constraint(equalTo: topAnchor, constant: HomeLayout.margins).isActive = true
                topAnchor = usersSelector.bottomAnchor
                useKeyboard = true
            case .textEditor(let txt):
                let textEditor = TextEditor(defaultText: txt, primary: primaryColor)
                
                DynamicAlert.textEditor = textEditor
                contentView.addSubview(textEditor)
                textEditor.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: HomeLayout.margin).isActive = true
                textEditor.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
                textEditor.topAnchor.constraint(equalTo: topAnchor, constant: HomeLayout.margins).isActive = true
                topAnchor = textEditor.bottomAnchor
                useKeyboard = true
            }
        }
        if actions.count > 0 {
            contentView.addSubview(actionsStack)
            actionsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: HomeLayout.margin).isActive = true
            actionsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -HomeLayout.margin).isActive = true
            actionsStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -HomeLayout.margin).isActive = true
            actionsStack.topAnchor.constraint(equalTo: topAnchor, constant: HomeLayout.margins).isActive = true
            actionsStack.heightAnchor.constraint(equalToConstant: HomeLayout.dynamicAlertActionsHeigth).isActive = true
            actionsStack.alignment = .fill
            actionsStack.axis = .horizontal
            actionsStack.distribution = .fillEqually
            actionsStack.spacing = HomeLayout.smargin
            for action in actions {
                let button = DynamicAlert.Button(action: action, color: primaryColor)
                
                actionsStack.addArrangedSubview(button)
                button.isUserInteractionEnabled = true
                button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(buttonSelected(sender:))))
            }
        }
        else {
            contentView.bottomAnchor.constraint(equalTo: topAnchor).isActive = true
        }
        
        contentView.heightAnchor.constraint(lessThanOrEqualToConstant: UIScreen.main.bounds.height - (HomeLayout.safeAera.top + HomeLayout.safeAera.bottom + HomeLayout.margin * 2.0)).isActive = true
        contentView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: HomeLayout.margins).isActive = true
        if useKeyboard {
            contentView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: HomeLayout.safeAera.top + HomeLayout.margin).isActive = true
            contentView.bottomAnchor.constraint(equalTo: self.view.keyboardLayoutGuide.topAnchor, constant: -HomeLayout.margin).isActive = true
        }
        else {
            contentView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        }
        self.present()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    required init() { fatalError("init() has not been implemented") }
    
    final private class Button: HomePressableUIView {
        
        let action: DynamicAlert.Action
        private let label: BasicUILabel
        
        init(action: DynamicAlert.Action, color: UIColor) {
            self.action = action
            self.label = BasicUILabel(text: "")
            super.init()
            self.layer.cornerRadius = HomeLayout.corner
            self.layer.borderColor = color.cgColor
            self.layer.borderWidth = HomeLayout.border
            self.clipsToBounds = true
            self.label.textAlignment = .center
            self.label.adjustsFontSizeToFitWidth = true
            if action.isHighligth {
                self.backgroundColor = color
                self.label.attributedText = NSAttributedString(string: action.text.uppercased(), attributes: [.font: HomeLayout.fontSemiBoldTitle, .foregroundColor: HomeDesign.white])
            }
            else {
                self.label.attributedText = NSAttributedString(string: action.text.uppercased(), attributes: [.font: HomeLayout.fontSemiBoldTitle, .foregroundColor: color])
            }
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        func setPrimary(_ color: UIColor, isHighligth: Bool) {
            self.layer.borderColor = color.cgColor
            if isHighligth {
                self.backgroundColor = color
                self.label.attributedText = NSAttributedString(string: action.text.uppercased(), attributes: [.font: HomeLayout.fontSemiBoldTitle, .foregroundColor: HomeDesign.white])
            }
            else {
                self.backgroundColor = .clear
                self.label.attributedText = NSAttributedString(string: action.text.uppercased(), attributes: [.font: HomeLayout.fontSemiBoldTitle, .foregroundColor: color])
            }
        }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }
            
            self.addSubview(self.label)
            self.label.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            self.label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: HomeLayout.smargin).isActive = true
            self.label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.smargin).isActive = true
            self.label.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        }
    }
    
    @objc private func buttonSelected(sender: UITapGestureRecognizer) {
        switch (sender.view as! DynamicAlert.Button).action {
        case .normal(_, let block), .highligth(_, let block):
            block?()
        case .getCode(_, let block):
            block(DynamicAlert.codeView.value)
        case .getAdvancedSelector(let block):
            block(DynamicAlert.advancedSelectorType.value())
        case .getRoulette(_, let block):
            block(DynamicAlert.rouletteView.index, DynamicAlert.rouletteView.value)
        case .getIcon(_, let block):
            block(DynamicAlert.iconsView.selectedIndex, DynamicAlert.iconsView.value)
        case .slotInterval(let block):
            block(DynamicAlert.slotInterval.startDate, DynamicAlert.slotInterval.endDate)
        case .apiErrorJSON(let data, let error):
            WebViewDataContainerDecoder(data: data, error: error)
        case .textEditor(let block):
            block(DynamicAlert.textEditor.view.text ?? DynamicAlert.textEditor.defaultText)
        }
        self.remove()
    }
  
    func setParticles(_ style: ParticlesEmitter.Style) {
        DispatchQueue.main.asyncAfter(deadline: .now() + HomeAnimations.durationShort, execute: {
            let emitter = ParticlesEmitterView(style)
            let contentView = self.view.viewWithTag(42)!
            
            emitter.tag = 23
            self.view.insertSubview(emitter, belowSubview: contentView)
            emitter.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            emitter.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
            emitter.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
            emitter.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        })
    }
    
    override func present() {
        let contentView = self.view.viewWithTag(42)!
        
        contentView.alpha = 0.0
        super.present()
        HomeAnimations.animateShort({
            contentView.alpha = 1.0
            self.background.effect = HomeDesign.blur
            if let backgroundPrimary = self.backgroundPrimary {
                backgroundPrimary.alpha = 1.0
            }
        })
    }
    override func remove(isFinish: Bool = true) {
        HomeAnimations.animateShort({
            self.view.viewWithTag(42)!.alpha = 0.0
            self.background.effect = nil
            if let backgroundPrimary = self.backgroundPrimary {
                backgroundPrimary.alpha = 0.0
            }
            if let particleView = self.view.viewWithTag(23) {
                particleView.alpha = 0.0
            }
        }, completion: super.remove(isFinish:))
    }
    
    @MainActor @inlinable static func presentWith(error: HomeApi.RequestError) {
        let actions: [DynamicAlert.Action]
        
        if let data = error.data {
            actions = [.normal(~"general.ok", nil), .apiErrorJSON(data, error)]
        }
        else {
            actions = [.normal(~"general.ok", nil)]
        }
        _ = DynamicAlert.init(contents: [.apiError(error)], actions: actions)
    }
    @MainActor @inlinable static func presentWith(error: Error) {
        _ = DynamicAlert.init(contents: [.text(error.localizedDescription)],
                              actions: [.normal(~"general.ok", nil)])
    }
    
    @inlinable static func presentInformation(_ asset: UIImage.Assets, title: String, description: String) {
        DynamicAlert(.none,
                     contents: [.imageWithPrimary(asset, HomeLayout.mainSelectionSize, HomeDesign.primary),
                                .titleWithPrimary(title, HomeDesign.primary), .separator(HomeDesign.primary.withAlphaComponent(HomeDesign.alphaMiddle)), .text(description)],
                     actions: [.highligth(~"general.i-understand", nil)])
    }
}
// MARK: - event header
extension DynamicAlert {
    
    final private class EventHeader: BasicUIView {
        
        private let title: BasicUILabel
        
        private let leftKindView: BasicUIView
        private let kindLabel: BasicUILabel
        private let rightKindView: BasicUIView
        
        private let startDateIcon: BasicUIImageView
        private let startDateLabel: BasicUILabel
        private let endDateIcon: BasicUIImageView
        private let endDateLabel: BasicUILabel
        private let locationIcon: BasicUIImageView!
        private let locationLabel: BasicUILabel!
        
        private let peopleButton: ActionButtonView?
        private let feedbackButton: ActionButtonView?
        
        let event: IntraEvent
        
        init(event: IntraEvent) {
            self.title = BasicUILabel(text: event.name)
            self.title.font = HomeLayout.fontSemiBoldMedium
            self.title.textColor = HomeDesign.white
            self.title.numberOfLines = 0
            self.title.textAlignment = .center
            self.leftKindView = BasicUIView()
            self.leftKindView.layer.cornerRadius = 1.0
            self.leftKindView.backgroundColor = HomeDesign.white
            self.kindLabel = BasicUILabel(text: ~event.kindKey)
            self.kindLabel.font = HomeLayout.fontRegularMedium
            self.kindLabel.textColor = HomeDesign.white
            self.kindLabel.textAlignment = .center
            self.rightKindView = BasicUIView()
            self.rightKindView.layer.cornerRadius = 1.0
            self.rightKindView.backgroundColor = HomeDesign.white
            self.startDateLabel = BasicUILabel(text: ~"event.header.start-at" + event.beginDate.toString(.custom("EEEE dd/MM/yyyy HH:mm")))
            self.startDateLabel.font = HomeLayout.fontRegularNormal
            self.startDateLabel.textColor = HomeDesign.white
            self.startDateLabel.adjustsFontSizeToFitWidth = true
            self.startDateIcon = BasicUIImageView(asset: .controllerEvents)
            self.startDateIcon.tintColor = HomeDesign.white
            self.endDateLabel = BasicUILabel(text: ~"event.header.end-at" + event.endDate.toString(.custom("EEEE dd/MM/yyyy HH:mm")))
            self.endDateLabel.font = self.startDateLabel.font
            self.endDateLabel.textColor = self.startDateLabel.textColor
            self.endDateLabel.adjustsFontSizeToFitWidth = true
            self.endDateIcon = BasicUIImageView(asset: .controllerEvents)
            self.endDateIcon.tintColor = HomeDesign.white
            if let location = event.location, location.count > 0 {
                self.locationLabel = BasicUILabel(text: location)
                self.locationLabel.font = self.endDateLabel.font
                self.locationLabel.textColor = self.endDateLabel.textColor
                self.locationIcon = BasicUIImageView(asset: .actionLocation)
                self.locationIcon.tintColor = HomeDesign.white
            }
            else {
                self.locationLabel = nil
                self.locationIcon = nil
            }
            if TrackerViewController.checkDefaultsValue() {
                self.peopleButton = ActionButtonView(asset: .actionPeople, color: event.uicolor)
            }
            else {
                self.peopleButton = nil
            }
            if event.endDate < Date() {
                self.feedbackButton = ActionButtonView(asset: .actionFeedbacks, color: event.uicolor)
            }
            else {
                self.feedbackButton = nil
            }
            self.event = event
            super.init()
            self.backgroundColor = event.uicolor
            if self.peopleButton != nil {
                self.peopleButton!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(EventHeader.usersTapped(gesture:))))
            }
            if self.feedbackButton != nil {
                self.feedbackButton!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(EventHeader.feedbacksTapped(gesture:))))
            }
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }
            let buttons = [self.peopleButton, self.feedbackButton].compactMap({ $0 })
            var buttonsTrailing: NSLayoutXAxisAnchor
            
            self.addSubview(self.title)
            self.title.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: HomeLayout.margin).isActive = true
            self.title.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.margin).isActive = true
            self.title.topAnchor.constraint(equalTo: self.topAnchor, constant: HomeLayout.margins).isActive = true
            
            self.addSubview(self.leftKindView)
            self.addSubview(self.rightKindView)
            self.addSubview(self.kindLabel)
            self.kindLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            self.kindLabel.topAnchor.constraint(equalTo: self.title.bottomAnchor, constant: HomeLayout.margin).isActive = true
            self.leftKindView.leadingAnchor.constraint(equalTo: self.title.leadingAnchor).isActive = true
            self.rightKindView.trailingAnchor.constraint(equalTo: self.title.trailingAnchor).isActive = true
            self.leftKindView.widthAnchor.constraint(equalTo: self.rightKindView.widthAnchor).isActive = true
            self.leftKindView.trailingAnchor.constraint(equalTo: self.kindLabel.leadingAnchor, constant: -HomeLayout.smargin).isActive = true
            self.rightKindView.leadingAnchor.constraint(equalTo: self.kindLabel.trailingAnchor, constant: HomeLayout.smargin).isActive = true
            self.leftKindView.heightAnchor.constraint(equalToConstant: 2.0).isActive = true
            self.rightKindView.heightAnchor.constraint(equalToConstant: 2.0).isActive = true
            self.leftKindView.centerYAnchor.constraint(equalTo: self.kindLabel.centerYAnchor).isActive = true
            self.rightKindView.centerYAnchor.constraint(equalTo: self.kindLabel.centerYAnchor).isActive = true
            self.addSubview(self.startDateIcon)
            self.startDateIcon.leadingAnchor.constraint(equalTo: self.title.leadingAnchor).isActive = true
            self.startDateIcon.widthAnchor.constraint(equalToConstant: 24.0).isActive = true
            self.startDateIcon.heightAnchor.constraint(equalToConstant: 24.0).isActive = true
            self.startDateIcon.topAnchor.constraint(equalTo: self.kindLabel.bottomAnchor, constant: HomeLayout.smargin).isActive = true
            self.addSubview(self.startDateLabel)
            self.startDateLabel.leadingAnchor.constraint(equalTo: self.startDateIcon.trailingAnchor, constant: HomeLayout.smargin).isActive = true
            self.startDateLabel.centerYAnchor.constraint(equalTo: self.startDateIcon.centerYAnchor).isActive = true
            self.startDateLabel.trailingAnchor.constraint(equalTo: self.title.trailingAnchor).isActive = true
            self.addSubview(self.endDateIcon)
            self.endDateIcon.leadingAnchor.constraint(equalTo: self.title.leadingAnchor).isActive = true
            self.endDateIcon.topAnchor.constraint(equalTo: self.startDateIcon.bottomAnchor, constant: HomeLayout.smargin).isActive = true
            self.endDateIcon.widthAnchor.constraint(equalToConstant: 24.0).isActive = true
            self.endDateIcon.heightAnchor.constraint(equalToConstant: 24.0).isActive = true
            self.addSubview(self.endDateLabel)
            self.endDateLabel.leadingAnchor.constraint(equalTo: self.endDateIcon.trailingAnchor, constant: HomeLayout.smargin).isActive = true
            self.endDateLabel.centerYAnchor.constraint(equalTo: self.endDateIcon.centerYAnchor).isActive = true
            self.endDateLabel.trailingAnchor.constraint(equalTo: self.title.trailingAnchor).isActive = true
            if self.locationLabel != nil {
                self.addSubview(self.locationIcon)
                self.locationIcon.topAnchor.constraint(equalTo: self.endDateIcon.bottomAnchor, constant: HomeLayout.smargin).isActive = true
                self.locationIcon.leadingAnchor.constraint(equalTo: self.title.leadingAnchor).isActive = true
                self.locationIcon.widthAnchor.constraint(equalToConstant: 24.0).isActive = true
                self.locationIcon.heightAnchor.constraint(equalToConstant: 24.0).isActive = true
                self.addSubview(self.locationLabel)
                self.locationLabel.leadingAnchor.constraint(equalTo: self.locationIcon.trailingAnchor, constant: HomeLayout.smargin).isActive = true
                self.locationLabel.trailingAnchor.constraint(equalTo: self.title.trailingAnchor).isActive = true
                self.locationLabel.centerYAnchor.constraint(equalTo: self.locationIcon.centerYAnchor).isActive = true
                self.locationLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -HomeLayout.margin).isActive = true
            }
            else {
                self.endDateLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -HomeLayout.margin).isActive = true
            }
            if buttons.count > 0 {
                buttonsTrailing = self.trailingAnchor
                for (index, button) in buttons.enumerated() {
                    self.addSubview(button)
                    if index == 0 {
                        button.trailingAnchor.constraint(equalTo: buttonsTrailing, constant: -HomeLayout.margin).isActive = true
                    }
                    else {
                        button.trailingAnchor.constraint(equalTo: buttonsTrailing, constant: -HomeLayout.smargin).isActive = true
                    }
                    button.centerYAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
                    buttonsTrailing = button.leadingAnchor
                }
            }
        }
        
        @objc private func feedbacksTapped(gesture: UITapGestureRecognizer) {
            let vc = EventFeedbacksHistoricViewController(event: self.event)
            
            self.parentHomeViewController?.presentWithBlur(vc)
        }
        
        @objc private func usersTapped(gesture: UITapGestureRecognizer) {
            let vc = UsersListViewController(.eventsWithEventIdUsers(self.event.id), primary: self.event.uicolor)
            
            vc.headerTitle = self.event.name
            self.parentHomeViewController?.presentWithBlur(vc)
        }
    }
}

// MARK: - AdvancedSelector
extension DynamicAlert {
    
    @frozen enum AdvancedSelectorViewType {
        case string
        case title
        case group
        case languages
        case campus
        
        func view(primaryColor: UIColor, values: [Any], index: Int) -> BasicUIView {
            switch self {
            case .string:
                return AdvancedSelector<String, AdvancedSelectorViewString>.init(primary: primaryColor, source: values as! [String], selectionIndex: index)
            case .title:
                return AdvancedSelector<IntraTitle, AdvancedSelectorViewTitle>.init(primary: primaryColor, source: values as! [IntraTitle], selectionIndex: index)
            case .group:
                return AdvancedSelector<IntraGroup, AdvancedSelectorViewGroup>.init(primary: primaryColor, source: values as! [IntraGroup], selectionIndex: index)
            case .languages:
                return AdvancedSelector<IntraLanguage, AdvancedSelectorViewLanguage>.init(primary: primaryColor, source: values as! [IntraLanguage], selectionIndex: index)
            case .campus:
                return AdvancedSelector<IntraCampus, AdvancedSelectorViewCampus>.init(primary: primaryColor, source: values as! [IntraCampus], selectionIndex: index)
            }
        }
        func value() -> Any {
            switch self {
            case .string:
                return (DynamicAlert.advancedSelector as! AdvancedSelector<String, AdvancedSelectorViewString>).selection
            case .title:
                return (DynamicAlert.advancedSelector as! AdvancedSelector<IntraTitle, AdvancedSelectorViewTitle>).selection
            case .group:
                return (DynamicAlert.advancedSelector as! AdvancedSelector<IntraGroup, AdvancedSelectorViewGroup>).selection
            case .languages:
                return (DynamicAlert.advancedSelector as! AdvancedSelector<IntraLanguage, AdvancedSelectorViewLanguage>).selection
            case .campus:
                return (DynamicAlert.advancedSelector as! AdvancedSelector<IntraCampus, AdvancedSelectorViewCampus>).selection
            }
        }
    }
    
    private class AdvancedSelectorViewBase<G: Equatable>: BasicUITableViewCell {
        
        let container: BasicUIView
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            self.container = BasicUIView()
            self.container.backgroundColor = HomeDesign.white
            self.container.layer.cornerRadius = HomeLayout.scorner
            self.container.layer.borderWidth = HomeLayout.sborder
            self.container.layer.borderColor = HomeDesign.gray.cgColor
            super.init(style: style, reuseIdentifier: reuseIdentifier)
        }
        required init?(coder: NSCoder) { fatalError() }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            self.contentView.addSubview(self.container)
            self.container.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
            self.container.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
            self.container.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -HomeLayout.margin).isActive = true
            self.container.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        }
        
        func update(with value: G) { }
        func setSelectedStyle(animate: Bool, primary: UIColor) { }
        func setUnSelectedStyle(animate: Bool, primary: UIColor) { }
        class func filter(_ source: [G], with text: String) -> [G] { [] }
        class func firstIndex(_ array: [G], with selection: G) -> Int { 0 }
    }
    
    private class AdvancedSelectorViewLabelBase<G: Equatable>: AdvancedSelectorViewBase<G> {
        
        let label: BasicUILabel
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            self.label = BasicUILabel(text: "???")
            self.label.font = HomeLayout.fontSemiBoldMedium
            self.label.textColor = HomeDesign.black
            self.label.numberOfLines = 0
            super.init(style: style, reuseIdentifier: reuseIdentifier)
        }
        required init?(coder: NSCoder) { fatalError() }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }
            
            super.willMove(toSuperview: newSuperview)
            self.container.addSubview(self.label)
            self.label.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: HomeLayout.margin).isActive = true
            self.label.trailingAnchor.constraint(equalTo: self.container.trailingAnchor, constant: -HomeLayout.margin).isActive = true
            self.label.bottomAnchor.constraint(equalTo: self.container.bottomAnchor, constant: -HomeLayout.margin).isActive = true
            self.label.topAnchor.constraint(equalTo: self.container.topAnchor, constant: HomeLayout.margin).isActive = true
        }
        
        override func setSelectedStyle(animate: Bool, primary: UIColor) {
            if animate {
                HomeAnimations.animateQuick({
                    self.container.backgroundColor = primary
                    self.label.textColor = HomeDesign.white
                }, completion: nil)
            }
            else {
                self.container.backgroundColor = primary
                self.label.textColor = HomeDesign.white
            }
        }
        override func setUnSelectedStyle(animate: Bool, primary: UIColor) {
            if animate {
                HomeAnimations.animateQuick({
                    self.container.backgroundColor = HomeDesign.lightGray
                    self.label.textColor = HomeDesign.black
                }, completion: nil)
            }
            else {
                self.container.backgroundColor = HomeDesign.lightGray
                self.label.textColor = HomeDesign.black
            }
        }
    }
    
    final private class AdvancedSelectorViewString: AdvancedSelectorViewLabelBase<String> {
        override func update(with value: String) {
            self.label.text = value
        }
        override class func filter(_ source: [String], with text: String) -> [String] { source.filter({ $0.contains(text) }) }
        override class func firstIndex(_ array: [String], with selection: String) -> Int { array.firstIndex(of: selection) ?? 0 }
    }
    final private class AdvancedSelectorViewTitle: AdvancedSelectorViewLabelBase<IntraTitle> {
        override func update(with value: IntraTitle) {
            self.label.text = value.name
        }
        override class func filter(_ source: [IntraTitle], with text: String) -> [IntraTitle] { source.filter({ $0.name.contains(text) }) }
        override class func firstIndex(_ array: [IntraTitle], with selection: IntraTitle) -> Int { array.firstIndex(where: { $0.id == selection.id }) ?? 0 }
    }
    final private class AdvancedSelectorViewGroup: AdvancedSelectorViewLabelBase<IntraGroup> {
        override func update(with value: IntraGroup) {
            self.label.text =  value.name
        }
        override class func filter(_ source: [IntraGroup], with text: String) -> [IntraGroup] { source.filter({ $0.name.contains(text) }) }
        override class func firstIndex(_ array: [IntraGroup], with selection: IntraGroup) -> Int { array.firstIndex(where: { $0.id == selection.id }) ?? 0 }
    }
    final private class AdvancedSelectorViewLanguage: AdvancedSelectorViewLabelBase<IntraLanguage> {
        override func update(with value: IntraLanguage) {
            self.label.text = "\(value.name) (\(value.identifier))"
        }
        override class func filter(_ source: [IntraLanguage], with text: String) -> [IntraLanguage] { source.filter({ $0.name.contains(text) }) }
        override class func firstIndex(_ array: [IntraLanguage], with selection: IntraLanguage) -> Int { array.firstIndex(where: { $0.id == selection.id }) ?? 0 }
    }
    
    final private class AdvancedSelectorViewCampus: AdvancedSelectorViewBase<IntraCampus> {
        
        private let label: BasicUILabel
        private let website: HomeInsetsLabel
        private var primary: UIColor!
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            self.label = BasicUILabel(text: "???")
            self.label.font = HomeLayout.fontSemiBoldMedium
            self.label.textColor = HomeDesign.black
            self.label.numberOfLines = 0
            self.website = HomeInsetsLabel(text: "???", inset: .init(width: HomeLayout.margins, height: 0.0))
            self.website.font = HomeLayout.fontRegularMedium
            self.website.textColor = HomeDesign.black
            self.website.layer.cornerRadius = HomeLayout.scorner
            self.website.layer.masksToBounds = true
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            self.website.isUserInteractionEnabled = true
            self.website.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(AdvancedSelectorViewCampus.websiteTapped)))
        }
        required init?(coder: NSCoder) { fatalError() }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }
            
            super.willMove(toSuperview: newSuperview)
            self.container.addSubview(self.label)
            self.label.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: HomeLayout.margin).isActive = true
            self.label.trailingAnchor.constraint(equalTo: self.container.trailingAnchor, constant: -HomeLayout.margin).isActive = true
            self.label.topAnchor.constraint(equalTo: self.container.topAnchor, constant: HomeLayout.margin).isActive = true
            self.container.addSubview(self.website)
            self.website.topAnchor.constraint(equalTo: self.label.bottomAnchor, constant: HomeLayout.margin).isActive = true
            self.website.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: HomeLayout.smargin).isActive = true
            self.website.trailingAnchor.constraint(equalTo: self.container.trailingAnchor, constant: -HomeLayout.smargin).isActive = true
            self.website.bottomAnchor.constraint(equalTo: self.container.bottomAnchor, constant: -HomeLayout.smargin).isActive = true
            self.website.heightAnchor.constraint(equalToConstant: HomeLayout.margind).isActive = true
        }
        
        override func setSelectedStyle(animate: Bool, primary: UIColor) {
            self.primary = primary
            if animate {
                HomeAnimations.animateQuick({
                    self.container.backgroundColor = primary
                    self.label.textColor = HomeDesign.white
                    self.website.backgroundColor = HomeDesign.white
                    self.website.textColor = primary
                }, completion: nil)
            }
            else {
                self.container.backgroundColor = primary
                self.label.textColor = HomeDesign.white
                self.website.backgroundColor = HomeDesign.white
                self.website.textColor = primary
            }
        }
        override func setUnSelectedStyle(animate: Bool, primary: UIColor) {
            self.primary = primary
            if animate {
                HomeAnimations.animateQuick({
                    self.container.backgroundColor = HomeDesign.lightGray
                    self.label.textColor = HomeDesign.black
                    self.website.backgroundColor = primary.withAlphaComponent(HomeDesign.alphaLowLayer)
                    self.website.textColor = HomeDesign.black
                }, completion: nil)
            }
            else {
                self.container.backgroundColor = HomeDesign.lightGray
                self.label.textColor = HomeDesign.black
                self.website.backgroundColor = primary.withAlphaComponent(HomeDesign.alphaLowLayer)
                self.website.textColor = HomeDesign.black
            }
        }
        override func update(with value: IntraCampus) {
            self.label.text = value.name
            self.website.text = value.website
        }
        
        @objc private func websiteTapped() {
            DynamicActionsSheet.presentWithWebLink(self.website.text!, primary: self.primary,
                                                   parentViewController: self.parentViewController!)
        }
        
        override class func filter(_ source: [IntraCampus], with text: String) -> [IntraCampus] {
            source.filter({ $0.name.uppercased().contains(text.uppercased()) })
        }
        override class func firstIndex(_ array: [IntraCampus], with selection: IntraCampus) -> Int {
            array.firstIndex(where: { $0.id == selection.id }) ?? 0
        }
    }
    
    final private class AdvancedSelector<G: Equatable, V: AdvancedSelectorViewBase<G>>: BasicUIView, UITableViewDelegate, UITableViewDataSource, SearchFieldViewDelegate {
        
        private let searchField: SearchFieldView
        private let tableView: BasicUITableView
        private let gradientTop: GradientView
        private let gradientBottom: GradientView
        
        private unowned(unsafe) let primary: UIColor
        private let source: [G]
        private var currentSource: [G]
        private var selectionIndex: Int
        private(set) var selection: G
        
        init(primary: UIColor, source: [G], selectionIndex: Int) {
            self.searchField = SearchFieldView()
            self.tableView = BasicUITableView()
            self.tableView.register(V.self, forCellReuseIdentifier: "cell")
            self.tableView.contentInset = .init(top: HomeLayout.margin, left: 0.0, bottom: HomeLayout.margin, right: 0.0)
            self.gradientTop = GradientView()
            self.gradientTop.startPoint = .init(x: 0.5, y: 0.0)
            self.gradientTop.endPoint = .init(x: 0.5, y: 1.0)
            self.gradientTop.colors = [HomeDesign.white.cgColor, UIColor.init(white: 1.0, alpha: 0.0).cgColor]
            self.gradientBottom = GradientView()
            self.gradientBottom.startPoint = .init(x: 0.5, y: 0.0)
            self.gradientBottom.endPoint = .init(x: 0.5, y: 1.0)
            self.gradientBottom.colors = [UIColor.init(white: 1.0, alpha: 0.0).cgColor, HomeDesign.white.cgColor]
            self.primary = primary
            self.source = source
            self.currentSource = source
            self.selectionIndex = selectionIndex
            self.selection = source[selectionIndex]
            super.init()
            self.searchField.delegate = self
            self.tableView.delegate = self
            self.tableView.dataSource = self
        }
        required init?(coder: NSCoder) { fatalError() }
        
        func searchFieldBeginEditing(_ searchField: SearchFieldView) { }
        func searchFieldTextUpdated(_ searchField: SearchFieldView) {
            if searchField.text.count == 0 {
                self.currentSource = self.source
            }
            else {
                self.currentSource = V.filter(self.source, with: searchField.text)
            }
            if let index = self.currentSource.firstIndex(of: self.selection) {
                self.selectionIndex = index
            }
            self.tableView.reloadData()
        }
        func searchFieldEndEditing(_ searchField: SearchFieldView) { }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return self.currentSource.count
        }
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! V
            
            cell.update(with: self.currentSource[indexPath.row])
            if indexPath.row == self.selectionIndex {
                cell.setSelectedStyle(animate: false, primary: self.primary)
            }
            else {
                cell.setUnSelectedStyle(animate: false, primary: self.primary)
            }
            return cell
        }
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            guard indexPath.row != self.selectionIndex else { return }
            
            if let cell = tableView.cellForRow(at: indexPath) as? V {
                cell.setSelectedStyle(animate: true, primary: self.primary)
            }
            if let cell = tableView.cellForRow(at: .init(row: self.selectionIndex, section: 0)) as? V {
                cell.setUnSelectedStyle(animate: true, primary: self.primary)
            }
            self.selection = self.currentSource[indexPath.row]
            self.selectionIndex = indexPath.row
        }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }
            
            self.addSubview(self.searchField)
            self.searchField.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            self.searchField.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            self.searchField.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            self.addSubview(self.tableView)
            self.tableView.topAnchor.constraint(equalTo: self.searchField.bottomAnchor).isActive = true
            self.tableView.leadingAnchor.constraint(equalTo: self.searchField.leadingAnchor).isActive = true
            self.tableView.trailingAnchor.constraint(equalTo: self.searchField.trailingAnchor).isActive = true
            self.tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: HomeLayout.margin).isActive = true
            let h = self.tableView.heightAnchor.constraint(equalToConstant: (UIScreen.main.bounds.height - (HomeLayout.safeAera.top + HomeLayout.safeAera.bottom)) / 2.0)
            
            h.priority = .defaultLow
            h.isActive = true
            self.addSubview(self.gradientTop)
            self.gradientTop.topAnchor.constraint(equalTo: self.tableView.topAnchor).isActive = true
            self.gradientTop.leadingAnchor.constraint(equalTo: self.tableView.leadingAnchor).isActive = true
            self.gradientTop.trailingAnchor.constraint(equalTo: self.tableView.trailingAnchor).isActive = true
            self.gradientTop.heightAnchor.constraint(equalToConstant: HomeLayout.margin).isActive = true
            self.addSubview(self.gradientBottom)
            self.gradientBottom.bottomAnchor.constraint(equalTo: self.tableView.bottomAnchor).isActive = true
            self.gradientBottom.leadingAnchor.constraint(equalTo: self.tableView.leadingAnchor).isActive = true
            self.gradientBottom.trailingAnchor.constraint(equalTo: self.tableView.trailingAnchor).isActive = true
            self.gradientBottom.heightAnchor.constraint(equalToConstant: HomeLayout.margin).isActive = true
        }
        override func draw(_ rect: CGRect) {
            self.tableView.scrollToRow(at: IndexPath.init(row: selectionIndex, section: 0),
                                       at: .middle, animated: false)
            super.draw(rect)
        }
    }
    static private var advancedSelectorType: AdvancedSelectorViewType = .string
    static private weak var advancedSelector: BasicUIView! = nil
}

// MARK: - roulette
extension DynamicAlert {
    
    final private class RouletteView: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
        
        private let primary: UIColor
        private let values: [String]
        var value: String {
            return self.values[self.selectedRow(inComponent: 0)]
        }
        var index: Int {
            get { return self.selectedRow(inComponent: 0) }
            set { self.selectRow(newValue, inComponent: 0, animated: false) }
        }
        
        init(primary: UIColor, values: [String]) {
            self.primary = primary
            self.values = values
            super.init(frame: .zero)
            self.translatesAutoresizingMaskIntoConstraints = false
            self.delegate = self
            self.dataSource = self
        }
        required init?(coder: NSCoder) { fatalError("DELUGE - TOMORROW - RROBIN X MACY LU") }
        
        final class TextView: BasicUIView {
            
            let label: BasicUILabel
            
            init(text: String, primary: UIColor) {
                self.label = BasicUILabel(text: text)
                self.label.numberOfLines = 3
                self.label.textColor = primary
                self.label.font = HomeLayout.fontSemiBoldMedium
                self.label.textAlignment = .center
                super.init()
                self.translatesAutoresizingMaskIntoConstraints = true
            }
            required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
            
            override func willMove(toSuperview newSuperview: UIView?) {
                guard newSuperview != nil else { return }
                
                self.addSubview(self.label)
                self.label.topAnchor.constraint(equalTo: self.topAnchor, constant: HomeLayout.smargin).isActive = true
                self.label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -HomeLayout.smargin).isActive = true
                self.label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: HomeLayout.smargin).isActive = true
                self.label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.smargin).isActive = true
            }
        }
        
        func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { self.values.count }
        func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
            if let reusing = view as? TextView {
                reusing.label.text = self.values[row]
                return reusing
            }
            else {
                return TextView(text: self.values[row], primary: self.primary)
            }
        }
    }
    static private weak var rouletteView: RouletteView!
}

// MARK: - icons
extension DynamicAlert {
    
    final private class IconsView: BasicUIView {
        private let primary: UIColor
        private let lightPrimary: UIColor
        private let values: [UIImage.Assets]
        var value: UIImage.Assets {
            return self.values[self.selectedIndex]
        }
        let size: CGFloat
        var selectedIndex: Int
        
        init(primary: UIColor, values: [UIImage.Assets], size: CGFloat, selectedIndex: Int) {
            self.primary = primary
            self.lightPrimary = primary.withAlphaComponent(HomeDesign.alphaLow)
            self.values = values
            self.size = size
            self.selectedIndex = selectedIndex
            super.init()
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }
            
            let availableWidth: CGFloat = (UIScreen.main.bounds.width - (HomeLayout.safeAera.left + HomeLayout.safeAera.right + HomeLayout.smargin + HomeLayout.margins))
            let countPerLine: Int = Int(availableWidth / (size + HomeLayout.margin))
            
            let container = BasicUIView()
            var leftImageView: BasicUIImageView? = nil
            var imageView: BasicUIImageView!
            var top = self.topAnchor
            var trailing: NSLayoutConstraint!
            var index: Int = 0
            
            self.addSubview(container)
            container.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            container.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            container.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            while index < self.values.count {
                for _ in 0 ..< countPerLine where index < self.values.count {
                    imageView = BasicUIImageView(asset: self.values[index])
                    imageView.isUserInteractionEnabled = true
                    imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageTapped(sender:))))
                    container.addSubview(imageView)
                    if let left = leftImageView {
                        imageView.leadingAnchor.constraint(equalTo: left.trailingAnchor, constant: HomeLayout.smargin).isActive = true
                    }
                    else {
                        imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: HomeLayout.smargin).isActive = true
                    }
                    imageView.widthAnchor.constraint(equalToConstant: self.size).isActive = true
                    imageView.topAnchor.constraint(equalTo: top, constant: HomeLayout.smargin).isActive = true
                    imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1.0).isActive = true
                    leftImageView = imageView
                    if index == self.selectedIndex {
                        imageView.backgroundColor = self.primary
                    }
                    else {
                        imageView.backgroundColor = self.lightPrimary
                    }
                    imageView.tintColor = HomeDesign.white
                    imageView.layer.cornerRadius = HomeLayout.corner
                    imageView.layer.masksToBounds = true
                    index &+= 1
                }
                trailing = imageView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -HomeLayout.smargin)
                trailing.priority = .defaultLow
                trailing.isActive = true
                top = imageView.bottomAnchor
                leftImageView = nil
            }
            imageView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -HomeLayout.smargin).isActive = true
        }
        
        @objc private func imageTapped(sender: UITapGestureRecognizer) {
            let oldSelection = self.subviews[0].subviews[self.selectedIndex] as! BasicUIImageView
            let newSelection = sender.view as! BasicUIImageView
            let newSelectedIndex = self.subviews[0].subviews.firstIndex(of: newSelection) ?? 0
            
            HomeAnimations.animateShort({
                oldSelection.backgroundColor = self.lightPrimary
                newSelection.backgroundColor = self.primary
            }, completion: nil)
            self.selectedIndex = newSelectedIndex
        }
    }
    static private weak var iconsView: IconsView!
}

// MARK: - code
extension DynamicAlert {
    
    final private class CodeView: UIStackView {
        
        final private class CodeInputView: BasicUILabel, UIKeyInput {
            
            var keyboardType: UIKeyboardType = .numberPad
            var keyboardAppearance: UIKeyboardAppearance = HomeDesign.keyboardAppearance
            var returnKeyType: UIReturnKeyType {
                if self.position >= self.count - 1 {
                    return .done
                }
                return .next
            }
            override var canBecomeFirstResponder: Bool { true }
            
            override func becomeFirstResponder() -> Bool {
                self.layer.basicAnimation(keyPath: \.borderColor, value: HomeDesign.primary.cgColor, duration: HomeAnimations.durationMedium)
                return super.becomeFirstResponder()
            }
            override func resignFirstResponder() -> Bool {
                self.layer.basicAnimation(keyPath: \.borderColor, value: HomeDesign.blackLayer.cgColor, duration: HomeAnimations.durationMedium)
                return super.resignFirstResponder()
            }
            override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
                _ = self.becomeFirstResponder()
            }
            
            private let position: Int
            private let count: Int
            
            init(position: Int, count: Int) {
                self.position = position
                self.count = count
                super.init(text: "")
                self.textColor = HomeDesign.black
                self.textAlignment = .center
                self.font = HomeLayout.fontSemiBoldMedium
                self.backgroundColor = HomeDesign.white
                self.layer.cornerRadius = HomeLayout.corner
                self.layer.borderWidth = HomeLayout.sborder
                self.layer.borderColor = HomeDesign.blackLayer.cgColor
                self.isUserInteractionEnabled = true
            }
            required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
            
            var hasText: Bool {
                return self.text!.count > 0
            }
            
            func insertText(_ text: String) {
                self.text = text
                if self.position >= self.count - 1 {
                    _ = self.resignFirstResponder()
                }
                else {
                    _ = self.resignFirstResponder()
                    if let stack: DynamicAlert.CodeView = self.parent() {
                        stack.arrangedSubviews[self.position + 1].becomeFirstResponder()
                    }
                }
            }
            
            func deleteBackward() {
                if self.hasText {
                    self.text = ""
                }
                else {
                    if self.position == 0 {
                        _ = self.resignFirstResponder()
                    }
                    else {
                        _ = self.resignFirstResponder()
                        if let stack: DynamicAlert.CodeView = self.parent() {
                            stack.arrangedSubviews[self.position - 1].becomeFirstResponder()
                        }
                    }
                }
            }
        }
        
        init(maximum: Int) {
            super.init(frame: .zero)
            for index in 0 ..< maximum {
                self.addArrangedSubview(CodeInputView(position: index, count: maximum))
            }
            self.isUserInteractionEnabled = true
            self.axis = .horizontal
            self.alignment = .fill
            self.distribution = .fillEqually
            self.spacing = HomeLayout.margin
        }
        required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        var value: Int {
            var result: Int = 0
            var pad: Int = 10 ** (self.arrangedSubviews.count - 1)
            
            for codeInput in self.arrangedSubviews {
                if let input = (codeInput as! CodeInputView).text, !input.isEmpty, let v = Int(input) {
                    result = result + v * pad
                }
                pad /= 10
            }
            return result
        }
    }
    static private weak var codeView: CodeView!
}

// MARK: - TextView web links
extension DynamicAlert {
    
    final class TextView: BasicUITextView, UITextViewDelegate, MFMailComposeViewControllerDelegate {
        
        private var heightAnchorConstraint: NSLayoutConstraint!
        
        init(text: String, color: UIColor) {
            super.init()
            self.heightAnchorConstraint = self.heightAnchor.constraint(equalToConstant: 0.0)
            self.heightAnchorConstraint.priority = .defaultLow
            self.text = text
            self.font = HomeLayout.fontRegularMedium
            self.textColor = HomeDesign.black
            self.textAlignment = .center
            self.isEditable = false
            self.dataDetectorTypes = .link
            self.delegate = self
            self.tintColor = color
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }
            let witdh = UIScreen.main.bounds.width - 48.0
            let estimatedHeigth = self.sizeThatFits(CGSize.init(width: witdh, height: .infinity)).height
            
            self.heightAnchorConstraint.constant = estimatedHeigth
            self.heightAnchorConstraint.isActive = true
        }
        
        func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
            if URL.absoluteString.starts(with: "mailto:") || URL.absoluteString.isEmail {
                let email = MFMailComposeViewController()
                
                email.mailComposeDelegate = self
                email.setToRecipients([URL.absoluteString.replacingOccurrences(of: "mailto:", with: "")])
                self.parentViewController!.present(email, animated: true, completion: nil)
            }
            else {
                let webView = SafariWebView(URL, primaryColor: self.tintColor)
                
                self.parentViewController!.present(webView, animated: true, completion: nil)
            }
            return false
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true, completion: nil)
        }
        
        override func draw(_ rect: CGRect) {
            super.draw(rect)
            if self.isScrollEnabled {
                self.showsVerticalScrollIndicator = true
                self.setScrollIndicatorColor(self.tintColor)
            }
        }
    }
}

// MARK: -
extension DynamicAlert {
    
    final private class SlotIntervalSelector: BasicUIView, SelectorViewDelegate {
        
        private let stateLabel: BasicUILabel
        private let startDaySelector: SelectorView<Int>
        private let startHourSelector: SelectorView<Int>
        private let startMinuteSelector: SelectorView<Int>
        private let endDaySelector: SelectorView<Int>
        private let endHourSelector: SelectorView<Int>
        private let endMinuteSelector: SelectorView<Int>
        private var invalidSelection: Bool = false
        
        override init() {
            let today = Date()
            let daysAfter = today.nextDays()
            let daysAfterKeys = daysAfter.dayKeys
            let daysKeys = zip(daysAfter, daysAfterKeys).map({ "\(~$1) \($0.day)" })
            let daysValues = daysAfter.map({ $0.day })
            let hoursWord = ~"time.hours"
            let hoursValue = (0 ..< 24).map({ $0 })
            let hoursKeys = hoursValue.map({ "\($0) \(hoursWord)" })
            let minutesWord = ~"time.mins"
            let minutesValue = [00, 15, 30, 45]
            let minutesKeys = minutesValue.map({ "\($0) \(minutesWord)"})
            let startDate = SlotIntervalSelector.nextWorkingDate(today)
            let endDate = SlotIntervalSelector.nextWorkingDate(startDate)
            
            self.stateLabel = BasicUILabel(text: ~"slots.availability")
            self.stateLabel.font = HomeLayout.fontSemiBoldMedium
            self.stateLabel.textColor = HomeDesign.black
            self.stateLabel.numberOfLines = 0
            self.stateLabel.textAlignment = .center
            self.startDaySelector = SelectorView(keys: daysKeys, values: daysValues, selectedIndex: daysAfter.firstIndex(where: { $0.day == startDate.day }) ?? 0)
            self.startHourSelector = SelectorView(keys: hoursKeys, values: hoursValue, selectedIndex: startDate.hour)
            self.startMinuteSelector = SelectorView(keys: minutesKeys, values: minutesValue, selectedIndex: minutesValue.firstIndex(where: { $0 >= startDate.minute }) ?? 0)
            self.endDaySelector = SelectorView(keys: daysKeys, values: daysValues, selectedIndex: daysAfter.firstIndex(where: { $0.day == startDate.day }) ?? 0)
            self.endHourSelector = SelectorView(keys: hoursKeys, values: hoursValue, selectedIndex: endDate.hour)
            self.endMinuteSelector = SelectorView(keys: minutesKeys, values: minutesValue, selectedIndex: minutesValue.firstIndex(where: { $0 >= endDate.minute }) ?? 0)
            super.init()
            self.startDaySelector.delegate = self
            self.startHourSelector.delegate = self
            self.startMinuteSelector.delegate = self
            self.endDaySelector.delegate = self
            self.endHourSelector.delegate = self
            self.endMinuteSelector.delegate = self
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }

            self.addSubview(self.stateLabel)
            self.stateLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            self.stateLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            self.stateLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            
            self.addSubview(self.startDaySelector)
            self.startDaySelector.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            self.startDaySelector.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            self.startDaySelector.topAnchor.constraint(equalTo: self.stateLabel.bottomAnchor, constant: HomeLayout.margin).isActive = true
            self.addSubview(self.startMinuteSelector)
            self.startMinuteSelector.topAnchor.constraint(equalTo: self.startDaySelector.bottomAnchor, constant: HomeLayout.margin).isActive = true
            self.startMinuteSelector.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            self.addSubview(self.startHourSelector)
            self.startHourSelector.trailingAnchor.constraint(equalTo: self.startMinuteSelector.leadingAnchor, constant: -HomeLayout.margin).isActive = true
            self.startHourSelector.centerYAnchor.constraint(equalTo: self.startMinuteSelector.centerYAnchor).isActive = true
            self.startHourSelector.topAnchor.constraint(equalTo: self.startDaySelector.bottomAnchor, constant: HomeLayout.margin).isActive = true
            self.startHourSelector.widthAnchor.constraint(equalTo: self.startMinuteSelector.widthAnchor).isActive = true
            self.startHourSelector.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            
            self.addSubview(self.endDaySelector)
            self.endDaySelector.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            self.endDaySelector.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            self.endDaySelector.topAnchor.constraint(equalTo: self.startHourSelector.bottomAnchor, constant: HomeLayout.margin).isActive = true
            self.addSubview(self.endMinuteSelector)
            self.endMinuteSelector.topAnchor.constraint(equalTo: self.endDaySelector.bottomAnchor, constant: HomeLayout.margin).isActive = true
            self.endMinuteSelector.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            self.addSubview(self.endHourSelector)
            self.endHourSelector.trailingAnchor.constraint(equalTo: self.endMinuteSelector.leadingAnchor, constant: -HomeLayout.margin).isActive = true
            self.endHourSelector.centerYAnchor.constraint(equalTo: self.endMinuteSelector.centerYAnchor).isActive = true
            self.endHourSelector.topAnchor.constraint(equalTo: self.endDaySelector.bottomAnchor, constant: HomeLayout.margin).isActive = true
            self.endHourSelector.widthAnchor.constraint(equalTo: self.endMinuteSelector.widthAnchor).isActive = true
            self.endHourSelector.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            
            self.endHourSelector.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        }
        var startDate: Date {
            return Date().dateBySet([
                .day: self.startDaySelector.value,
                .hour: self.startHourSelector.value,
                .minute: self.startMinuteSelector.value
            ])!
        }
        var endDate: Date {
            return Date().dateBySet([
                .day: self.endDaySelector.value,
                .hour: self.endHourSelector.value,
                .minute: self.endMinuteSelector.value
            ])!
        }
        
        static func nextWorkingDate(_ date: Date) -> Date {
            var newDate = date
            let diff = date.minute - (date.minute / 15) * 15
            
            newDate = newDate.dateByAdding(15 - diff, .minute).date
            return newDate
        }
        
        func selectorSelect<Int>(_ selector: SelectorView<Int>) {
            self.invalidSelection = self.startDate >= self.endDate
            self.changeOnInvalidSelection()
        }
        
        private func changeOnInvalidSelection() {
            let primary: UIColor
            
            func getSelectionButton() -> DynamicAlert.Button? {
                var superview: UIView = self
                
                while superview.superview != nil {
                    superview = superview.superview!
                }
                
                func search(view: UIView) -> DynamicAlert.Button? {
                    for subview in view.subviews {
                        if let button = (subview as? DynamicAlert.Button) {
                            switch button.action {
                            case .slotInterval(_):
                                return button
                            default: break
                            }
                        }
                        if subview.subviews.count > 0, let button = search(view: subview) {
                            return button
                        }
                    }
                    return nil
                }
                
                return search(view: superview)
            }
            
            if self.invalidSelection {
                primary = HomeDesign.redError
                if let button = getSelectionButton() {
                    button.isUserInteractionEnabled = false
                    button.setPrimary(primary, isHighligth: true)
                }
            }
            else {
                primary = HomeDesign.primary
                if let button = getSelectionButton() {
                    button.isUserInteractionEnabled = true
                    button.setPrimary(primary, isHighligth: false)
                }
            }
            self.startDaySelector.setPrimary(primary)
            self.startHourSelector.setPrimary(primary)
            self.startMinuteSelector.setPrimary(primary)
            self.endDaySelector.setPrimary(primary)
            self.endHourSelector.setPrimary(primary)
            self.endMinuteSelector.setPrimary(primary)
        }
    }
    static weak private var slotInterval: SlotIntervalSelector! = nil
}

// MARK: - color picker
extension DynamicAlert {
    
    final private class ColorPicker: BasicUIView, ValueSelectorWithArrowsDelegate {
        
        private struct ColorDescriptor {
            
            var hue: CGFloat
            var saturation: CGFloat
            var brightness: CGFloat
            var red: CGFloat
            var redInteger: Int {
                return Int(self.red * 255.0)
            }
            var green: CGFloat
            var greenInteger: Int {
                return Int(self.green * 255.0)
            }
            var blue: CGFloat
            var blueInteger: Int {
                return Int(self.blue * 255.0)
            }
            var uicolor: UIColor
            var whiteColor: UIColor {
                return UIColor.init(hue: self.hue, saturation: self.saturation, brightness: 1.0, alpha: 1.0)
            }
            var blackColor: UIColor {
                return UIColor.init(hue: self.hue, saturation: self.saturation, brightness: 0.0, alpha: 1.0)
            }
            
            init(color: UIColor) {
                self.uicolor = color
                self.hue = 0.0
                self.saturation = 0.0
                self.brightness = 0.0
                self.red = 0.0
                self.green = 0.0
                self.blue = 0.0
                self.uicolor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: nil)
                self.uicolor.getRed(&red, green: &green, blue: &blue, alpha: nil)
            }
            
            @inlinable mutating func updateWith(ired: Int, igreen: Int, iblue: Int) {
                self.uicolor = UIColor(red: CGFloat(ired) / 255.0, green: CGFloat(igreen) / 255.0, blue: CGFloat(iblue) / 255.0, alpha: 1.0)
                self.uicolor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: nil)
                self.uicolor.getRed(&red, green: &green, blue: &blue, alpha: nil)
            }
            
            @inlinable mutating func updateWith(brightness: CGFloat) {
                self.uicolor = UIColor(hue: self.hue, saturation: self.saturation, brightness: self.brightness, alpha: 1.0)
                self.brightness = brightness
                self.uicolor.getHue(&hue, saturation: &saturation, brightness: nil, alpha: nil)
                self.uicolor.getRed(&red, green: &green, blue: &blue, alpha: nil)
            }
            
            @inlinable mutating func updateWith(normalizedPosition: CGPoint) {
                let hue = normalize(radian: -atan2(normalizedPosition.y - 0.5, normalizedPosition.x - 0.5)) / (CGFloat.pi * 2)
                let saturation = min(0.5, hypot(normalizedPosition.x - 0.5, normalizedPosition.y - 0.5)) * 2
                
                self.uicolor = UIColor(hue: hue, saturation: saturation, brightness: self.brightness, alpha: 1.0)
                self.hue = hue
                self.saturation = saturation
                self.uicolor.getRed(&red, green: &green, blue: &blue, alpha: nil)
            }
            
            @inlinable func normalizedPosition(in size: CGSize) -> CGPoint {
                let radius = self.saturation / 2
                let angle = self.hue * (CGFloat.pi * -2)
                
                return CGPoint(x: ((radius * cos(angle)) + 0.5) * size.width, y: ((radius * sin(angle)) + 0.5) * size.height)
            }
            
            @inlinable func normalize(radian: CGFloat) -> CGFloat {
                let pi2 = CGFloat.pi * 2
                let reminder = radian.truncatingRemainder(dividingBy: pi2)
                
                return radian < 0.0 ? reminder + pi2 : reminder
            }
        }
        
        private var colorDescriptor: ColorDescriptor
        private let pointer: UnsafeMutablePointer<UIColor>
        
        private let colorMap: ColorMapView
        private let indicatorView: BasicUIView
        private let brightnessSlider: BrightnessSlider
        
        private let hexLabel: BasicUILabel
        
        private let redSelector: ValueSelectorWithArrows<Int>
        private let greenSelector: ValueSelectorWithArrows<Int>
        private let blueSelector: ValueSelectorWithArrows<Int>
        
        init(color: UIColor, pointer: UnsafeMutablePointer<UIColor>) {
            self.colorDescriptor = ColorDescriptor(color: color)
            self.pointer = pointer
            self.colorMap = ColorMapView(color: &self.colorDescriptor)
            self.brightnessSlider = BrightnessSlider(color: &self.colorDescriptor)
            self.indicatorView = BasicUIView()
            self.indicatorView.backgroundColor = color
            self.indicatorView.layer.borderWidth = HomeLayout.borders
            self.indicatorView.layer.borderColor = HomeDesign.gray.cgColor
            self.hexLabel = BasicUILabel(text: String(format: "#%02x%02x%02x", self.colorDescriptor.redInteger, self.colorDescriptor.greenInteger, self.colorDescriptor.blueInteger))
            self.hexLabel.textColor = HomeDesign.black
            self.hexLabel.textAlignment = .left
            self.hexLabel.font = HomeLayout.fontRegularNormal
            self.redSelector = .init(min: 0, max: 255, step: 1, value: self.colorDescriptor.redInteger, textDisplay: .usingSuffix(~"colorpicker-red" + ": "))
            self.greenSelector = .init(min: 0, max: 255, step: 1, value: self.colorDescriptor.greenInteger, textDisplay: .usingSuffix(~"colorpicker-green" + ": "))
            self.blueSelector = .init(min: 0, max: 255, step: 1, value: self.colorDescriptor.blueInteger, textDisplay: .usingSuffix(~"colorpicker-blue" + ": "))
            super.init()
            self.redSelector.delegate = self
            self.greenSelector.delegate = self
            self.blueSelector.delegate = self
            self.colorMap.isUserInteractionEnabled = true
            self.colorMap.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(colorMapPanGesture(gesture:))))
            self.brightnessSlider.selector.isUserInteractionEnabled = true
            self.brightnessSlider.selector.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(brightnessSliderPanGesture(gesture:))))
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else {
                return
            }
            self.addSubview(self.brightnessSlider)
            self.brightnessSlider.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.smargin).isActive = true
            self.brightnessSlider.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            self.addSubview(self.colorMap)
            self.colorMap.topAnchor.constraint(equalTo: self.topAnchor, constant: 0.0).isActive = true
            self.colorMap.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            self.colorMap.trailingAnchor.constraint(equalTo: self.brightnessSlider.leadingAnchor, constant: -HomeLayout.margin).isActive = true
            self.colorMap.heightAnchor.constraint(equalTo: self.colorMap.widthAnchor, multiplier: 1.0).isActive = true
            self.brightnessSlider.bottomAnchor.constraint(equalTo: self.colorMap.bottomAnchor).isActive = true
            self.addSubview(self.indicatorView)
            self.indicatorView.topAnchor.constraint(equalTo: self.colorMap.topAnchor, constant: HomeLayout.border).isActive = true
            self.indicatorView.trailingAnchor.constraint(equalTo: self.colorMap.trailingAnchor, constant: -HomeLayout.borders).isActive = true
            self.indicatorView.widthAnchor.constraint(equalTo: self.colorMap.widthAnchor, multiplier: 0.17).isActive = true
            self.indicatorView.heightAnchor.constraint(equalTo: self.indicatorView.widthAnchor).isActive = true
            self.addSubview(self.redSelector)
            self.addSubview(self.greenSelector)
            self.addSubview(self.blueSelector)
            self.redSelector.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            self.redSelector.topAnchor.constraint(equalTo: self.colorMap.bottomAnchor, constant: HomeLayout.margin).isActive = true
            self.redSelector.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            self.greenSelector.leadingAnchor.constraint(equalTo: self.redSelector.leadingAnchor).isActive = true
            self.greenSelector.topAnchor.constraint(equalTo: self.redSelector.bottomAnchor, constant: HomeLayout.smargin).isActive = true
            self.greenSelector.trailingAnchor.constraint(equalTo: self.redSelector.trailingAnchor).isActive = true
            self.blueSelector.leadingAnchor.constraint(equalTo: self.greenSelector.leadingAnchor).isActive = true
            self.blueSelector.trailingAnchor.constraint(equalTo: self.greenSelector.trailingAnchor).isActive = true
            self.blueSelector.topAnchor.constraint(equalTo: self.greenSelector.bottomAnchor, constant: HomeLayout.smargin).isActive = true
            self.blueSelector.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            self.addSubview(self.hexLabel)
            self.hexLabel.trailingAnchor.constraint(equalTo: self.brightnessSlider.leadingAnchor, constant: -HomeLayout.smargin).isActive = true
            self.hexLabel.bottomAnchor.constraint(equalTo: self.brightnessSlider.bottomAnchor, constant: -HomeLayout.smargin).isActive = true
        }
        override func draw(_ rect: CGRect) {
            super.draw(rect)
            self.indicatorView.layer.cornerRadius = self.indicatorView.frame.width / 2.0
        }
        
        private func colorChanged() {
            let ired = self.colorDescriptor.redInteger
            let iblue = self.colorDescriptor.blueInteger
            let igreen = self.colorDescriptor.greenInteger
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            self.colorMap.cursor.colorLayer.backgroundColor = self.colorDescriptor.uicolor.cgColor
            self.colorMap.cursor.backgroundLayer.backgroundColor = self.colorMap.cursor.colorLayer.backgroundColor
            (self.brightnessSlider.layer as! CAGradientLayer).colors = [self.colorDescriptor.whiteColor.cgColor, self.colorDescriptor.blackColor.cgColor]
            CATransaction.commit()
            self.indicatorView.backgroundColor = self.colorDescriptor.uicolor
            self.redSelector.update(min: 0, max: 255, step: 1, value: ired)
            self.greenSelector.update(min: 0, max: 255, step: 1, value: igreen)
            self.blueSelector.update(min: 0, max: 255, step: 1, value: iblue)
            self.hexLabel.text = String(format: "#%02x%02x%02x", ired, igreen, iblue)
            self.pointer.pointee = self.colorDescriptor.uicolor
        }
        
        // MARK: -
        func valueSelectorChanged() {
            self.colorDescriptor.updateWith(ired: self.redSelector.value, igreen: self.greenSelector.value, iblue: self.blueSelector.value)
            self.colorChanged()
            self.colorMap.setNeedsDisplay()
            self.colorMap.cursor.center = self.colorDescriptor.normalizedPosition(in: self.colorMap.bounds.size)
        }
        
        @objc private func brightnessSliderPanGesture(gesture: UIPanGestureRecognizer) {
            let location = gesture.location(in: self)
            let constant = max(0, min(floor(location.y), self.frame.height))
            let brightness = abs(1.0 - CGFloat(constant / self.frame.height))
            
            self.brightnessSlider.selectorTop.constant = constant
            self.brightnessSlider.layoutIfNeeded()
            self.colorDescriptor.updateWith(brightness: brightness)
            self.colorChanged()
            self.colorMap.setNeedsDisplay()
        }
        
        @objc private func colorMapPanGesture(gesture: UIPanGestureRecognizer) {
            let position = gesture.location(in: self)
            
            self.colorDescriptor.updateWith(normalizedPosition: CGPoint(x: position.x / self.colorMap.bounds.width, y: position.y / self.colorMap.bounds.height))
            switch gesture.state {
            case .began:
                self.colorMap.cursor.startEditing()
            case .cancelled, .ended, .failed:
                self.colorMap.cursor.endEditing()
            default:
                break
            }
            self.colorMap.cursor.center = position
            self.colorChanged()
        }
        
        final private class BrightnessSlider: BasicUIView {
            
            private let color: UnsafePointer<ColorDescriptor>
            let selector: BasicUIView
            var selectorTop: NSLayoutConstraint!
            
            override class var layerClass: AnyClass {
                return CAGradientLayer.self
            }
            
            init(color: UnsafePointer<ColorDescriptor>) {
                self.color = color
                self.selector = BasicUIView()
                self.selector.backgroundColor = HomeDesign.gray
                self.selector.layer.cornerRadius = HomeLayout.scorner
                self.selector.layer.masksToBounds = true
                super.init()
                (self.layer as! CAGradientLayer).startPoint = .init(x: 0.5, y: 0.0)
                (self.layer as! CAGradientLayer).endPoint = .init(x: 0.5, y: 1.0)
                (self.layer as! CAGradientLayer).colors = [color.pointee.whiteColor.cgColor, color.pointee.blackColor.cgColor]
                self.layer.cornerRadius = HomeLayout.corner
                self.layer.borderWidth = HomeLayout.border
                self.layer.borderColor = HomeDesign.gray.cgColor
            }
            required init?(coder aDecoder: NSCoder) { fatalError() }
            
            override func willMove(toSuperview newSuperview: UIView?) {
                guard newSuperview != nil else { return }
                
                self.addSubview(self.selector)
                self.selector.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: -HomeLayout.smargin).isActive = true
                self.selector.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: HomeLayout.smargin).isActive = true
                self.selector.heightAnchor.constraint(equalToConstant: HomeLayout.margin).isActive = true
                self.selectorTop = self.selector.centerYAnchor.constraint(equalTo: self.topAnchor)
                self.selectorTop.isActive = true
                self.widthAnchor.constraint(equalToConstant: 40.0).isActive = true
            }
            
            override func draw(_ rect: CGRect) {
                super.draw(rect)
                self.selectorTop.constant = abs(1.0 - self.color.pointee.brightness) * rect.height
                self.layoutIfNeeded()
            }
        }
                
        final private class ColorMapView: BasicUIView {
            
            final class Cursor: UIView {
                
                let backgroundLayer = CALayer()
                let colorLayer = CALayer()
                
                init(cgColor: CGColor) {
                    super.init(frame: CGRect(x: 0, y: 0, width: 28, height: 28))
                    self.backgroundLayer.shadowColor = UIColor.black.cgColor
                    self.backgroundLayer.shadowOffset = CGSize(width: 0, height: 2)
                    self.backgroundLayer.shadowRadius = 3
                    self.backgroundLayer.shadowOpacity = 0.5
                    self.layer.addSublayer(backgroundLayer)
                    self.layer.addSublayer(colorLayer)
                    self.isUserInteractionEnabled = false
                    self.colorLayer.backgroundColor = cgColor
                    self.backgroundLayer.backgroundColor = cgColor
                }
                required init?(coder aDecoder: NSCoder) { fatalError() }
                
                override func layoutSubviews() {
                    let backgroundSize = CGSize(width: 28, height: 28)
                    let colorSize = CGSize(width: 26, height: 26)
                    
                    super.layoutSubviews()
                    self.backgroundLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
                    self.backgroundLayer.bounds = CGRect(origin: .zero, size: backgroundSize)
                    self.backgroundLayer.cornerRadius = backgroundSize.width / 2.0
                    self.colorLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
                    self.colorLayer.bounds = CGRect(origin: .zero, size: colorSize)
                    self.colorLayer.cornerRadius = colorSize.width / 2.0
                }
                
                func startEditing() {
                    self.backgroundLayer.transform = CATransform3DMakeScale(1.6, 1.6, 1)
                    self.colorLayer.transform = CATransform3DMakeScale(1.4, 1.4, 1)
                }
                func endEditing() {
                    self.backgroundLayer.transform = CATransform3DIdentity
                    self.colorLayer.transform = CATransform3DIdentity
                }
            }
            
            private let color: UnsafePointer<ColorDescriptor>
            let cursor: Cursor
            private let mapLayer: CALayer = CALayer()
            
            init(color: UnsafePointer<ColorDescriptor>) {
                self.color = color
                self.cursor = Cursor(cgColor: color.pointee.uicolor.cgColor)
                super.init()
                self.layer.addSublayer(self.mapLayer)
            }
            required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
            
            override func draw(_ rect: CGRect) {
                super.draw(rect)
                self.mapLayer.frame = rect
                self.mapLayer.contents = self.createColorMap(size: rect.size)
                self.layer.cornerRadius = rect.width / 2.0
                self.layer.masksToBounds = true
                self.layer.borderWidth = HomeLayout.borders
                self.layer.borderColor = HomeDesign.gray.cgColor
                self.addSubview(self.cursor)
                self.cursor.center = self.color.pointee.normalizedPosition(in: rect.size)
            }
                        
            private func createColorMap(size: CGSize) -> CGImage {
                let width = Int(size.width)
                let height = Int(size.height)
                let bufferSize: Int = width * height * 3
                let bitmapData: CFMutableData = CFDataCreateMutable(nil, 0)
                let bitmap: UnsafeMutablePointer<UInt8>!
                
                var color = ColorDescriptor(color: self.color.pointee.uicolor)
                var offset: Int = 0
                
                CFDataSetLength(bitmapData, CFIndex(bufferSize))
                bitmap = CFDataGetMutableBytePtr(bitmapData)
                for y in stride(from: CGFloat(0), to: size.height, by: 1) {
                    for x in stride(from: CGFloat(0), to: size.width, by: 1) {
                        color.updateWith(normalizedPosition: CGPoint(x: x / size.width, y: y / size.height))
                        offset = (Int(x) + (Int(y) * width)) * 3
                        bitmap[offset] = UInt8(color.redInteger)
                        bitmap[offset + 1] = UInt8(color.greenInteger)
                        bitmap[offset + 2] = UInt8(color.blueInteger)
                    }
                }
                
                return CGImage(width: width, height: height,
                               bitsPerComponent: 8, bitsPerPixel: 24, bytesPerRow: width * 3,
                               space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: [], provider: CGDataProvider(data: bitmapData)!,
                               decode: nil, shouldInterpolate: false, intent: .defaultIntent)!
            }
        }
    }
}

// MARK: - UsersSelector
extension DynamicAlert {
    
    final private class UsersSelector: BasicUIView, SearchFieldViewDelegate {
        
        private let searchField: SearchFieldViewWithTimer
        private let gradientTop: GradientView
        private let gradientBottom: GradientView
        private let tableView: UserInfoInfiniteRequestTableView
        private let block: (IntraUserInfo) -> ()
        
        init(user: IntraUserInfo?, primary: UIColor, block: @escaping (IntraUserInfo) -> ()) {
            self.searchField = SearchFieldViewWithTimer(placeholder: ~"general.login")
            self.searchField.setPrimary(primary)
            self.gradientTop = GradientView()
            self.gradientTop.startPoint = .init(x: 0.5, y: 0.0)
            self.gradientTop.endPoint = .init(x: 0.5, y: 1.0)
            self.gradientTop.colors = [HomeDesign.white.cgColor, UIColor.init(white: 1.0, alpha: 0.0).cgColor]
            self.gradientBottom = GradientView()
            self.gradientBottom.startPoint = .init(x: 0.5, y: 0.0)
            self.gradientBottom.endPoint = .init(x: 0.5, y: 1.0)
            self.gradientBottom.colors = [UIColor.init(white: 1.0, alpha: 0.0).cgColor, HomeDesign.white.cgColor]
            if let user = user {
                self.tableView = .init(.users, parameters: ["search[login]": user.login, "sort":"-login"],
                                       page: 1, pageSize: 50, primary: primary)
                self.searchField.text = user.login
            }
            else {
                self.tableView = .init(.users, parameters: ["sort":"-login"],
                                       page: 1, pageSize: 50, primary: primary)
            }
            self.tableView.contentInset = .init(top: HomeLayout.margin, left: 0.0, bottom: HomeLayout.margin, right: 0.0)
            self.block = block
            super.init()
            self.searchField.delegate = self
            self.tableView.block = self.userSelected(_:)
            self.tableView.nextPage()
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        func searchFieldTextUpdated(_ searchField: SearchFieldView) {
            self.tableView.restart(with: ["search[login]": searchField.text, "sort":"-login"])
        }
        func searchFieldBeginEditing(_ searchField: SearchFieldView) { }
        func searchFieldEndEditing(_ searchField: SearchFieldView) { }
        
        private func userSelected(_ user: IntraUserInfo) {
            let alert = self.parentViewController as! DynamicAlert
            
            alert.remove()
            self.block(user)
        }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }
            let h = self.tableView.heightAnchor.constraint(equalToConstant: (UIScreen.main.bounds.height - (HomeLayout.safeAera.top + HomeLayout.safeAera.bottom)) / 2.0)
            
            self.addSubview(self.searchField)
            self.searchField.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            self.searchField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: HomeLayout.margin).isActive = true
            self.searchField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.margin).isActive = true
            self.addSubview(self.tableView)
            self.tableView.topAnchor.constraint(equalTo: self.searchField.bottomAnchor).isActive = true
            self.tableView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            self.tableView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            self.tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            self.addSubview(self.gradientTop)
            self.gradientTop.topAnchor.constraint(equalTo: self.tableView.topAnchor).isActive = true
            self.gradientTop.leadingAnchor.constraint(equalTo: self.tableView.leadingAnchor).isActive = true
            self.gradientTop.trailingAnchor.constraint(equalTo: self.tableView.trailingAnchor).isActive = true
            self.gradientTop.heightAnchor.constraint(equalToConstant: HomeLayout.margin).isActive = true
            self.addSubview(self.gradientBottom)
            self.gradientBottom.bottomAnchor.constraint(equalTo: self.tableView.bottomAnchor).isActive = true
            self.gradientBottom.leadingAnchor.constraint(equalTo: self.tableView.leadingAnchor).isActive = true
            self.gradientBottom.trailingAnchor.constraint(equalTo: self.tableView.trailingAnchor).isActive = true
            self.gradientBottom.heightAnchor.constraint(equalToConstant: HomeLayout.margin).isActive = true
            h.priority = .defaultLow
            h.isActive = true
        }
    }
}

// MARK: - TextEditor
extension DynamicAlert {
    
    final private class TextEditor: RoundedGenericActionsView<BasicUITextField, ActionButtonView>, UITextFieldDelegate {
        
        let defaultText: String
        
        init(defaultText: String, primary: UIColor) {
            let textField = BasicUITextField()
            let resetAction = ActionButtonView(asset: .actionClose, color: primary)
            
            self.defaultText = defaultText
            super.init(textField, initialActions: [resetAction])
            textField.attributedPlaceholder = .init(string: ~"general.replace", attributes: [.foregroundColor: HomeDesign.gray, .font: HomeLayout.fontRegularMedium])
            textField.delegate = self
            textField.text = defaultText
            resetAction.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(TextEditor.resetButtonTapped(sender:))))
            super.setPrimary(primary)
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
                
        @objc private func resetButtonTapped(sender: UITapGestureRecognizer) {
            self.view.text = ""
        }
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            return textField.resignFirstResponder()
        }
        
        @discardableResult override func resignFirstResponder() -> Bool {
            return self.textFieldShouldReturn(self.view)
        }
    }
    static private weak var textEditor: TextEditor! = nil
}
