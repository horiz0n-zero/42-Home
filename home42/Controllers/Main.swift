// home42/Main.swift
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

class HomeViewController: UIViewController, UIViewControllerTransitioningDelegate {
        
    override var prefersStatusBarHidden: Bool { true }
    
    required init() { super.init(nibName: nil, bundle: nil) }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return HomeAnimations()
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return HomeAnimations()
    }
    
    static private(set) var depth: Int = 2
    
    func presentWithBlur(_ vc: HomeViewController, completion: (() -> Void)? = nil) {
        vc.modalPresentationStyle = .fullScreen
        vc.transitioningDelegate = self
        self.present(vc, animated: true, completion: completion)
    }
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        super.present(viewControllerToPresent, animated: flag, completion: completion)
        HomeViewController.depth &+= 1
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        HomeViewController.depth &-= 1
    }
    
    func dismissToRootController(animated: Bool, completion: (() -> Void)? = nil) {
        var parent = self.presentingViewController ?? self
        
        while parent != App.mainController.controller && parent.presentingViewController != nil {
            parent = parent.presentingViewController!
        }
        parent.dismiss(animated: animated, completion: completion)
        HomeViewController.depth = 1
    }
}

final class MainViewController: HomeViewController {
    
    private let background: BasicUIImageView
    
    private let selectionIcon: SelectionIcon
    private let selectionLabel: SelectionLabel
    private let userIcon: UserProfilIconView
    private let blurBackground: BasicUIVisualEffectView?
    
    private let controllerContainer: BasicUIView
    private(set) var controller: HomeViewController!
    
