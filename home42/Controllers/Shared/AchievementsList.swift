// home42/AchievementsList.swift
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

final class AchievementsListViewController: HomeViewController, SearchFieldViewDelegate, AdjustableParametersProviderDelegate {
    
    private let header: HeaderWithActionsBase
    var headerTitle: String {
        set { self.header.title = newValue }
        get { return self.header.title }
    }
    private let searchField: SearchFieldViewWithTimer
    private let settingsButton: ActionButtonView
    private var settings: AdjustableParametersProviderViewController<AchievementsListViewController>!
    private let tableView: GenericSingleInfiniteRequestTableView<AchievementTableViewCell, IntraUserAchievement>
    private let gradientView: GradientView
    
    let primary: UIColor
    
    static let defaultParameters: [String: Any] = [:]
    static let searchParameter: AdjustableParametersProviderViewController<AchievementsListViewController>.SearchParameter? = .init(title: "field.search-description",
                                                                                                                                    keys: [.searchName, .searchDescription],
                                                                                                                                    keysName: ["sort.name", "sort.description"],
                                                                                                                                    textGetter: \.searchField.text)
    static let parameters: [AdjustableParametersProviderViewController<AchievementsListViewController>.Parameter] = [
        .init(key: .sort, source: .achievementSort, selectorType: .string, selectorTitleKey: "field.sort-message", selectorInlineWithNextElement: false, selectorCanSelectNULL: false)
    ]
    
