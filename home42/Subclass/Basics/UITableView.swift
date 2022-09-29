// home42/UITableView.swift
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

class BasicUITableView: UITableView {
    
    init() {
        super.init(frame: .zero, style: .plain)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.rowHeight = UITableView.automaticDimension
        self.estimatedRowHeight = 250.0
        self.estimatedSectionFooterHeight = UITableView.automaticDimension
        self.estimatedSectionHeaderHeight = UITableView.automaticDimension
        self.separatorStyle = .none
        self.backgroundColor = HomeDesign.white
        self.sectionHeaderTopPadding = 0.0
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    @inlinable @inline(__always) func contentInsetAdjustTopAndBottom() {
        self.contentInset = .init(top: HomeLayout.safeAeraMain.top, left: 0.0,
                                  bottom: HomeLayout.safeAeraMain.bottom, right: 0.0)
        self.contentInsetAdjustmentBehavior = .never
        self.setContentOffset(.init(x: 0.0, y: -HomeLayout.safeAeraMain.top), animated: false)
    }
    
    @inlinable @inline(__always) func contentInsetAdjustTopConstant(_ constant: CGFloat, bottom: CGFloat = HomeLayout.safeAeraMain.bottom) {
        self.contentInset = .init(top: constant, left: 0.0, bottom: bottom, right: 0.0)
        self.contentInsetAdjustmentBehavior = .never
        self.setContentOffset(.init(x: 0.0, y: -constant), animated: false)
    }
}

class BasicUITableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = .clear
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

protocol GenericTableViewCellView: UIView {
    
    init()
}
final class GenericTableViewCell<G: GenericTableViewCellView>: BasicUITableViewCell {
    let view: G = G()
    
    override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview != nil else { return }
        
        self.contentView.addSubview(self.view)
        self.view.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        self.view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        self.view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        self.view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
    }
}

protocol HomeFramingTableViewCellView: UIView {
    
    static var edges: UIEdgeInsets { get }
    init()
}
final class HomeFramingTableViewCell<G: HomeFramingTableViewCellView>: BasicUITableViewCell {
    
    let view: G = G()
    
    override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview != nil else { return }
        
        self.contentView.addSubview(self.view)
        self.view.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: G.edges.top).isActive = true
        self.view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -G.edges.bottom).isActive = true
        self.view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: G.edges.left).isActive = true
        self.view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -G.edges.right).isActive = true
    }
}

protocol HomeWhiteContainerTableViewCellView: UIView {
    init()
}
class HomeWhiteContainerTableViewCell<G: HomeWhiteContainerTableViewCellView>: BasicUITableViewCell {
    
    let view: G = G()
    
    override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview != nil else { return }
        
        self.contentView.addSubview(self.view)
        self.view.backgroundColor = HomeDesign.white
        self.view.layer.cornerRadius = HomeLayout.corner
        self.view.layer.masksToBounds = true
        self.view.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: HomeLayout.smargin).isActive = true
        self.view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -HomeLayout.smargin).isActive = true
        self.view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: HomeLayout.margin).isActive = true
        self.view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -HomeLayout.margin).isActive = true
    }
}
final class HomeWhiteContainerUserInfoTableViewCell: HomeWhiteContainerTableViewCell<UserInfoView>, GenericSingleInfiniteRequestCell {
    
    func fill(with element: IntraUserInfo) {
        self.view.update(with: element)
    }
}

protocol SeparatorTableViewCellView: UIView {
    init()
}
final class SeparatorTableViewCell<G: SeparatorTableViewCellView>: BasicUITableViewCell {
    
    let separator: BasicUIView
    let view: G
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.separator = BasicUIView()
        self.separator.backgroundColor = HomeDesign.primary
        self.separator.layer.cornerRadius = HomeLayout.sborder
        self.view = G()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview != nil else { return }
        
        self.contentView.addSubview(self.view)
        self.view.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        self.view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        self.view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        self.contentView.addSubview(self.separator)
        self.separator.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        self.separator.heightAnchor.constraint(equalToConstant: HomeLayout.border).isActive = true
        self.separator.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        self.separator.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: HomeLayout.margind).isActive = true
        self.separator.topAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
}

// MARK: -
extension SeparatorTableViewCell: GenericSingleInfiniteRequestCell where G: UserInfoView {
    typealias E = IntraUserInfo
    
    func fill(with element: IntraUserInfo) {
        self.view.update(with: element)
    }
}

final class UserInfoInfiniteRequestTableView: GenericSingleInfiniteRequestTableView<SeparatorTableViewCell<UserInfoView>, IntraUserInfo> {
    
    var primary: UIColor
    