    required init() {
        
        self.background = BasicUIImageView(asset: .coalitionDefaultBackground)
        self.selectionIcon = SelectionIcon(asset: .controllerMystere)
        self.selectionLabel = SelectionLabel(text: "???")
        self.userIcon = UserProfilIconView()
        self.blurBackground = App.settings.graphicsBlurHeader ? BasicUIVisualEffectView() : nil
        self.controllerContainer = BasicUIView()
        
        super.init()
        
        self.view.addSubview(self.background)
        if App.settings.graphicsUseParallax {
            self.background.setUpParallaxEffect(usingAmout: App.settings.graphicsParallaxForce.rawValue)
            self.background.setUpParallaxConstraint(usingParent: self.view)
        }
        else {
            self.background.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
            self.background.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
            self.background.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            self.background.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        }
        
        self.view.addSubview(self.controllerContainer)
        self.controllerContainer.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.controllerContainer.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.controllerContainer.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.controllerContainer.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        if let blurBackground = self.blurBackground {
            self.view.addSubview(blurBackground)
            blurBackground.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            blurBackground.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
            blurBackground.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
            blurBackground.heightAnchor.constraint(equalToConstant: HomeLayout.safeAeraMain.top).isActive = true
        }
        self.view.addSubview(self.selectionLabel)
        self.view.addSubview(self.selectionIcon)
        self.selectionIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectionIconTapped(sender:))))
        self.selectionIcon.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: HomeLayout.margins).isActive = true
        self.selectionIcon.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: HomeLayout.margins).isActive = true
        self.selectionLabel.centerYAnchor.constraint(equalTo: self.selectionIcon.centerYAnchor).isActive = true
        self.selectionLabel.leadingAnchor.constraint(equalTo: self.selectionIcon.trailingAnchor,
                                                     constant: -HomeLayout.margins).isActive = true
        self.view.addSubview(self.userIcon)
        self.userIcon.centerYAnchor.constraint(equalTo: self.selectionIcon.centerYAnchor).isActive = true
        self.userIcon.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -HomeLayout.margins).isActive = true
        self.userIcon.setSize(HomeLayout.userProfilIconMainHeigth, HomeLayout.userProfilIconMainRadius)
        self.userIcon.isUserInteractionEnabled = true
        self.userIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userIconTapped(sender:))))
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: -
    private func controllerSet(_ controller: HomeViewController) {
        controller.view.frame = UIScreen.main.bounds
        
        self.addChild(controller)
        self.controllerContainer.addSubview(controller.view)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        controller.view.topAnchor.constraint(equalTo: self.controllerContainer.topAnchor).isActive = true
        controller.view.leadingAnchor.constraint(equalTo: self.controllerContainer.leadingAnchor).isActive = true
        controller.view.trailingAnchor.constraint(equalTo: self.controllerContainer.trailingAnchor).isActive = true
        controller.view.bottomAnchor.constraint(equalTo: self.controllerContainer.bottomAnchor).isActive = true
        controller.didMove(toParent: self)
    }
    
    private func controllerSwitch( _ controllerRepresentation: MainViewController.ControllerRepresentation, animate: Bool) {
        let oldController: HomeViewController = self.controller
        let controller: HomeViewController
        
        controller = controllerRepresentation.type.init()
        controller.view.frame = UIScreen.main.bounds
        controller.modalPresentationStyle = .overCurrentContext
        self.addChild(controller)
        oldController.willMove(toParent: nil)
        if animate {
            self.transition(from: self.controller, to: controller, duration: HomeAnimations.durationShort, options: HomeAnimations.curve, animations: {
                oldController.view.alpha = 0.0
            }, completion: { _ in
                oldController.removeFromParent()
                controller.didMove(toParent: self)
            })
            
            HomeAnimations.transitionShort(withView: self.selectionIcon.icon, {
                self.selectionIcon.icon.image = controllerRepresentation.icon.image
            })
            HomeAnimations.transitionShort(withView: self.selectionLabel, {
                self.selectionLabel.text = ~controllerRepresentation.title
            })
        }
        else {
            self.controllerContainer.addSubview(controller.view)
            controller.view.translatesAutoresizingMaskIntoConstraints = false
            controller.view.topAnchor.constraint(equalTo: self.controllerContainer.topAnchor).isActive = true
            controller.view.leadingAnchor.constraint(equalTo: self.controllerContainer.leadingAnchor).isActive = true
            controller.view.trailingAnchor.constraint(equalTo: self.controllerContainer.trailingAnchor).isActive = true
            controller.view.bottomAnchor.constraint(equalTo: self.controllerContainer.bottomAnchor).isActive = true
            oldController.view.removeFromSuperview()
            oldController.removeFromParent()
            controller.didMove(toParent: self)
            
            self.selectionIcon.icon.image = controllerRepresentation.icon.image
            self.selectionLabel.text = ~controllerRepresentation.title
        }
        self.controller = controller
        HomeDefaults.save(controllerRepresentation.id.rawValue, forKey: .controller)
    }
    
    private func controllerRemove() {
        self.controller.willMove(toParent: nil)
        self.controller.view.removeFromSuperview()
        self.controller.removeFromParent()
    }
    
    // MARK: -
    func login() {
        let controllerRepresentation = MainViewController.getController(Controller(id: HomeDefaults.read(.controller)))
        
        self.selectionIcon.icon.image = controllerRepresentation.icon.image
        self.selectionLabel.text = ~controllerRepresentation.title
        self.controller = controllerRepresentation.type.init()
        self.controllerSet(self.controller)
        self.userIcon.update(with: App.user)
        self.updateUserCoalition(App.userCoalition)
    }
    
    func logout() {
        HomeDesign.primary = HomeDesign.primaryDefault
        self.presentWithBlur(LoginViewController(), completion: {
            self.background.image = UIImage.Assets.coalitionDefaultBackground.image
            self.userIcon.reset()
            self.controllerRemove()
        })
    }
    
    private func updateUserCoalition(_ coalition: IntraCoalition?) {
        guard let coalition = coalition else {
            self.background.image = UIImage.Assets.coalitionDefaultBackground.image
            self.selectionIcon.layer.shadowColor = HomeDesign.primaryDefault.cgColor
            return
        }
        
        if let background = HomeResources.storageCoalitionsImages.get(coalition) {
            self.background.image = background
        }
        else {
            self.background.image = UIImage.Assets.coalitionDefaultBackground.image
            Task.init(priority: .userInitiated, operation: {
                if let (_, background) = await HomeResources.storageCoalitionsImages.obtain(coalition) {
                    self.background.image = background
                }
            })
        }
        HomeDesign.primary = coalition.uicolor
        self.selectionIcon.layer.shadowColor = HomeDesign.primary.cgColor
        self.selectionIcon.icon.tintColor = HomeDesign.primary
    }
        
    // MARK: -
    @objc private func userIconTapped(sender: UITapGestureRecognizer) {
        let myProfil = ProfilViewController()
        
        Task.init(priority: .userInitiated, operation: {
            await myProfil.setupWithMe()
        })
        self.presentWithBlur(myProfil)
    }
    
    @objc private func selectionIconTapped(sender: UITapGestureRecognizer) {
        SelectionViewController().present()
    }
    
    func topPresentedViewController() -> UIViewController {
        var last = self.presentedViewController
        
        while last != nil && last!.presentedViewController != nil {
            last = last!.presentedViewController
        }
        return last ?? self
    }
}

