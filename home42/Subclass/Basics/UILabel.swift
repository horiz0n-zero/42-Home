// home42/UILabel.swift
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

final class CoalitionBackgroundWithParallaxLabel: BasicUIView {
    
    private let background: BasicUIImageView
    private let backgroundWidth: NSLayoutConstraint
    private let backgroundHeight: NSLayoutConstraint
    private let label: BasicUILabel
    
    var coalition: IntraCoalition? {
        didSet {
            if let coalition = coalition {
                if let image = HomeResources.storageCoalitionsImages.get(coalition) {
                    self.background.image = image
                }
                else {
                    Task.init(priority: .userInitiated, operation: {
                        if let image = await HomeResources.storageCoalitionsImages.obtain(coalition)?.1 {
                            self.background.image = image
                        }
                    })
                }
            }
            else {
                self.background.image = UIImage.Assets.coalitionDefaultBackground.image
            }
        }
    }
    
    var text: String! {
        get { self.label.text }
        set {
            self.label.text = newValue
        }
    }
    var textAlignment: NSTextAlignment {
        get { self.label.textAlignment }
        set {
            self.label.textAlignment = newValue
        }
    }
    var font: UIFont! {
        get { self.label.font }
        set {
            self.label.font = newValue
        }
    }
    var adjustsFontSizeToFitWidth: Bool {
        get { self.label.adjustsFontSizeToFitWidth }
        set {
            self.label.adjustsFontSizeToFitWidth = newValue
        }
    }
    var numberOfLines: Int {
        get { self.label.numberOfLines }
        set {
            self.label.numberOfLines = newValue
        }
    }
    
    init(_ coalition: IntraCoalition! = App.userCoalition, text: String = "") {
        self.coalition = coalition
        self.background = .init(asset: .coalitionDefaultBackground)
        self.backgroundWidth = self.background.widthAnchor.constraint(equalToConstant: 0.0)
        self.backgroundHeight = self.background.heightAnchor.constraint(equalToConstant: 0.0)
        self.label = BasicUILabel(text: text)
        super.init()
        self.layer.masksToBounds = true
        if let coalition = coalition {
            if let image = HomeResources.storageCoalitionsImages.get(coalition) {
                self.background.image = image
            }
            else {
                Task.init(priority: .userInitiated, operation: {
                    if let image = await HomeResources.storageCoalitionsImages.obtain(coalition)?.1 {
                        self.background.image = image
                    }
                })
            }
        }
    }
    required init?(coder: NSCoder) { fatalError() }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview != nil else { return }
        
        self.addSubview(self.background)
        self.addSubview(self.label)
        self.label.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.label.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.label.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.label.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        if App.settings.graphicsUseParallax {
            self.background.setUpParallaxEffect(usingAmout: UserSettings.ParallaxForce.light.rawValue)
        }
        self.background.centerYAnchor.constraint(equalTo: self.label.centerYAnchor).isActive = true
        self.background.centerXAnchor.constraint(equalTo: self.label.centerXAnchor).isActive = true
        self.backgroundWidth.isActive = true
        self.backgroundHeight.isActive = true
    }
    
    override func draw(_ rect: CGRect) {
        let force = App.settings.graphicsUseParallax ? UserSettings.ParallaxForce.light.rawValue * 4.0 : 0.0
        
        self.backgroundHeight.constant = rect.height + force
        self.backgroundWidth.constant = rect.width + force
        self.layoutIfNeeded()
        super.draw(rect)
        self.layer.mask = self.label.layer
    }
}
