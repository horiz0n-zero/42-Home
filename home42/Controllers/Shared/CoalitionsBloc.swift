// home42/CoalitionsBloc.swift
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

final class CoalitionsBlocViewController: HomeViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let header: HeaderWithActionsView
    private let tableView: BasicUITableView
    
    required init() {
        self.header = HeaderWithActionsView(title: ~"title.coalitions")
        self.tableView = BasicUITableView()
        self.tableView.register(CoalitionTableViewCell.self, forCellReuseIdentifier: "cell")
        super.init()
        self.view.backgroundColor = HomeDesign.white
        self.view.addSubview(self.header)
        self.header.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.header.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.header.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.view.addSubview(self.tableView)
        self.tableView.topAnchor.constraint(equalTo: self.header.bottomAnchor).isActive = true
        self.tableView.leadingAnchor.constraint(equalTo: self.header.leadingAnchor).isActive = true
        self.tableView.trailingAnchor.constraint(equalTo: self.header.trailingAnchor).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.isScrollEnabled = false
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: -
    private var bloc: IntraBlock!
        
    @MainActor func setup(with campusId: Int, cursusId: Int) async {
        async let blocs: [IntraBlock] = HomeApi.get(.blocs, params: ["filter[campus_id]": campusId,
                                                                     "filter[cursus_id]": cursusId])
        
        do {
            try await self.bloc = blocs[0]
            
            self.bloc.coalitions.sort(by: { $0.score > $1.score })
            self.tableView.reloadData()
        }
        catch {
            self.dismiss(animated: true, completion: nil)
            return DynamicAlert.presentWith(error: error as! HomeApi.RequestError)
        }
    }
    
    // MARK: -
    final private class CoalitionTableViewCell: BasicUITableViewCell {
        
        private let background: CoalitionBackgroundWithParallaxImageView
        private let flagView: CoalitionHorizontalFlagView
        private let container: BasicUIView
        private let scoreLabel: BasicUILabel
        private let trophyIcon: BasicUIImageView
        private let trophyLabel: BasicUILabel
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            self.background = CoalitionBackgroundWithParallaxImageView()
            self.background.clipsToBounds = true
            self.flagView = CoalitionHorizontalFlagView()
            self.container = BasicUIView()
            self.scoreLabel = BasicUILabel(text: "")
            self.scoreLabel.font = HomeLayout.fontMonospacedSemiBoldBigTitle
            self.scoreLabel.textColor = HomeDesign.white
            self.trophyIcon = .init(asset: .trophy)
            self.trophyIcon.tintColor = HomeDesign.white
            self.trophyLabel = .init(text: "")
            self.trophyLabel.font = HomeLayout.fontRegularMedium
            self.trophyLabel.textColor = HomeDesign.white
            self.trophyLabel.textAlignment = .center
            super.init(style: style, reuseIdentifier: reuseIdentifier)
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }
            
            self.contentView.addSubview(self.background)
            self.background.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
            self.background.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
            self.background.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
            self.background.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
            self.contentView.addSubview(self.flagView)
            self.flagView.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
            self.flagView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
            self.flagView.trailingAnchor.constraint(lessThanOrEqualTo: self.contentView.trailingAnchor, constant: -HomeLayout.margin).isActive = true
            self.contentView.addSubview(self.container)
            self.container.topAnchor.constraint(equalTo: self.flagView.bottomAnchor).isActive = true
            self.container.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
            self.container.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
            self.container.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
            self.container.addSubview(self.trophyIcon)
            self.trophyIcon.centerYAnchor.constraint(equalTo: self.container.centerYAnchor).isActive = true
            self.trophyIcon.trailingAnchor.constraint(equalTo: self.container.trailingAnchor, constant: -HomeLayout.margind).isActive = true
            self.trophyIcon.widthAnchor.constraint(equalToConstant: 50.0).isActive = true
            self.trophyIcon.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
            self.trophyIcon.addSubview(self.trophyLabel)
            self.trophyLabel.topAnchor.constraint(equalTo: self.trophyIcon.topAnchor, constant: 8.0).isActive = true
            self.trophyLabel.centerXAnchor.constraint(equalTo: self.trophyIcon.centerXAnchor).isActive = true
            self.container.addSubview(self.scoreLabel)
            self.scoreLabel.trailingAnchor.constraint(equalTo: self.trophyIcon.leadingAnchor, constant: -HomeLayout.margin).isActive = true
            self.scoreLabel.centerYAnchor.constraint(equalTo: self.trophyIcon.centerYAnchor).isActive = true
        }
        
        var coalition: IntraCoalition!
        func update(with coalition: IntraCoalition, position: Int, blocSize: Int) {
            self.coalition = coalition
            if let background = HomeResources.storageCoalitionsImages.get(coalition) {
                HomeAnimations.transitionQuick(withView: self.background, {
                    self.background.image = background
                })
            }
            else {
                self.background.image = UIImage.Assets.coalitionDefaultBackground.image
                Task.init(priority: .userInitiated, operation: {
                    if let (coa, background) = await HomeResources.storageCoalitionsImages.obtain(coalition), coa.id == coalition.id {
                        HomeAnimations.transitionQuick(withView: self.background, {
                            self.background.image = background
                        })
                    }
                })
            }
            self.flagView.update(with: coalition, position: position, blocSize: blocSize)
            self.scoreLabel.text = coalition.score.scoreFormatted
            self.trophyLabel.text = "\(position)"
        }
    }
    
    private lazy var defaultBlocSize: Int = {
        if let curcusId = App.userCursus?.cursus_id {
            if let first = HomeApiResources.blocs.first(where: { $0.campus_id == App.userCampus.campus_id && $0.cursus_id == curcusId }) {
                return first.coalitions.count
            }
        }
        else if let first = HomeApiResources.blocs.first(where: { $0.campus_id == App.userCampus.campus_id }) {
            return first.coalitions.count
        }
        return 4
    }()
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.bloc?.coalitions.count ?? self.defaultBlocSize
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (tableView.frame.size.height - tableView.contentInset.bottom) / CGFloat(self.bloc?.coalitions.count ?? 4)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CoalitionTableViewCell
        
        if let coalition = self.bloc?.coalitions[indexPath.row] {
            cell.update(with: coalition, position: indexPath.row + 1, blocSize: self.bloc!.coalitions.count)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? CoalitionTableViewCell, cell.coalition != nil else {
            return
        }
        let usersList = UsersListViewController(.coalitionsWithCoalitionIdUsers(cell.coalition.id), settings: nil, extra: .coalitions(cell.coalition, self.bloc), primary: cell.coalition.uicolor)
        
        self.presentWithBlur(usersList)
    }
}