    init(_ route: HomeApi.Routes, parameters: [String : Any]? = nil, page: Int = 1, pageSize: Int = 100, primary: UIColor = HomeDesign.primary) {
        self.primary = primary
        super.init(route, parameters: parameters, page: page, pageSize: pageSize)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let cell = cell as? SeparatorTableViewCell<UserInfoView> {
            cell.separator.isHidden = self.elements.count - 1 == indexPath.row
            cell.separator.backgroundColor = self.primary.withAlphaComponent(HomeDesign.alphaLow)
        }
        return cell
    }
}

final class MessageTableViewCell: BasicUITableViewCell {
    
    private let container: BasicUIView
    private let contentLabel: BasicUILabel
    var setHeigthConstraint: Bool = false
    var marginX: CGFloat = 0.0
    var marginBottom: CGFloat = 0.0
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.container = BasicUIView()
        self.container.layer.cornerRadius = HomeLayout.scorner
        self.container.layer.masksToBounds = true
        self.contentLabel = BasicUILabel(text: "???")
        self.contentLabel.textColor = HomeDesign.black
        self.contentLabel.textAlignment = .center
        self.contentLabel.font = HomeLayout.fontRegularMedium
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview != nil else { return }
        
        self.contentView.addSubview(self.container)
        self.container.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: HomeLayout.smargin).isActive = true
        self.container.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: self.marginX).isActive = true
        self.container.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -self.marginX).isActive = true
        self.container.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -self.marginBottom).isActive = true
        self.container.addSubview(self.contentLabel)
        self.contentLabel.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: HomeLayout.smargin).isActive = true
        self.contentLabel.trailingAnchor.constraint(equalTo: self.container.trailingAnchor, constant: -HomeLayout.smargin).isActive = true
        self.contentLabel.centerYAnchor.constraint(equalTo: self.container.centerYAnchor).isActive = true
        if self.setHeigthConstraint {
            self.contentView.heightAnchor.constraint(equalToConstant: HomeLayout.userProfilCorrectionViewEmptyHeight + HomeLayout.smargin).isActive = true
        }
    }
    
    func update(with text: String, primary: UIColor) {
        self.contentLabel.text = text
        self.container.backgroundColor = primary.withAlphaComponent(HomeDesign.alphaLowLayer)
    }
}

class BasicUITableViewHeaderFooterView: UITableViewHeaderFooterView {
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.backgroundConfiguration = UIBackgroundConfiguration.clear()
        self.automaticallyUpdatesBackgroundConfiguration = false
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

final class SectionTableViewHeaderFooterView: BasicUITableViewHeaderFooterView {
    
    private let header: LeftCurvedTitleView
    
    override init(reuseIdentifier: String?) {
        self.header = LeftCurvedTitleView(text: "???", primaryColor: HomeDesign.primary, addTopCorner: false)
        self.header.backgroundColor = .clear
        super.init(reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview != nil else { return }
        
        self.contentView.addSubview(self.header)
        self.header.removeConstraints(self.header.constraints)
        self.header.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        self.header.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        self.header.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        self.header.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
    }
    
    func update(with title: String, primaryColor: UIColor) {
        self.header.update(with: title, primaryColor: primaryColor)
    }
}

final class SectionTableViewHeaderFooterViewWithIcon: BasicUITableViewHeaderFooterView {
    
    private let iconContainer: BasicUIView
    private let icon: BasicUIImageView
    private let title: LeftCurvedTitleView
    
    override init(reuseIdentifier: String?) {
        self.iconContainer = BasicUIView()
        self.icon = BasicUIImageView(image: nil)
        self.icon.tintColor = HomeDesign.white
        self.title = LeftCurvedTitleView(text: "???", primaryColor: HomeDesign.primary, addTopCorner: false)
        self.title.backgroundColor = .clear
        super.init(reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview != nil else { return }
        
        self.contentView.addSubview(self.iconContainer)
        self.contentView.addSubview(self.title)
        self.contentView.addSubview(self.icon)
        
        self.iconContainer.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        self.iconContainer.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        self.iconContainer.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        self.iconContainer.widthAnchor.constraint(equalToConstant: HomeLayout.margin).isActive = true
        self.icon.leadingAnchor.constraint(equalTo: self.iconContainer.trailingAnchor).isActive = true
        self.icon.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        self.icon.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        self.icon.widthAnchor.constraint(equalTo: self.icon.heightAnchor, multiplier: 1.0).isActive = true
        self.title.removeConstraints(self.title.constraints)
        self.title.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        self.title.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        self.title.leadingAnchor.constraint(equalTo: self.icon.trailingAnchor, constant: -HomeLayout.smargin).isActive = true
        self.title.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        super.willMove(toSuperview: newSuperview)
    }
    
    func update(with title: String, icon: UIImage, primaryColor: UIColor) {
        self.title.update(with: title, primaryColor: primaryColor)
        self.icon.image = icon
        self.icon.backgroundColor = primaryColor
        self.iconContainer.backgroundColor = primaryColor
    }
}
