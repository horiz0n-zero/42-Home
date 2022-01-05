//
//  UITextView.swift
//  home42
//
//  Created by Antoine Feuerstein on 15/04/2021.
//

import Foundation
import UIKit

class BasicUITextView: UITextView {
        
    init() {
        super.init(frame: .zero, textContainer: nil)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.tintColor = HomeDesign.primary
        self.backgroundColor = .clear
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.isScrollEnabled = floor(self.sizeThatFits(CGSize.init(width: rect.width, height: .infinity)).height) > floor(rect.height)
    }
}
