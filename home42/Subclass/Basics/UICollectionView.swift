// home42/UICollectionView.swift
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

class BasicUICollectionView: UICollectionView {
    
    init(_ collectionViewLayout: UICollectionViewLayout) {
        super.init(frame: .zero, collectionViewLayout: collectionViewLayout)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class BasicUICollectionViewCell: UICollectionViewCell {

    
}


protocol GenericCollectionViewCellView: UIView {
    
    init()
}
final class GenericCollectionViewCell<G: GenericCollectionViewCellView>: BasicUICollectionViewCell {
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

protocol GenericFramingCollectionViewCellView: UIView {
    
    static var edges: UIEdgeInsets { get }
    init()
}
final class GenericFramingCollectionViewCell<G: GenericFramingCollectionViewCellView>: BasicUITableViewCell {
    
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

final class HorizontalCollectionView: BasicUICollectionView {
    
    var heightConstraint: NSLayoutConstraint!
    
    init(height: CGFloat, itemSpacing: CGFloat = HomeLayout.margin, insets: UIEdgeInsets = .init(top: 0.0, left: HomeLayout.margin, bottom: 0.0, right: HomeLayout.margin)) {
        let flow = UICollectionViewFlowLayout()
        
        flow.scrollDirection = .horizontal
        flow.minimumInteritemSpacing = itemSpacing
        flow.minimumLineSpacing = itemSpacing
        flow.sectionInset = insets
        flow.estimatedItemSize = .init(width: height * 3.0, height: height)
        super.init(flow)
        self.heightConstraint = self.heightAnchor.constraint(equalToConstant: height)
        self.backgroundColor = UIColor.clear
        self.showsHorizontalScrollIndicator = false
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview != nil else { return }
        
        self.heightConstraint.isActive = true
    }
}
