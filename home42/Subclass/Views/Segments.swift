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
    
    var views: ContiguousArray<V>
    
    fileprivate(set) var selectedIndex: Int
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
        self.views = []
        self.views.reserveCapacity(values.count)
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
        // sep
        
        for (index, value) in values.enumerated() {
            view = V(value: value, primary: self.primary)
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
            if let last = self.views.last {
                view.widthAnchor.constraint(equalTo: last.widthAnchor).isActive = true
            }
            self.views.append(view)
            leading = view.trailingAnchor
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
    
    @objc fileprivate func viewTapped(sender: UITapGestureRecognizer) {
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

protocol ClusterSegmentViewDelegate: AnyObject {
    
    func clusterSegmentViewSelect(_ segmentView: ClusterSegmentView)
    func clusterSegmentViewPeopleCounterSelect(_ segmentView: ClusterSegmentView, listType: People.ListType)
    func clusterSegmentViewPlacesCounterSelect(_ segmentView: ClusterSegmentView)
}

final class ClusterSegmentView: GenericSegmentView<String, ClusterSegmentViewFloorView> {
    
    weak var delegate: ClusterSegmentViewDelegate!
    var oldSelectedIndex: Int
    override var selectedIndex: Int {
        didSet {
            self.oldSelectedIndex = oldValue
        }
    }
    
    struct ExtraValues: Codable {
        let placeAvailable: Int
        let placeCount: Int
        let friends: Int
        let extra1: Int
        let extra2: Int
        
        init(placeAvailable: Int, placeCount: Int, friends: Int, extra1: Int, extra2: Int) {
            self.placeAvailable = placeAvailable
            self.placeCount = placeCount
            self.friends = friends
            self.extra1 = extra1
            self.extra2 = extra2
        }
        init() {
            self.placeAvailable = 0
            self.placeCount = 0
            self.friends = 0
            self.extra1 = 0
            self.extra2 = 0
        }
    }
    
    var extraValues: [ClusterSegmentView.ExtraValues] {
        didSet {
            for (index, value) in self.extraValues.enumerated() {
                self.views[index].update(withValues: value)
            }
        }
    }
    
    init(values: [String], extraValues: [ClusterSegmentView.ExtraValues]?, selectedIndex: Int = 0, primary: UIColor = HomeDesign.primary) {
        self.oldSelectedIndex = selectedIndex
        self.extraValues = extraValues ?? Array(repeating: .init(placeAvailable: 0, placeCount: 0, friends: 0, extra1: 0, extra2: 0), count: values.count)
        super.init(values: values, selectedIndex: selectedIndex)
        self.primary = primary
        self.backgroundColor = HomeDesign.white
        self.layer.borderWidth = HomeLayout.border
        self.layer.borderColor = primary.cgColor
        self.layer.cornerRadius = HomeLayout.corner
    }
    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        guard newSuperview != nil else { return }
        
        for (index, value) in self.extraValues.enumerated() {
            self.views[index].update(withValues: value)
        }
    }
    
    override func viewTapped(sender: UITapGestureRecognizer) {
        super.viewTapped(sender: sender)
        self.delegate.clusterSegmentViewSelect(self)
    }
}

final class ClusterSegmentViewFloorView: BasicUIView, CompatibleSegmentView {
    
    var value: String
    unowned(unsafe) var primary: UIColor
    
    private let placeCounter: HomeInsetsLabel
    private let peopleFriends: HomeInsetsLabel
    private let peopleExtraList1: HomeInsetsLabel?
    private let peopleExtraList2: HomeInsetsLabel?
    
    private let nameLabel: BasicUILabel
    private let stackView: BasicUIStackView
    
    init(value: String, primary: UIColor) {
        self.value = value
        self.primary = primary
        self.nameLabel = .init(text: value)
        self.nameLabel.textAlignment = .center
        self.nameLabel.adjustsFontSizeToFitWidth = true
        self.nameLabel.font = HomeLayout.fontSemiBoldMedium
        self.nameLabel.layer.cornerRadius = HomeLayout.scorner
        self.nameLabel.layer.masksToBounds = true
        self.stackView = BasicUIStackView()
        self.stackView.axis = .horizontal
        self.stackView.spacing = HomeLayout.dmargin
        self.placeCounter = HomeInsetsLabel(text: "?", inset: .init(width: 4.0, height: 4.0))
        self.placeCounter.adjustsFontSizeToFitWidth = true
        self.placeCounter.backgroundColor = primary
        self.placeCounter.font = HomeLayout.fontBlackLittle
        self.placeCounter.textColor = HomeDesign.white
        self.placeCounter.textAlignment = .center
        self.placeCounter.layer.cornerRadius = HomeLayout.dcorner
        self.placeCounter.layer.masksToBounds = true
        self.peopleFriends = HomeInsetsLabel(text: "?", inset: .init(width: 4.0, height: 4.0))
        self.peopleFriends.backgroundColor = HomeDesign.greenSuccess
        self.peopleFriends.font = self.placeCounter.font
        self.peopleFriends.textColor = self.placeCounter.textColor
        self.peopleFriends.textAlignment = self.placeCounter.textAlignment
        self.peopleFriends.layer.cornerRadius = self.placeCounter.layer.cornerRadius
        self.peopleFriends.layer.masksToBounds = true
        self.peopleFriends.widthAnchor.constraint(greaterThanOrEqualTo: self.peopleFriends.heightAnchor).isActive = true
        if let list = App.settings.peopleExtraList2 {
            self.peopleExtraList2 = HomeInsetsLabel(text: "?", inset: .init(width: 4.0, height: 4.0))
            self.peopleExtraList2!.backgroundColor = list.color
            self.peopleExtraList2!.font = self.placeCounter.font
            self.peopleExtraList2!.textColor = self.placeCounter.textColor
            self.peopleExtraList2!.textAlignment = self.placeCounter.textAlignment
            self.peopleExtraList2!.layer.cornerRadius = self.placeCounter.layer.cornerRadius
            self.peopleExtraList2!.layer.masksToBounds = true
            self.peopleExtraList2!.widthAnchor.constraint(greaterThanOrEqualTo: self.peopleExtraList2!.heightAnchor).isActive = true
            self.stackView.addArrangedSubview(self.peopleExtraList2!)
        }
        else {
            self.peopleExtraList2 = nil
        }
        if let list = App.settings.peopleExtraList1 {
            self.peopleExtraList1 = HomeInsetsLabel(text: "?", inset: .init(width: 4.0, height: 4.0))
            self.peopleExtraList1!.backgroundColor = list.color
            self.peopleExtraList1!.font = self.placeCounter.font
            self.peopleExtraList1!.textColor = self.placeCounter.textColor
            self.peopleExtraList1!.textAlignment = self.placeCounter.textAlignment
            self.peopleExtraList1!.layer.cornerRadius = self.placeCounter.layer.cornerRadius
            self.peopleExtraList1!.layer.masksToBounds = true
            self.peopleExtraList1!.widthAnchor.constraint(greaterThanOrEqualTo: self.peopleExtraList1!.heightAnchor).isActive = true
            self.stackView.addArrangedSubview(self.peopleExtraList1!)
        }
        else {
            self.peopleExtraList1 = nil
        }
        self.stackView.addArrangedSubview(self.peopleFriends)
        if App.settings.clusterHidePlaceCounter == false {
            self.stackView.addArrangedSubview(self.placeCounter)
        }
        super.init()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview != nil else { return }
        
        self.addSubview(self.nameLabel)
        self.nameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: HomeLayout.border).isActive = true
        self.nameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.border).isActive = true
        self.nameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: HomeLayout.border).isActive = true
        self.nameLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -HomeLayout.border).isActive = true
        
        if App.settings.clusterShowCounters {
            self.addSubview(self.stackView)
            self.stackView.bottomAnchor.constraint(equalTo: self.topAnchor, constant: -HomeLayout.smargin).isActive = true
            self.stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            self.stackView.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor).isActive = true
        }
        self.heightAnchor.constraint(equalToConstant: HomeLayout.clusterSegmentHeigth).isActive = true
    }
    
    func selectedStyle() {
        self.nameLabel.textColor = HomeDesign.white
        self.nameLabel.backgroundColor = self.primary
    }
    
    func unselectedStyle() {
        self.nameLabel.textColor = HomeDesign.black
        self.nameLabel.backgroundColor = HomeDesign.white
    }
    
    fileprivate func update(withValues values: ClusterSegmentView.ExtraValues) {
        if App.settings.clusterCounterPreferTakenPlaces == false {
            self.placeCounter.text = "\(values.placeCount)"
        }
        else {
            self.placeCounter.text = "\(values.placeAvailable - values.placeCount)"
        }
        self.peopleFriends.text = "\(values.friends)"
        if App.settings.peopleExtraList1Available {
            self.peopleExtraList1?.text = "\(values.extra1)"
        }
        if App.settings.peopleExtraList1Available {
            self.peopleExtraList2?.text = "\(values.extra2)"
        }
    }
}
