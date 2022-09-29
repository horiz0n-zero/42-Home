// home42/Particles.swift
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

final class ParticlesEmitter: CAEmitterLayer {
    
    @frozen enum Images: String {
        case particlesGlow = "particles_glow"
        case particlesLight = "particles_light"
        case particlesStar = "particles_star"
        
        var image: UIImage {
            return UIImage(named: self.rawValue)!
        }
    }
    
    @frozen enum Style {
        case trophies
        case stars
        case alertStars
        case coalitionHorizontal(UIImage, UIColor, Float)
        //case donationGoldStars
    }
    
    override init() {
        super.init()
    }
    
    func configure(_ style: Style) {
        switch style {
        case .trophies:
            let cell1 = CAEmitterCell.init()
            let cell2 = CAEmitterCell.init()
            let cell3 = CAEmitterCell.init()
            
            cell1.contents = Images.particlesGlow.image.cgImage
            cell2.contents = Images.particlesStar.image.cgImage
            cell3.contents = Images.particlesLight.image.cgImage
            self.emitterSize = .init(width: 20.0, height: 20.0)
            self.emitterPosition = .init(x: 50.0, y: 50.0)
            self.emitterMode = .outline
            self.emitterCells = [cell1, cell2, cell3]
            for cell in self.emitterCells! {
                cell.color = HomeDesign.gold.cgColor
                cell.birthRate = (1.25 * Float(drand48())) + 0.5
                cell.spinRange = 0.8
                cell.lifetime = 3.0
                cell.lifetimeRange = 0.75
                cell.velocity = 40.0
                cell.velocityRange = 5.0
                cell.alphaSpeed = -0.5
                cell.emissionRange = .pi * 0.25
                cell.emissionLatitude = .pi * 2.0
                cell.scaleSpeed = 0.45
                cell.scaleRange = 0.1
                cell.redSpeed = 0.1
            }
        case .stars:
            let cell1 = CAEmitterCell.init()
            let cell2 = CAEmitterCell.init()
            let cell3 = CAEmitterCell.init()
            let cell4 = CAEmitterCell.init()
            let cell5 = CAEmitterCell.init()
            let image = Images.particlesLight.image.cgImage
            
            cell1.color = HomeDesign.actionRed.cgColor
            cell2.color = HomeDesign.actionBlue.cgColor
            cell3.color = HomeDesign.actionGreen.cgColor
            cell4.color = HomeDesign.actionOrange.cgColor
            cell5.color = HomeDesign.actionYellow.cgColor
            self.emitterSize = .init(width: 20.0, height: 20.0)
            self.emitterPosition = .init(x: 50.0, y: 50.0)
            self.emitterMode = .outline
            self.emitterCells = [cell1, cell2, cell3, cell4, cell5]
            for cell in self.emitterCells! {
                cell.contents = image
                cell.birthRate = (3.0 * Float(drand48())) + 0.5
                cell.spinRange = 0.4
                cell.lifetime = 2.0
                cell.lifetimeRange = 0.75
                cell.velocity = 35.0
                cell.velocityRange = 10.0
                cell.alphaSpeed = -0.5
                cell.emissionRange = .pi * 2.0
                cell.scaleSpeed = 0.45
                cell.scaleRange = 0.1
                cell.redSpeed = 0.5
                cell.blueSpeed = 0.2
                cell.greenSpeed = 0.2
            }
        case .alertStars:
            let cell1 = CAEmitterCell.init()
            let cell2 = CAEmitterCell.init()
            let cell3 = CAEmitterCell.init()
            let cell4 = CAEmitterCell.init()
            let cell5 = CAEmitterCell.init()
            let image = Images.particlesLight.image.cgImage
            
            cell1.color = HomeDesign.actionRed.cgColor
            cell2.color = HomeDesign.actionBlue.cgColor
            cell3.color = HomeDesign.actionGreen.cgColor
            cell4.color = HomeDesign.actionOrange.cgColor
            cell5.color = HomeDesign.actionYellow.cgColor
            self.emitterSize = UIScreen.main.bounds.size / 2.0
            self.emitterMode = .outline
            self.emitterCells = [cell1, cell2, cell3, cell4, cell5]
            for cell in self.emitterCells! {
                cell.contents = image
                cell.birthRate = (6.0 * Float(drand48())) + 1.0
                cell.spinRange = 0.4
                cell.lifetime = 12.0
                cell.lifetimeRange = 2.0
                cell.velocity = 100.0
                cell.velocityRange = 20.0
                cell.alphaSpeed = -0.5
                cell.emissionRange = .pi * 2.0
                cell.scaleSpeed = 0.45
                cell.scaleRange = 0.1
                cell.redSpeed = 0.5
                cell.blueSpeed = 0.2
                cell.greenSpeed = 0.2
                cell.spinRange = .pi * 2.0
            }
        /*case .donationGoldStars:
            let cell1 = CAEmitterCell.init()
            let cell2 = CAEmitterCell.init()
            let cell3 = CAEmitterCell.init()
            let cell4 = CAEmitterCell.init()
            let cell5 = CAEmitterCell.init()
            let image = Images.particlesLight.image.cgImage
            
            cell1.color = HomeDesign.gold.cgColor
            cell2.color = HomeDesign.gold.cgColor
            cell3.color = HomeDesign.gold.cgColor
            cell4.color = HomeDesign.gold.cgColor
            cell5.color = HomeDesign.gold.cgColor
            self.emitterSize = .init(width: HomeLayout.donationCellHeight, height: HomeLayout.donationCellHeight)
            self.emitterPosition = .init(x: HomeLayout.donationCellHeight / 2.0, y: HomeLayout.donationCellHeight / 2.0)
            self.emitterMode = .volume
            self.emitterCells = [cell1, cell2, cell3, cell4, cell5]
            for cell in self.emitterCells! {
                cell.contents = image
                cell.birthRate = (5.0 * Float(drand48())) + 0.5
                cell.spinRange = 0.4
                cell.lifetime = 3.0
                cell.lifetimeRange = 0.25
                cell.velocity = 40.0
                cell.velocityRange = 20.0
                cell.alphaSpeed = -0.5
                cell.emissionRange = .pi * 2.0
                cell.scaleSpeed = 0.1 + 0.35 * CGFloat(drand48())
                cell.scaleRange = 0.1 + 0.3 * CGFloat(drand48())
                cell.redSpeed = 0.2 * Float(drand48())
                cell.blueSpeed = 0.2 * Float(drand48())
                cell.greenSpeed = 0.2 * Float(drand48())
            }*/
        case .coalitionHorizontal(let image, let color, let birthRateMultiplier):
            let cell = CAEmitterCell.init()
            
            self.emitterMode = .outline
            self.emitterShape = .rectangle
            self.emitterCells = [cell]
            self.emitterSize = .init(width: 0.0, height: -25.0)
            cell.color = color.cgColor
            cell.contents = image.cgImage
            cell.birthRate = 2.5 * birthRateMultiplier
            cell.xAcceleration = 30
            cell.lifetime = 6.0
            cell.emissionLongitude = .pi * 2.0
            cell.scale = 0.20
            cell.scaleRange = 0.20
        }
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    @inlinable func pause() {
        self.lifetime = 0.0
    }
    @inlinable func play() {
        self.lifetime = 1.0
    }
}

final class ParticlesEmitterView: BasicUIView {
    
    override class var layerClass: AnyClass {
        return ParticlesEmitter.self
    }
    var particleLayer: ParticlesEmitter {
        return self.layer as! ParticlesEmitter
    }
    
    init(_ style: ParticlesEmitter.Style) {
        super.init()
        self.particleLayer.configure(style)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.particleLayer.emitterSize.width += rect.size.width
        self.particleLayer.emitterSize.height += rect.size.height
        self.particleLayer.emitterPosition = .init(x: rect.size.width / 2.0, y: rect.size.height / 2.0)
    }
    
    func autoRemove(withStartingDelay start: TimeInterval, endingDelay end: TimeInterval) {
        self.alpha = 0.0
        UIView.animate(withDuration: start, delay: 0.0, options: HomeAnimations.curve, animations: {
            self.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: end, delay: 0.0, options: HomeAnimations.curve, animations: {
                self.alpha = 0.0
            }, completion: { _ in
                self.removeFromSuperview()
            })
        })
    }
}