extension MainViewController {
    
    final private class SelectionIcon: BasicUIView {
        
        fileprivate let icon: BasicUIImageView
        
        init(asset: UIImage.Assets) {
            self.icon = BasicUIImageView(asset: asset)
            self.icon.tintColor = HomeDesign.primary
            super.init()
            self.backgroundColor = HomeDesign.white
            self.layer.cornerRadius = HomeLayout.mainSelectionRadius
            self.layer.shadowColor = HomeDesign.primary.cgColor
            self.layer.shadowOffset = .zero
            self.layer.shadowRadius = HomeLayout.margin
            self.layer.shadowOpacity = Float(HomeDesign.alphaLayer)
            self.isUserInteractionEnabled = true
        }
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
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
    
    final private class SelectionLabel: BasicUILabel {
        
        override var intrinsicContentSize: CGSize {
            let rect = super.intrinsicContentSize
            
            return .init(width: rect.width + HomeLayout.mainSelectionLabelSize + HomeLayout.margin, height: rect.height)
        }
        
        override init(text: String) {
            super.init(text: text)
            self.textAlignment = .center
            self.textColor = HomeDesign.black
            self.backgroundColor = HomeDesign.white
            self.layer.cornerRadius = HomeLayout.mainSelectionLabelRadius
            self.layer.masksToBounds = true
        }
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }

            self.heightAnchor.constraint(equalToConstant: HomeLayout.mainSelectionLabelSize).isActive = true
        }
    }
}

fileprivate extension MainViewController {
    
    struct ControllerRepresentation {
        let type: HomeViewController.Type
        let id: Controller
        let title: String
        let icon: UIImage.Assets
        let isHidden: Bool
    }
    @frozen enum Controller: String {
        case clusters = "clusters"
        case events = "events"
        case elearning = "elearning"
        case corrections = "corrections"
        case research = "research"
        case companies = "companies"
        case shop = "shop"
        case broadcasts = "broadcasts"
        case tracker = "tracker"
        case graph = "graph"
        
        init(id: String?) {
            if let id = id {
                self = Controller(rawValue: id) ?? .clusters
            }
            else {
                self = .clusters
            }
        }
    }
    static let controllerRepresentations: [ControllerRepresentation] = [
        .init(type: ClustersViewController.self, id: .clusters, title: "title.clusters",
              icon: .controllerClusters, isHidden: false),
        .init(type: TrackerViewController.self, id: .tracker, title: "title.tracker",
              icon: .controllerTracker, isHidden: true),
        .init(type: EventsViewController.self, id: .events, title: "title.events",
              icon: .controllerEvents, isHidden: false),
        .init(type: ElearningViewController.self, id: .elearning, title: "title.elearning",
              icon: .controllerElearning, isHidden: false),
        .init(type: GraphViewController.self, id: .graph, title: "title.graph",
              icon: .controllerGraph, isHidden: false),
        .init(type: CorrectionsViewController.self, id: .corrections, title: "title.corrections",
              icon: .controllerCorrections, isHidden: true),
        .init(type: ResearchViewController.self, id: .research, title: "title.research",
              icon: .controllerResearch, isHidden: false),
        .init(type: ShopViewController.self, id: .shop, title: "title.shop",
              icon: .controllerShop, isHidden: false),
        .init(type: CompaniesViewController.self, id: .companies, title: "title.companies",
              icon: .controllerCompanies, isHidden: false)
    ]
    static func getController(_ id: Controller) -> ControllerRepresentation {
        if let representation = MainViewController.controllerRepresentations.first(where: { $0.id == id }) {
            if representation.isHidden {
                if (representation.type as! HiddenViewController.Type).checkDefaultsValue() {
                    return representation
                }
            }
            else {
                return representation
            }
        }
        return MainViewController.controllerRepresentations[0]
    }
}

