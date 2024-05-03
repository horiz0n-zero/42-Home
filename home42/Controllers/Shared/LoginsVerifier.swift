// home42/LoginsVerifier.swift
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

final class LoginsVerifierViewController: HomeViewController, UIDocumentPickerDelegate {

    fileprivate struct Condition {
        let titleKey: String
        let descriptionKey: String
        let viewClass: ConditionView.Type
        typealias Validator = ((inout Condition.Context, UIView) async throws -> Bool)
        let validator: Validator
        
        init(_ titleKey: String, _ descriptionKey: String, _ viewClass: ConditionView.Type, validator: @escaping Validator) {
            self.titleKey = titleKey
            self.descriptionKey = descriptionKey
            self.viewClass = viewClass
            self.validator = validator
        }
        
        struct Context {
            var user: IntraUser!
            var userCoalitions: [IntraCoalition]!
                        
            mutating func clear(withUser user: IntraUser) {
                self.user = user
                self.userCoalitions = nil
            }
        }
    }
    private static let conditions: [Condition] = [
        .init("cond.blackhole.title", "cond.blackhole.desc", ConditionViewBoolean.self, validator: unsafeBitCast(implBlackHole(ctx:inputView:), to: Condition.Validator.self)),
        .init("cond.coa.title", "cond.coa.desc", ConditionViewBase<SelectorCoalitions>.self, validator: unsafeBitCast(implContainCoa(ctx:inputView:), to: Condition.Validator.self)),
        .init("cond.campus.title", "cond.campus.desc", ConditionViewBase<SelectorCampus>.self, validator: unsafeBitCast(implBelongCampus(ctx:inputView:), to: Condition.Validator.self)),
        .init("cond.notcampus.title", "cond.notcampus.desc", ConditionViewBase<SelectorCampus>.self, validator: unsafeBitCast(implBelongNotCampus(ctx:inputView:), to: Condition.Validator.self)),
        .init("cond.alumni.title", "cond.alumni.desc", ConditionViewBoolean.self, validator: unsafeBitCast(implAlumni(ctx:inputView:), to: Condition.Validator.self))
    ]
    
    static private func implBlackHole(ctx: inout Condition.Context, inputView: ConditionViewBoolean) async throws -> Bool {
        if inputView.valueView.isOn {

        }
        return true
    }
    
    static private func implContainCoa(ctx: inout Condition.Context, inputView: ConditionViewBase<SelectorCoalitions>) async throws -> Bool {
        if let selection = inputView.valueView.value {
            if ctx.userCoalitions == nil {
                ctx.userCoalitions = try await HomeApi.get(.usersWithUserIdCoalitions(ctx.user.id))
            }
            return ctx.userCoalitions.contains(where: { $0.id == selection.id })
        }
        return true
    }
    
    static private func implBelongCampus(ctx: inout Condition.Context, inputView: ConditionViewBase<SelectorCampus>) async throws -> Bool {
        if let selection = inputView.valueView.value {
            return ctx.user.campus.contains(where: { $0.id == selection.id })
        }
        return true
    }
    
    static private func implBelongNotCampus(ctx: inout Condition.Context, inputView: ConditionViewBase<SelectorCampus>) async throws -> Bool {
        if let selection = inputView.valueView.value {
            return !ctx.user.campus.contains(where: { $0.id == selection.id })
        }
        return true
    }
    
    static private func implAlumni(ctx: inout Condition.Context, inputView: ConditionViewBoolean) async throws -> Bool {
        if inputView.valueView.isOn {
            return ctx.user.is_alumni ?? false
        }
        return !(ctx.user.is_alumni ?? true)
    }
    
    private let header: HeaderWithActionsBase
    var headerTitle: String {
        set { self.header.title = newValue }
        get { return self.header.title }
    }
    private let contentView: BasicUIScrollView
    
    private let stateView: StateView
    private let conditionViews: BasicUIStackView
    private let addConditionView: AddConditionView
    private let copyableValidView, copyableFailureView, copyableUnknowView: CopyableContentView
    
    private var logins: ContiguousArray<String>!
    