    required init() {
        self.primary = HomeDesign.primary
        self.header = HeaderWithActionsView(title: ~"title.achievements")
        self.searchField = SearchFieldViewWithTimer()
        self.searchField.setPrimary(self.primary)
        self.settingsButton = ActionButtonView(asset: .actionSettings, color: self.primary)
        self.tableView = .init(.campusWithCampusIdAchievements(App.userCampus.campus_id))
        self.gradientView = GradientView()
        self.gradientView.startPoint = .init(x: 0.5, y: 0.0)
        self.gradientView.endPoint = .init(x: 0.5, y: 1.0)
        self.gradientView.colors = [HomeDesign.white.cgColor, UIColor.init(white: 1.0, alpha: 0.0).cgColor]
        super.init()
        self.settings = .init(delegate: self, defaultParameters: [:], extra: .achievementCampus)
        self.view.backgroundColor = HomeDesign.white
        self.searchField.delegate = self
        self.view.addSubview(self.header)
        self.header.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.header.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.header.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.view.addSubview(self.searchField)
        self.searchField.topAnchor.constraint(equalTo: self.header.bottomAnchor, constant: HomeLayout.margin).isActive = true
        self.searchField.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: HomeLayout.margin).isActive = true
        self.view.addSubview(self.settingsButton)
        self.settingsButton.leadingAnchor.constraint(equalTo: self.searchField.trailingAnchor, constant: HomeLayout.margin).isActive = true
        self.settingsButton.centerYAnchor.constraint(equalTo: self.searchField.centerYAnchor).isActive = true
        self.settingsButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -HomeLayout.margin).isActive = true
        self.view.addSubview(self.tableView)
        self.tableView.topAnchor.constraint(equalTo: self.searchField.bottomAnchor).isActive = true
        self.tableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        self.tableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.tableView.contentInset = .init(top: HomeLayout.margin, left: 0.0, bottom: HomeLayout.safeAera.bottom, right: 0.0)
        self.view.addSubview(self.gradientView)
        self.gradientView.topAnchor.constraint(equalTo: self.tableView.topAnchor).isActive = true
        self.gradientView.leadingAnchor.constraint(equalTo: self.tableView.leadingAnchor).isActive = true
        self.gradientView.trailingAnchor.constraint(equalTo: self.tableView.trailingAnchor).isActive = true
        self.gradientView.heightAnchor.constraint(equalToConstant: HomeLayout.margin).isActive = true
        self.settingsButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(AchievementsListViewController.settingsButtonTapped(sender:))))
        self.tableView.block = self.achievementSelected(achievement:)
        self.tableView.parameters = self.settings.parameters
        self.tableView.nextPage()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func adjustableParametersProviderExtraValueSelected(_ newTitle: String, newRoute: HomeApi.Routes) {
        self.headerTitle = newTitle
        self.tableView.route = newRoute
    }
    
    func adjustableParametersProviderParametersUpdated(_ newParameters: [String : Any]) {
        self.tableView.reset()
        self.tableView.parameters = newParameters
        self.tableView.nextPage()
    }
    
    // MARK: -
    func searchFieldBeginEditing(_ searchField: SearchFieldView) { }
    func searchFieldEndEditing(_ searchField: SearchFieldView) { }
    func searchFieldTextUpdated(_ searchField: SearchFieldView) {
        self.tableView.reset()
        self.tableView.parameters = self.settings.parameters
        self.tableView.nextPage()
    }
    
    private func achievementSelected(achievement: IntraUserAchievement) {
        self.presentWithBlur(UsersListViewController(.achievementsWithAchievementIdUsers(achievement.id), extra: .achievement(achievement)))
    }
    
    @objc private func settingsButtonTapped(sender: UITapGestureRecognizer) {
        self.presentWithBlur(self.settings)
    }
    
    static let canExport: Bool = false
    func adjustableParametersProviderWillExport() -> String { fatalError() }
    
    final class AchievementTableViewCell: BasicUITableViewCell, GenericSingleInfiniteRequestCell {
        
        private let view: AchievementView = AchievementView()
        static private let edges: UIEdgeInsets = .init(top: HomeLayout.margin, left: HomeLayout.margin, bottom: 0.0, right: HomeLayout.margin)
        
        func fill(with element: IntraUserAchievement) {
            self.view.update(with: element, primary: HomeDesign.primary)
        }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }
            
            self.contentView.addSubview(self.view)
            self.view.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: Self.edges.top).isActive = true
            self.view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -Self.edges.bottom).isActive = true
            self.view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: Self.edges.left).isActive = true
            self.view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -Self.edges.right).isActive = true
        }
    }
    
    final class AchievementView: BasicUIView, HomeFramingTableViewCellView {
        static var edges: UIEdgeInsets = HomeLayout.profilCellInsets
        
        private let imageView: BasicUIImageView
        private let nameLabel: BasicUILabel
        private let descriptionContainer: BasicUIView
        private let descriptionLabel: BasicUILabel
        
        override init() {
            self.imageView = .init(image: nil)
            self.imageView.contentMode = .scaleAspectFill
            self.imageView.layer.cornerRadius = HomeLayout.scorner
            self.imageView.layer.masksToBounds = true
            self.nameLabel = BasicUILabel(text: "???")
            self.nameLabel.font = HomeLayout.fontSemiBoldTitle
            self.nameLabel.textColor = HomeDesign.black
            self.nameLabel.numberOfLines = 0
            self.descriptionContainer = BasicUIView()
            self.descriptionContainer.layer.cornerRadius = HomeLayout.scorner
            self.descriptionLabel = BasicUILabel(text: "???")
            self.descriptionLabel.font = HomeLayout.fontRegularMedium
            self.descriptionLabel.textColor = HomeDesign.black
            self.descriptionLabel.numberOfLines = 0
            super.init()
            self.layer.cornerRadius = HomeLayout.scorner
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }
          
            self.addSubview(self.imageView)
            self.imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: HomeLayout.margin).isActive = true
            self.imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: HomeLayout.margin).isActive = true
            self.imageView.heightAnchor.constraint(equalToConstant: HomeLayout.profilAchievementImageSize).isActive = true
            self.imageView.widthAnchor.constraint(equalToConstant: HomeLayout.profilAchievementImageSize).isActive = true
            self.addSubview(self.nameLabel)
            self.nameLabel.leadingAnchor.constraint(equalTo: self.imageView.trailingAnchor, constant: HomeLayout.margin).isActive = true
            self.nameLabel.centerYAnchor.constraint(equalTo: self.imageView.centerYAnchor).isActive = true
            self.nameLabel.topAnchor.constraint(lessThanOrEqualTo: self.imageView.topAnchor).isActive = true
            self.nameLabel.bottomAnchor.constraint(lessThanOrEqualTo: self.imageView.bottomAnchor).isActive = true
            self.nameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.smargin).isActive = true
            self.addSubview(self.descriptionContainer)
            self.descriptionContainer.topAnchor.constraint(equalTo: self.imageView.bottomAnchor, constant: HomeLayout.margin).isActive = true
            self.descriptionContainer.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: HomeLayout.smargin).isActive = true
            self.descriptionContainer.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.smargin).isActive = true
            self.descriptionContainer.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -HomeLayout.smargin).isActive = true
            self.descriptionContainer.addSubview(self.descriptionLabel)
            self.descriptionLabel.topAnchor.constraint(equalTo: self.descriptionContainer.topAnchor, constant: HomeLayout.smargin).isActive = true
            self.descriptionLabel.leadingAnchor.constraint(equalTo: self.descriptionContainer.leadingAnchor, constant: HomeLayout.smargin).isActive = true
            self.descriptionLabel.trailingAnchor.constraint(equalTo: self.descriptionContainer.trailingAnchor, constant: -HomeLayout.smargin).isActive = true
            self.descriptionLabel.bottomAnchor.constraint(equalTo: self.descriptionContainer.bottomAnchor, constant: -HomeLayout.smargin).isActive = true
        }
        
        private unowned(unsafe) var achievement: IntraUserAchievement!
        
        func update(with achievement: IntraUserAchievement, primary: UIColor) {
            self.achievement = achievement
            if let image = HomeResources.storageSVGAchievement.get(achievement) {
                self.imageView.image = image
            }
            else {
                self.imageView.image = nil
                Task.init(priority: .userInitiated, operation: {
                    if let (achiev, image) = await HomeResources.storageSVGAchievement.obtain(achievement), achiev.id == self.achievement.id {
                        self.imageView.image = image
                    }
                })
            }
            self.nameLabel.text = achievement.name
            self.descriptionLabel.text = achievement.achievementDescription
            if achievement.visible {
                self.backgroundColor = HomeDesign.lightGray
                self.descriptionContainer.backgroundColor = primary.withAlphaComponent(HomeDesign.alphaLowLayer)
            }
            else {
                self.backgroundColor = HomeDesign.gold.withAlphaComponent(HomeDesign.alphaLowLayer)
                self.descriptionContainer.backgroundColor = HomeDesign.gold.withAlphaComponent(HomeDesign.alphaLowLayer)
            }
        }
    }
}
