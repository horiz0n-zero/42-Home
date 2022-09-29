// home42/SkeletonView.swift
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

/* https://dmtopolog.com/cadisplaylink-and-its-applications/
 var displaylink: CADisplayLink!

     var x: CGFloat = 0
 DispatchQueue.global().async {
             self.displaylink = CADisplayLink(target: self, selector: #selector(self.linkTriggered))
             self.displaylink.add(to: .current, forMode: .default)
             RunLoop.current.run()
         }
 @objc func linkTriggered(displaylink: CADisplayLink) {
         x += 1
         if x >= bounds.size.width {
             x = 0
             let col = secondColor
             secondColor = firstColor
             firstColor = col
         }
         type.doCalculationIfNeeded(link: displaylink)
         DispatchQueue.main.async { [weak self] in
             self?.setNeedsDisplay()
         }
         NSLog("type: \(type), x: \(x)")
     }
 */
/*
 static let applicationDidBecomeActiveNotification = UIApplication.didBecomeActiveNotification
 static let applicationWillTerminateNotification = UIApplication.willTerminateNotification
 static let applicationDidEnterForegroundNotification = UIApplication.didEnterBackgroundNotification
 */

/*
 cas d'usage:
 
    Evenement (controller, cellule, fond blanc)
    Elearning (controller, cellule, fond blanc)
    Companies (controller, cellule, fond blanc)
    Users search page (cellule, fond transparent)
    Alert -> Recherche users (cellule, fond transparent)
    ProfilCorrectionCellLoadingView (simple, view, fond transparent)
    
    (internal) error loadingCell
 
    ?Profil (dynamic view, fond transparent)
    ?Graph (view, fond blanc)
    ?CoalitionsBloc
    ?Project (cellule, fond transparent)
 */

protocol SkeletonSourceView: UIView {

    static func skeletonInit() -> Self
    static var  skeletonSources: [SkeletonView<Self>.Source] { get }
}

struct SkeletonViewConfiguration: OptionSet {
    
    var rawValue: UInt
    
    static let useClearBackground: Self = .init(rawValue: 1 << 0)
    static let overrideCoalitionUseErrorScheme: Self = .init(rawValue: 1 << 1)
    
    static let defaultConfigurationOnWhiteBackground: Self = []
    static let defaultConfigurationOnCoalitionBackground: Self = []
    
    static fileprivate let gradientLayerWidth: CGFloat = 0.2
    static fileprivate let animationKeySkeleton: String = "skeleton"
    static fileprivate let animationKeyPulse: String = "pulse"
}

final class SkeletonView<G: SkeletonSourceView>: BasicUIView {
    
    struct Source {
        let keypath: PartialKeyPath<G>
        let effect: Source.Effect
        
        enum Effect {
            case fill
            case labelText(String)
            case labelDynamicText(() -> String)
        }
    }
    
    private let pulseView = BasicUIView()
    private let coalitionImageView = BasicUIImageView(asset: .coalitionDefaultBackground)
    private let gradientLayer: CAGradientLayer = CAGradientLayer()
    private let renderedImageView = BasicUIImageView(image: nil)
    
    private let width: CGFloat
    private var height: CGFloat = 0.0
    private let configuration: SkeletonViewConfiguration
    