    required init() {
        let exportButton = ActionButtonView(asset: .actionShare, color: HomeDesign.greenSuccess)
        let importButton = ActionButtonView(asset: .actionImport, color: HomeDesign.blueAccess)
        var contentTop: NSLayoutYAxisAnchor

        self.header = HeaderWithActionsView(title: ~"login-verifier", actions: [importButton, exportButton])
        self.header.backgroundColor = HomeDesign.lightGray
        self.contentView = .init()
        self.contentView.contentInsetAdjustmentBehavior = .never
        self.contentView.contentInset = .init(top: HomeLayout.safeAeraMain.top, left: 0.0, bottom: 0.0, right: 0.0)
        contentTop = self.contentView.topAnchor
        self.stateView = .init()
        self.conditionViews = .init()
        self.conditionViews.alignment = .fill
        self.conditionViews.spacing = HomeLayout.smargin
        self.conditionViews.axis = .vertical
        self.conditionViews.distribution = .equalSpacing
        for condition in Self.conditions {
            self.conditionViews.addArrangedSubview(condition.viewClass.init(condition: condition))
        }
        self.addConditionView = .init()
        self.copyableValidView = .init(title: ~"login-verifier.copyable.valid", primaryColor: HomeDesign.actionGreen)
        self.copyableFailureView = .init(title: ~"login-verifier.copyable.failure", primaryColor: HomeDesign.actionRed)
        self.copyableUnknowView = .init(title: ~"login-verifier.copyable.unknow", primaryColor: HomeDesign.actionOrange)
        super.init()
        self.view.backgroundColor = HomeDesign.white
        exportButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LoginsVerifierViewController.shareAction)))
        importButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LoginsVerifierViewController.importAction)))
        
        self.view.addSubview(self.contentView)
        self.contentView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.contentView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.contentView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.contentView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        for subview in [self.conditionViews, self.addConditionView, self.stateView, self.copyableValidView, self.copyableFailureView, self.copyableUnknowView] {
            self.contentView.addSubview(subview)
            if subview is CopyableContentView {
                subview.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: HomeLayout.margin).isActive = true
                subview.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true
                subview.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - (HomeLayout.margin * 2.0)).isActive = true
            }
            else {
                subview.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
                subview.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
                subview.widthAnchor.constraint(equalTo: self.contentView.widthAnchor).isActive = true
            }
            subview.topAnchor.constraint(equalTo: contentTop, constant: HomeLayout.margins).isActive = true
            contentTop = subview.bottomAnchor
        }
        self.copyableValidView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * HomeLayout.imageViewHeightRatio).isActive = true
        self.copyableFailureView.heightAnchor.constraint(equalTo: self.copyableValidView.heightAnchor, multiplier: 1.0).isActive = true
        self.copyableUnknowView.heightAnchor.constraint(equalTo: self.copyableValidView.heightAnchor, multiplier: 1.0).isActive = true
        self.contentView.bottomAnchor.constraint(greaterThanOrEqualTo: contentTop, constant: HomeLayout.safeAera.bottom).isActive = true
        self.view.addSubview(self.header)
        self.header.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.header.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.header.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
    }
    required init?(coder: NSCoder) { fatalError() }
    
    private func startProcess() async throws {
        var conditionResult: Bool = true
        var ctx = Condition.Context()
        
        self.copyableValidView.clear()
        self.copyableFailureView.clear()
        self.copyableUnknowView.clear()
        for (index, login) in self.logins.enumerated() {
            do {
                self.stateView.setProgress(now: index &+ 1, end: self.logins.count)
                ctx.clear(withUser: try await HomeApi.get(.userWithLogin(login)))
                for conditionView in self.conditionViews.arrangedSubviews as! [ConditionView] {
                    conditionResult = try await conditionView.condition.validator(&ctx, conditionView)
                    if !conditionResult {
                        break
                    }
                }
                if !conditionResult {
                    self.copyableFailureView.write("\(login)\n")
                }
                else {
                    self.copyableValidView.write("\(login)\n")
                }
            }
            catch {
                switch (error as! HomeApi.RequestError).status {
                case .cancel:
                    break
                default:
                    self.copyableUnknowView.write("\(login)\n")
                }
                throw error
            }
        }
        self.stateView.state = .ready
    }
    
    @objc private func shareAction() {
        
    }
    
    @objc private func importAction() {
        switch self.stateView.state {
        case .waitingForImport, .ready:
            let documentViewController = UIDocumentPickerViewController.init(forOpeningContentTypes: [.plainText, .text, .content])
            
            documentViewController.delegate = self
            documentViewController.allowsMultipleSelection = false
            documentViewController.shouldShowFileExtensions = true
            self.present(documentViewController, animated: true)
        case .importing, .processing:
            DynamicAlert(contents: [.title(~"login-verifier.error.operation-running")], actions: [.normal(~"general.ok", nil)])
        }
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        self.stateView.state = .importing
        do {
            let location = urls.first!
            let data: String
            let lines: [String.SubSequence]
            let regex = try NSRegularExpression(pattern: "^[a-z0-9-]+$")
            
            if location.startAccessingSecurityScopedResource() {
                data = try String(contentsOf: location)
                lines = data.split(separator: "\n")
                
                self.logins = []
                self.logins.reserveCapacity(lines.count)
                for (index, line) in lines.enumerated() {
                    self.logins.append(String(line))
                    if regex.firstMatch(in: self.logins.last!, range: NSMakeRange(0, self.logins.last!.count)) == nil {
                        throw HomeApi.RequestError(status: .internal, path: "", data: nil, parameters: nil, serverMessage: "login au format invalid: \(self.logins.last!)")
                    }
                }
                self.stateView.state = .ready
            }
            else {
                self.stateView.state = .waitingForImport
                throw HomeApi.RequestError(status: .internal, path: "", data: nil, parameters: nil, serverMessage: "file: access denied")
            }
            
            location.stopAccessingSecurityScopedResource()
        }
        catch {
            if error is HomeApi.RequestError {
                DynamicAlert.presentWith(error: error as! HomeApi.RequestError)
            }
            self.stateView.state = .waitingForImport
            #if DEBUG
            print(#function, #line, error)
            #endif
        }
    }
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) { }
}

