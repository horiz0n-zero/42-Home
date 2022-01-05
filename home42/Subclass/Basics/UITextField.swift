//
//  UITextField.swift
//  home42
//
//  Created by Antoine Feuerstein on 12/04/2021.
//

import Foundation
import UIKit

class BasicUITextField: UITextField {
    
    init() {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.autocapitalizationType = .none
        self.autocorrectionType = .no
        self.spellCheckingType = .no
        self.smartQuotesType = .no
        self.smartDashesType = .no
        self.smartInsertDeleteType = .no
        self.textColor = HomeDesign.black
        self.font = HomeLayout.fontRegularMedium
        self.keyboardAppearance = HomeDesign.keyboardAppearance
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
