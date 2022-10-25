// home42/Segments.swift
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

protocol CompatibleSegmentView: UIView {
    
    associatedtype Value
    init(value: Value, primary: UIColor)
    
    var value: Value { get set }
    var primary: UIColor { get set }
    
    func selectedStyle()
    func unselectedStyle()
}

class GenericSegmentView<G, V: CompatibleSegmentView>: BasicUIView where V.Value == G {
    
    private let values: [G]
    let views: [V]
    
    var selectedIndex: Int
    var selectedValue: G {
        return self.values[self.selectedIndex]
    }
    var primary: UIColor = HomeDesign.primary {
        didSet {
            for (index, view) in self.views.enumerated() {
                view.primary = self.primary
                if self.selectedIndex == index {
                    view.selectedStyle()
                }
                else {
                    view.unselectedStyle()
                }
            }
        }
    }
    
    init(values: [G], selectedIndex: Int = 0) {
        self.values = values
        self.views = values.map({ V(value: $0, primary: HomeDesign.primary) })
        self.selectedIndex = selectedIndex
        super.init()
        self.backgroundColor = HomeDesign.lightGray
        self.layer.cornerRadius = HomeLayout.scorner
    }
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview != nil else { return }
        
        var view: V!
        var leading: NSLayoutXAxisAnchor = self.leadingAnchor
        var last: V! = nil
        // sep
        
        for (index, _) in values.enumerated() {
            view = self.views[index]
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(GenericSegmentView<G, V>.viewTapped(sender:))))
            if index == self.selectedIndex {
                view.selectedStyle()
                view.isUserInteractionEnabled = false
            }
            else {
                view.unselectedStyle()
                view.isUserInteractionEnabled = true
            }
            self.addSubview(view)
            view.leadingAnchor.constraint(equalTo: leading, constant: HomeLayout.dmargin).isActive = true
            view.topAnchor.constraint(equalTo: self.topAnchor, constant: HomeLayout.dmargin).isActive = true
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -HomeLayout.dmargin).isActive = true
            if let last = last {
                view.widthAnchor.constraint(equalTo: last.widthAnchor).isActive = true
            }
            leading = view.trailingAnchor
            last = view
        }
        view.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.dmargin).isActive = true
    }
    
    @inline(__always) private func animateToNewSelected(index newIndex: Int) {
        guard self.views.count > 0 else {
            self.selectedIndex = newIndex
            return
        }
        let oldIndex = self.selectedIndex
        let oldView: V
        let view: V
        
        self.selectedIndex = newIndex
        if oldIndex != self.selectedIndex {
            oldView = self.views[oldIndex]
            view = self.views[self.selectedIndex]
            HomeAnimations.transitionQuick(withView: oldView, {
                oldView.unselectedStyle()
            }) { _ in
                oldView.isUserInteractionEnabled = true
            }
            HomeAnimations.transitionQuick(withView: view, {
                view.selectedStyle()
            }) { _ in
                view.isUserInteractionEnabled = false
            }
        }
    }
    
    func setSelectedIndex(_ index: Int) {
        self.animateToNewSelected(index: index)
    }
    
    @objc func viewTapped(sender: UITapGestureRecognizer) {
        self.animateToNewSelected(index: self.views.firstIndex(of: sender.view as! V)!)
    }
}

protocol SegmentViewDelegate: AnyObject {
    
    func segmentViewSelect(_ segmentView: SegmentView)
}

final class SegmentView: GenericSegmentView<String, SegmentView.Label> {
    
    weak var delegate: SegmentViewDelegate!
    
    override func viewTapped(sender: UITapGestureRecognizer) {
        super.viewTapped(sender: sender)
        self.delegate.segmentViewSelect(self)
    }
    
    override init(values: [String], selectedIndex: Int = 0) {
        super.init(values: values, selectedIndex: selectedIndex)
    }
    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    final class Label: BasicUILabel, CompatibleSegmentView {
        
        typealias Value = String
        var value: String {
            get {
                return self.text!
            }
            set {
                self.text = newValue
            }
        }
        unowned(unsafe) var primary: UIColor
        
        init(value: Value, primary: UIColor) {
            self.primary = primary
            super.init(text: value)
            self.layer.cornerRadius = HomeLayout.scorner
            self.layer.masksToBounds = true
            self.textAlignment = .center
        }
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }
            
            super.willMove(toSuperview: newSuperview)
            self.heightAnchor.constraint(equalToConstant: HomeLayout.segmentHeigth).isActive = true
        }
        
        func selectedStyle() {
            self.font = HomeLayout.fontSemiBoldNormal
            self.textColor = HomeDesign.white
            self.backgroundColor = self.primary
        }
        func unselectedStyle() {
            self.font = HomeLayout.fontRegularNormal
            self.textColor = HomeDesign.black
            self.backgroundColor = HomeDesign.lightGray
        }
    }
}
