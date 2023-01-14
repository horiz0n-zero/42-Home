// home42/ClustersSegments.swift
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

protocol ClusterSelectorViewDelegate: AnyObject {
    
    func clusterSegmentViewSelect(_ segmentView: ClusterSelectorView)
    func clusterSegmentViewPeopleCounterSelect(_ segmentView: ClusterSelectorView, listType: People.ListType)
    func clusterSegmentViewPlacesCounterSelect(_ segmentView: ClusterSelectorView)
}

protocol ClusterSelectorView: UIView {
    
    var clusterSelectorDelegate: ClusterSelectorViewDelegate! { get set }
    
    var selectedIndex: Int { get }
    var oldSelectedIndex: Int { get }
    var extraValues: [ClusterSelectorViewExtraValues] { get set }
    
    init(values: [String], extraValues: [ClusterSelectorViewExtraValues]?, selectedIndex: Int, primary: UIColor)
    
    func setSelectedIndex(_ index: Int)
}

struct ClusterSelectorViewExtraValues: Codable {
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

final class ClusterSegmentView: GenericSegmentView<String, ClusterSegmentViewFloorView>, ClusterSelectorView {
    
    weak var clusterSelectorDelegate: ClusterSelectorViewDelegate!
    var oldSelectedIndex: Int
    override var selectedIndex: Int {
        didSet {
            self.oldSelectedIndex = oldValue
        }
    }
    
    var extraValues: [ClusterSelectorViewExtraValues] {
        didSet {
            for (index, value) in self.extraValues.enumerated() {
                self.views[index].update(withValues: value)
            }
        }
    }
    
    init(values: [String], extraValues: [ClusterSelectorViewExtraValues]?, selectedIndex: Int = 0, primary: UIColor = HomeDesign.primary) {
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
        
        for (index, value) in self.extraValues.enumerated() where self.views.count > index {
            self.views[index].update(withValues: value)
        }
    }
    
