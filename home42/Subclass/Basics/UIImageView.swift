//
//  UIImageView.swift
//  home42
//
//  Created by Antoine Feuerstein on 12/04/2021.
//

import Foundation
import UIKit

class BasicUIImageView: UIImageView {
    
    override init(image: UIImage?) {
        super.init(image: image)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.contentMode = .scaleAspectFill
    }
    
    init(asset: UIImage.Assets) {
        super.init(image: asset.image)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.contentMode = .scaleAspectFill
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.contentMode = .scaleAspectFill
    }
    required init?(coder: NSCoder) { fatalError("Herobust WTF") }
    
    final func setUpParallaxEffect(usingAmout amount: CGFloat = 100.0) {
        let horizontal = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        let vertical = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        let group = UIMotionEffectGroup()
        
        horizontal.minimumRelativeValue = -amount
        horizontal.maximumRelativeValue = amount
        vertical.minimumRelativeValue = -amount
        vertical.maximumRelativeValue = amount
        group.motionEffects = [horizontal, vertical]
        self.addMotionEffect(group)
    }
}
