// home42/UserProfilIconView.swift
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

final class UserProfilIconView: BasicUIView {
    
    private let imageView = BasicUIImageView(image: UIImage.Assets.defaultLogin.image)
    private(set) var login: String!
    
    init(user: IntraUser) {
        super.init()
        self.login = user.login
        if let image = HomeResources.storageLoginImages.get(user) {
            self.imageView.image = image
        }
        else {
            self.imageView.image = UIImage.Assets.defaultLogin.image
            Task.init(priority: .userInitiated, operation: {
                if let (login, image) = await HomeResources.storageLoginImages.obtain(user), login == self.login {
                    self.imageView.image = image
                }
            })
        }
    }
    init(user: IntraUserInfo) {
        super.init()
        self.login = user.login
        if let image = HomeResources.storageLoginImages.get(user) {
            self.imageView.image = image
        }
        else {
            self.imageView.image = UIImage.Assets.defaultLogin.image
            Task.init(priority: .userInitiated, operation: {
                if let (login, image) = await HomeResources.storageLoginImages.obtain(user), login == self.login {
                    self.imageView.image = image
                }
            })
        }
    }
    init(people: People) {
        super.init()
        self.login = people.login
        if let image = HomeResources.storageLoginImages.get(people) {
            self.imageView.image = image
        }
        else {
            self.imageView.image = UIImage.Assets.defaultLogin.image
            Task.init(priority: .userInitiated, operation: {
                if let (login, image) = await HomeResources.storageLoginImages.obtain(people), login == self.login {
                    self.imageView.image = image
                }
            })
        }
    }
    init(contributor: HomeApiResources.Contributor) {
        super.init()
        self.login = contributor.login
        if let image = HomeResources.storageLoginImages.get(contributor) {
            self.imageView.image = image
        }
        else {
            self.imageView.image = UIImage.Assets.defaultLogin.image
            Task.init(priority: .userInitiated, operation: {
                if let (login, image) = await HomeResources.storageLoginImages.obtain(contributor), login==self.login {
                    self.imageView.image = image
                }
            })
        }
    }
    override init() {
        super.init()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview != nil else { return }
        
        self.addSubview(self.imageView)
        self.imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.imageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    private func imageReceived(_ login: String, image: UIImage) {
        if login == self.login {
            self.imageView.image = image
        }
    }
    
    func update(with user: IntraUser) {
        self.login = user.login
        if let image = HomeResources.storageLoginImages.get(user) {
            self.imageView.image = image
        }
        else {
            self.imageView.image = UIImage.Assets.defaultLogin.image
            Task.init(priority: .userInitiated, operation: {
                if let (login, image) = await HomeResources.storageLoginImages.obtain(user), login == self.login {
                    self.imageView.image = image
                }
            })
        }
    }
    func update(with user: IntraUserInfo) {
        self.login = user.login
        if let image = HomeResources.storageLoginImages.get(user) {
            self.imageView.image = image
        }
        else {
            self.imageView.image = UIImage.Assets.defaultLogin.image
            Task.init(priority: .userInitiated, operation: {
                if let (login, image) = await HomeResources.storageLoginImages.obtain(user), login == self.login {
                    self.imageView.image = image
                }
            })
        }
    }
    func update(with people: People) {
        self.login = people.login
        if let image = HomeResources.storageLoginImages.get(people) {
            self.imageView.image = image
        }
        else {
            self.imageView.image = UIImage.Assets.defaultLogin.image
            Task.init(priority: .userInitiated, operation: {
                if let (login, image) = await HomeResources.storageLoginImages.obtain(people), login == self.login {
                    self.imageView.image = image
                }
            })
        }
    }
    
    @inline(__always) func setSize(_ size: CGFloat, _ radius: CGFloat) {
        self.heightAnchor.constraint(equalToConstant: size).isActive = true
        self.widthAnchor.constraint(equalToConstant: size).isActive = true
        self.imageView.layer.cornerRadius = radius
        self.imageView.layer.masksToBounds = true
    }
    
    @inlinable func reset() {
        self.imageView.image = UIImage.Assets.defaultLogin.image
        self.login = nil
    }
    
    func showImageInFullScreen() {
        SeeContentInFullScreen(value: self.imageView.image ?? UIImage.Assets.defaultLogin.image)
    }
}
