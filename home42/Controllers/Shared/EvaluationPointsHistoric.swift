// home42/EvaluationPointsHistoric.swift
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

final class EvaluationPointsHistoricViewController: HomeViewController, UserSearchFieldViewDelegate {
    
    private let header: HeaderWithActionsView
    private let userSearchFieldView: UserSearchFieldView
    private let tableView: GenericSingleInfiniteRequestTableView<EvaluationPointsHistoricViewControllerCell, IntraEvaluationPointHistoric>
    
    init(userId: Int, userLogin: String, userImage: IntraUser.Image, primary: UIColor) {
        self.header = .init(title: ~"profil.info.evaluation-points")
        self.userSearchFieldView = UserSearchFieldView(user: .init(id: userId, login: userLogin, image: userImage), primary: primary)
        self.tableView = .init(.usersWithUserIdCorrectionPointHistorics(userId), parameters: ["sort":"-created_at"])
        super.init()
        self.view.backgroundColor = HomeDesign.white
        self.view.addSubview(self.header)
        self.header.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.header.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.header.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.userSearchFieldView)
        self.userSearchFieldView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: HomeLayout.margin).isActive = true
        self.userSearchFieldView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -HomeLayout.margin).isActive = true
        self.userSearchFieldView.topAnchor.constraint(equalTo: self.header.bottomAnchor, constant: HomeLayout.margin).isActive = true
        self.userSearchFieldView.delegate = self
        self.tableView.topAnchor.constraint(equalTo: self.userSearchFieldView.centerYAnchor).isActive = true
        self.tableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        self.tableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.tableView.contentInsetAdjustTopConstant(HomeLayout.roundedGenericActionsViewRadius + HomeLayout.margin)
        self.tableView.block = self.evaluationPointHistoricSelect(_:)
        self.tableView.nextPage()
    }
    required init() { fatalError() }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func userSearchFieldViewSelect(view: UserSearchFieldView, user: IntraUserInfo) {
        self.tableView.route = .usersWithUserIdCorrectionPointHistorics(user.id)
        self.tableView.reset()
        self.tableView.nextPage()
    }
    
    private func evaluationPointHistoricSelect(_ evaluationPointHistoric: IntraEvaluationPointHistoric) {
        dump(evaluationPointHistoric)
        //scale_team_id?
    }
    
    final class EvaluationPointsHistoricViewControllerCell: BasicUITableViewCell, GenericSingleInfiniteRequestCell {
        
        private let container: BasicUIView
        private let totalLabel: BasicUILabel
        private let sumLabel: BasicUILabel
        private let reasonLabel: BasicUILabel
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            self.container = BasicUIView()
            self.container.backgroundColor = HomeDesign.lightGray
            self.container.layer.cornerRadius = HomeLayout.corner
            self.container.layer.masksToBounds = true
            self.totalLabel = BasicUILabel(text: "???")
            self.totalLabel.layer.cornerRadius = HomeLayout.scorner
            self.totalLabel.layer.masksToBounds = true
            self.totalLabel.font = HomeLayout.fontBlackBigTitle
            self.totalLabel.textColor = HomeDesign.white
            self.totalLabel.textAlignment = .center
            self.sumLabel = BasicUILabel(text: "???")
            self.sumLabel.layer.cornerRadius = HomeLayout.scorner
            self.sumLabel.layer.masksToBounds = true
            self.sumLabel.font = HomeLayout.fontBoldNormal
            self.sumLabel.textColor = HomeDesign.white
            self.sumLabel.textAlignment = .center
            self.sumLabel.adjustsFontSizeToFitWidth = true
            self.reasonLabel = BasicUILabel(text: "???")
            self.reasonLabel.adjustsFontSizeToFitWidth = true
            self.reasonLabel.numberOfLines = 0
            self.reasonLabel.textColor = HomeDesign.black
            self.reasonLabel.font = HomeLayout.fontRegularMedium
            super.init(style: style, reuseIdentifier: reuseIdentifier)
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }
            
            self.contentView.addSubview(self.container)
            self.container.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: HomeLayout.margin).isActive = true
            self.container.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -HomeLayout.margin).isActive = true
            self.container.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: HomeLayout.smargin).isActive = true
            self.container.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -HomeLayout.smargin).isActive = true
            self.container.addSubview(self.totalLabel)
            self.totalLabel.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: HomeLayout.smargin).isActive = true
            self.totalLabel.topAnchor.constraint(equalTo: self.container.topAnchor, constant: HomeLayout.smargin).isActive = true
            self.totalLabel.bottomAnchor.constraint(equalTo: self.container.bottomAnchor, constant: -HomeLayout.smargin).isActive = true
            self.totalLabel.heightAnchor.constraint(equalTo: self.totalLabel.widthAnchor, multiplier: 1.0).isActive = true
            self.totalLabel.widthAnchor.constraint(equalTo: self.container.widthAnchor, multiplier: 0.25).isActive = true
            self.container.addSubview(self.sumLabel)
            self.sumLabel.leadingAnchor.constraint(equalTo: self.totalLabel.trailingAnchor, constant: HomeLayout.smargin).isActive = true
            self.sumLabel.bottomAnchor.constraint(equalTo: self.totalLabel.bottomAnchor).isActive = true
            self.sumLabel.heightAnchor.constraint(equalTo: self.totalLabel.widthAnchor, multiplier: 0.5).isActive = true
            self.sumLabel.widthAnchor.constraint(equalTo: self.sumLabel.heightAnchor, multiplier: 1.0).isActive = true
            self.container.addSubview(self.reasonLabel)
            self.reasonLabel.bottomAnchor.constraint(equalTo: self.sumLabel.topAnchor, constant: -HomeLayout.smargin).isActive = true
            self.reasonLabel.topAnchor.constraint(equalTo: self.totalLabel.topAnchor, constant: HomeLayout.smargin).isActive = true
            self.reasonLabel.leadingAnchor.constraint(equalTo: self.sumLabel.leadingAnchor).isActive = true
            self.reasonLabel.trailingAnchor.constraint(equalTo: self.container.trailingAnchor, constant: -HomeLayout.smargin).isActive = true
        }
        
        func fill(with element: IntraEvaluationPointHistoric) {
            let color: UIColor
            
            if element.sum < 0 {
                color = HomeDesign.redError
                self.sumLabel.text = "\(element.sum)"
            }
            else if element.sum > 0 {
                color = HomeDesign.greenSuccess
                self.sumLabel.text = "+\(element.sum)"
            }
            else {
                color = HomeDesign.blueAccess
            }
            self.totalLabel.text = "\(element.total + element.sum)"
            self.reasonLabel.text = element.reason
            self.container.backgroundColor = HomeDesign.lightGray
            self.totalLabel.backgroundColor = color.withAlphaComponent(HomeDesign.alphaLayer)
            self.sumLabel.backgroundColor = self.totalLabel.backgroundColor
        }
    }
}
