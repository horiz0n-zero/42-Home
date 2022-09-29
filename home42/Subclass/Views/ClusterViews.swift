// home42/ClusterView.swift
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

protocol ClusterView: UIView {
    var location: IntraClusterLocation? { get }
    var display: String { get set }
    
    init(frame: CGRect, display: String)
    
    func configure(location: IntraClusterLocation?, color: CGColor?)
    func transition(location: IntraClusterLocation?, color: CGColor?)
}

protocol ClusterPillarView: UIView {
    
    init(frame: CGRect)
    func setPrimary(_ color: UIColor)
}

class ClusterPillarViewBase: UIView, ClusterPillarView {
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = HomeDesign.primary
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func setPrimary(_ color: UIColor) {
        self.backgroundColor = color
    }
}

final class ClusterPillarViewRectangular: ClusterPillarViewBase { }
final class ClusterPillarViewCurved: ClusterPillarViewBase {
    required init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = HomeLayout.dcorner
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - classic
class ClusterViewClassicBase: UIImageView, ClusterView {
    
    private(set) var location: IntraClusterLocation? = nil
    private let label: BasicUILabel
    var display: String {
        get { return self.label.text! }
        set { self.label.text = newValue }
    }
    
    required init(frame: CGRect, display: String) {
        self.label = BasicUILabel(text: display)
        self.label.textColor = HomeDesign.black
        self.label.textAlignment = .center
        self.label.font = HomeLayout.fontBoldNormal
        self.label.adjustsFontSizeToFitWidth = true
        super.init(frame: frame)
        self.contentMode = .scaleAspectFill
        self.backgroundColor = HomeDesign.white
        self.layer.borderWidth = HomeLayout.border
        self.layer.masksToBounds = true
        self.tintColor = HomeDesign.black
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview != nil else { return }
        
        self.addSubview(self.label)
        self.label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -HomeLayout.dmargin).isActive = true
        self.label.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.label.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }
    
    func configure(location: IntraClusterLocation?, color: CGColor?) {
        if let user = location?.user {
            self.label.textColor = HomeDesign.white
            if user.id != self.location?.user.id {
                if let image = HomeResources.storageLoginImages.get(user) {
                    self.image = image
                }
                else {
                    self.image = UIImage.Assets.defaultLogin.image
                    Task.init(priority: .userInitiated, operation: {
                        if let (login, image) = await HomeResources.storageLoginImages.obtain(user), login == self.location?.user.login {
                            self.image = image
                        }
                    })
                }
            }
        }
        else {
            self.image = nil
            self.label.textColor = HomeDesign.black
        }
        self.label.text = display
        self.location = location
        self.layer.borderColor = color ?? UIColor.clear.cgColor
    }
    func transition(location: IntraClusterLocation?, color: CGColor?) {
        self.configure(location: location, color: color)
    }
}

final class ClusterViewClassicRectangular: ClusterViewClassicBase { }
final class ClusterViewClassicCurved: ClusterViewClassicBase {
    
    required init(frame: CGRect, display: String) {
        super.init(frame: frame, display: display)
        self.layer.cornerRadius = HomeLayout.dcorner
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - clear
class ClusterViewClearBase: UIImageView, ClusterView {
    
    private(set) var location: IntraClusterLocation? = nil
    var display: String
    
    required init(frame: CGRect, display: String) {
        self.display = display
        super.init(frame: frame)
        self.contentMode = .scaleAspectFill
        self.backgroundColor = HomeDesign.white
        self.layer.borderWidth = HomeLayout.border
        self.layer.masksToBounds = true
        self.tintColor = HomeDesign.black
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func configure(location: IntraClusterLocation?, color: CGColor?) {
        if let user = location?.user {
            if self.location?.user.id != user.id {
                if let image = HomeResources.storageLoginImages.get(user) {
                    self.image = image
                }
                else {
                    self.image = UIImage.Assets.defaultLogin.image
                    Task.init(priority: .userInitiated, operation: {
                        if let (login, image) = await HomeResources.storageLoginImages.obtain(user), login == self.location?.user.login {
                            self.image = image
                        }
                    })
                }
            }
        }
        else {
            self.image = nil
        }
        self.location = location
        self.layer.borderColor = color ?? UIColor.clear.cgColor
    }
    func transition(location: IntraClusterLocation?, color: CGColor?) {
        self.configure(location: location, color: color)
    }
}

final class ClusterViewClearRectangular: ClusterViewClearBase { }
final class ClusterViewClearCurved: ClusterViewClearBase {
    
    required init(frame: CGRect, display: String) {
        super.init(frame: frame, display: display)
        self.layer.cornerRadius = HomeLayout.dcorner
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - blurred
class ClusterViewBlurredBase: UIImageView, ClusterView {
    
    private(set) var location: IntraClusterLocation? = nil
    private let label: BasicUILabel
    private let blurredView: BasicUIView
    var display: String {
        get { return self.label.text! }
        set { self.label.text = newValue }
    }
    
    required init(frame: CGRect, display: String) {
        self.label = BasicUILabel(text: display)
        self.label.textColor = HomeDesign.black
        self.label.textAlignment = .center
        self.label.font = HomeLayout.fontBoldNormal
        self.label.adjustsFontSizeToFitWidth = true
        self.blurredView = BasicUIView()
        self.blurredView.backgroundColor = HomeDesign.black.withAlphaComponent(HomeDesign.alphaLayer)
        super.init(frame: frame)
        self.contentMode = .scaleAspectFill
        self.backgroundColor = HomeDesign.white
        self.layer.borderWidth = HomeLayout.border
        self.layer.masksToBounds = true
        self.tintColor = HomeDesign.black
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview != nil else { return }
        
        self.addSubview(self.blurredView)
        self.blurredView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.blurredView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.blurredView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.addSubview(self.label)
        self.label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -HomeLayout.dmargin).isActive = true
        self.label.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.label.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.blurredView.topAnchor.constraint(equalTo: self.label.topAnchor).isActive = true
    }
    
    func configure(location: IntraClusterLocation?, color: CGColor?) {
        self.label.text = display
        if let user = location?.user {
            self.blurredView.isHidden = false
            self.label.textColor = HomeDesign.white
            if user.id != self.location?.user.id {
                if let image = HomeResources.storageLoginImages.get(user) {
                    self.image = image
                }
                else {
                    self.image = UIImage.Assets.defaultLogin.image
                    Task.init(priority: .userInitiated, operation: {
                        if let (login, image) = await HomeResources.storageLoginImages.obtain(user), login == self.location?.user.login {
                            self.image = image
                        }
                    })
                }
            }
        }
        else {
            self.blurredView.isHidden = true
            self.image = nil
            self.label.textColor = HomeDesign.black
        }
        self.location = location
        self.layer.borderColor = color ?? UIColor.clear.cgColor
    }
    func transition(location: IntraClusterLocation?, color: CGColor?) {
        self.configure(location: location, color: color)
    }
}

final class ClusterViewBlurredRectangular: ClusterViewBlurredBase { }
final class ClusterViewBlurredCurved: ClusterViewBlurredBase {
    
    required init(frame: CGRect, display: String) {
        super.init(frame: frame, display: display)
        self.layer.cornerRadius = HomeLayout.dcorner
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
