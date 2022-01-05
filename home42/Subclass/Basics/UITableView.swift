//
//  UITableView.swift
//  home42
//
//  Created by Antoine Feuerstein on 18/04/2021.
//

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
        self.contentInset = .init(top: App.safeAeraMain.top, left: 0.0, bottom: App.safeAeraMain.bottom, right: 0.0)
        self.contentInsetAdjustmentBehavior = .never
        self.setContentOffset(.init(x: 0.0, y: -App.safeAeraMain.top), animated: false)
    }
    
    @inlinable @inline(__always) func contentInsetAdjustTopConstant(_ constant: CGFloat, bottom: CGFloat = App.safeAeraMain.bottom) {
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

protocol GenericSingleInfiniteRequestCell: UITableViewCell {
    
    associatedtype E
    
    func fill(with element: Self.E)
}

class GenericSingleInfiniteRequestTableView<C: GenericSingleInfiniteRequestCell, G: IntraObject>: BasicUITableView, UITableViewDataSource, UITableViewDelegate where C.E == G {
    
    var route: HomeApi.Routes
    private var page: Int
    private var pageSize: Int
    private var pageEnded: Bool = false
    var elements: ContiguousArray<G> = []
    var parameters: [String: Any]
    
    private var currentTask: Task<(), Never>? = nil
    
    private var error: HomeApi.RequestError? = nil
    private lazy var antenneViewCell: AntenneTableViewCell = self.dequeueReusableCell(withIdentifier: "antenne") as! AntenneTableViewCell
    
    var block: ((G) -> ())? = nil
    
    init(_ route: HomeApi.Routes, parameters: [String: Any]? = nil, page: Int = 1, pageSize: Int = 100, blurAntenne: Bool = false) {
        self.route = route
        if let parameters = parameters {
            self.parameters = parameters
        }
        else {
            self.parameters = [:]
        }
        self.page = page
        self.pageSize = pageSize
        super.init()
        self.delegate = self
        self.dataSource = self
        self.register(C.self, forCellReuseIdentifier: "cell")
        if blurAntenne {
            self.register(AntenneBlurTableViewCell.self, forCellReuseIdentifier: "antenne")
        }
        else {
            self.register(AntenneWhiteTableViewCell.self, forCellReuseIdentifier: "antenne")
        }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @MainActor func nextPage() {
        guard self.currentTask == nil && self.pageEnded == false && self.error == nil else {
            return
        }
        
        self.antenneViewCell.antenne.isBreak = false
        self.antenneViewCell.antenne.isAntenneAnimating = true
        self.currentTask = Task(priority: .userInitiated, operation: {
            do {
                let newElements: [G]
                var withPagesParameters = self.parameters
                
                withPagesParameters["page[number]"] = self.page
                withPagesParameters["page[size]"] = self.pageSize
                newElements = try await HomeApi.get(self.route, params: withPagesParameters)
                self.elements.append(contentsOf: newElements)
                if newElements.count == self.pageSize {
                    self.page &+= 1
                }
                else {
                    self.pageEnded = true
                }
                self.antenneViewCell.antenne.isBreak = false
                self.antenneViewCell.antenne.isAntenneAnimating = false
                self.error = nil
            }
            catch {
                self.error = error as? HomeApi.RequestError
                if self.error!.isCancelled {
                    return
                }
                self.antenneViewCell.antenne.isBreak = true
                self.antenneViewCell.antenne.isAntenneAnimating = true
                DynamicAlert.presentWith(error: self.error!)
            }
            self.currentTask = nil
            self.reloadData()
        })
        self.reloadData()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0 && scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height) {
            self.nextPage()
        }
    }
    
    func reset() {
        self.page = 1
        self.currentTask?.cancel()
        self.currentTask = nil
        self.pageEnded = false
        self.antenneViewCell.antenne.isAntenneAnimating = false
        self.error = nil
        self.elements.removeAll()
    }
    
    func restart(with parameters: [String: Any]? = nil) {
        self.reset()
        if let parameters = parameters {
            self.parameters = parameters
        }
        else {
            self.parameters = [:]
        }
        self.nextPage()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.currentTask != nil || self.error != nil {
            return self.elements.count + 1
        }
        return self.elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row >= self.elements.count {
            return self.antenneViewCell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! C
            
            cell.fill(with: self.elements[indexPath.row])
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < self.elements.count {
            self.block?(self.elements[indexPath.row])
        }
    }
    
    deinit {
        self.currentTask?.cancel()
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

final class SectionTableViewHeaderFooterView: UITableViewHeaderFooterView {
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
