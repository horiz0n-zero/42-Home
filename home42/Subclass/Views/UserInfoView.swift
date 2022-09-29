// home42/UserInfoView.swift
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

final class UserInfoView: BasicUIView, SeparatorTableViewCellView, HomeWhiteContainerTableViewCellView, GenericTableViewCellView {
    
    private let profilIcon: UserProfilIconView
    private let loginLabel: BasicUILabel
    
    override init() {
        self.profilIcon = UserProfilIconView()
        self.loginLabel = BasicUILabel(text: "???")
        self.loginLabel.font = HomeLayout.fontBoldMedium
        self.loginLabel.textColor = HomeDesign.black
        super.init()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview != nil else { return }
        
        self.addSubview(self.profilIcon)
        self.profilIcon.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: HomeLayout.margin).isActive = true
        self.profilIcon.topAnchor.constraint(equalTo: self.topAnchor, constant: HomeLayout.margin).isActive = true
        self.profilIcon.setSize(HomeLayout.userProfilIconHeigth, HomeLayout.userProfilIconRadius)
        self.addSubview(self.loginLabel)
        self.loginLabel.leadingAnchor.constraint(equalTo: self.profilIcon.trailingAnchor, constant: HomeLayout.margin).isActive = true
        self.loginLabel.centerYAnchor.constraint(equalTo: self.profilIcon.centerYAnchor).isActive = true
        self.loginLabel.trailingAnchor.constraint(greaterThanOrEqualTo: self.trailingAnchor, constant: -HomeLayout.smargin).isActive = true
        self.heightAnchor.constraint(equalToConstant: HomeLayout.userInfoViewHeigth).isActive = true
    }
    
    weak var userInfo: IntraUserInfo!
    func update(with userInfo: IntraUserInfo) {
        self.userInfo = userInfo
        self.profilIcon.update(with: userInfo)
        self.loginLabel.text = userInfo.login
    }
    
    weak var user: IntraUser!
    func update(with user: IntraUser) {
        self.user = user
        self.profilIcon.update(with: user)
        self.loginLabel.text = user.login
    }
}
