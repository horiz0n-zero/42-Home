// home42/RoundedGenericActionsView.swift
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
import SwiftDate
import CryptoKit

class RoundedGenericActionsView<G: UIView, A: HomePressableUIView>: BasicUIView {
    
    let view: G
    fileprivate let actionsStack: BasicUIStackView
    var actionViews: [A] {
        return self.actionsStack.arrangedSubviews as! [A]
    }
    
    init(_ view: G, initialActions: [A], primary: UIColor = HomeDesign.primary) {
        self.view = view
        self.actionsStack = BasicUIStackView()
        self.actionsStack.axis = .horizontal
        self.actionsStack.alignment = .fill
        self.actionsStack.spacing = 0.0
        self.actionsStack.distribution = .fillEqually
        for action in initialActions {
            self.actionsStack.addArrangedSubview(action)
        }
        super.init()
        self.backgroundColor = HomeDesign.white
        self.layer.cornerRadius = HomeLayout.roundedGenericActionsViewRadius
        self.layer.borderWidth = HomeLayout.border
        self.layer.borderColor = primary.cgColor
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setPrimary(_ color: UIColor) {
        self.layer.borderColor = color.cgColor
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview != nil else { return }
        
        self.heightAnchor.constraint(equalToConstant: HomeLayout.roundedGenericActionsViewHeigth).isActive = true
        self.addSubview(self.view)
        self.view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: HomeLayout.roundedGenericActionsViewRadius - HomeLayout.smargin).isActive = true
        self.view.topAnchor.constraint(equalTo: self.topAnchor, constant: HomeLayout.dmargin).isActive = true
        self.view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -HomeLayout.dmargin).isActive = true
        self.addSubview(self.actionsStack)
        self.actionsStack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.dmargin).isActive = true
        self.actionsStack.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.view.trailingAnchor.constraint(equalTo: self.actionsStack.leadingAnchor, constant: -HomeLayout.smargin).isActive = true
    }
    
    fileprivate func addAction(_ action: A, animated: Bool) {
        if animated {
            HomeAnimations.animateShort({
                self.actionsStack.addArrangedSubview(action)
                self.layoutIfNeeded()
            })
        }
        else {
            self.actionsStack.addArrangedSubview(action)
        }
    }
    fileprivate func removeAction(_ action: A, animated: Bool) {
        guard let _ = self.actionsStack.arrangedSubviews.firstIndex(of: action) else {
            return
        }
        
        if animated {
            HomeAnimations.animateShort({
                self.actionsStack.removeArrangedSubview(action)
                self.layoutIfNeeded()
            })
        }
        else {
            self.actionsStack.removeArrangedSubview(action)
        }
    }
}

// MARK: -
protocol SearchFieldViewDelegate: AnyObject {
    
    func searchFieldTextUpdated(_ searchField: SearchFieldView)
    func searchFieldBeginEditing(_ searchField: SearchFieldView)
    func searchFieldEndEditing(_ searchField: SearchFieldView)
}

class SearchFieldView: RoundedGenericActionsView<BasicUITextField, ActionButtonView>, UITextFieldDelegate {
    
    final var text: String {
        get { return self.view.text! }
        set { self.view.text = newValue }
    }
    final unowned(unsafe) var delegate: SearchFieldViewDelegate!
    
    init(placeholder: String = ~"general.search", actions: [ActionButtonView]? = nil) {
        let textField = BasicUITextField()
        let searchAction = ActionButtonView(asset: .actionSearch, color: HomeDesign.primary)
        
        if actions != nil {
            super.init(textField, initialActions: [searchAction] + actions!)
        }
        else {
            super.init(textField, initialActions: [searchAction])
        }
        textField.attributedPlaceholder = .init(string: placeholder, attributes: [.foregroundColor: HomeDesign.gray, .font: HomeLayout.fontRegularMedium])
        textField.delegate = self
        searchAction.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SearchFieldView.searchButtonTapped(sender:))))
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        self.delegate.searchFieldTextUpdated(self)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.delegate.searchFieldBeginEditing(self)
        return true
    }
    
    @objc private func searchButtonTapped(sender: UITapGestureRecognizer) {
        _ = self.textFieldShouldReturn(self.view)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.delegate.searchFieldEndEditing(self)
    }
    
    @discardableResult override func resignFirstResponder() -> Bool {
        return self.textFieldShouldReturn(self.view)
    }
    
    final override func setPrimary(_ color: UIColor) {
        super.setPrimary(color)
        for actionButton in self.actionsStack.arrangedSubviews as! [ActionButtonView] {
            actionButton.primary = color
        }
    }
}