fileprivate extension MainViewController {
    
    private final class SelectionViewController: DynamicController {
        
        private let selectionViews: [SelectionView]
        private let closeButton: ActionButtonView
        
        final private class SelectionView: BasicUIView {
            
            private let icon: BasicUIImageView
            private let label: BasicUILabel
            let representation: ControllerRepresentation
            
            init(representation: ControllerRepresentation) {
                let asset: UIImage.Assets
                let text: String
                let color: UIColor
                
                if representation.isHidden {
                    if (representation.type as! HiddenViewController.Type).checkDefaultsValue() == false {
                        asset = UIImage.Assets.controllerMystere
                        text = "???"
                        color = HomeDesign.primary
                    }
                    else {
                        asset = representation.icon
                        text = ~representation.title
                        color = HomeDesign.gold
                    }
                }
                else {
                    asset = representation.icon
                    text = ~representation.title
                    color = HomeDesign.primary
                }
                self.representation = representation
                self.icon = BasicUIImageView(asset: asset)
                self.icon.tintColor = color
                self.label = BasicUILabel(text: text)
                self.label.textColor = color
                self.label.font = HomeLayout.fontSemiBoldMedium
                self.label.textAlignment = .center
                super.init()
                self.layer.cornerRadius = HomeLayout.scorner
                self.layer.borderWidth = HomeLayout.border
                self.layer.borderColor = color.cgColor
                self.isUserInteractionEnabled = true
                self.alpha = 0.0
            }
            required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
            
            override func willMove(toSuperview newSuperview: UIView?) {
                guard newSuperview != nil else { return }
                
                self.addSubview(self.icon)
                self.icon.heightAnchor.constraint(equalToConstant: HomeLayout.mainSelectionSize).isActive = true
                self.icon.widthAnchor.constraint(equalToConstant: HomeLayout.mainSelectionSize).isActive = true
                self.icon.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
                self.icon.topAnchor.constraint(equalTo: self.topAnchor, constant: HomeLayout.margin).isActive = true
                self.icon.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor,
                                                   constant: HomeLayout.margin).isActive = true
                self.addSubview(self.label)
                self.label.leadingAnchor.constraint(equalTo: self.leadingAnchor,
                                                    constant: HomeLayout.margin).isActive = true
                self.label.trailingAnchor.constraint(equalTo: self.trailingAnchor,
                                                     constant: -HomeLayout.margin).isActive = true
                self.label.bottomAnchor.constraint(equalTo: self.bottomAnchor,
                                                   constant: -HomeLayout.margin).isActive = true
                self.label.topAnchor.constraint(equalTo: self.icon.bottomAnchor,
                                                constant: HomeLayout.smargin).isActive = true
            }
            
            func estimatedWidth(in width: CGFloat) -> CGFloat {
                let marg = HomeLayout.margin * 2.0
                let w = ceil(self.label.textRect(forBounds: .init(origin: .zero,
                                                                  size: .init(width: width, height: .infinity)),
                                                 limitedToNumberOfLines: 1).width + marg)
                
                return max(w, 74.0)
            }
        }

        
        required init() {
            self.selectionViews = MainViewController.controllerRepresentations.map({SelectionView(representation: $0)})
            self.closeButton = ActionButtonView(asset: .actionClose, color: HomeDesign.actionRed)
            self.closeButton.alpha = 0.0
            super.init()
            
            var index: Int = 0
            var view: SelectionView
            var estimated: CGFloat
            let screenWidth: CGFloat = UIScreen.main.bounds.width
            
            var rowWidth: CGFloat
            var rowViewContainer: BasicUIView!
            var rowViewContainerLeading: NSLayoutXAxisAnchor
            
            let colView = BasicUIView()
            var colViewTop: NSLayoutYAxisAnchor = colView.topAnchor
            
            self.view.addSubview(colView)
            while index < self.selectionViews.count {
                
                rowWidth = 0.0
                rowViewContainer = BasicUIView()
                rowViewContainerLeading = rowViewContainer.leadingAnchor
                colView.addSubview(rowViewContainer)
                
                view = self.selectionViews[index]
                estimated = self.selectionViews[index].estimatedWidth(in: screenWidth) + HomeLayout.smargin
                while true {
                    self.view.addSubview(view)
                    view.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                     action: #selector(selectionViewSelect(sender:))))
                    view.leadingAnchor.constraint(equalTo: rowViewContainerLeading,
                                                  constant: rowWidth == 0.0 ? 0.0 : HomeLayout.smargin).isActive = true
                    view.topAnchor.constraint(equalTo: rowViewContainer.topAnchor).isActive = true
                    view.bottomAnchor.constraint(equalTo: rowViewContainer.bottomAnchor).isActive = true
                    rowViewContainerLeading = view.trailingAnchor
                    
                    func addColView() {
                        rowViewContainer.topAnchor.constraint(equalTo: colViewTop,
                                                              constant: HomeLayout.smargin).isActive = true
                        rowViewContainer.centerXAnchor.constraint(equalTo: colView.centerXAnchor).isActive = true
                        colViewTop = rowViewContainer.bottomAnchor
                    }
                    
                    rowWidth += estimated
                    index += 1
                    if index >= self.selectionViews.count {
                        addColView()
                        break
                    }
                    view = self.selectionViews[index]
                    estimated = self.selectionViews[index].estimatedWidth(in: screenWidth) + HomeLayout.smargin * 2.0
                    if rowWidth + estimated > screenWidth {
                        addColView()
                        break
                    }
                }
                rowViewContainerLeading.constraint(equalTo: rowViewContainer.trailingAnchor).isActive = true
            }
            colViewTop.constraint(equalTo: colView.bottomAnchor).isActive = true
            colView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
            colView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            
            self.view.isUserInteractionEnabled = true
            self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SelectionViewController.closeButtonTapped(sender:))))
        }
        required init?(coder: NSCoder) { fatalError("Serge Funk - You and I") }
        
        override func present() {
            let range: ClosedRange<TimeInterval> = HomeAnimations.durationQuick ... HomeAnimations.durationMedium
            
            super.present()
            HomeAnimations.animateShort({
                self.background.effect = HomeDesign.blur
                self.closeButton.alpha = 1.0
            })
            for view in self.selectionViews {
                UIView.animate(withDuration: .random(in: range),
                               delay: HomeAnimations.durationLigthSpeed,
                               options: HomeAnimations.curve,
                               animations: { view.alpha = 1.0 }, completion: nil)
            }
        }
        
        @objc func closeButtonTapped(sender: UITapGestureRecognizer) {
            self.remove()
        }
        override func remove(isFinish: Bool = true) {
            HomeAnimations.animateShort({
                self.background.effect = nil
                for view in self.selectionViews {
                    view.alpha = 0.0
                }
                self.closeButton.alpha = 0.0
            }, completion: super.remove(isFinish:))
        }
                
        @objc private func selectionViewSelect(sender: UITapGestureRecognizer) {
            let representation = (sender.view as! SelectionView).representation
            
            if type(of: App.mainController.controller) == representation.type {
                return
            }
            else if representation.isHidden {
                if (representation.type as! HiddenViewController.Type).checkDefaultsValue() {
                    App.mainController.controllerSwitch(representation, animate: true)
                    return self.remove()
                }
                DynamicAlert(contents: [.title(~"selection.hidden-title"), .text(~"selection.hidden-text")],
                             actions: [.normal(~"general.ok", nil)])
            }
            else {
                App.mainController.controllerSwitch(representation, animate: true)
                return self.remove()
            }
        }
    }
}

