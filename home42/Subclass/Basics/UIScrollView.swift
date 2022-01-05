//
//  UIScrollView.swift
//  home42
//
//  Created by Antoine Feuerstein on 22/05/2021.
//

import Foundation
import UIKit

class BasicUIScrollView: UIScrollView {
    
    init() {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
    }
    required init?(coder: NSCoder) { fatalError("Dance cult Holograpic") }
}

extension UIScrollView {
    
    func setScrollIndicatorColor(_ color: UIColor) {
        for subview in self.subviews {
            if subview is UIImageView {
                subview.backgroundColor = color
            }
        }
    }
}