final class SearchFieldViewWithTimer: SearchFieldView {
    
    var timer: Timer! = nil
    
    override init(placeholder: String = ~"general.search", actions: [ActionButtonView]? = nil) {
        super.init(placeholder: placeholder, actions: actions)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if self.timer != nil {
            self.timer.invalidate()
        }
        self.timer = Timer.scheduledTimer(timeInterval: 0.6, target: self, selector: #selector(SearchFieldViewWithTimer.scheduledTimerFired(_:)), userInfo: nil, repeats: false)
        return true
    }
    override func textFieldDidChangeSelection(_ textField: UITextField) { }
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if self.timer != nil {
            self.timer.invalidate()
        }
        return textField.resignFirstResponder()
    }
    
    @objc func scheduledTimerFired(_ timer: Timer) {
        self.delegate.searchFieldTextUpdated(self)
    }
    
    deinit {
        self.timer?.invalidate()
    }
}

// MARK: -

protocol SelectorViewDelegate: AnyObject {
    
    func selectorSelect<E>(_ selector: SelectorView<E>)
}
protocol SelectorViewSource: RawRepresentable, Equatable {
    
    static var allValues: [Self] { get }
    static var allKeys: [String] { get }
}
protocol SelectorViewAdvancedSelectorCompatible: AnyObject {
    
    static var advancedSelectorType: DynamicAlert.AdvancedSelectorViewType { get }
    var advancedSelectorText: String { get }
}
extension IntraTitle: SelectorViewAdvancedSelectorCompatible {
    static let advancedSelectorType: DynamicAlert.AdvancedSelectorViewType = .title
    var advancedSelectorText: String { return self.name }
}
extension IntraCampus: SelectorViewAdvancedSelectorCompatible {
    static let advancedSelectorType: DynamicAlert.AdvancedSelectorViewType = .campus
    var advancedSelectorText: String { return self.name }
}
extension IntraLanguage: SelectorViewAdvancedSelectorCompatible {
    static let advancedSelectorType: DynamicAlert.AdvancedSelectorViewType = .languages
    var advancedSelectorText: String { return self.name }
}
extension IntraGroup: SelectorViewAdvancedSelectorCompatible {
    static let advancedSelectorType: DynamicAlert.AdvancedSelectorViewType = .group
    var advancedSelectorText: String { return self.name }
}

final class SelectorView<E>: RoundedGenericActionsView<BasicUILabel, ActionButtonView> {
    
    weak var delegate: SelectorViewDelegate!
    private var selectedIndex: Int?
    private let selectNoneString: String?
    private(set) var value: E!
    
    private var keys: [String]
    private var values: [E]
        