extension LoginsVerifierViewController {
    
    private class StateView: BasicUIView {
        
        enum State {
            case waitingForImport
            case importing
            case ready
            case processing
        }
        var state: StateView.State = .waitingForImport {
            didSet {
                HomeAnimations.transitionQuick(withView: self, {
                    switch self.state {
                    case .waitingForImport:
                        self.stateLabel.text = ~"login-verifier.state.waiting-import"
                        self.actionPlayPause.set(asset: .actionLock, color: HomeDesign.gray)
                    case .importing:
                        self.stateLabel.text = ~"login-verifier.state.importing"
                        self.actionPlayPause.set(asset: .actionLock, color: HomeDesign.gray)
                    case .ready:
                        self.stateLabel.text =  String.init(format: ~"login-verifier.state.ready", (self.parentViewController as! LoginsVerifierViewController).logins.count)
                        self.actionPlayPause.set(asset: .actionAdd, color: HomeDesign.actionGreen)
                    default:
                        self.actionPlayPause.set(asset: .actionSee, color: HomeDesign.actionOrange)
                    }
                })
            }
        }
        func setProgress(now: Int, end: Int) {
            HomeAnimations.transitionQuick(withView: self.stateLabel, {
                self.stateLabel.text = "\(now) / \(end)"
            })
        }
        
        private var borderView: BasicUIView
        private var stateLabel: BasicUILabel
        private var actionPlayPause: ActionButtonView
        private var process: Task<(), Never>!
        
