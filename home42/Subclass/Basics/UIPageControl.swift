//
//  UIPageControl.swift
//  home42
//
//  Created by Antoine Feuerstein on 08/11/2021.
//

import Foundation
import UIKit

final class BasicUIPageControl: UIPageControl {
    
    init() {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func trySettingCustomBlur(_ effect: UIVisualEffect) {
        func search(_ view: UIView) {
            if let visualEffectView = view as? UIVisualEffectView {
                visualEffectView.effect = effect
                return
            }
            else {
                for subview in view.subviews {
                    search(subview)
                }
            }
        }
        search(self)
    }
}