    init(keys: [String], values: [E], selectedIndex: Int? = nil, selectNoneString: String? = nil) {
        let selectButton = ActionButtonView(asset: .actionSelect, color: HomeDesign.primary)
        let removeButton: ActionButtonView!
        let text: String

        self.keys = keys
        self.values = values
        self.selectedIndex = selectedIndex
        self.selectNoneString = selectNoneString
        if selectNoneString != nil {
            self.keys.insert(selectNoneString!, at: 0)
            if selectedIndex != nil {
                self.value = values[selectedIndex!]
                text = keys[selectedIndex!]
            }
            else {
                text = selectNoneString!
            }
        }
        else {
            if keys.count > 0 {
                self.value = values[selectedIndex ?? 0]
                text = keys[selectedIndex ?? 0]
            }
            else {
                self.value = nil
                text = "---"
            }
        }
        if selectNoneString != nil && E.self is any SelectorViewAdvancedSelectorCompatible.Type {
            removeButton = .init(asset: .actionClose, color: HomeDesign.primary)
            removeButton.isHidden = selectedIndex == nil
            super.init(BasicUILabel(text: text), initialActions: [removeButton, selectButton])
        }
        else {
            removeButton = nil
            super.init(BasicUILabel(text: text), initialActions: [selectButton])
        }
        self.view.adjustsFontSizeToFitWidth = true
        self.view.textColor = HomeDesign.black
        selectButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SelectorView<E>.selectButtonTapped(sender:))))
        removeButton?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SelectorView<E>.closeButtonTapped(sender:))))
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
    @objc private func selectButtonTapped(sender: UITapGestureRecognizer) {
        let primary = self.actionViews[0].primary
        
        if self.keys.count == 0 {
            DynamicAlert.init(.withPrimary(~"general.impossible", primary), contents: [.text(~"no-selection-available")], actions: [.normal(~"general.ok", nil)])
        }
        else if E.self is any SelectorViewAdvancedSelectorCompatible.Type {
            let actions: [DynamicAlert.Action]
            
            func selectValue(_ index: Int, _ value: E) {
                self.value = value
                self.selectedIndex = index
                self.view.text = (value as! any SelectorViewAdvancedSelectorCompatible).advancedSelectorText
                if self.selectNoneString != nil {
                    self.actionViews[0].isHidden = false
                }
                self.delegate?.selectorSelect(self)
            }
            
            if self.selectNoneString == nil {
                actions = [.getAdvancedSelector(unsafeBitCast(selectValue, to: ((Int, Any) -> ()).self))]
            }
            else {
                actions = [.normal(~"general.cancel", nil), .getAdvancedSelector(unsafeBitCast(selectValue, to: ((Int, Any) -> ()).self))]
            }
            DynamicAlert.init(.noneWithPrimary(primary),
                              contents: [.advancedSelector((E.self as! any SelectorViewAdvancedSelectorCompatible.Type).advancedSelectorType, self.values, self.selectedIndex ?? 0)],
                              actions: actions)
        }
        else {
            DynamicAlert.init(.noneWithPrimary(primary), contents: [.roulette(self.keys, self.selectedIndex ?? 0)], actions: [.getRoulette(~"general.select", { index, text in
                if self.selectNoneString != nil && index == 0 {
                    self.value = nil
                    self.selectedIndex = nil
                    self.view.text = self.selectNoneString
                    self.delegate?.selectorSelect(self)
                }
                else {
                    self.selectedIndex = index
                    self.value = self.values[self.selectNoneString == nil ? index : index - 1]
                    self.view.text = text
                    self.delegate?.selectorSelect(self)
                }
            })])
        }
    }
    
    @objc private func closeButtonTapped(sender: UITapGestureRecognizer) {
        self.value = nil
        self.selectedIndex = nil
        self.view.text = self.selectNoneString
        sender.view!.isHidden = true
        self.delegate?.selectorSelect(self)
    }
    
    func update(keys: [String], values: [E], selectedIndex: Int? = nil) {
        let text: String
        
        self.keys = keys
        self.values = values
        self.selectedIndex = selectedIndex
        if selectNoneString != nil {
            self.keys.insert(selectNoneString!, at: 0)
            if selectedIndex != nil {
                self.value = values[selectedIndex!]
                text = keys[selectedIndex! - 1]
            }
            else {
                self.value = nil
                text = selectNoneString!
            }
            if E.self is any SelectorViewAdvancedSelectorCompatible.Type {
                self.actionViews[0].isHidden = self.selectedIndex != nil
            }
        }
        else {
            if keys.count > 0 {
                self.value = values[selectedIndex ?? 0]
                text = keys[selectedIndex ?? 0]
            }
            else {
                self.value = nil
                text = "---"
            }
        }
        self.view.text = text
    }
    
    override func setPrimary(_ color: UIColor) {
        super.setPrimary(color)
        for actionButton in self.actionsStack.arrangedSubviews as! [ActionButtonView] {
            actionButton.primary = color
        }
    }
}

// MARK: -

protocol ValueSelectorWithArrowsDelegate: AnyObject {
    func valueSelectorChanged()
}

final class ValueSelectorWithArrows<V: Comparable & Numeric>: RoundedGenericActionsView<BasicUILabel, ActionButtonView> {
    
    private(set) var min: V
    private(set) var max: V
    private(set) var step: V
    private(set) var value: V
    private let leftArrow: ActionButtonView = ActionButtonView(asset: .actionArrowLeft, color: HomeDesign.primary)
    private let rigthArrow: ActionButtonView = ActionButtonView(asset: .actionArrowRight, color: HomeDesign.primary)
    
    @frozen enum TextDisplay {
        case normal
        case time
        case usingPrefix(String)
        case usingSuffix(String)
    }
    private let textDisplay: TextDisplay
    
    weak var delegate: ValueSelectorWithArrowsDelegate? = nil
    
