// home42/InfiniteTableView.swift
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
                if case .cancel = self.error!.status {
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

// MARK: - Skeleton
/*
protocol GenericSkeletonInfiniteRequestCell: GenericSingleInfiniteRequestCell, SkeletonSourceView { }

class GenericSkeletonInfiniteRequestTableView<C: GenericSkeletonInfiniteRequestCell, G: IntraObject>: BasicUITableView, UITableViewDataSource, UITableViewDelegate where C.E == G {
    
    var route: HomeApi.Routes
    private var page: Int
    private var pageSize: Int
    private var pageEnded: Bool = false
    var elements: ContiguousArray<G> = []
    var parameters: [String: Any]
    
    private var currentTask: Task<(), Never>? = nil
    
    private var error: HomeApi.RequestError? = nil
    private let skeletonConfiguration: SkeletonViewConfiguration
    
    var block: ((G) -> ())? = nil
    
    init(_ route: HomeApi.Routes, parameters: [String: Any]? = nil, page: Int = 1, pageSize: Int = 100,
         configuration skeletonConfiguration: SkeletonViewConfiguration) {
        self.route = route
        if let parameters = parameters {
            self.parameters = parameters
        }
        else {
            self.parameters = [:]
        }
        self.page = page
        self.pageSize = pageSize
        self.skeletonConfiguration = skeletonConfiguration
        super.init()
        self.delegate = self
        self.dataSource = self
        self.register(C.self, forCellReuseIdentifier: "cell")
        self.register(SkeletonTableViewCell<C>.self, forCellReuseIdentifier: "skeleton")
        self.register(SkeletonErrorTableViewCell.self, forCellReuseIdentifier: "skeletonError")
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @MainActor func nextPage() {
        guard self.currentTask == nil && self.pageEnded == false && self.error == nil else {
            return
        }
        
        //self.antenneViewCell.antenne.isBreak = false
        //self.antenneViewCell.antenne.isAntenneAnimating = true
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
                //self.antenneViewCell.antenne.isBreak = false
                //self.antenneViewCell.antenne.isAntenneAnimating = false
                self.error = nil
            }
            catch {
                self.error = error as? HomeApi.RequestError
                if self.error!.isCancelled {
                    return
                }
                //self.antenneViewCell.antenne.isBreak = true
                //self.antenneViewCell.antenne.isAntenneAnimating = true
                DynamicAlert.presentWith(error: self.error!)
            }
            self.currentTask = nil
            self.reloadData() // reload fade ?
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
        // self.antenneViewCell.antenne.isAntenneAnimating = false
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
            if let error = error {
                let cell = tableView.dequeueReusableCell(withIdentifier: "skeletonError") as! SkeletonErrorTableViewCell
                
                // cell.view.
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "skeleton") as! SkeletonTableViewCell<C>
                
                cell.configure(self.skeletonConfiguration)
                return cell
            }
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
}*/
