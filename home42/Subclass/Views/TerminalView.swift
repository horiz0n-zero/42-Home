//
//  TerminalView.swift
//  home42
//
//  Created by Antoine Feuerstein on 12/05/2021.
//

import Foundation
import UIKit

final class TerminalView: UIVisualEffectView {
    
    private let header: BasicUILabel
    var title: String {
        set {
            self.header.text = newValue.uppercased()
        }
        get {
            return self.header.text!
        }
    }
    private let textView: UITextView
    
    init(title: String) {
        self.header = BasicUILabel(text: title.uppercased())
        self.header.backgroundColor = HomeDesign.black
        self.header.textColor = HomeDesign.white
        self.header.textAlignment = .center
        self.header.font = HomeLayout.fontBoldTitle
        self.textView = UITextView()
        self.textView.isEditable = false
        self.textView.isScrollEnabled = true
        self.textView.isSelectable = false
        self.textView.translatesAutoresizingMaskIntoConstraints = false
        self.textView.font = HomeLayout.fontThinNormal
        self.textView.textColor = .white
        self.textView.textAlignment = .left
        self.textView.backgroundColor = UIColor.clear
        super.init(effect: HomeDesign.blur)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layer.cornerRadius = HomeLayout.corner
        self.layer.masksToBounds = true
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview != nil else { return }
        
        self.contentView.addSubview(self.header)
        self.header.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        self.header.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        self.header.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        self.header.heightAnchor.constraint(equalToConstant: HomeLayout.terminalHeaderHeight).isActive = true
        self.contentView.addSubview(self.textView)
        self.textView.topAnchor.constraint(equalTo: self.header.bottomAnchor, constant: HomeLayout.smargin).isActive = true
        self.textView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: HomeLayout.smargin).isActive = true
        self.textView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -HomeLayout.smargin).isActive = true
        self.textView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -HomeLayout.smargin).isActive = true
    }
    
    private var logs: [String] = []
    
    func log(_ content: String) {
        self.logs.append(content)
        if logs.count > 100 {
            logs.removeFirst(10)
        }
        self.textView.text = self.logs.joined(separator: "\n")
        #if DEBUG
            print("$", content)
        #endif
    }
}
