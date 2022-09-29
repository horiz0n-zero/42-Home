// home42/EventFeedbacksHistoric.swift
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

final class EventFeedbacksHistoricViewController: HomeViewController, UserSearchFieldViewDelegate {
    
    private let header: HeaderWithActionsView
    private let userSearchField: UserSearchFieldView?
    private let gradientTop: GradientView
    private let tableView: GenericSingleInfiniteRequestTableView<EventFeedbackCell, IntraFeedback>
    
    convenience init(event: IntraEvent) {
        self.init(headerTitle: event.name, route: .eventsWithEventIdFeedbacks(event.id), parameters: ["sort":"-created_at"], addUserSearchField: false)
    }
    required convenience init() {
        self.init(headerTitle: ~"general.feedbacks", route: .feedbacks, parameters: ["sort":"-created_at", "filter[user_id]": App.user.id, "filter[feedbackable_type]": "Event"], addUserSearchField: true)
    }
    
    private init(headerTitle: String, route: HomeApi.Routes, parameters: [String : Any]?, addUserSearchField: Bool) {
        self.header = HeaderWithActionsView(title: headerTitle, actions: nil)
        if addUserSearchField {
            self.userSearchField = UserSearchFieldView(user: .init(id: App.user.id, login: App.user.login, image_url: App.user.image_url), primary: HomeDesign.primary)
        }
        else {
            self.userSearchField = nil
        }
        self.gradientTop = GradientView()
        self.gradientTop.startPoint = .init(x: 0.5, y: 0.0)
        self.gradientTop.endPoint = .init(x: 0.5, y: 1.0)
        self.gradientTop.colors = [HomeDesign.white.cgColor, UIColor.init(white: 1.0, alpha: 0.0).cgColor]
        self.tableView = .init(route, parameters: parameters, page: 1, pageSize: 100)
        self.tableView.contentInset = .init(top: HomeLayout.margin, left: 0.0, bottom: 0.0, right: 0.0)
        super.init()
        self.view.backgroundColor = HomeDesign.white
        self.view.addSubview(self.header)
        self.header.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.header.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.header.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.view.addSubview(self.tableView)
        if let userSearchField = self.userSearchField {
            self.view.addSubview(userSearchField)
            userSearchField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: HomeLayout.margin).isActive = true
            userSearchField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -HomeLayout.margin).isActive = true
            userSearchField.topAnchor.constraint(equalTo: self.header.bottomAnchor, constant: HomeLayout.margin).isActive = true
            userSearchField.delegate = self
            self.tableView.topAnchor.constraint(equalTo: userSearchField.bottomAnchor).isActive = true
        }
        else {
            self.tableView.topAnchor.constraint(equalTo: self.header.bottomAnchor).isActive = true
        }
        self.tableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        self.tableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.view.addSubview(self.gradientTop)
        self.gradientTop.topAnchor.constraint(equalTo: self.tableView.topAnchor).isActive = true
        self.gradientTop.leadingAnchor.constraint(equalTo: self.tableView.leadingAnchor).isActive = true
        self.gradientTop.trailingAnchor.constraint(equalTo: self.tableView.trailingAnchor).isActive = true
        self.gradientTop.heightAnchor.constraint(equalToConstant: HomeLayout.margin).isActive = true
        self.tableView.nextPage()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func userSearchFieldViewSelect(view: UserSearchFieldView, user: IntraUserInfo) {
        self.tableView.restart(with: ["sort":"-created_at", "filter[user_id]": user.id, "filter[feedbackable_type]": "Event"])
    }
    
    final private class EventFeedbackCell: BasicUITableViewCell, GenericSingleInfiniteRequestCell {
        
        let view: EventFeedbackView = EventFeedbackView()
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }
           
            self.contentView.addSubview(self.view)
            self.view.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: HomeLayout.smargin).isActive = true
            self.view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -HomeLayout.smargin).isActive = true
            self.view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: HomeLayout.margin).isActive = true
            self.view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -HomeLayout.margin).isActive = true
        }
        
        func fill(with element: IntraFeedback) {
            self.view.update(with: element)
        }
    }
    
    final class EventFeedbackView: BasicUIView, HomeFramingTableViewCellView {
        static var edges: UIEdgeInsets = .init(top: HomeLayout.smargin, left: HomeLayout.margin, bottom: HomeLayout.smargin, right: HomeLayout.margin)
        private let userIcon: UserProfilIconView
        private let userLabel: BasicUILabel
        
        private let userComment: HomeInsetsLabel
        private let starsView: StarsView
        
        override init() {
            self.userIcon = UserProfilIconView()
            self.userLabel = BasicUILabel(text: "???")
            self.userLabel.font = HomeLayout.fontSemiBoldNormal
            self.userLabel.textColor = HomeDesign.black
            self.userLabel.textAlignment = .left
            self.userComment = HomeInsetsLabel(text: "???", inset: .init(width: HomeLayout.margin, height: HomeLayout.margins))
            self.userComment.numberOfLines = 20
            self.userComment.font = HomeLayout.fontRegularNormal
            self.userComment.textColor = HomeDesign.black
            self.userComment.textAlignment = .left
            self.starsView = StarsView()
            super.init()
            self.layer.cornerRadius = HomeLayout.corner
            self.layer.masksToBounds = true
            self.backgroundColor = HomeDesign.lightGray
            self.userIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(EventFeedbackView.userProfilIconTapped(sender:))))
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }
            
            self.addSubview(self.userIcon)
            self.userIcon.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: HomeLayout.margin).isActive = true
            self.userIcon.topAnchor.constraint(equalTo: self.topAnchor, constant: HomeLayout.margin).isActive = true
            self.userIcon.setSize(HomeLayout.userProfilIconHeigth, HomeLayout.userProfilIconRadius)
            self.addSubview(self.userLabel)
            self.userLabel.leadingAnchor.constraint(equalTo: self.userIcon.trailingAnchor, constant: HomeLayout.margin).isActive = true
            self.userLabel.centerYAnchor.constraint(equalTo: self.userIcon.centerYAnchor).isActive = true
            
            self.addSubview(self.userComment)
            self.userComment.leadingAnchor.constraint(equalTo: self.userIcon.leadingAnchor, constant: 0.0).isActive = true
            self.userComment.topAnchor.constraint(equalTo: self.userIcon.bottomAnchor, constant: HomeLayout.margins).isActive = true
            self.userComment.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.margin).isActive = true
            
            self.addSubview(self.starsView)
            self.starsView.topAnchor.constraint(equalTo: self.userComment.bottomAnchor, constant: HomeLayout.smargin).isActive = true
            self.starsView.trailingAnchor.constraint(equalTo: self.userComment.trailingAnchor, constant: 0.0).isActive = true
            self.starsView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -HomeLayout.smargin).isActive = true
        }
        
        private weak var feedback: IntraFeedback! = nil
        func update(with feedback: IntraFeedback) {
            self.feedback = feedback
            self.userIcon.update(with: feedback.user)
            self.userLabel.text = feedback.user.login
            self.userComment.text = feedback.comment
            self.starsView.note = feedback.rating
            self.backgroundColor = feedback.ratingColor.withAlphaComponent(HomeDesign.alphaLowLayer)
            self.setNeedsDisplay()
        }
        
        override func draw(_ rect: CGRect) {
            super.draw(rect)
            HomeDesign.lightGray.setFill()
            UIBezierPath(roundedRect: self.userComment.frame.insetBy(dx: -HomeLayout.smargin, dy: 0.0), cornerRadius: HomeLayout.scorner).fill()
        }
        
        @objc private func userProfilIconTapped(sender: UITapGestureRecognizer) {
            guard self.feedback != nil, let parent = self.parentHomeViewController else { return }
            
            let vc = ProfilViewController()
            
            parent.presentWithBlur(vc)
            Task.init(priority: .userInitiated, operation: {
                await vc.setupWithUser(self.feedback.user.login, id: self.feedback.user.id)
            })
        }
    }
}