    init(min: V, max: V, step: V, value: V, textDisplay: TextDisplay = .normal) {
        self.min = min
        self.max = max
        self.step = step
        self.value = value
        self.textDisplay = textDisplay
        if value <= min {
            self.leftArrow.isUserInteractionEnabled = true
        }
        if value >= max {
            self.rigthArrow.isUserInteractionEnabled = true
        }
        super.init(BasicUILabel(text: "???"), initialActions: [self.leftArrow, self.rigthArrow])
        self.view.textColor = HomeDesign.black
        self.view.text = self.valueText
        self.leftArrow.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ValueSelectorWithArrows<V>.arrowTapped(sender:))))
        self.rigthArrow.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ValueSelectorWithArrows<V>.arrowTapped(sender:))))
        self.leftArrow.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(ValueSelectorWithArrows<V>.arrowPressed(sender:))))
        self.rigthArrow.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(ValueSelectorWithArrows<V>.arrowPressed(sender:))))
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    var valueText: String {
        switch self.textDisplay {
        case .time:
            return (self.value as! TimeInterval).toString {
                $0.unitsStyle = .full
                $0.collapsesLargestUnit = false
                $0.allowsFractionalUnits = true
            }
        case .usingPrefix(let prefix):
            return "\(prefix)\(self.value)"
        case .usingSuffix(let suffix):
            return "\(suffix)\(self.value)"
        default:
            return "\(self.value)"
        }
    }
    
    func update(min: V, max: V, step: V, value: V) {
        self.min = min
        self.max = max
        self.step = step
        self.value = value
        if value <= min {
            self.leftArrow.isUserInteractionEnabled = true
        }
        if value >= max {
            self.rigthArrow.isUserInteractionEnabled = true
        }
        self.view.text = self.valueText
    }
    
    //@_specialize(where V == Int)
    //@_specialize(where V == TimeInterval) swift compiler with whole module opti enabled crash on it ...
    @objc private func arrowTapped(sender: UITapGestureRecognizer) {
        if (sender.view as! ActionButtonView) == self.leftArrow {
            self.value -= self.step
            if self.value == min {
                self.leftArrow.isUserInteractionEnabled = false
            }
            self.rigthArrow.isUserInteractionEnabled = true
        }
        else {
            self.value += self.step
            if self.value == max {
                self.rigthArrow.isUserInteractionEnabled = false
            }
            self.leftArrow.isUserInteractionEnabled = true
        }
        self.view.text = self.valueText
        self.delegate?.valueSelectorChanged()
    }
    
    @objc private func arrowPressed(sender: UILongPressGestureRecognizer) {
        print(sender.state, sender.delaysTouchesBegan)
    }
}

protocol UserSearchFieldViewDelegate: AnyObject {
    func userSearchFieldViewSelect(view: UserSearchFieldView, user: IntraUserInfo)
}

final class UserSearchFieldView: RoundedGenericActionsView<UserSearchFieldView.UserIconLoginView, ActionButtonView> {
    
    private let seeAction: ActionButtonView
    
    private(set) var user: IntraUserInfo?
    unowned(unsafe) let primary: UIColor
    weak var delegate: UserSearchFieldViewDelegate? = nil
    