    override func viewTapped(sender: UITapGestureRecognizer) {
        super.viewTapped(sender: sender)
        self.clusterSelectorDelegate.clusterSegmentViewSelect(self)
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
    
    fileprivate func update(withValues values: ClusterSelectorViewExtraValues) {
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

final class ClusterScrollableSegmentView: BasicUIView, ClusterSelectorView, UIScrollViewDelegate {
    
    var clusterSelectorDelegate: ClusterSelectorViewDelegate!
    
    var oldSelectedIndex: Int
    var selectedIndex: Int {
        didSet {
            self.oldSelectedIndex = oldValue
        }
    }
    var extraValues: [ClusterSelectorViewExtraValues] {
        didSet {
            for (index, value) in self.extraValues.enumerated() where self.views.count > index {
                self.views[index].update(withExtraValues: value)
            }
        }
    }
    
    private let scrollView: BasicUIScrollView
    private let viewsContainer: BasicUIView
    private let views: [SelectableView]
    
    init(values: [String], extraValues: [ClusterSelectorViewExtraValues]?, selectedIndex: Int, primary: UIColor) {
        self.selectedIndex = selectedIndex
        self.oldSelectedIndex = selectedIndex
        if let extraValues = extraValues, extraValues.count == values.count {
            self.extraValues = extraValues
        }
        else {
            self.extraValues = Array(repeating: .init(placeAvailable: 0, placeCount: 0, friends: 0, extra1: 0, extra2: 0), count: values.count)
        }
        self.scrollView = BasicUIScrollView()
        self.scrollView.contentInset = .init(top: 0.0, left: HomeLayout.scorner, bottom: 0.0, right: HomeLayout.scorner)
        self.viewsContainer = BasicUIView()
        self.views = (0 ..< values.count).map({
            return SelectableView(values[$0], extraValues: extraValues?[$0], isSelected: $0 == selectedIndex, primary: primary)
        })
        super.init()
        self.scrollView.delegate = self
        self.backgroundColor = HomeDesign.white
        self.layer.borderWidth = HomeLayout.border
        self.layer.borderColor = primary.cgColor
        self.layer.cornerRadius = HomeLayout.corner
        self.layer.masksToBounds = true
        self.isUserInteractionEnabled = true
        self.scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ClusterScrollableSegmentView.scrollViewTapped(sender:))))
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview != nil else {
            return
        }
        
        self.addSubview(self.scrollView)
        self.scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.scrollView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.scrollView.addSubview(self.viewsContainer)
        self.viewsContainer.topAnchor.constraint(equalTo: self.scrollView.topAnchor).isActive = true
        self.viewsContainer.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor).isActive = true
        self.viewsContainer.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor).isActive = true
        self.viewsContainer.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor).isActive = true
        self.viewsContainer.heightAnchor.constraint(equalTo: self.scrollView.heightAnchor).isActive = true
        for (index, view) in self.views.enumerated() {
            self.viewsContainer.addSubview(view)
            view.topAnchor.constraint(equalTo: self.viewsContainer.topAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: self.viewsContainer.bottomAnchor).isActive = true
            view.leadingAnchor.constraint(equalTo: index == 0 ? self.viewsContainer.leadingAnchor : self.views[index - 1].trailingAnchor).isActive = true
        }
        self.views.last!.trailingAnchor.constraint(equalTo: self.viewsContainer.trailingAnchor).isActive = true
        self.heightAnchor.constraint(equalToConstant: HomeLayout.clusterSegmentHeigth + (HomeLayout.dmargin * 2.0)).isActive = true
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { self.viewsContainer }
    
    @objc private func scrollViewTapped(sender: UITapGestureRecognizer) {
        let location = sender.location(in: sender.view)
        
        if let index = self.views.firstIndex(where: { $0.point(inside: $0.convert(location, from: sender.view!), with: nil) }), index != self.selectedIndex {
            let oldView = self.views[self.selectedIndex]
            let view = self.views[index]
            
            self.oldSelectedIndex = self.selectedIndex
            self.selectedIndex = index
            sender.view!.isUserInteractionEnabled = false
            HomeAnimations.transitionQuick(withView: oldView, {
                oldView.isSelected = false
            })
            HomeAnimations.transitionQuick(withView: view, {
                view.isSelected = true
            }) { _ in
                sender.view!.isUserInteractionEnabled = true
            }
            self.clusterSelectorDelegate.clusterSegmentViewSelect(self)
        }
    }
    
    func updateIndicators() {
        
    }
    
    func setSelectedIndex(_ index: Int) {
        self.views[self.oldSelectedIndex].isSelected = false
        self.views[index].isSelected = true
        self.selectedIndex = index
    }
    
    final private class SelectableView: BasicUIView {
        
        private let container: BasicUIView
        private let nameLabel: BasicUILabel
        private let stackView: BasicUIStackView
        private let placeCounter: HomeInsetsLabel
        private let peopleFriends: HomeInsetsLabel
        private let peopleExtraList1: HomeInsetsLabel?
        private let peopleExtraList2: HomeInsetsLabel?
        private unowned(unsafe) let primary: UIColor
        
        var isSelected: Bool {
            didSet {
                self.updateSelectStyle()
            }
        }
        
        init(_ value: String, extraValues: ClusterSelectorViewExtraValues?, isSelected: Bool, primary: UIColor) {
            
            self.container = BasicUIView()
            self.container.layer.cornerRadius = HomeLayout.scorner
            self.container.layer.masksToBounds = true
            self.nameLabel = BasicUILabel(text: value)
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
            self.placeCounter.layer.borderColor = HomeDesign.white.cgColor
            self.placeCounter.layer.borderWidth = HomeLayout.sborder
            self.peopleFriends = HomeInsetsLabel(text: "?", inset: .init(width: 4.0, height: 4.0))
            self.peopleFriends.backgroundColor = HomeDesign.greenSuccess
            self.peopleFriends.font = self.placeCounter.font
            self.peopleFriends.textColor = self.placeCounter.textColor
            self.peopleFriends.textAlignment = self.placeCounter.textAlignment
            self.peopleFriends.layer.cornerRadius = self.placeCounter.layer.cornerRadius
            self.peopleFriends.layer.masksToBounds = true
            self.peopleFriends.layer.borderColor = HomeDesign.white.cgColor
            self.peopleFriends.layer.borderWidth = HomeLayout.sborder
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
                self.peopleExtraList2!.layer.borderColor = HomeDesign.white.cgColor
                self.peopleExtraList2!.layer.borderWidth = HomeLayout.sborder
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
                self.peopleExtraList1!.layer.borderColor = HomeDesign.white.cgColor
                self.peopleExtraList1!.layer.borderWidth = HomeLayout.sborder
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
            self.isSelected = isSelected
            self.primary = primary
            super.init()
            self.updateSelectStyle()
        }
        required init?(coder: NSCoder) { fatalError() }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else {
                return
            }
            
            self.addSubview(self.container)
            self.container.topAnchor.constraint(equalTo: self.topAnchor, constant: HomeLayout.scorner).isActive = true
            self.container.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            self.container.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -HomeLayout.scorner).isActive = true
            self.container.addSubview(self.nameLabel)
            self.nameLabel.centerYAnchor.constraint(equalTo: self.container.centerYAnchor).isActive = true
            self.nameLabel.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: HomeLayout.smargin).isActive = true
            
            if App.settings.clusterShowCounters {
                self.addSubview(self.stackView)
                self.stackView.leadingAnchor.constraint(equalTo: self.nameLabel.trailingAnchor, constant: HomeLayout.scorner).isActive = true
                self.stackView.centerYAnchor.constraint(equalTo: self.container.centerYAnchor).isActive = true
                self.stackView.trailingAnchor.constraint(equalTo: self.container.trailingAnchor, constant: -HomeLayout.scorner).isActive = true
                self.container.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            }
            else {
                self.nameLabel.trailingAnchor.constraint(equalTo: self.container.trailingAnchor, constant: -HomeLayout.smargin).isActive = true
                self.container.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            }
        }
        
        func updateSelectStyle() {
            if self.isSelected {
                self.nameLabel.textColor = HomeDesign.white
                self.container.backgroundColor = self.primary
            }
            else {
                self.nameLabel.textColor = HomeDesign.black
                self.container.backgroundColor = .clear
            }
        }
        
        func update(withExtraValues values: ClusterSelectorViewExtraValues) {
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
}
