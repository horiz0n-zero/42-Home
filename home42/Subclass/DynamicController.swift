// home42/DynamicController.swift
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

class DynamicController: HomeViewController {
    
    private var window: UIWindow!
    override var prefersStatusBarHidden: Bool { true }
    let background = UIVisualEffectView(effect: nil)
    let backgroundPrimary: BasicUIView?
    
    required init() {
        if App.settings.graphicsBlurPrimary {
            self.backgroundPrimary = BasicUIView()
        }
        else {
            self.backgroundPrimary = nil
        }
        super.init()
        self.background.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.background)
        self.background.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.background.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.background.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.background.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        if let backgroundPrimary = self.backgroundPrimary {
            self.view.addSubview(backgroundPrimary)
            backgroundPrimary.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
            backgroundPrimary.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
            backgroundPrimary.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            backgroundPrimary.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    static private(set) var alertsCount: Int = 0
    func present() {
        DynamicController.alertsCount += 1
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window.windowLevel = .alert
        self.window.rootViewController = self
        self.window.makeKeyAndVisible()
    }
    
    func remove(isFinish: Bool = true) {
        DynamicController.alertsCount -= 1
        self.window?.resignKey()
        self.window = nil
    }
}
