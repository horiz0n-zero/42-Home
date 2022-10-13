// home42/UserCorrectionsLogs.swift
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

final class UserCorrectionsLogsViewController: HomeViewController, SegmentViewDelegate, UserSearchFieldViewDelegate {
    
    private let header: HeaderWithActionsView
    private let userSearchField: UserSearchFieldView
    private let segment: SegmentView
    private let tableView: GenericSingleInfiniteRequestTableView<ScaleTeamCell, IntraScaleTeam>
    
    @frozen enum Selection: Int {
        case corrector = 0
        case corrected = 1
        
        static var keys: [String] {
            return [~"general.as-corrector", ~"general.as-corrected"]
        }
    }
    
    private unowned(unsafe) let primary: UIColor
    
    init(user: IntraUser, primary: UIColor = HomeDesign.primary) {
        self.header = HeaderWithActionsView(title: ~"title.corrections")
        self.userSearchField = UserSearchFieldView(user: .init(id: user.id, login: user.login, image: user.image), primary: primary)
        self.segment = SegmentView(values: UserCorrectionsLogsViewController.Selection.keys)
        self.tableView = .init(.usersWithUserIdScaleTeamsAsCorrector(user.id), parameters: ["filter[future]": false, "filter[filled]": true, "sort": "-begin_at"], pageSize: 15)
        self.primary = primary
        super.init()
        
        self.view.backgroundColor = HomeDesign.white
        self.view.addSubview(self.header)
        self.header.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.header.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.header.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.view.addSubview(self.userSearchField)
        self.userSearchField.topAnchor.constraint(equalTo: self.header.bottomAnchor, constant: HomeLayout.margin).isActive = true
        self.userSearchField.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: HomeLayout.margin).isActive = true
        self.userSearchField.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -HomeLayout.margin).isActive = true
        self.view.addSubview(self.segment)
        self.segment.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: HomeLayout.margin).isActive = true
        self.segment.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -HomeLayout.margin).isActive = true
        self.segment.topAnchor.constraint(equalTo: self.userSearchField.bottomAnchor, constant: HomeLayout.margin).isActive = true
        self.view.addSubview(self.tableView)
        self.tableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        self.tableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        self.tableView.topAnchor.constraint(equalTo: self.segment.bottomAnchor).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.tableView.contentInset = .init(top: HomeLayout.margin, left: 0.0, bottom: 0.0, right: 0.0)
        self.userSearchField.delegate = self
        self.segment.delegate = self
        self.segment.primary = primary
        self.tableView.nextPage()
    }
    required init() { fatalError() }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func segmentViewSelect(_ segmentView: SegmentView) {
        if segmentView.selectedIndex == Selection.corrector.rawValue {
            self.tableView.route = .usersWithUserIdScaleTeamsAsCorrector(self.userSearchField.user!.id)
        }
        else {
            self.tableView.route = .usersWithUserIdScaleTeamsAsCorrected(self.userSearchField.user!.id)
        }
        self.tableView.restart(with: ["filter[future]": false, "filter[filled]": true, "sort": "-begin_at"])
    }
    func userSearchFieldViewSelect(view: UserSearchFieldView, user: IntraUserInfo) {
        self.segmentViewSelect(self.segment)
    }
    
    final private class ScaleTeamCell: BasicUITableViewCell, GenericSingleInfiniteRequestCell {
        
        let view: ScaleTeamView = ScaleTeamView()
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }
           
            self.contentView.addSubview(self.view)
            self.view.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: HomeLayout.smargin).isActive = true
            self.view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -HomeLayout.smargin).isActive = true
            self.view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: HomeLayout.margin).isActive = true
            self.view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -HomeLayout.margin).isActive = true
        }
        
        func fill(with element: IntraScaleTeam) {
            self.view.update(with: element)
        }
    }
    
    final class ScaleTeamView: BasicUIView, HomeFramingTableViewCellView {
        
        static var edges: UIEdgeInsets = .init(top: HomeLayout.smargin, left: HomeLayout.margin, bottom: HomeLayout.smargin, right: HomeLayout.margin)
        private let correctorIcon: UserProfilIconView
        private let correctorLabel: BasicUILabel
        private let flagView: HomeInsetsLabel
        
        private let correctorComment: HomeInsetsLabel
        private let starsView: StarsView
        
        private let correctedIcons: BasicUIStackView
        private let correctedLabel: BasicUILabel
        private let correctedFeedback: HomeInsetsLabel
        
        override init() {
            self.correctorIcon = UserProfilIconView()
            self.correctorLabel = BasicUILabel(text: "???")
            self.correctorLabel.font = HomeLayout.fontSemiBoldNormal
            self.correctorLabel.textColor = HomeDesign.black
            self.correctorLabel.textAlignment = .left
            self.flagView = HomeInsetsLabel(text: "???", inset: .init(width: HomeLayout.margin, height: HomeLayout.smargin))
            self.flagView.layer.cornerRadius = HomeLayout.scorner
            self.flagView.layer.masksToBounds = true
            self.flagView.textAlignment = .center
            self.flagView.textColor = HomeDesign.white
            self.flagView.font = HomeLayout.fontBoldNormal
            self.correctorComment = HomeInsetsLabel(text: "???", inset: .init(width: HomeLayout.margin, height: HomeLayout.margins))
            self.correctorComment.numberOfLines = 20
            self.correctorComment.font = HomeLayout.fontRegularNormal
            self.correctorComment.textColor = HomeDesign.black
            self.correctorComment.textAlignment = .left
            self.starsView = StarsView()
            self.correctedIcons = BasicUIStackView()
            self.correctedIcons.axis = .horizontal
            self.correctedIcons.spacing = HomeLayout.smargin
            self.correctedLabel = BasicUILabel(text: "???")
            self.correctedLabel.font = HomeLayout.fontSemiBoldNormal
            self.correctedLabel.textColor = HomeDesign.black
            self.correctedLabel.textAlignment = .right
            self.correctedLabel.numberOfLines = 2
            self.correctedFeedback = HomeInsetsLabel(text: "???", inset: .init(width: HomeLayout.margin, height: HomeLayout.margins))
            self.correctedFeedback.numberOfLines = self.correctorComment.numberOfLines
            self.correctedFeedback.font = self.correctorComment.font
            self.correctedFeedback.textColor = self.correctorComment.textColor
            self.correctedFeedback.textAlignment = .left
            super.init()
            self.layer.cornerRadius = HomeLayout.corner
            self.layer.masksToBounds = true
            self.backgroundColor = HomeDesign.lightGray
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }
            
            self.addSubview(self.correctorIcon)
            self.correctorIcon.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: HomeLayout.margin).isActive = true
            self.correctorIcon.topAnchor.constraint(equalTo: self.topAnchor, constant: HomeLayout.margin).isActive = true
            self.correctorIcon.setSize(HomeLayout.userProfilIconHeigth, HomeLayout.userProfilIconRadius)
            self.addSubview(self.correctorLabel)
            self.correctorLabel.leadingAnchor.constraint(equalTo: self.correctorIcon.trailingAnchor, constant: HomeLayout.margin).isActive = true
            self.correctorLabel.centerYAnchor.constraint(equalTo: self.correctorIcon.centerYAnchor).isActive = true
            self.addSubview(self.flagView)
            self.flagView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.margin).isActive = true
            self.flagView.topAnchor.constraint(equalTo: self.correctorIcon.topAnchor).isActive = true
            self.addSubview(self.correctorComment)
            self.correctorComment.leadingAnchor.constraint(equalTo: self.correctorIcon.leadingAnchor, constant: 0.0).isActive = true
            self.correctorComment.topAnchor.constraint(equalTo: self.correctorIcon.bottomAnchor, constant: HomeLayout.margin).isActive = true
            self.correctorComment.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.margin).isActive = true
            self.addSubview(self.correctedFeedback)
            self.correctedFeedback.leadingAnchor.constraint(equalTo: self.correctorComment.leadingAnchor).isActive = true
            self.correctedFeedback.trailingAnchor.constraint(equalTo: self.correctorComment.trailingAnchor).isActive = true
            self.correctedFeedback.topAnchor.constraint(equalTo: self.correctorComment.bottomAnchor, constant: HomeLayout.smargin).isActive = true
            self.addSubview(self.correctedIcons)
            self.correctedIcons.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.margin).isActive = true
            self.correctedIcons.topAnchor.constraint(equalTo: self.correctedFeedback.bottomAnchor, constant: HomeLayout.margins).isActive = true
            self.correctedIcons.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -HomeLayout.margin).isActive = true
            self.addSubview(self.correctedLabel)
            self.correctedLabel.trailingAnchor.constraint(equalTo: self.correctedIcons.leadingAnchor, constant: -HomeLayout.margin).isActive = true
            self.correctedLabel.centerYAnchor.constraint(equalTo: self.correctedIcons.centerYAnchor).isActive = true
            self.correctedLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor, constant: HomeLayout.margin).isActive = true
            self.addSubview(self.starsView)
            self.starsView.centerYAnchor.constraint(equalTo: self.correctedFeedback.bottomAnchor).isActive = true
            self.starsView.trailingAnchor.constraint(equalTo: self.correctedFeedback.trailingAnchor).isActive = true
        }
        
        unowned(unsafe) var scaleTeam: IntraScaleTeam!
        func update(with scaleTeam: IntraScaleTeam) {
            var userProfilIconView: UserProfilIconView!
            
            self.scaleTeam = scaleTeam
            self.correctorIcon.update(with: scaleTeam.corrector)
            self.correctorIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ScaleTeamView.userProfilIconTapped(sender:))))
            self.correctorLabel.text = scaleTeam.corrector.login
            self.correctorComment.text = scaleTeam.comment
            
            if let note = scaleTeam.feedbacks.first?.rating, note >= 0 && note <= 5 {
                self.starsView.note = note
                switch note {
                case 0 ... 2:
                    self.starsView.primary = HomeDesign.redError
                case 3:
                    self.starsView.primary = HomeDesign.actionOrange
                default:
                    self.starsView.primary = HomeDesign.greenSuccess
                }
            }
            else {
                self.starsView.note = 1
                self.starsView.primary = HomeDesign.redError
            }
            self.correctedFeedback.text = scaleTeam.feedback
            if scaleTeam.flag.positive == false && scaleTeam.flag.name == "Cheat" {
                self.flagView.backgroundColor = HomeDesign.actionRed
                self.flagView.text = ~"general.cheater"
            }
            else {
                self.flagView.backgroundColor = IntraUserProject.finalMarkColor(scaleTeam.final_mark ?? 100)
                self.flagView.text = "\(scaleTeam.final_mark ?? 100)"
            }
            for (index, corrected) in scaleTeam.correcteds.enumerated() {
                if index >= self.correctedIcons.arrangedSubviews.count {
                    userProfilIconView = UserProfilIconView(user: corrected)
                    userProfilIconView.setSize(HomeLayout.userProfilIconHeigth, HomeLayout.userProfilIconRadius)
                    userProfilIconView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ScaleTeamView.userProfilIconTapped(sender:))))
                    self.correctedIcons.addArrangedSubview(userProfilIconView)
                }
                else {
                    userProfilIconView = (self.correctedIcons.arrangedSubviews[index] as! UserProfilIconView)
                    userProfilIconView.isHidden = false
                    userProfilIconView.update(with: corrected)
                }
            }
            if self.correctedIcons.arrangedSubviews.count > scaleTeam.correcteds.count {
                for index in scaleTeam.correcteds.count ..< self.correctedIcons.arrangedSubviews.count {
                    (self.correctedIcons.arrangedSubviews[index] as! UserProfilIconView).isHidden = true
                }
            }
            self.correctedLabel.text = scaleTeam.correcteds.map(\.login).joined(separator: " ")
            self.backgroundColor = self.flagView.backgroundColor!.withAlphaComponent(HomeDesign.alphaLowLayer)
            self.setNeedsDisplay()
        }
        
        override func draw(_ rect: CGRect) {
            super.draw(rect)
            HomeDesign.lightGray.setFill()
            UIBezierPath(roundedRect: self.correctorComment.frame.insetBy(dx: -HomeLayout.smargin, dy: 0.0), cornerRadius: HomeLayout.scorner).fill()
            UIBezierPath(roundedRect: self.correctedFeedback.frame.insetBy(dx: -HomeLayout.smargin, dy: 0.0), cornerRadius: HomeLayout.scorner).fill()
        }
        
        @objc private func userProfilIconTapped(sender: UITapGestureRecognizer) {
            guard let parent = self.parentHomeViewController else {
                return
            }
            let vc = ProfilViewController()
            let login = (sender.view as! UserProfilIconView).login!
            let id: Int
            
            if self.scaleTeam.corrector.login == login {
                id = self.scaleTeam.corrector.id
            }
            else {
                id = self.scaleTeam.correcteds.first(where: { $0.login == login })?.id ?? self.scaleTeam.corrector.id
            }
            parent.presentWithBlur(vc)
            Task.init(priority: .userInitiated, operation: {
                await vc.setupWithUser(login, id: id)
            })
        }
    }
}
