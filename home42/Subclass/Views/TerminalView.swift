// home42/TerminalView.swift
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

final class TerminalView: UIVisualEffectView, TextOutputStream {
    
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
        self.textView.textAlignment = .left
        self.textView.backgroundColor = UIColor.clear
        self.textView.font = HomeLayout.fontRegularMedium
        self.textView.textColor = HomeDesign.white
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
        self.textView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: HomeLayout.dmargin).isActive = true
        self.textView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -HomeLayout.smargin).isActive = true
        self.textView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -HomeLayout.smargin).isActive = true
    }
    
    /*private var logs: [NSAttributedString] = []
    
    private func updateLogs() {
        let newAttrs = NSMutableAttributedString.init()
        
        for log in self.logs {
            newAttrs.append(log)
        }
        self.textView.attributedText = newAttrs
        self.textView.scrollRangeToVisible(NSMakeRange(self.textView.text!.count - 1, 1))
    }
    
    func log(_ format: String, args: [CVarArg], colors: [UIColor?]) {
        let result = String(format: format, arguments: args)
        var offset: Int = 0
        var newAttr: NSMutableAttributedString = NSMutableAttributedString(string: result, attributes: [.font: HomeLayout.fontThinNormal, .foregroundColor: HomeDesign.white])
        var matches = format.extractRangeMatchesWithRegexPattern("%[\\-\\+0\\s\\#]{0,1}(\\d+){0,1}(\\.\\d+){0,1}[hlI]{0,1}[cCdiouxXeEfgGnpsS@]{1}")
        var transformed: [Substring] = []
        var colorIndex: Int = 0
        var matchesLenght: Int = 0
        
        while let match = matches.first {
            _ = matches.removeFirst()
            if colors[colorIndex] == nil {
                colorIndex &+= 1
                continue
            }
            
            if let next = matches.first {
                // newAttr.append(T##attrString: NSAttributedString##NSAttributedString)
                return
                if transformed.count > 0 {
                    offset = match.location + transformed.joined().count - matchesLenght
                    matchesLenght += match.length
                }
                else {
                    offset = match.location
                    matchesLenght += match.length
                }
                for indexedOffset in offset ..< result.count {
                    let x = result[result.index(result.startIndex, offsetBy: indexedOffset) ..< result.endIndex]
                    let y = format[format.index(format.startIndex, offsetBy: match.location + match.length) ..< format.endIndex]
                    
                    if x == y {
                        transformed.append(result[result.index(result.startIndex, offsetBy: offset) ..< result.index(result.startIndex, offsetBy: indexedOffset)])
                        newAttr.addAttributes([.foregroundColor: colors[colorIndex]!, .font: HomeLayout.fontRegularNormal], range: NSMakeRange(offset, indexedOffset - offset))
                        break
                    }
                }
            }
            else {
                offset = match.location
                matchesLenght += match.length
                for indexedOffset in offset ..< result.count {
                    let x = result[result.index(result.startIndex, offsetBy: indexedOffset) ..< result.endIndex]
                    let y = format[format.index(format.startIndex, offsetBy: match.location + match.length) ..< format.endIndex]
                    
                    if x == y {
                        transformed.append(result[result.index(result.startIndex, offsetBy: offset) ..< result.index(result.startIndex, offsetBy: indexedOffset)])
                        newAttr.addAttributes([.foregroundColor: colors[colorIndex]!, .font: HomeLayout.fontRegularNormal], range: NSMakeRange(offset, indexedOffset - offset))
                        break
                    }
                }
            }
            colorIndex += 1
        }
        self.logs.append(newAttr)
        self.updateLogs()
    }*/
    
    private var logs: [String] = []
    
    func write(_ string: String) {
        self.logs.append(string)
        if logs.count > 100 {
            logs.removeFirst(10)
        }
        self.textView.text = self.logs.joined(separator: "\n")
        self.textView.scrollRangeToVisible(NSMakeRange(self.textView.text!.count - 1, 1))
        #if DEBUG
        print(string)
        #endif
    }
}