extension MainViewController {
    
    // MARK: - Files
    func openClustersDebugFile(_ file: String) {
        
        func selectCampus(_ campus: IntraCampus) {
            do {
                let vc = try ClustersSharedViewController(debugFile: file, campus: .init(campus: campus))
                
                self.presentWithBlur(vc, completion: nil)
            }
            catch {
                DynamicAlert(contents: [.title(error.localizedDescription)], actions: [.normal(~"general.ok", nil)])
            }
        }
        
        DynamicAlert(contents: [
                        .text(~"clusters.debugfile"),
                        .advancedSelector(.campus, Array<IntraCampus>(HomeApiResources.campus!), 0)],
                     actions: [
                        .normal(~"general.cancel", nil),
                        .getAdvancedSelector(unsafeBitCast(selectCampus, to: ((Any) -> ()).self))])
    }
    
    // MARK: - Deeplinks
    private func deeplinkUnlock(_ hidden: HiddenViewController.Type, data: String) {
        let image = UIImage.Assets(rawValue: "controller_\(hidden.id)")!
        let oldValue = HomeDefaults.read(hidden.id)
        
        if let value = oldValue, value == data {
            DynamicAlert(.noneWithPrimary(HomeDesign.gold),
                         contents: [.titleWithPrimary(~"title.\(hidden.id)", HomeDesign.gold),
                                    .imageWithPrimary(image, 50.0, HomeDesign.gold),
                                    .text(String(format: ~"coupon.already-redeem", App.user.login))],
                         actions: [.highligth(~"general.cool", nil)])
            return
        }
        HomeDefaults.save(data, forRawKey: hidden.id)
        if hidden.checkDefaultsValue() {
            DynamicAlert(.noneWithPrimary(HomeDesign.gold),
                         contents: [.titleWithPrimary(~"title.\(hidden.id)", HomeDesign.gold),
                                    .imageWithPrimary(image, 50.0, HomeDesign.gold),
                                    .text(~"unlock.\(hidden.id)")],
                         actions: [.highligth(~"general.cool", nil)])
        }
        else {
            DynamicAlert(contents: [.text(~"coupon.invalid")], actions: [.normal(~"general.ok", nil)])
            if let oldValue = oldValue {
                HomeDefaults.save(oldValue, forRawKey: hidden.id)
            }
            else {
                HomeDefaults.remove(hidden.id)
            }
        }
    }
    
