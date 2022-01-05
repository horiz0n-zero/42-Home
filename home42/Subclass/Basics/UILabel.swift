//
//  UILabel.swift
//  home42
//
//  Created by Antoine Feuerstein on 12/04/2021.
//

import Foundation
import UIKit

class BasicUILabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    init(text: String) {
        super.init(frame: .zero)
        self.text = text
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    init(attribute: NSAttributedString) {
        super.init(frame: .zero)
        self.attributedText = attribute
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class HomeInsetsLabel: BasicUILabel {
    
    let inset: CGSize
    override var intrinsicContentSize: CGSize {
        let originalSize = super.intrinsicContentSize
        
        return .init(width: originalSize.width + self.inset.width, height: originalSize.height + self.inset.height)
    }
    
    init(text: String, inset: CGSize) {
        self.inset = inset
        super.init(text: text)
        self.textAlignment = .center
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class HomePressableLabel: BasicUILabel {
    
    var isPressed: Bool = false
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.isPressed = true
        HomeAnimations.animateLigthSpeed({
            self.transform = CGAffineTransform.init(scaleX: 0.95, y: 0.95)
        })
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.isPressed == true {
            self.isPressed = false
            HomeAnimations.animateLigthSpeed({
                self.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
            })
        }
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.isPressed == true {
            self.isPressed = false
            HomeAnimations.animateLigthSpeed({
                self.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
            })
        }
    }
}

final class AlternateLabel: BasicUILabel {
    
    private(set) var selectedIndex: Int
    private(set) var array: [String]!
    
    init(_ array: [String], selectedIndex: Int) {
        self.array = array
        self.selectedIndex = selectedIndex
        super.init(text: array[selectedIndex])
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeText)))
    }
    override init(text: String) {
        self.array = nil
        self.selectedIndex = 0
        super.init(text: text)
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeText)))
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    @objc private func changeText() {
        if self.array != nil {
            if self.selectedIndex >= self.array.count {
                self.selectedIndex = 0
                self.text = self.array[self.selectedIndex]
            }
            else {
                self.text = self.array[self.selectedIndex]
                self.selectedIndex &+= 1
            }
        }
    }
    
    func update(with strings: [String], selectedIndex: Int = 0) {
        self.array = strings
        self.selectedIndex = selectedIndex
        self.text = strings[selectedIndex]
    }
}
