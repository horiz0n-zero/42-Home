// home42/TagsView.swift
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

final class TagsView: BasicUICollectionView, GenericTableViewCellView, UICollectionViewDelegate, UICollectionViewDataSource {
    
    final private class TagView: BasicUILabel, GenericCollectionViewCellView {
                
        required init() {
            super.init(text: "???")
            self.font = HomeLayout.fontSemiBoldMedium
            self.textAlignment = .center
            self.layer.cornerRadius = HomeLayout.scorner
            self.layer.masksToBounds = true
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    }
    
    private var heightConstraint: NSLayoutConstraint!
    
    init() {
        super.init(Layout())
        self.register(GenericCollectionViewCell<TagView>.self, forCellWithReuseIdentifier: "cell")
        self.backgroundColor = UIColor.clear
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.isScrollEnabled = false
        self.delegate = self
        self.dataSource = self
        self.heightConstraint = self.heightAnchor.constraint(equalToConstant: 0.0)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview != nil else { return }
        
        self.heightConstraint.isActive = true
    }
    
    private var tags: [IntraGroup]!
    func update(with groups: [IntraGroup], width: CGFloat = UIScreen.main.bounds.width) {
        self.tags = groups
        (self.collectionViewLayout as! Layout).prepare(with: groups, width: width, heigthUpdate: self.heightConstraint)
        (self.collectionViewLayout as! Layout).invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.tags == nil ? 0 : self.tags.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! GenericCollectionViewCell<TagView>
        let tag = self.tags[indexPath.row]
        
        if tag.isLocal {
            cell.view.text = tag.name
        }
        else {
            cell.view.text = tag.name.uppercased()
        }
        cell.view.textColor = tag.textColor
        cell.view.backgroundColor = tag.color
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let parent = self.parentHomeViewController else {
            return
        }
        let tag: IntraGroup = self.tags[indexPath.row]
        let vc: UsersListViewController
        let primary = (parent as? ProfilViewController)?.currentPrimary ?? HomeDesign.primary
        
        if tag.isLocal == false {
            vc = UsersListViewController(.groupsWithGroupIdUsers(tag.id), extra: .group(tag),
                                         primary: primary, warnAboutIncorrectAPIResult: true)
            vc.headerTitle = tag.name
            parent.presentWithBlur(vc)
        }
        else {
            parent.presentWithBlur(ContributorsListViewController())
        }
    }
    
    final private class Layout: UICollectionViewLayout {
        
        private var attrs: [UICollectionViewLayoutAttributes]
        
        override init() {
            self.attrs = []
            super.init()
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        func prepare(with groups: [IntraGroup], width: CGFloat, heigthUpdate: NSLayoutConstraint) {
            var index: Int = 0
            var y: CGFloat = 0.0
            var x: CGFloat
            var estimatedWidth: CGFloat
            let bounds: CGRect = .init(origin: .zero, size: .init(width: width, height: .infinity))
            let estimator = TagView()
            var attr: UICollectionViewLayoutAttributes
            
            self.attrs.removeAll()
            self.attrs.reserveCapacity(groups.count)
            while index < groups.count {
                x = HomeLayout.margin
                while index < groups.count {
                    if groups[index].isLocal {
                        estimator.text = groups[index].name
                    }
                    else {
                        estimator.text = groups[index].name.uppercased()
                    }
                    estimatedWidth = ceil(estimator.textRect(forBounds: bounds, limitedToNumberOfLines: 1).width) + HomeLayout.margins
                    if x + estimatedWidth + HomeLayout.smargin > width {
                        break
                    }
                    attr = UICollectionViewLayoutAttributes(forCellWith: IndexPath(row: index, section: 0))
                    attr.frame = .init(x: x, y: y, width: estimatedWidth, height: HomeLayout.tagViewHeigth)
                    self.attrs.append(attr)
                    x += estimatedWidth + HomeLayout.smargin
                    index += 1
                }
                y += HomeLayout.tagViewHeigth + HomeLayout.smargin
            }
            heigthUpdate.constant = y
        }
        
        override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
            return self.attrs
        }
        override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
            return self.attrs[indexPath.row]
        }
    }
}