    init(width: CGFloat, configuration: SkeletonViewConfiguration, coalition: IntraCoalition? = App.userCoalition) {
        self.width = width
        self.configuration = configuration
        super.init()
        self.backgroundColor = .clear
        self.layer.masksToBounds = true
        self.layer.cornerRadius = HomeLayout.corner
        if configuration.contains(.overrideCoalitionUseErrorScheme) {
            self.pulseView.backgroundColor = HomeDesign.redError
        }
        else {
            if let coalition = coalition {
                if let image = HomeResources.storageCoalitionsImages.get(coalition) {
                    self.coalitionImageView.image = image
                }
                else {
                    Task.init(priority: .userInitiated, operation: {
                        if let image = await HomeResources.storageCoalitionsImages.obtain(coalition)?.1 {
                            self.coalitionImageView.image = image
                        }
                    })
                }
                self.pulseView.backgroundColor = coalition.uicolor
            }
            else {
                self.pulseView.backgroundColor = HomeDesign.primaryDefault
            }
        }
        self.renderSource()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    fileprivate var renderSourceView: G? = nil
    private func renderSource() {
        let view: G
        var sourceView: UIView
        let superview: UIView
        let targetView: UIView
        let rect: CGRect = .init(x: 0.0, y: 0.0, width: self.width, height: UIScreen.main.bounds.height)
        
        if let renderSourceView = self.renderSourceView {
            view = renderSourceView
        }
        else {
            view = G.skeletonInit()
            self.renderSourceView = view
        }
        for source in G.skeletonSources {
            sourceView = view[keyPath: source.keypath] as! UIView
            switch source.effect {
            case .fill:
                sourceView.backgroundColor = UIColor.black
            case .labelText(let txt):
                (sourceView as! UILabel).textColor = UIColor.black
                (sourceView as! UILabel).text = txt
            case .labelDynamicText(let txtBlock):
                (sourceView as! UILabel).textColor = UIColor.black
                (sourceView as! UILabel).text = txtBlock()
            }
        }
        if view is UITableViewCell {
            targetView = view
            targetView.translatesAutoresizingMaskIntoConstraints = false
        }
        else {
            targetView = view
        }
        if targetView.superview == nil {
            superview = BasicUIView()
            superview.frame = rect
            targetView.frame = rect
            superview.addSubview(targetView)
            //targetView.topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
            targetView.leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
            targetView.trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
            targetView.bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
            superview.heightAnchor.constraint(equalToConstant: rect.height).isActive = true
            superview.widthAnchor.constraint(equalToConstant: rect.width).isActive = true
            
        }
        targetView.superview?.layoutIfNeeded()
        targetView.setNeedsDisplay()
        self.renderedImageView.image = targetView.renderImage()
        self.height = self.renderedImageView.image!.size.height
        print(self.renderedImageView.image!.size)
        self.coalitionImageView.image = self.renderedImageView.image
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview != nil else {
            return
        }
        
        print(#function, self.height)
        self.heightAnchor.constraint(equalToConstant: self.height).isActive = true
        self.addSubview(self.pulseView)
        self.pulseView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.pulseView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.pulseView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.pulseView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.addSubview(self.coalitionImageView)
        self.coalitionImageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.coalitionImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.coalitionImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.coalitionImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.gradientLayer.colors = [UIColor.init(white: 1.0, alpha: 0.0).cgColor,
                                     UIColor.white.cgColor,
                                     UIColor.init(white: 1.0, alpha: 0.0).cgColor]
        self.gradientLayer.startPoint = .init(x: 0.0, y: 0.5)
        self.gradientLayer.endPoint = .init(x: SkeletonViewConfiguration.gradientLayerWidth, y: 0.5)
    }
    
    /*override func draw(_ rect: CGRect) {
        return super.draw(rect)
        let positionLR = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.position))
        let positionRL = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.position))
        let animGroup = CAAnimationGroup()
        let gradientLayerSWidth = (rect.width * SkeletonViewConfiguration.gradientLayerWidth) / 2.0
        
        self.removeAnimations()
        self.gradientLayer.frame = rect
        self.layer.addSublayer(self.gradientLayer)
        positionLR.fromValue = NSValue(cgPoint: .init(x: self.gradientLayer.position.x - gradientLayerSWidth,
                                                      y: self.gradientLayer.position.y))
        positionLR.toValue = NSValue(cgPoint: .init(x: self.gradientLayer.position.x + rect.width - gradientLayerSWidth,
                                                    y: self.gradientLayer.position.y))
        positionRL.fromValue = positionLR.toValue
        positionRL.toValue = positionLR.fromValue
        animGroup.animations = [positionLR, positionRL]
        animGroup.duration = HomeAnimations.durationLongLong
        animGroup.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)// HomeAnimations.curveCG
        animGroup.repeatCount = .infinity
        animGroup.autoreverses = true
        animGroup.isRemovedOnCompletion = false
        self.gradientLayer.add(animGroup, forKey: SkeletonViewConfiguration.animationKeySkeleton)
        self.coalitionImageView.layer.mask = self.gradientLayer
        self.pulseView.layer.add(self.pulse(), forKey: SkeletonViewConfiguration.animationKeyPulse)
    }*/
    
    private func pulse() -> CAAnimation {
        let pulseAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
        
        pulseAnimation.fromValue = 0.3
        pulseAnimation.toValue = 0.0
        pulseAnimation.duration = HomeAnimations.durationLongLong / 4.0
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        pulseAnimation.isRemovedOnCompletion = false
        return pulseAnimation
    }
    
    private func removeAnimations() {
        self.gradientLayer.removeAnimation(forKey: SkeletonViewConfiguration.animationKeySkeleton)
        self.pulseView.layer.removeAnimation(forKey: SkeletonViewConfiguration.animationKeyPulse)
    }
}

final class SkeletonTableViewCell<G: SkeletonSourceView>: BasicUITableViewCell {
    
    private var view: SkeletonView<G>! = nil
    private var configuration: SkeletonViewConfiguration? = nil
    private var error: HomeApi.RequestError? = nil
    private var width: CGFloat? = nil
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = UIColor.clear
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func trySetup() {
        guard let configuration = self.configuration, let width = self.width,
                self.superview != nil, self.view == nil else {
            return
        }
        
        self.view = SkeletonView(width: width, configuration: configuration)
        self.contentView.addSubview(self.view)
        self.view.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        self.view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        self.view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        self.view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        if let error = self.error {
            (self.view as! SkeletonView<SkeletonSourceViewErrorView>).renderSourceView?.fill(error)
        }
    }
    
    func configure(_ configuration: SkeletonViewConfiguration) {
        self.configuration = configuration
        self.trySetup()
    }
    func configure(_ conf: SkeletonViewConfiguration, err: HomeApi.RequestError) where G==SkeletonSourceViewErrorView {
        self.configuration = conf
        self.error = err
        self.trySetup()
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview != nil else {
            return
        }
        self.trySetup()
    }
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.width = rect.width
        self.trySetup()
    }
}
/*
@objc protocol SkeletonTableViewDelegate: UITableViewDelegate { }

extension SkeletonTableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell is SkeletonTableViewCell {
            
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell is SkeletonTableViewCell {
            
        }
    }
}
*/

final class SkeletonSourceViewErrorView: BasicUIView, SkeletonSourceView {
    
    static func skeletonInit() -> Self {
        return Self.init()
    }
    static var skeletonSources: [SkeletonView<SkeletonSourceViewErrorView>.Source] = [
        .init(keypath: \.container, effect: .fill)
    ]
    
    private var error: HomeApi.RequestError!
    private let container: BasicUIView = BasicUIView()
    
    func fill(_ error: HomeApi.RequestError) {
        self.error = error
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview != nil else {
            return
        }
        
        self.addSubview(self.container)
        self.container.topAnchor.constraint(equalTo: self.topAnchor, constant: 8.0).isActive = true
        self.container.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8.0).isActive = true
        self.container.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8.0).isActive = true
        self.container.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8.0).isActive = true
        self.heightAnchor.constraint(equalToConstant: 100.0).isActive = true
    }
}
typealias SkeletonErrorTableViewCell = SkeletonTableViewCell<SkeletonSourceViewErrorView>
