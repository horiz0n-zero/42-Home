// home42/ViewRecycler.swift
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

protocol ViewRecyclable: UIView {
    associatedtype RecyclingData: Equatable
    
    init(data: RecyclingData)
    func update(with data: RecyclingData)
    var data: RecyclingData { get set }
}

final class ViewRecycler<G: ViewRecyclable>: BasicUIView {
    
    var views: [G]
    private var isUpdateNeeded: Bool = true
    private let constant: CGFloat
    
    init(datas: [G.RecyclingData], constant: CGFloat = 0.0) {
        self.views = datas.map({ G.init(data: $0) })
        self.constant = constant
        super.init()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func insert(_ data: G.RecyclingData) {
        for view in self.views where view.data == data {
            return view.update(with: data)
        }
        self.views.append(G.init(data: data))
        self.isUpdateNeeded = true
    }
    
    func delete(_ data: G.RecyclingData) {
        for (index, view) in self.views.enumerated() where view.data == data {
            self.views.remove(at: index)
            self.isUpdateNeeded = true
            return
        }
    }
    
    func updateIfNeeded() {
        if self.isUpdateNeeded && self.superview != nil {
            self.reloadViews()
        }
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview != nil else {
            return
        }
        
        self.reloadViews()
    }
    
    private func reloadViews() {
        var top: NSLayoutAnchor = self.topAnchor
        
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
        self.removeConstraints(self.constraints)
        for (index, view) in self.views.enumerated() {
            self.addSubview(view)
            view.topAnchor.constraint(equalTo: top, constant: index == 0 ? 0.0 : self.constant).isActive = true
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            top = view.bottomAnchor
        }
        self.bottomAnchor.constraint(equalTo: top).isActive = true
        self.isUpdateNeeded = false
    }
}
