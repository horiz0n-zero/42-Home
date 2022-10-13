// home42/Graph.swift
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

final class GraphViewController: HomeViewController {
    
    private let graphView: HolyGraphView
    
    required init() {
        self.graphView = HolyGraphView(user: App.user, cursus: App.userCursus, primary: HomeDesign.primary, isController: true)
        super.init()
        self.view.addSubview(self.graphView)
        self.graphView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.graphView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.graphView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.graphView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

final class GraphSharedViewController: HomeViewController {
    
    private let coalitionBackground: BasicUIImageView
    private let header: ControllerHeaderWithActionsView
    private let graphView: HolyGraphView
    
    init(user: IntraUser, cursus: IntraUserCursus, coalition: IntraCoalition?) {
        let primary: UIColor
        var needUpdateCoalitionBackground: Bool = false
        
        if let coalition = coalition {
            if let background = HomeResources.storageCoalitionsImages.get(coalition) {
                self.coalitionBackground = BasicUIImageView(image: background)
            }
            else {
                self.coalitionBackground = BasicUIImageView(image: UIImage.Assets.coalitionDefaultBackground.image)
                needUpdateCoalitionBackground = true
            }
            primary = coalition.uicolor
        }
        else {
            primary = HomeDesign.primaryDefault
            self.coalitionBackground = BasicUIImageView(asset: .coalitionDefaultBackground)
        }
        self.header = ControllerHeaderWithActionsView(asset: .controllerGraph, title: ~"title.graph", primary: primary)
        self.graphView = HolyGraphView(user: user, cursus: cursus, primary: primary, isController: false)
        super.init()
        if needUpdateCoalitionBackground {
            Task.init(priority: .userInitiated, operation: {
                if let (coa, background) = await HomeResources.storageCoalitionsImages.obtain(coalition!), coa.id == coalition!.id {
                    self.coalitionBackground.image = background
                }
            })
        }
        self.view.backgroundColor = HomeDesign.white
        self.view.addSubview(self.coalitionBackground)
        self.coalitionBackground.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.coalitionBackground.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.coalitionBackground.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.coalitionBackground.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.view.addSubview(self.graphView)
        self.graphView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.graphView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.graphView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.graphView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.view.addSubview(self.header)
        self.header.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.header.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.header.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
    }
    required init() { fatalError() }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

final fileprivate class HolyGraphView: BasicUIView, SelectorViewDelegate, SearchFieldViewDelegate, UserSearchFieldViewDelegate, UIScrollViewDelegate, Keyboard {

    private var user: IntraUser
    private var cursus: IntraUserCursus!
    private let primary: UIColor
    
    private let antenneView: AntenneBlurredView
    private let userSearchField: UserSearchFieldView!
    private let cursusSelector: SelectorView<IntraUserCursus>
    private let searchField: SearchFieldView
    private let scrollView: BasicUIScrollView
    private var scrollViewContainer: BasicUIView!
    
    @frozen private enum State {
        case cursusIsEmpty(IntraUser)
        case loadingUser(String)
        case loading(IntraUser, IntraUserCursus)
        case done(IntraUser, IntraUserCursus)
        case error
    }
    private var state: HolyGraphView.State {
        didSet {
            self.updateState()
        }
    }
    private func updateState() {
        func interactionOff(userSearchFieldUserInteractionEnabled: Bool) {
            self.userSearchField?.isUserInteractionEnabled = userSearchFieldUserInteractionEnabled
            self.cursusSelector.isUserInteractionEnabled = false
            self.searchField.view.isUserInteractionEnabled = false
            self.searchField.view.resignFirstResponder()
        }
        func interactionOn() {
            self.userSearchField?.isUserInteractionEnabled = true
            self.cursusSelector.isUserInteractionEnabled = true
            self.searchField.view.isUserInteractionEnabled = true
        }
        
        switch self.state {
        case .loading(_, _), .loadingUser(_):
            self.antenneView.antenne.isBreak = false
            self.antenneView.antenne.isAntenneAnimating = true
            self.antenneView.isHidden = false
            interactionOff(userSearchFieldUserInteractionEnabled: false)
        case .done(_, _), .cursusIsEmpty(_):
            self.antenneView.antenne.isBreak = false
            self.antenneView.antenne.isAntenneAnimating = false
            self.antenneView.isHidden = true
            if case .done(_, _) = self.state {
                interactionOn()
            }
            else {
                interactionOff(userSearchFieldUserInteractionEnabled: true)
            }
        case .error:
            self.antenneView.antenne.isBreak = true
            self.antenneView.antenne.isAntenneAnimating = true
            self.antenneView.isHidden = false
            interactionOff(userSearchFieldUserInteractionEnabled: true)
        }
        self.removeSearchProjectsView()
        self.removeProjectInfoView()
    }
    
    init(user: IntraUser, cursus: IntraUserCursus!, primary: UIColor, isController: Bool) {
        self.user = user
        self.cursus = cursus
        self.primary = primary
        if isController {
            self.antenneView = AntenneBlurredView(isBreak: false, isAntenneAnimating: true)
            self.userSearchField = UserSearchFieldView(user: .init(id: user.id, login: user.login, image: user.image), primary: primary)
        }
        else {
            self.antenneView = AntenneBlurredView(isBreak: false, isAntenneAnimating: true)
            self.userSearchField = nil
        }
        if cursus != nil {
            self.cursusSelector = SelectorView<IntraUserCursus>(keys: user.cursus_users.map(\.cursus.name), values: user.cursus_users,
                                                                selectedIndex: user.cursus_users.firstIndex(where: { $0.cursus_id == cursus.cursus_id }) ?? 0)
        }
        else {
            self.cursusSelector = .init(keys: [], values: [])
        }
        self.cursusSelector.setPrimary(primary)
        self.searchField = SearchFieldView(placeholder: ~"general.search")
        self.searchField.setPrimary(primary)
        self.scrollView = BasicUIScrollView()
        self.scrollView.backgroundColor = UIColor.clear
        self.state = .loading(user, cursus)
        super.init()
        self.updateState()
        self.cursusSelector.delegate = self
        self.searchField.delegate = self
        self.userSearchField?.delegate = self
        self.addSubview(self.scrollView)
        self.scrollView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        if isController {
            self.addSubview(self.userSearchField)
            self.userSearchField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: HomeLayout.safeAeraMain.left + HomeLayout.margin).isActive = true
            self.userSearchField.topAnchor.constraint(equalTo: self.topAnchor, constant: HomeLayout.safeAeraMain.top + HomeLayout.margin).isActive = true
            self.userSearchField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -(HomeLayout.safeAeraMain.right + HomeLayout.margin)).isActive = true
        }
        self.addSubview(self.cursusSelector)
        self.cursusSelector.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: HomeLayout.safeAeraMain.left + HomeLayout.margin).isActive = true
        if isController {
            self.cursusSelector.topAnchor.constraint(equalTo: self.userSearchField.bottomAnchor, constant: HomeLayout.margin).isActive = true
        }
        else {
            self.cursusSelector.topAnchor.constraint(equalTo: self.topAnchor, constant: HomeLayout.headerWithActionControllerViewHeigth + HomeLayout.safeAera.top + HomeLayout.margin).isActive = true
        }
        self.cursusSelector.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: HomeLayout.safeAeraMain.left + HomeLayout.margin).isActive = true
        self.addSubview(self.searchField)
        self.searchField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -(HomeLayout.safeAeraMain.right + HomeLayout.margin)).isActive = true
        self.searchField.centerYAnchor.constraint(equalTo: self.cursusSelector.centerYAnchor).isActive = true
        self.searchField.leadingAnchor.constraint(equalTo: self.cursusSelector.trailingAnchor, constant: HomeLayout.margin).isActive = true
        self.searchField.widthAnchor.constraint(equalTo: self.cursusSelector.widthAnchor).isActive = true
        self.addSubview(self.antenneView)
        self.antenneView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        if isController {
            self.antenneView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: HomeLayout.roundedGenericActionsViewHeigth * 2.0).isActive = true
        }
        else {
            self.antenneView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: HomeLayout.roundedGenericActionsViewHeigth * 1.0).isActive = true
        }
        if self.cursus == nil {
            self.state = .cursusIsEmpty(user)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                DynamicAlert(contents: [.text(String(format: ~"graph.required-cursus", self.user.login))], actions: [.normal(~"general.ok", nil)])
            })
        }
        else {
            Task.init(priority: .userInitiated, operation: {
                await self.startBuildingHolyGraph()
            })
        }
        self.keyboardInterfaceSetup()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private var projects: ContiguousArray<IntraNetGraphProject>!
    
    @MainActor private func startBuildingHolyGraph() async {
        let offsetY: CGFloat
        let width = UIScreen.main.bounds.width
        let height: CGFloat
        let widthRatio: CGFloat
        let heightRatio: CGFloat
        let minZoom: CGFloat
        
        if self.userSearchField == nil {
            offsetY = HomeLayout.headerWithActionViewHeigth + HomeLayout.safeAera.top + HomeLayout.margin
        }
        else {
            offsetY = HomeLayout.safeAeraMain.top + HomeLayout.roundedGenericActionsViewHeigth * 2.0 + HomeLayout.margin * 4.0
        }
        height = UIScreen.main.bounds.height - (offsetY + HomeLayout.safeAera.bottom)
        do {
            self.projects = try await HomeApi.intranetRequest(.graph, parameters: ["login": self.user.login, "cursus_id": self.cursus.cursus_id])
            self.scrollViewContainer = await self.createViews()
            widthRatio = min(width, self.scrollViewContainer.frame.width) / max(width, self.scrollViewContainer.frame.width)
            heightRatio = min(height, self.scrollViewContainer.frame.height) / max(height, self.scrollViewContainer.frame.height)
            minZoom = max(widthRatio, heightRatio)
            self.scrollView.addSubview(self.scrollViewContainer)
            self.scrollViewContainer.topAnchor.constraint(equalTo: self.scrollView.topAnchor).isActive = true
            self.scrollViewContainer.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor).isActive = true
            self.scrollViewContainer.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor).isActive = true
            self.scrollViewContainer.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor).isActive = true
            self.scrollViewContainer.widthAnchor.constraint(equalToConstant: self.scrollViewContainer.frame.width).isActive = true
            self.scrollViewContainer.heightAnchor.constraint(equalToConstant: self.scrollViewContainer.frame.height).isActive = true
            self.scrollViewContainer.isUserInteractionEnabled = true
            self.scrollViewContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(HolyGraphView.scrollViewContentTapped(sender:))))
            self.scrollView.minimumZoomScale = minZoom
            self.scrollView.maximumZoomScale = minZoom + 1.0
            self.scrollView.isScrollEnabled = true
            self.scrollView.delegate = self
            self.scrollView.contentInset = .init(top: offsetY, left: 0.0, bottom: 0.0, right: 0.0)
            self.scrollView.zoom(to: .init(origin: .zero, size: .init(width: self.scrollViewContainer.frame.width,
                                                                      height: self.scrollViewContainer.frame.height)),
                                 animated: false)
            self.state = .done(self.user, self.cursus)
        }
        catch {
            DynamicAlert.presentWith(error: error as! HomeApi.RequestError)
            self.state = .error
        }
    }
    
    private func prepareToRestartHolyGraph() {
        if self.scrollViewContainer != nil {
            self.scrollViewContainer.removeFromSuperview()
            self.scrollViewContainer = nil
        }
    }
    
    private func createViews() async -> BasicUIView {
        let primary: UIColor = self.primary
        let container = BasicUIView()
        let linesView: ProjectLinesView
        var lines: [ProjectLinesView.Line] = []
        var view: ProjectView
        var minX: CGFloat = .infinity
        var minY: CGFloat = .infinity
        var maxX: CGFloat = 0.0
        var maxY: CGFloat = 0.0
        guard self.projects.count > 0 else {
            return container
        }
        
        for project in self.projects {
            minX = min(project.x, minX)
            minY = min(project.y, minY)
            maxX = max(project.x, maxX)
            maxY = max(project.y, maxY)
            view = ProjectView(project: project, primary: primary)
            container.addSubview(view)
        }
        minX -= ProjectView.maxEstimatedWidth
        if minX < 0 {
            minX = 0
        }
        minY -= ProjectView.maxEstimatedHeight
        if minY < 0 {
            minY = 0
        }
        maxX += ProjectView.maxEstimatedWidth * 2.0
        maxY += ProjectView.maxEstimatedHeight * 2.0
        lines.reserveCapacity(self.projects.count)
        for index in 0 ..< self.projects.count {
            view = container.subviews[index] as! ProjectView
            view.frame.origin.x -= minX
            view.frame.origin.y -= minY
        }
        for projectView in container.subviews as! [ProjectView] {
            for line in projectView.project.by {
               lines.append(.init(from: .init(x: line.points[0][0] - (minX - projectView.frame.width / 2.0), y: line.points[0][1] - (minY - projectView.frame.height / 2.0)),
                                  to: .init(x: line.points[1][0] - (minX - projectView.frame.width / 2.0), y: line.points[1][1] - (minY - projectView.frame.height / 2.0))))
            }
        }
        container.frame.size = .init(width: CGFloat(maxX - minX), height: CGFloat(maxY - minY))
        linesView = ProjectLinesView(lines: lines)
        linesView.frame = container.frame
        container.insertSubview(linesView, at: 0)
        return container
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { return self.scrollView.subviews.first }
    
    func selectorSelect<E>(_ selector: SelectorView<E>) {
        let value: IntraUserCursus = unsafeBitCast(selector.value, to: IntraUserCursus.self)
        
        switch self.state {
        case .loading(_, _):
            return
        default:
            if value.cursus_id != self.cursus.cursus_id {
                self.cursus = value
                self.state = .loading(self.user, value)
                self.prepareToRestartHolyGraph()
                Task.init(priority: .userInitiated, operation: {
                    await self.startBuildingHolyGraph()
                })
            }
        }
    }
    
    func userSearchFieldViewSelect(view: UserSearchFieldView, user: IntraUserInfo) {
        self.state = .loadingUser(user.login)
        Task.init(priority: .userInitiated, operation: {
            do {
                let user: IntraUser = try await HomeApi.get(.userWithId(user.id))
                let selectedIndex: Int
                
                self.user = user
                self.cursus = user.primaryCursus
                if self.cursus != nil {
                    selectedIndex = user.cursus_users.firstIndex(of: self.cursus)!
                }
                else {
                    selectedIndex = 0
                }
                self.cursusSelector.update(keys: user.cursus_users.map(\.cursus.name), values: user.cursus_users, selectedIndex: selectedIndex)
                if self.cursus == nil {
                    self.state = .cursusIsEmpty(user)
                    DynamicAlert(contents: [.text(String(format: ~"graph.required-cursus", self.user.login))], actions: [.normal(~"general.ok", nil)])
                    return
                }
                self.prepareToRestartHolyGraph()
                self.state = .loading(user, self.cursus)
                await self.startBuildingHolyGraph()
            }
            catch {
                DynamicAlert.presentWith(error: error as! HomeApi.RequestError)
            }
        })
    }
    
    private var projectInfoView: ProjectInfoView? = nil
    
    @objc private func scrollViewContentTapped(sender: UITapGestureRecognizer) {
        guard self.projectInfoView == nil else { return }
        let location = sender.location(in: sender.view)
        let projectInfoView: ProjectInfoView
        let offset: CGFloat
        
        if let view = self.scrollViewContainer.subviews.last(where: { $0.point(inside: $0.convert(location, from: sender.view!), with: nil) }) as? ProjectView {
            projectInfoView = ProjectInfoView(intraNetProject: view.project,
                                              userProject: self.user.projects_users.first(where: { $0.project.id == view.project.projectId && $0.final_mark == view.project.finalMark }),
                                              primary: self.primary)
            offset = self.searchField.offsetFromYBottomOrigin(fromParent: self)
            projectInfoView.frame = .init(x: HomeLayout.margin,
                                          y: offset + HomeLayout.margin,
                                          width: UIScreen.main.bounds.width - HomeLayout.margin * 2.0,
                                          height: UIScreen.main.bounds.height - (HomeLayout.safeAera.top + HomeLayout.safeAera.bottom + offset + HomeLayout.margin))
            projectInfoView.translatesAutoresizingMaskIntoConstraints = true
            self.addSubview(projectInfoView)
            self.projectInfoView = projectInfoView
            projectInfoView.present(completion: nil)
        }
    }
    
    private var searchProjectsView: SearchProjectsView? = nil
    
    private func searchProjectsViewSelect(_ project: IntraNetGraphProject) {
        self.searchField.resignFirstResponder()
        if let view = (self.scrollViewContainer.subviews as! [ProjectView]).last(where: { $0.project.id == project.id }) {
            self.scrollView.zoom(to: view.frame, animated: true)
        }
    }
    
    func searchFieldBeginEditing(_ searchField: SearchFieldView) {
        print(#function)
    }
    func searchFieldEndEditing(_ searchField: SearchFieldView) {
        self.removeSearchProjectsView()
        print(#function)
    }
    func searchFieldTextUpdated(_ searchField: SearchFieldView) {
        self.searchProjectsView?.searchFieldValueChanged(shouldReloadData: true)
    }
    
    func keyboardWillShow(curve: UIView.AnimationCurve, duration: TimeInterval, frame: CGRect) {
        guard self.searchProjectsView == nil && self.searchField.isFirstResponder else { return }
        let searchProjectsView = SearchProjectsView(graphView: self)
        let offsetY = self.searchField.offsetFromYBottomOrigin(fromParent: self) + HomeLayout.margin
        
        searchProjectsView.frame = .init(x: HomeLayout.margin,
                                         y: offsetY,
                                         width: UIScreen.main.bounds.width - HomeLayout.margin * 2.0,
                                         height: UIScreen.main.bounds.height - (offsetY + HomeLayout.smargin + frame.height))
        self.addSubview(searchProjectsView)
        searchProjectsView.present(with: duration, curve: curve)
        self.searchProjectsView = searchProjectsView
    }
    
    func keyboardWillHide(curve: UIView.AnimationCurve, duration: TimeInterval, frame: CGRect) { }
    func keyboardWillChangeFrame(curve: UIView.AnimationCurve, duration: TimeInterval, frame: CGRect) { }
    
    private func removeSearchProjectsView() {
        self.searchProjectsView?.remove { _ in
            self.searchProjectsView?.removeFromSuperview()
            self.searchProjectsView = nil
        }
    }
    
    private func removeProjectInfoView() {
        self.projectInfoView?.remove { _ in
            self.projectInfoView?.removeFromSuperview()
            self.projectInfoView = nil
        }
    }
}

private extension HolyGraphView {
    
    final private class ProjectInfoView: HomePresentableVisualEffectView {
        
        private unowned(unsafe) let intraNetProject: IntraNetGraphProject
        private unowned(unsafe) let userProject: IntraUserProject?
        private unowned(unsafe) let primary: UIColor
        
        init(intraNetProject: IntraNetGraphProject, userProject: IntraUserProject?, primary: UIColor) {
            self.intraNetProject = intraNetProject
            self.userProject = userProject
            self.primary = primary
            super.init()
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }
            let titleLabel: BasicUILabel
            let seeButton: ActionButtonView
            let closeButton: ActionButtonView
            let state: HomeInsetsLabel
            let xpLabel: BasicUILabel
            let unavailableContainer: BasicUIView
            let unavailableLabel: BasicUILabel
            let descriptionLabel: BasicUITextView
            
            titleLabel = BasicUILabel(text: self.intraNetProject.name)
            titleLabel.textColor = HomeDesign.white
            titleLabel.font = HomeLayout.fontSemiBoldTitle
            titleLabel.textAlignment = .left
            titleLabel.numberOfLines = 2
            titleLabel.adjustsFontSizeToFitWidth = true
            if self.userProject != nil {
                seeButton = ActionButtonView(asset: .actionSee, color: self.primary)
                seeButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProjectInfoView.seeButtonTapped(sender:))))
            }
            else {
                seeButton = ActionButtonView(asset: .actionPeople, color: self.primary)
                seeButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProjectInfoView.seePeopleButtonTapped(sender:))))
            }
            closeButton = ActionButtonView(asset: .actionClose, color: HomeDesign.actionRed)
            
            self.contentView.addSubview(titleLabel)
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: HomeLayout.margin).isActive = true
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: HomeLayout.margin).isActive = true
            self.contentView.addSubview(closeButton)
            closeButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.margin).isActive = true
            closeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
            
            self.contentView.addSubview(seeButton)
            seeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
            seeButton.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -HomeLayout.smargin).isActive = true
            seeButton.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: HomeLayout.smargin).isActive = true
            
            closeButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProjectInfoView.closeButtonTapped(sender:))))
            descriptionLabel = BasicUITextView()
            descriptionLabel.text = self.intraNetProject.projectDescription
            descriptionLabel.textColor = HomeDesign.white
            descriptionLabel.font = HomeLayout.fontRegularMedium
            descriptionLabel.textAlignment = .left
            descriptionLabel.isUserInteractionEnabled = false
            if self.intraNetProject.state == .unavailable && self.intraNetProject.rules != nil {
                xpLabel = BasicUILabel(text: self.intraNetProject.difficulty.scoreFormatted + " XP")
                xpLabel.textColor = HomeDesign.white
                xpLabel.font = HomeLayout.fontThinMedium
                xpLabel.textAlignment = .center
                xpLabel.adjustsFontSizeToFitWidth = true
                self.contentView.addSubview(xpLabel)
                xpLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: HomeLayout.margin).isActive = true
                xpLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: HomeLayout.margin).isActive = true
                xpLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -HomeLayout.margin).isActive = true
                unavailableContainer = BasicUIView()
                unavailableContainer.layer.cornerRadius = HomeLayout.scorner
                unavailableContainer.layer.borderWidth = HomeLayout.sborder
                unavailableContainer.layer.borderColor = HomeDesign.redError.cgColor
                unavailableContainer.backgroundColor = HomeDesign.redError.withAlphaComponent(HomeDesign.alphaLowLayer)
                unavailableLabel = BasicUILabel(text: self.intraNetProject.rules)
                unavailableLabel.textColor = HomeDesign.white
                unavailableLabel.font = HomeLayout.fontRegularMedium
                unavailableLabel.textAlignment = .left
                unavailableLabel.numberOfLines = 4
                self.contentView.addSubview(unavailableContainer)
                unavailableContainer.topAnchor.constraint(equalTo: xpLabel.bottomAnchor, constant: HomeLayout.margin).isActive = true
                unavailableContainer.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: HomeLayout.margin).isActive = true
                unavailableContainer.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -HomeLayout.margin).isActive = true
                self.contentView.addSubview(unavailableLabel)
                unavailableLabel.topAnchor.constraint(equalTo: unavailableContainer.topAnchor, constant: HomeLayout.smargin).isActive = true
                unavailableLabel.leadingAnchor.constraint(equalTo: unavailableContainer.leadingAnchor, constant: HomeLayout.smargin).isActive = true
                unavailableLabel.trailingAnchor.constraint(equalTo: unavailableContainer.trailingAnchor, constant: -HomeLayout.smargin).isActive = true
                unavailableLabel.bottomAnchor.constraint(equalTo: unavailableContainer.bottomAnchor, constant: -HomeLayout.smargin).isActive = true
                self.contentView.addSubview(descriptionLabel)
                descriptionLabel.topAnchor.constraint(equalTo: unavailableContainer.bottomAnchor, constant: HomeLayout.smargin).isActive = true
            }
            else {
                state = HomeInsetsLabel(text: self.intraNetProject.stateText, inset: .init(width: HomeLayout.margin, height: HomeLayout.smargin))
                state.textColor = HomeDesign.white
                state.font = HomeLayout.fontBoldMedium
                state.backgroundColor = self.intraNetProject.stateColor
                state.layer.cornerRadius = HomeLayout.scorner
                state.layer.masksToBounds = true
                self.contentView.backgroundColor = state.backgroundColor?.withAlphaComponent(HomeDesign.alphaLowLayer) // en faire une option
                xpLabel = BasicUILabel(text: self.intraNetProject.difficulty.scoreFormatted + " XP")
                xpLabel.textColor = HomeDesign.white
                xpLabel.font = HomeLayout.fontThinMedium
                xpLabel.textAlignment = .right
                xpLabel.adjustsFontSizeToFitWidth = true
                self.contentView.addSubview(state)
                state.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: HomeLayout.margin).isActive = true
                state.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
                self.contentView.addSubview(xpLabel)
                xpLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -HomeLayout.margins).isActive = true
                xpLabel.centerYAnchor.constraint(equalTo: state.centerYAnchor).isActive = true
                xpLabel.leadingAnchor.constraint(equalTo: state.trailingAnchor, constant: HomeLayout.smargin).isActive = true
                self.contentView.addSubview(descriptionLabel)
                descriptionLabel.topAnchor.constraint(equalTo: state.bottomAnchor, constant: HomeLayout.margin).isActive = true
            }
            descriptionLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: HomeLayout.margin).isActive = true
            descriptionLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -HomeLayout.margin).isActive = true
            descriptionLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -HomeLayout.margin).isActive = true
        }
        
        @objc private func seeButtonTapped(sender: UITapGestureRecognizer) {
            let graphView: HolyGraphView = self.parent()!
            let userProjectVC: UserProjectViewController
            
            userProjectVC = UserProjectViewController(user: graphView.user, userProject: self.userProject!, primary: graphView.primary)
            self.parentHomeViewController?.presentWithBlur(userProjectVC) {
                self.closeButtonTapped(sender: sender)
            }
        }
        
        @objc private func seePeopleButtonTapped(sender: UITapGestureRecognizer) {
            let userList = UsersListViewController(.projectsWithProjectIdUsers(self.intraNetProject.projectId), primary: self.primary, extra: .project(self.intraNetProject.projectId))
            
            self.parentHomeViewController?.presentWithBlur(userList)
        }
        
        @objc private func closeButtonTapped(sender: UITapGestureRecognizer) {
            (self.parent() as! HolyGraphView).removeProjectInfoView()
        }
    }
    
    final private class ProjectLinesView: BasicUIView {
        
        struct Line {
            let from: CGPoint
            let to: CGPoint
        }
        private let lines: [ProjectLinesView.Line]
        
        init(lines: [ProjectLinesView.Line]) {
            self.lines = lines
            super.init()
            self.translatesAutoresizingMaskIntoConstraints = false
            self.backgroundColor = .clear
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override func draw(_ rect: CGRect) {
            let context = UIGraphicsGetCurrentContext()!
            
            if App.settings.graphPreferDarkTheme {
                HomeDesign.blackGray.setStroke()
                HomeDesign.blackGray.setFill()
            }
            else {
                HomeDesign.lightGray.setStroke()
                HomeDesign.lightGray.setFill()
            }
            context.setLineWidth(20.0)
            context.setLineCap(.round)
            for line in self.lines {
                context.move(to: line.to)
                context.addLine(to: line.from)
                context.strokePath()
            }
        }
    }
    
    final private class ProjectView: UIView {
        
        private let nameLabel: BasicUILabel
        
        unowned(unsafe) let project: IntraNetGraphProject
        
        static let maxEstimatedWidth: CGFloat = 200.0
        static let maxEstimatedHeight: CGFloat = 200.0
        
        init(project: IntraNetGraphProject, primary: UIColor) {
            self.nameLabel = BasicUILabel(text: project.name)
            self.nameLabel.numberOfLines = 0
            self.nameLabel.font = HomeLayout.fontBoldTitle
            self.nameLabel.textAlignment = .center
            self.nameLabel.adjustsFontSizeToFitWidth = true
            self.project = project
            switch project.kind {
            case .project:
                super.init(frame: .init(x: project.x, y: project.y, width: 100.0, height: 100.0))
                self.layer.cornerRadius = 50.0
            case .bigProject, .partTime, .secondInternship, .firstInternship:
                super.init(frame: .init(x: project.x, y: project.y, width: 200.0, height: 200.0))
                self.layer.cornerRadius = 100.0
            default:
                super.init(frame: .init(x: project.x, y: project.y, width: 160.0, height: 60.0))
                self.layer.cornerRadius = HomeLayout.corner
            }
            
            if App.settings.graphPreferDarkTheme {
                switch project.state {
                case .done:
                    self.backgroundColor = primary
                    self.nameLabel.textColor = HomeDesign.lightGray
                    self.layer.borderWidth = HomeLayout.borders
                    self.layer.borderColor = HomeDesign.blackGray.cgColor
                case .fail:
                    self.backgroundColor = HomeDesign.redError
                    self.nameLabel.textColor = HomeDesign.lightGray
                    self.layer.borderWidth = HomeLayout.borders
                    self.layer.borderColor = HomeDesign.blackGray.cgColor
                case .inProgress:
                    self.backgroundColor = HomeDesign.black
                    self.layer.borderWidth = HomeLayout.borders
                    self.layer.borderColor = HomeDesign.blackGray.cgColor
                    self.nameLabel.textColor = primary
                case .unavailable:
                    self.backgroundColor = HomeDesign.black
                    self.layer.borderWidth = HomeLayout.borders
                    self.layer.borderColor = HomeDesign.blackGray.cgColor
                    self.nameLabel.textColor = HomeDesign.lightGray
                case .available:
                    self.backgroundColor = HomeDesign.black
                    self.layer.borderWidth = HomeLayout.borders
                    self.layer.borderColor = HomeDesign.blackGray.cgColor
                    self.nameLabel.textColor = HomeDesign.lightGray
                }
            }
            else {
                switch project.state {
                case .done:
                    self.backgroundColor = primary
                    self.nameLabel.textColor = HomeDesign.white
                    self.layer.borderWidth = HomeLayout.borders
                    self.layer.borderColor = HomeDesign.lightGray.cgColor
                case .fail:
                    self.backgroundColor = HomeDesign.redError
                    self.nameLabel.textColor = HomeDesign.white
                    self.layer.borderWidth = HomeLayout.borders
                    self.layer.borderColor = HomeDesign.lightGray.cgColor
                case .inProgress:
                    self.backgroundColor = HomeDesign.gray
                    self.layer.borderWidth = HomeLayout.borders
                    self.layer.borderColor = HomeDesign.lightGray.cgColor
                    self.nameLabel.textColor = primary
                case .unavailable:
                    self.backgroundColor = HomeDesign.gray
                    self.layer.borderWidth = HomeLayout.borders
                    self.layer.borderColor = HomeDesign.lightGray.cgColor
                    self.nameLabel.textColor = HomeDesign.white
                case .available:
                    self.backgroundColor = HomeDesign.gray
                    self.layer.borderWidth = HomeLayout.borders
                    self.layer.borderColor = HomeDesign.lightGray.cgColor
                    self.nameLabel.textColor = HomeDesign.white
                }
            }
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }
            
            self.addSubview(self.nameLabel)
            self.nameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: HomeLayout.smargin).isActive = true
            self.nameLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -HomeLayout.smargin).isActive = true
            self.nameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: HomeLayout.smargin).isActive = true
            self.nameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.smargin).isActive = true
        }
    }
    
    final private class SearchProjectsView: HomePresentableVisualEffectView, UITableViewDelegate, UITableViewDataSource {
        
        private let tableView: BasicUITableView
        private unowned(unsafe) let graphView: HolyGraphView
        private var projects: ContiguousArray<IntraNetGraphProject>!
        
        init(graphView: HolyGraphView) {
            self.tableView = BasicUITableView()
            self.graphView = graphView
            super.init()
            self.tableView.register(SearchProjectTableViewCell.self, forCellReuseIdentifier: "cell")
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.backgroundColor = .clear
            self.translatesAutoresizingMaskIntoConstraints = true
            self.contentView.translatesAutoresizingMaskIntoConstraints = true
            self.searchFieldValueChanged(shouldReloadData: false)
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }
            
            self.contentView.addSubview(self.tableView)
            self.tableView.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
            self.tableView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
            self.tableView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
            self.tableView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return self.projects.count
        }
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SearchProjectTableViewCell
            
            cell.update(with: self.projects[indexPath.row])
            return cell
        }
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            self.graphView.searchProjectsViewSelect(self.projects[indexPath.row])
        }
        
        final private class SearchProjectTableViewCell: BasicUITableViewCell {
            
            private let container: BasicUIView
            private let stateLabel: HomeInsetsLabel
            private let nameLabel: BasicUILabel
            
            override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
                self.container = BasicUIView()
                self.container.backgroundColor = HomeDesign.white
                self.container.layer.cornerRadius = HomeLayout.corner
                self.container.layer.masksToBounds = true
                self.stateLabel = HomeInsetsLabel(text: "???", inset: .init(width: HomeLayout.margin, height: HomeLayout.smargin))
                self.stateLabel.textColor = HomeDesign.white
                self.stateLabel.font = HomeLayout.fontBoldMedium
                self.stateLabel.layer.cornerRadius = HomeLayout.scorner
                self.stateLabel.layer.masksToBounds = true
                self.nameLabel = BasicUILabel(text: "???")
                self.nameLabel.textColor = HomeDesign.black
                self.nameLabel.font = HomeLayout.fontSemiBoldMedium
                self.nameLabel.textAlignment = .left
                self.nameLabel.numberOfLines = 0
                super.init(style: style, reuseIdentifier: reuseIdentifier)
            }
            required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
            
            override func willMove(toSuperview newSuperview: UIView?) {
                guard newSuperview != nil else { return }
                
                self.contentView.addSubview(self.container)
                self.container.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: HomeLayout.smargin).isActive = true
                self.container.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: HomeLayout.margin).isActive = true
                self.container.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -HomeLayout.margin).isActive = true
                self.container.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -HomeLayout.smargin).isActive = true
                self.container.addSubview(self.nameLabel)
                self.nameLabel.topAnchor.constraint(equalTo: self.container.topAnchor, constant: HomeLayout.smargin).isActive = true
                self.nameLabel.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: HomeLayout.smargin).isActive = true
                self.nameLabel.trailingAnchor.constraint(equalTo: self.container.trailingAnchor, constant: -HomeLayout.smargin).isActive = true
                self.container.addSubview(self.stateLabel)
                self.stateLabel.topAnchor.constraint(equalTo: self.nameLabel.bottomAnchor, constant: HomeLayout.smargin).isActive = true
                self.stateLabel.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: HomeLayout.smargin).isActive = true
                self.stateLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.container.trailingAnchor, constant: -HomeLayout.smargin).isActive = true
                self.stateLabel.bottomAnchor.constraint(equalTo: self.container.bottomAnchor, constant: -HomeLayout.smargin).isActive = true
            }
            
            func update(with project: IntraNetGraphProject) {
                self.stateLabel.text = project.stateText
                self.stateLabel.backgroundColor = project.stateColor
                if App.settings.graphMixColor {
                    self.container.backgroundColor = UIColor.mix(withLowAlphaColor: self.stateLabel.backgroundColor!.withAlphaComponent(HomeDesign.alphaLowLayer), color: HomeDesign.white)
                }
                self.nameLabel.text = project.name
            }
        }
        
        func searchFieldValueChanged(shouldReloadData: Bool) {
            if self.graphView.searchField.text.count == 0 {
                self.projects = self.graphView.projects
            }
            else {
                self.projects = self.graphView.projects.filter({ $0.name.uppercased().contains(self.graphView.searchField.text.uppercased()) })
            }
            if shouldReloadData {
                self.tableView.reloadSections(IndexSet(integer: 0), with: .fade)
            }
        }
    }
}