        override init() {
            self.borderView = BasicUIView()
            self.borderView.layer.cornerRadius = HomeLayout.corner
            self.borderView.backgroundColor = HomeDesign.lightGray
            self.stateLabel = .init(text: ~"login-verifier.state.waiting-import")
            self.stateLabel.font = HomeLayout.fontSemiBoldMedium
            self.stateLabel.textColor = HomeDesign.black
            self.stateLabel.numberOfLines = 1
            self.stateLabel.adjustsFontSizeToFitWidth = true
            self.actionPlayPause = .init(asset: .actionLock, color: HomeDesign.gray)
            super.init()
            self.actionPlayPause.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(playPauseTapped)))
        }
        required init?(coder: NSCoder) { fatalError() }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else {
                return
            }
            
            self.addSubview(self.borderView)
            self.borderView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            self.borderView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: HomeLayout.margin).isActive = true
            self.borderView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.margin).isActive = true
            self.borderView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            self.borderView.addSubview(self.actionPlayPause)
            self.actionPlayPause.leadingAnchor.constraint(equalTo: self.borderView.leadingAnchor, constant: HomeLayout.margin).isActive = true
            self.actionPlayPause.topAnchor.constraint(equalTo: self.borderView.topAnchor, constant: HomeLayout.margin).isActive = true
            self.actionPlayPause.bottomAnchor.constraint(equalTo: self.borderView.bottomAnchor, constant: -HomeLayout.margin).isActive = true
            self.borderView.addSubview(self.stateLabel)
            self.stateLabel.centerYAnchor.constraint(equalTo: self.actionPlayPause.centerYAnchor).isActive = true
            self.stateLabel.leadingAnchor.constraint(equalTo: self.actionPlayPause.trailingAnchor, constant: HomeLayout.margin).isActive = true
            self.stateLabel.trailingAnchor.constraint(equalTo: self.borderView.trailingAnchor, constant: -HomeLayout.margin).isActive = true
        }
        
        @objc private func playPauseTapped() {
            
            func stopProcess() {
                self.process?.cancel()
                self.state = .ready
            }
            
            switch self.state {
            case .waitingForImport, .importing:
                break
            case .ready:
                if let parent = self.parentViewController as? LoginsVerifierViewController {
                    self.state = .processing
                    self.process = Task {
                        do {
                            try await parent.startProcess()
                        }
                        catch {
                            DynamicAlert.presentWith(error: error as! HomeApi.RequestError)
                        }
                    }
                }
            case .processing:
                DynamicAlert(contents: [.title(~"login-verifier.action.stop")], actions: [.normal(~"general.cancel", nil), .highligth(~"general.ok", stopProcess)])
            }
        }
    }
    
    private class AddConditionView: BasicUIView {
        
        private let borderView: BasicUIView
        private let titleLabel: BasicUILabel

        override init() {
            self.borderView = BasicUIView()
            self.borderView.layer.cornerRadius = HomeLayout.corner
            self.borderView.backgroundColor = HomeDesign.lightGray
            self.titleLabel = BasicUILabel(text: "ajouter une condition")
            self.titleLabel.font = HomeLayout.fontSemiBoldMedium
            self.titleLabel.textColor = HomeDesign.black
            self.titleLabel.numberOfLines = 1
            self.titleLabel.textAlignment = .center
            self.titleLabel.adjustsFontSizeToFitWidth = true
            super.init()
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }
            
            self.addSubview(self.borderView)
            self.borderView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            self.borderView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: HomeLayout.margin).isActive = true
            self.borderView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.margin).isActive = true
            self.borderView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
            self.borderView.addSubview(self.titleLabel)
            self.titleLabel.topAnchor.constraint(equalTo: self.borderView.topAnchor, constant: HomeLayout.margin).isActive = true
            self.titleLabel.leadingAnchor.constraint(equalTo: self.borderView.leadingAnchor, constant: HomeLayout.margin).isActive = true
            self.titleLabel.centerYAnchor.constraint(equalTo: self.borderView.centerYAnchor).isActive = true
            self.titleLabel.centerXAnchor.constraint(equalTo: self.borderView.centerXAnchor).isActive = true
        }
    }
}

fileprivate protocol ConditionView: UIView {
    
    var condition: LoginsVerifierViewController.Condition { get }
    init(condition: LoginsVerifierViewController.Condition)
}
fileprivate protocol ConditionViewParameterView: UIView {
    
    init(condition: LoginsVerifierViewController.Condition)
}

extension LoginsVerifierViewController {
    
    private class ConditionViewBase<V: ConditionViewParameterView>: BasicUIView, ConditionView {
        
        private let borderView: BasicUIView
        private let titleLabel: BasicUILabel
        private let descriptionLabel: BasicUILabel
        private let deleteButtonView: ActionButtonView
        fileprivate let valueView: V
        fileprivate let condition: Condition

