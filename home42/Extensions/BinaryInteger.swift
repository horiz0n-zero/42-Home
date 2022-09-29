// home42/BinaryInteger.swift
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

fileprivate let scoreFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    
    formatter.numberStyle = .decimal
    formatter.usesGroupingSeparator = true
    formatter.groupingSeparator = " "
    return formatter
}()

extension BinaryInteger {
    
    var scoreFormatted: String {
        return scoreFormatter.string(from: NSNumber(integerLiteral: Int(self)))!
    }
}
