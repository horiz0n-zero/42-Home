// home42/CoalitionHorizontalFlagView.swift
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

final class CoalitionHorizontalFlagView: BasicUIView {
    
    private let icon: BasicUIImageView
    private let label: BasicUILabel
    
    override init() {
        self.icon = .init(asset: .svgFactionless)
        self.icon.contentMode = .scaleToFill
        self.icon.translatesAutoresizingMaskIntoConstraints = false
        self.label = BasicUILabel(text: "???")
        self.label.font = HomeLayout.fontBlackTitle
        self.label.textColor = HomeDesign.white
        self.label.textAlignment = .left
        super.init()
        self.backgroundColor = .clear
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview != nil else { return }
        
        let w = self.widthAnchor.constraint(equalToConstant: HomeLayout.coalitionHorizontalFlagWidth)
        
        w.priority = .defaultLow
        w.isActive = true
        self.heightAnchor.constraint(equalToConstant: HomeLayout.coalitionHorizontalFlagHeigth).isActive = true
        self.addSubview(self.icon)
        self.icon.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: HomeLayout.smargin).isActive = true
        self.icon.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.icon.topAnchor.constraint(equalTo: self.topAnchor, constant: HomeLayout.smargin).isActive = true
        self.icon.widthAnchor.constraint(equalTo: self.icon.heightAnchor, multiplier: 1.0).isActive = true
        self.addSubview(self.label)
        self.label.leadingAnchor.constraint(equalTo: self.icon.trailingAnchor, constant: HomeLayout.margin).isActive = true
        self.label.centerYAnchor.constraint(equalTo: self.icon.centerYAnchor).isActive = true
        self.label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.coalitionHorizontalFlagHeigth).isActive = true
    }
    
    var coalition: IntraCoalition!
    //var particlesEmitter: ParticlesEmitterView!
    func update(with coalition: IntraCoalition, position: Int, blocSize: Int) {
        self.coalition = coalition
        /*if self.particlesEmitter != nil {
            self.particlesEmitter.removeFromSuperview()
        }*/
        if let image = HomeResources.storageSVGCoalition.get(coalition) {
            self.icon.image = image
            self.icon.tintColor = HomeDesign.white
        }
        else {
            self.icon.image = UIImage.Assets.svgFactionless.image
            self.icon.tintColor = HomeDesign.white
            Task.init(priority: .userInitiated, operation: {
                if let (coa, image) = await HomeResources.storageSVGCoalition.obtain(coalition), coa.id == coalition.id {
                    self.icon.tintColor = HomeDesign.white
                    self.icon.image = image
                }
            })
        }
        self.label.text = coalition.name
        self.setNeedsDisplay()
    }
    /*
    private func setupParticlesEmitter(image: SVGKImage, color: UIColor, position: Int, blocSize: Int) {
        self.particlesEmitter = ParticlesEmitterView(.coalitionHorizontal(image, color, 1 - (Float(position) / Float(blocSize)) + 0.25))
        self.addSubview(self.particlesEmitter)
        self.particlesEmitter.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.coalitionHorizontalFlagTriangle).isActive = true
        self.particlesEmitter.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.particlesEmitter.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        self.particlesEmitter.widthAnchor.constraint(equalToConstant: 1.0).isActive = true
    }*/
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        
        (self.coalition?.uicolor ?? HomeDesign.primaryDefault).setFill()
        context.move(to: .zero)
        context.addLine(to: .init(x: rect.size.width - HomeLayout.coalitionHorizontalFlagTriangle, y: 0.0))
        context.addLine(to: .init(x: rect.size.width, y: rect.size.height / 2.0))
        context.addLine(to: .init(x: rect.size.width - HomeLayout.coalitionHorizontalFlagTriangle, y: rect.size.height))
        context.addLine(to: .init(x: 0.0, y: rect.size.height))
        context.addLine(to: .zero)
        context.closePath()
        context.fillPath()
        super.draw(rect)
    }
}
