// home42/UserSlots.swift
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

final class UserSlotsViewController: HomeViewController {
    /*
    private let header: HeaderWithActionsView
    private let daySelector: IntegerSelectorWithArrows
    
    private let manager: SlotsManagerView
    private let lockButton: ActionButtonView
    
    required init() {
        let closeButton = ActionButtonView(asset: .actionClose, color: HomeDesign.actionRed)
        
        self.header = HeaderWithActionsView(title: ~"general.slots", actions: [closeButton])
        self.daySelector = IntegerSelectorWithArrows(min: 0, max: 30, currentValue: 0)
        self.manager = SlotsManagerView()
        self.lockButton = ActionButtonView(asset: .actionUnlock, color: HomeDesign.actionOrange)
        super.init()
        self.view.backgroundColor = HomeDesign.white
        self.view.addSubview(self.header)
        self.header.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.header.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.header.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.view.addSubview(self.daySelector)
        self.daySelector.topAnchor.constraint(equalTo: self.header.bottomAnchor, constant: HomeLayout.margin).isActive = true
        self.daySelector.leadingAnchor.constraint(equalTo: self.header.leadingAnchor, constant: HomeLayout.margin).isActive = true
        self.daySelector.trailingAnchor.constraint(equalTo: self.header.trailingAnchor, constant: -HomeLayout.margin).isActive = true
        self.view.addSubview(self.manager)
        self.manager.topAnchor.constraint(equalTo: self.daySelector.bottomAnchor, constant: HomeLayout.actionButtonIconRadius + HomeLayout.margin).isActive = true
        self.manager.leadingAnchor.constraint(equalTo: self.daySelector.leadingAnchor).isActive = true
        self.manager.trailingAnchor.constraint(equalTo: self.daySelector.trailingAnchor).isActive = true
        self.manager.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -HomeLayout.margin).isActive = true
        self.view.addSubview(self.lockButton)
        self.lockButton.centerYAnchor.constraint(equalTo: self.manager.topAnchor).isActive = true
        self.lockButton.trailingAnchor.constraint(equalTo: self.daySelector.trailingAnchor, constant: -HomeLayout.smargin).isActive = true
        
        self.daySelector.delegate = self
        closeButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeButtonTapped(sender:))))
        self.lockButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(lockButtonTapped(sender:))))
        HomeApi.get(.meSlots, params: ["sort":"begin_at", "filter[future]": true], block: self.slotsReceived(_:error:))
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    final private class SlotsManagerView: BasicUITableView, UITableViewDelegate, UITableViewDataSource {
        
        private let activityIndicator: BasicUIActivityIndicatorView
        
        override init() {
            self.activityIndicator = BasicUIActivityIndicatorView()
            
            super.init()
            self.backgroundColor = HomeDesign.primary.withAlphaComponent(HomeDesign.alphaLowLayer)
            self.layer.cornerRadius = HomeLayout.corner
            self.layer.masksToBounds = true
        }
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 0
        }
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            return UITableViewCell()
        }
    }
    
    private func slotsReceived(_ slots: [IntraSlot]?, error: HomeApi.RequestError?) {
        print(#function, slots, error)
    }
    
    func integerSelectorValueChanged(_ selector: IntegerSelectorWithArrows) {
        
    }
    
    @objc private func lockButtonTapped(sender: UITapGestureRecognizer) {
        if self.lockButton.asset == .actionUnlock {
            self.lockButton.switch(asset: .actionLock, color: HomeDesign.actionRed)
        }
        else {
            self.lockButton.switch(asset: .actionUnlock, color: HomeDesign.actionOrange)
        }
    }
    
    @objc private func closeButtonTapped(sender: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }*/
}
