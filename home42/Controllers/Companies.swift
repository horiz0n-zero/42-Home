// home42/Companies.swift
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

final class CompaniesViewController: HomeViewController {
    
    private let tableView: GenericSingleInfiniteRequestTableView<HomeFramingTableViewCell<CompanieView>, IntraOffer>
    
    required init() {
        self.tableView = .init(.offers, parameters: ["sort": "-created_at", "filter[valid]": true], pageSize: 100)
        super.init()
        self.tableView.block = self.offerSelected(_:)
        self.tableView.contentInsetAdjustTopConstant(HomeLayout.safeAeraMain.top + HomeLayout.smargin, bottom: HomeLayout.safeAeraMain.bottom + HomeLayout.smargin)
        self.tableView.backgroundColor = UIColor.clear
        self.view.addSubview(self.tableView)
        self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.tableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        self.tableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        Task.init(priority: .userInitiated, operation: {
            self.tableView.nextPage()
        })
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
    private func offerSelected(_ offer: IntraOffer) {
        
        func seeDetails() {
            self.present(SafariWebView(offer.intraUrl, addUserCookies: true, primaryColor: HomeDesign.primary), animated: true)
        }
        
        DynamicAlert(.none, contents: [.titleWithPrimary(offer.title, HomeDesign.primary), .text(offer.big_description)], actions: [.normal(~"general.ok", nil), .highligth(~"general.see", seeDetails)])
    }
    
    final class CompanieView: BasicUIView, HomeFramingTableViewCellView {
        static var edges: UIEdgeInsets = .init(top: HomeLayout.margin, left: HomeLayout.margin, bottom: HomeLayout.margin, right: HomeLayout.margin)
        
        fileprivate let titleLabel: BasicUILabel
        private let descriptionLabelBackground: BasicUIView
        fileprivate let descriptionLabel: BasicUILabel
        fileprivate let contractTypeLabel: HomeInsetsLabel
        
        override init() {
            self.titleLabel = .init(text: "???")
            self.titleLabel.font = HomeLayout.fontBoldTitle
            self.titleLabel.textColor = HomeDesign.black
            self.titleLabel.numberOfLines = 3
            self.titleLabel.textAlignment = .left
            self.descriptionLabelBackground = BasicUIView()
            self.descriptionLabelBackground.backgroundColor = HomeDesign.primary.withAlphaComponent(HomeDesign.alphaLowLayer)
            self.descriptionLabelBackground.layer.cornerRadius = HomeLayout.scorner
            self.descriptionLabelBackground.layer.masksToBounds = true
            self.descriptionLabel = .init(text: "???")
            self.descriptionLabel.font = HomeLayout.fontRegularNormal
            self.descriptionLabel.textColor = HomeDesign.black
            self.descriptionLabel.numberOfLines = 0
            self.descriptionLabel.textAlignment = .left
            self.contractTypeLabel = .init(text: "???", inset: .init(width: HomeLayout.margin, height: HomeLayout.smargin))
            self.contractTypeLabel.numberOfLines = 0
            self.contractTypeLabel.textColor = HomeDesign.white
            self.contractTypeLabel.font = HomeLayout.fontSemiBoldMedium
            self.contractTypeLabel.textAlignment = .center
            self.contractTypeLabel.layer.cornerRadius = HomeLayout.corner
            self.contractTypeLabel.layer.masksToBounds = true
            self.contractTypeLabel.backgroundColor = HomeDesign.primary
            super.init()
            self.backgroundColor = HomeDesign.white
            self.layer.cornerRadius = HomeLayout.corner
        }
        required init?(coder: NSCoder) { fatalError() }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }
            self.addSubview(self.titleLabel)
            self.titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: HomeLayout.margin).isActive = true
            self.titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: HomeLayout.margin).isActive = true
            self.titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.smargin).isActive = true
            self.addSubview(self.descriptionLabelBackground)
            self.descriptionLabelBackground.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: HomeLayout.smargin).isActive = true
            self.descriptionLabelBackground.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor).isActive = true
            self.descriptionLabelBackground.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.margin).isActive = true
            self.descriptionLabelBackground.addSubview(self.descriptionLabel)
            self.descriptionLabel.topAnchor.constraint(equalTo: self.descriptionLabelBackground.topAnchor, constant: HomeLayout.smargin).isActive = true
            self.descriptionLabel.leadingAnchor.constraint(equalTo: self.descriptionLabelBackground.leadingAnchor, constant: HomeLayout.smargin).isActive = true
            self.descriptionLabel.trailingAnchor.constraint(equalTo: self.descriptionLabelBackground.trailingAnchor, constant: -HomeLayout.margin).isActive = true
            self.descriptionLabel.bottomAnchor.constraint(equalTo: self.descriptionLabelBackground.bottomAnchor, constant: -HomeLayout.smargin).isActive = true
            self.addSubview(self.contractTypeLabel)
            self.contractTypeLabel.centerYAnchor.constraint(equalTo: self.topAnchor).isActive = true
            self.contractTypeLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.margin).isActive = true
            self.descriptionLabelBackground.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -HomeLayout.margin).isActive = true
        }
    }
}

extension HomeFramingTableViewCell: GenericSingleInfiniteRequestCell where G: CompaniesViewController.CompanieView {
    
    func fill(with element: IntraOffer) {
        self.view.titleLabel.text = element.title
        self.view.descriptionLabel.text = element.little_description
        self.view.contractTypeLabel.text = ~element.contract_type.key
    }
}
