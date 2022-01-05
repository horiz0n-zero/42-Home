//
//  UserProfilIconView.swift
//  home42
//
//  Created by Antoine Feuerstein on 16/04/2021.
//

import Foundation
import UIKit

final class UserProfilIconView: BasicUIView {
    
    private let imageView = BasicUIImageView(image: UIImage.Assets.defaultLogin.image)
    private(set) var login: String!
    
    init(login: String) {
        super.init()
        self.login = login
        if let image = HomeResources.storageLoginImages.get(login) {
            self.imageView.image = image
        }
        else {
            self.imageView.image = UIImage.Assets.defaultLogin.image
            Task.init(priority: .userInitiated, operation: {
                if let (login, image) = await HomeResources.storageLoginImages.obtain(login), login == self.login {
                    self.imageView.image = image
                }
            })
        }
    }
    override init() {
        super.init()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    
    func update(with login: String) {
        self.login = login
        if let image = HomeResources.storageLoginImages.get(login) {
            self.imageView.image = image
        }
        else {
            self.imageView.image = UIImage.Assets.defaultLogin.image
            Task.init(priority: .userInitiated, operation: {
                if let (login, image) = await HomeResources.storageLoginImages.obtain(login), login == self.login {
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
}
