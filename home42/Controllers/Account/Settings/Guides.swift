// home42/Guides.swift
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
import PDFKit
import QuickLook

final class GuidesViewController: HomeViewController, UITableViewDataSource, UITableViewDelegate,
                                  UIDocumentInteractionControllerDelegate {
    
    private struct Guide: Codable {
        let title: String
        let description: String
        let video: String
        let version: String
        let coalition: IntraCoalition?
    }
    private let guides: [Guide]
    
    private let header: DarkBlurHeaderWithActionsView
    private let tableView: BasicUITableView
    
    required init() {
        self.header = DarkBlurHeaderWithActionsView(icon: .settingsGuides, title: ~"settings.extra.guides")
        self.tableView = BasicUITableView()
        self.tableView.register(GuideTableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.contentInsetAdjustTopConstant(HomeLayout.headerWithActionViewHeigth + HomeLayout.safeAera.top + HomeLayout.margin, bottom: HomeLayout.safeAera.bottom + HomeLayout.margin)
        
        func readFile<G: Codable>(_ filename: String) -> G {
            let file = try! Data(contentsOf: HomeResources.applicationDirectory.appendingPathComponent(filename))
            let elements = try! JSONDecoder.decoder.decode(G.self, from: file)
            
            return elements
        }
        
        self.guides = readFile("res/guides/guides.json")
        super.init()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = .clear
        self.view.backgroundColor = HomeDesign.black
        self.view.addSubview(self.tableView)
        self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.view.addSubview(self.header)
        self.header.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.header.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.header.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
    }
    required init?(coder: NSCoder) { fatalError("") }
    
    final private class GuideTableViewCell: BasicUITableViewCell {
        
        let container: BasicUIView
        let title: CoalitionBackgroundWithParallaxLabel
        let subtitle: BasicUILabel
        let version: CoalitionMaskView<EventPeopleCurvedView>
        let versionLabel: BasicUILabel
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            self.container = BasicUIView()
            self.container.layer.masksToBounds = true
            self.container.layer.cornerRadius = HomeLayout.corners
            self.container.backgroundColor = HomeDesign.white
            self.title = CoalitionBackgroundWithParallaxLabel(text: "")
            self.title.font = HomeLayout.fontBoldTitle
            self.title.numberOfLines = 1
            self.title.adjustsFontSizeToFitWidth = true
            self.subtitle = BasicUILabel(text: "")
            self.subtitle.font = HomeLayout.fontRegularMedium
            self.subtitle.numberOfLines = 0
            self.version = CoalitionMaskView(EventPeopleCurvedView(text: "?.?.?",
                                                                   primaryColor: HomeDesign.primary,
                                                                   secondaryColor: HomeDesign.primary))
            self.versionLabel = BasicUILabel(text: "")
            self.versionLabel.font = HomeLayout.fontBoldMedium
            self.versionLabel.textColor = HomeDesign.white
            self.versionLabel.textAlignment = .right
            super.init(style: style, reuseIdentifier: reuseIdentifier)
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else {
                return
            }
            
            self.contentView.addSubview(self.container)
            self.container.topAnchor.constraint(equalTo: self.contentView.topAnchor,
                                                constant: 0.0).isActive = true
            self.container.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor,
                                                    constant: HomeLayout.margin).isActive = true
            self.container.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor,
                                                     constant: -HomeLayout.margin).isActive = true
            self.container.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor,
                                                   constant: -HomeLayout.margin).isActive = true
            self.container.addSubview(self.title)
            self.title.heightAnchor.constraint(equalToConstant: 24.0).isActive = true
            self.title.leadingAnchor.constraint(equalTo: self.container.leadingAnchor,
                                                constant: HomeLayout.margin).isActive = true
            self.title.topAnchor.constraint(equalTo: self.container.topAnchor,
                                            constant: HomeLayout.margin).isActive = true
            self.title.trailingAnchor.constraint(equalTo: self.container.trailingAnchor,
                                                 constant: -HomeLayout.margin).isActive = true
            self.container.addSubview(self.subtitle)
            self.subtitle.topAnchor.constraint(equalTo: self.title.bottomAnchor,
                                               constant: HomeLayout.margin).isActive = true
            self.subtitle.leadingAnchor.constraint(equalTo: self.title.leadingAnchor).isActive = true
            self.subtitle.trailingAnchor.constraint(equalTo: self.title.trailingAnchor).isActive = true
            self.container.addSubview(self.version)
            self.version.topAnchor.constraint(equalTo: self.subtitle.bottomAnchor,
                                              constant: HomeLayout.smargin).isActive = true
            self.version.leadingAnchor.constraint(equalTo: self.container.leadingAnchor).isActive = true
            self.version.trailingAnchor.constraint(equalTo: self.container.trailingAnchor).isActive = true
            self.version.bottomAnchor.constraint(equalTo: self.container.bottomAnchor).isActive = true
            self.container.addSubview(self.versionLabel)
            self.versionLabel.trailingAnchor.constraint(equalTo: self.container.trailingAnchor,
                                                        constant: -(HomeLayout.margins + HomeLayout.smargin)).isActive = true
            self.versionLabel.bottomAnchor.constraint(equalTo: self.version.bottomAnchor).isActive = true
            self.versionLabel.topAnchor.constraint(equalTo: self.version.topAnchor).isActive = true
        }
        
        func update(with guide: Guide) {
            self.title.coalition = guide.coalition
            self.title.text = ~guide.title
            self.subtitle.text = ~guide.description
            self.version.coalition = guide.coalition
            self.version.view.text = "\(guide.version)"
            self.versionLabel.text = self.version.view.text!
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.guides.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! GuideTableViewCell
        
        cell.update(with: self.guides[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let guide = self.guides[indexPath.row]
        
        DynamicActionsSheet.presentWithWebLink(guide.video, primary: HomeDesign.primary, parentViewController: self)
    }
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
}