    @objc func deeplinkTrackerQRCode(parameters: [String: Any]) {
        let data = parameters[HomeDeeplinks.Parameter.data.rawValue] as! String
        
        deeplinkUnlock(TrackerViewController.self, data: data)
    }
    
    @objc func deeplinkCorrectionsQRCode(parameters: [String: Any]) {
        let data = parameters[HomeDeeplinks.Parameter.data.rawValue] as! String
        
        deeplinkUnlock(CorrectionsViewController.self, data: data)
    }
    
    @objc func testNonInANonAsyncContext() {
        let user = App.user!
        
        DynamicAlert.init(contents: [.text(user.login)], actions: [.normal(~"general.ok", nil)])
    }
    
    @objc func deeplinkEvents(parameters: [String: Any]) {
        let id = parameters[HomeDeeplinks.Parameter.id.rawValue] as! Int
        
        Task.init(priority: .userInitiated, operation: {
            do {
                let event: IntraEvent = try await HomeApi.get(.eventWithId(id))
                
                DynamicAlert.init(.event(event),
                                  contents: [.text(event.eventDescription)],
                                  actions: [.normal(~"general.ok", nil)])
            }
            catch {
                DynamicAlert.presentWith(error: error as! HomeApi.RequestError)
            }
        })
    }
}