    init(user: IntraUserInfo? = nil, primary: UIColor) {
        self.user = user
        self.primary = primary
        self.seeAction = ActionButtonView(asset: .actionSee, color: primary)
        self.seeAction.isUserInteractionEnabled = self.user != nil
        super.init(UserIconLoginView(user: user, primary: primary), initialActions: [self.seeAction, ActionButtonView(asset: .actionSearch, color: primary)], primary: primary)
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UserSearchFieldView.tapGesture(sender:))))
        self.seeAction.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UserSearchFieldView.seeTapGesture(sender:))))
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func update(with user: IntraUserInfo?) {
        self.user = user
        self.view.update(with: user)
    }
    
    @objc private func seeTapGesture(sender: UITapGestureRecognizer) {
        if let user = user {
            let profil = ProfilViewController()
            
            Task.init(priority: .userInitiated, operation: {
                await profil.setupWithUser(user.login, id: user.id)
            })
            self.parentHomeViewController?.presentWithBlur(profil, completion: nil)
        }
    }
    
    @objc private func tapGesture(sender: UITapGestureRecognizer) {
        let block: (IntraUserInfo) -> () = { user in
            self.update(with: user)
            self.delegate?.userSearchFieldViewSelect(view: self, user: user)
        }
        
        DynamicAlert(.noneWithPrimary(self.primary), contents: [.usersSelector(self.user, block)], actions: [.normal(~"general.cancel", nil)])
    }
    
    final class UserIconLoginView: BasicUIView {
        
        private let icon: UserProfilIconView
        private let loginLabel: BasicUILabel
        
        init(user: IntraUserInfo?, primary: UIColor) {
            if let user = user {
                self.icon = UserProfilIconView(user: user)
                self.loginLabel = BasicUILabel(text: user.login)
            }
            else {
                self.icon = UserProfilIconView()
                self.loginLabel = BasicUILabel(text: ~"general.login") // make text grey placeholder ?
            }
            //self.icon.layer.borderWidth = HomeLayout.sborder
            //self.icon.layer.borderColor = primary.cgColor
            self.loginLabel.font = HomeLayout.fontRegularMedium
            self.loginLabel.textColor = HomeDesign.black
            self.loginLabel.textAlignment = .left
            self.loginLabel.adjustsFontSizeToFitWidth = true
            super.init()
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else {
                return
            }
            
            self.addSubview(self.icon)
            self.icon.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            self.icon.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            self.icon.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: -(HomeLayout.margin - HomeLayout.border)).isActive = true
            self.icon.widthAnchor.constraint(equalTo: self.icon.heightAnchor).isActive = true
            self.addSubview(self.loginLabel)
            self.loginLabel.leadingAnchor.constraint(equalTo: self.icon.trailingAnchor, constant: HomeLayout.dmargin).isActive = true
            self.loginLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            self.loginLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: HomeLayout.smargin).isActive = true
        }
        
        override func draw(_ rect: CGRect) {
            super.draw(rect)
            self.icon.layer.cornerRadius = self.icon.bounds.width / 2.0
            self.icon.layer.masksToBounds = true
        }
        
        fileprivate func update(with user: IntraUserInfo?) {
            if let user = user {
                self.loginLabel.text = user.login
                self.icon.update(with: user)
            }
            else {
                self.loginLabel.text = ~"general.login"
                self.icon.reset()
            }
        }
    }
}

protocol DateSelectorViewDelegate: AnyObject {
    
    func dateSelectorViewSelect(_ date: Date!)
}

final class DateSelectorView: RoundedGenericActionsView<BasicUILabel, ActionButtonView> {
    
    static private let emptyDateString: String = "--/--/--"
 
    private let closeAction: ActionButtonView!
    private let dateAction: ActionButtonView
    
    var date: Date! {
        didSet {
            self.view.text = self.date?.toString(.dateSelectorWithSlashs) ?? Self.emptyDateString
            self.closeAction?.isHidden = date == nil
        }
    }
    weak var delegate: DateSelectorViewDelegate? = nil
    
    init(date: Date!, canBeNull: Bool, primary: UIColor = HomeDesign.primary) {
        self.dateAction = .init(asset: .actionCalendar, color: primary)
        self.date = date
        if canBeNull {
            self.closeAction = .init(asset: .actionClose, color: primary)
            self.closeAction.isHidden = date == nil
            super.init(BasicUILabel(text: date?.toString(.dateSelectorWithSlashs) ?? Self.emptyDateString), initialActions: [closeAction, dateAction], primary: primary)
        }
        else {
            self.closeAction = nil
            super.init(BasicUILabel(text: date.toString(.dateSelectorWithSlashs)), initialActions: [dateAction], primary: primary)
        }
        self.view.textColor = HomeDesign.black
        if canBeNull {
            self.closeAction.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(DateSelectorView.closeActionTapped)))
        }
        self.dateAction.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(DateSelectorView.dateActionTapped)))
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    @objc private func closeActionTapped() {
        self.date = nil
        self.view.text = Self.emptyDateString
        self.closeAction.isHidden = true
        self.delegate?.dateSelectorViewSelect(nil)
    }
    
    private func dateSelected(_ date: Date) {
        print(#function, date.toString(.comprehensive))
        self.date = date
        self.view.text = date.toString(.dateSelectorWithSlashs)
        self.delegate?.dateSelectorViewSelect(date)
    }
    
    @objc private func dateActionTapped() {
        DynamicAlert(.none, contents: [.dateSelector(self.date ?? Date())], actions: [.normal(~"general.cancel", nil), .dateSelector(self.dateSelected(_:))])
    }
    
    override func setPrimary(_ color: UIColor) {
        super.setPrimary(color)
    }
}
