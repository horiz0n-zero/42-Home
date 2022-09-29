// home42/StarsView.swift
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

final class StarsView: BasicUIView {
    
    private let starsImages: Array<BasicUIImageView>
    var count: Int {
        return self.starsImages.count
    }
    var note: Int {
        didSet {
            self.updateStarsNote()
        }
    }
    var primary: UIColor {
        get {
            return self.starsImages[0].tintColor
        }
        set {
            self.updateWithPrimary(newValue)
        }
    }
    
    private func updateStarsNote() {
        for index in 0 ..< self.count {
            self.starsImages[index].image = index < self.note ? UIImage.Assets.starsFull.image : UIImage.Assets.starsEmpty.image
        }
    }
    
    private func updateWithPrimary(_ primary: UIColor) {
        for imageView in self.starsImages {
            imageView.tintColor = primary
        }
    }
    
    init(note: Int = 0, count: Int = 5) {
        self.starsImages = (0 ..< count).map({ BasicUIImageView(asset: $0 < note ? .starsFull : .starsEmpty ) })
        self.note = note
        super.init()
        self.updateWithPrimary(HomeDesign.primary)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview != nil else { return }
        
        unowned(unsafe) var leading: NSLayoutXAxisAnchor = self.leadingAnchor
        
        for imageView in self.starsImages {
            self.addSubview(imageView)
            imageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            imageView.leadingAnchor.constraint(equalTo: leading, constant: 0.0).isActive = true
            imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: 20.0).isActive = true
            leading = imageView.trailingAnchor
        }
        self.starsImages.last!.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }
}