        required init(condition: LoginsVerifierViewController.Condition) {
            self.borderView = BasicUIView()
            self.borderView.layer.cornerRadius = HomeLayout.corner
            self.borderView.backgroundColor = HomeDesign.lightGray
            self.titleLabel = BasicUILabel(text: ~condition.titleKey)
            self.titleLabel.font = HomeLayout.fontSemiBoldMedium
            self.titleLabel.textColor = HomeDesign.black
            self.titleLabel.numberOfLines = 1
            self.titleLabel.adjustsFontSizeToFitWidth = true
            self.descriptionLabel = BasicUILabel(text: ~condition.descriptionKey)
            self.descriptionLabel.font = HomeLayout.fontRegularMedium
            self.descriptionLabel.textColor = HomeDesign.blackGray
            self.descriptionLabel.numberOfLines = 0
            self.deleteButtonView = .init(asset: .actionTrash, color: UIColor.clear)
            self.deleteButtonView.iconTintColor = HomeDesign.actionRed
            self.deleteButtonView.removeBorderWidth()
            self.condition = condition
            self.valueView = V(condition: condition)
            super.init()
            self.deleteButtonView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(deleteView)))
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }
            
            self.addSubview(self.borderView)
            self.borderView.topAnchor.constraint(equalTo: self.topAnchor, constant: HomeLayout.margin).isActive = true
            self.borderView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: HomeLayout.margin).isActive = true
            self.borderView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.margin).isActive = true
            self.addSubview(self.valueView)
            self.valueView.centerYAnchor.constraint(equalTo: self.borderView.bottomAnchor).isActive = true
            self.valueView.trailingAnchor.constraint(equalTo: self.borderView.trailingAnchor, constant: -HomeLayout.margin).isActive = true
            self.valueView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -HomeLayout.smargin).isActive = true
            self.borderView.addSubview(self.titleLabel)
            self.titleLabel.topAnchor.constraint(equalTo: self.borderView.topAnchor, constant: HomeLayout.margin).isActive = true
            self.titleLabel.leadingAnchor.constraint(equalTo: self.borderView.leadingAnchor, constant: HomeLayout.margin).isActive = true
            self.borderView.addSubview(self.deleteButtonView)
            self.deleteButtonView.centerYAnchor.constraint(equalTo: self.titleLabel.centerYAnchor).isActive = true
            self.deleteButtonView.trailingAnchor.constraint(equalTo: self.borderView.trailingAnchor, constant: -HomeLayout.smargin).isActive = true
            self.titleLabel.trailingAnchor.constraint(greaterThanOrEqualTo: self.deleteButtonView.leadingAnchor, constant: -HomeLayout.margin).isActive = true
            self.borderView.addSubview(self.descriptionLabel)
            self.descriptionLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: HomeLayout.margin).isActive = true
            self.descriptionLabel.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor).isActive = true
            self.descriptionLabel.centerXAnchor.constraint(equalTo: self.borderView.centerXAnchor).isActive = true
            self.descriptionLabel.bottomAnchor.constraint(equalTo: self.valueView.topAnchor, constant: 0.0).isActive = true
        }
        
        @objc private func deleteView() {
            let parent = self.parentViewController as! LoginsVerifierViewController
            
            self.isUserInteractionEnabled = false
            HomeAnimations.animateQuick({
                self.alpha = 0.0
            }, completion: { _ in
                HomeAnimations.animateQuick({
                    parent.conditionViews.removeArrangedSubview(self)
                    parent.view.layoutIfNeeded()
                })
            })
        }
    }
    
    final private class ConditionViewBoolean: ConditionViewBase<HomeSwitch> { }
    final private class SelectorCoalitions: SelectorView<IntraCoalition>, ConditionViewParameterView {
        
        required convenience init(condition: LoginsVerifierViewController.Condition) {
            let coalitions: [IntraCoalition] = HomeApiResources.blocs.reduce([], { array, bloc in
                return array + bloc.coalitions
            })
            
            self.init(keys: coalitions.map({ $0.name }), values: coalitions)
        }
    }
    final private class SelectorCampus: SelectorView<IntraCampus>, ConditionViewParameterView {
        
        required convenience init(condition: LoginsVerifierViewController.Condition) {
            self.init(keys: HomeApiResources.campus.map({ $0.name }), values: Array(HomeApiResources.campus))
        }
    }
}

extension HomeSwitch: ConditionViewParameterView {
    
    fileprivate convenience init(condition: LoginsVerifierViewController.Condition) {
        self.init()
    }
}
