// home42/HomeQRCode.swift
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
import CoreImage

final class HomeQRCode: NSObject {
    
    let image: UIImage
    let content: String
    
    init(image: UIImage, content: String) {
        self.image = image
        self.content = content
        super.init()
    }
    
    @MainActor func present() {
        QRCodeAlert(qrCode: self).present()
    }
    
    struct Coupon {
        let login: String
        let coalition: IntraCoalition?
        let controllerTitle: String
        let controllerIcon: UIImage.Assets
    }
    
    @MainActor func presentWithCoupon(_ coupon: Coupon) {
        QRCodeAlert(qrCode: self, coupon: coupon).present()
    }
    
    final private class QRCodeAlert: DynamicController {
        
        @MainActor init(qrCode: HomeQRCode, coupon: Coupon? = nil) {
            super.init()
            let primaryColor: UIColor
            let contentView = BasicUIView()
            let coalitionBackground = BasicUIImageView(asset: .coalitionDefaultBackground)
            let imageView = BasicUIImageView(image: qrCode.image)
            
            if let coalition = coupon?.coalition {
                primaryColor = coalition.uicolor
                if let background = HomeResources.storageCoalitionsImages.get(coalition) {
                    coalitionBackground.image = background
                }
                else {
                    Task.init(priority: .userInitiated, operation: {
                        if let (_, background) = await HomeResources.storageCoalitionsImages.obtain(coalition) {
                            coalitionBackground.image = background
                        }
                    })
                }
            }
            else {
                primaryColor = HomeDesign.primary
            }
            if let backgroundPrimary = self.backgroundPrimary {
                backgroundPrimary.alpha = 0.0
                backgroundPrimary.backgroundColor = primaryColor.withAlphaComponent(HomeDesign.alphaLow)
            }
            contentView.tag = 42
            if let coupon = coupon {
                let header = LeftCurvedTitleView(text: coupon.login + "'s coupon", primaryColor: HomeDesign.black, addTopCorner: true)
                let bottomContainer = BasicUIView()
                let appIcon = BasicUIImageView(asset: .settingsAppIcon)
                let controllerIcon = BasicUIImageView(asset: coupon.controllerIcon)
                let controllerText = BasicUILabel(text: coupon.controllerTitle)
                
                self.view.addSubview(contentView)
                contentView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
                contentView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
                contentView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: HomeLayout.margins).isActive = true
                contentView.clipsToBounds = true
                contentView.layer.cornerRadius = HomeLayout.corner
                contentView.backgroundColor = HomeDesign.white
                contentView.isUserInteractionEnabled = true
                contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(QRCodeAlert.contentViewTapped(sender:))))
                contentView.addSubview(header)
                header.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
                header.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
                header.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
                
                contentView.insertSubview(coalitionBackground, belowSubview: header)
                coalitionBackground.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
                coalitionBackground.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
                coalitionBackground.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
                coalitionBackground.heightAnchor.constraint(equalTo: coalitionBackground.widthAnchor, constant: HomeLayout.leftCurvedTitleViewHeigth).isActive = true
                coalitionBackground.addSubview(imageView)
                imageView.contentMode = .center
                imageView.topAnchor.constraint(equalTo: coalitionBackground.topAnchor, constant: HomeLayout.leftCurvedTitleViewHeigth + HomeLayout.smargin).isActive = true
                imageView.leadingAnchor.constraint(equalTo: coalitionBackground.leadingAnchor, constant: HomeLayout.smargin).isActive = true
                imageView.trailingAnchor.constraint(equalTo: coalitionBackground.trailingAnchor, constant: -HomeLayout.smargin).isActive = true
                imageView.bottomAnchor.constraint(equalTo: coalitionBackground.bottomAnchor, constant: -HomeLayout.smargin).isActive = true
                
                contentView.addSubview(bottomContainer)
                bottomContainer.backgroundColor = HomeDesign.black
                bottomContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
                bottomContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
                bottomContainer.topAnchor.constraint(equalTo: coalitionBackground.bottomAnchor).isActive = true
                bottomContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
                bottomContainer.heightAnchor.constraint(equalToConstant: 60.0 + HomeLayout.smargin * 2.0).isActive = true
                bottomContainer.addSubview(appIcon)
                appIcon.leadingAnchor.constraint(equalTo: bottomContainer.leadingAnchor, constant: HomeLayout.margin).isActive = true
                appIcon.centerYAnchor.constraint(equalTo: bottomContainer.centerYAnchor).isActive = true
                appIcon.heightAnchor.constraint(equalToConstant: 60.0).isActive = true
                appIcon.widthAnchor.constraint(equalToConstant: 60.0).isActive = true
                bottomContainer.addSubview(controllerIcon)
                bottomContainer.addSubview(controllerText)
                controllerText.font = HomeLayout.fontBoldTitle
                controllerText.textColor = HomeDesign.gold
                controllerText.numberOfLines = 0
                controllerText.textAlignment = .right
                controllerText.centerYAnchor.constraint(equalTo: appIcon.centerYAnchor).isActive = true
                controllerText.leadingAnchor.constraint(equalTo: appIcon.trailingAnchor, constant: HomeLayout.margin).isActive = true
                controllerText.trailingAnchor.constraint(equalTo: controllerIcon.leadingAnchor, constant: -HomeLayout.margin).isActive = true
                controllerIcon.tintColor = HomeDesign.gold
                controllerIcon.centerYAnchor.constraint(equalTo: appIcon.centerYAnchor).isActive = true
                controllerIcon.trailingAnchor.constraint(equalTo: bottomContainer.trailingAnchor, constant: -HomeLayout.margin).isActive = true
                controllerIcon.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
                controllerIcon.widthAnchor.constraint(equalToConstant: 50.0).isActive = true
            }
            else {
                self.view.addSubview(contentView)
                contentView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
                contentView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
                contentView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: HomeLayout.margins).isActive = true
                contentView.clipsToBounds = true
                contentView.layer.cornerRadius = HomeLayout.corner
                contentView.backgroundColor = HomeDesign.white
                contentView.isUserInteractionEnabled = true
                contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(QRCodeAlert.contentViewTapped(sender:))))
                contentView.addSubview(coalitionBackground)
                coalitionBackground.layer.cornerRadius = HomeLayout.scorner
                coalitionBackground.layer.masksToBounds = true
                coalitionBackground.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
                coalitionBackground.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
                coalitionBackground.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: HomeLayout.margin).isActive = true
                coalitionBackground.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: HomeLayout.margins).isActive = true
                coalitionBackground.heightAnchor.constraint(equalToConstant: qrCode.image.size.height).isActive = true
                coalitionBackground.widthAnchor.constraint(equalToConstant: qrCode.image.size.width).isActive = true
                coalitionBackground.addSubview(imageView)
                imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
                imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
                imageView.heightAnchor.constraint(equalTo: coalitionBackground.heightAnchor).isActive = true
                imageView.widthAnchor.constraint(equalTo: coalitionBackground.widthAnchor).isActive = true
                coalitionBackground.mask = imageView
            }
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        required init() { fatalError("init() has not been implemented") }
        
        override func present() {
            let contentView = self.view.viewWithTag(42)!
            
            contentView.alpha = 0.0
            super.present()
            HomeAnimations.animateShort({
                contentView.alpha = 1.0
                self.background.effect = HomeDesign.blur
                if let backgroundPrimary = self.backgroundPrimary {
                    backgroundPrimary.alpha = 1.0
                }
            })
        }
        override func remove(isFinish: Bool = true) {
            HomeAnimations.animateShort({
                self.view.viewWithTag(42)!.alpha = 0.0
                self.background.effect = nil
                if let backgroundPrimary = self.backgroundPrimary {
                    backgroundPrimary.alpha = 0.0
                }
                if let particleView = self.view.viewWithTag(23) {
                    particleView.alpha = 0.0
                }
            }, completion: super.remove(isFinish:))
        }
        @objc private func contentViewTapped(sender: UITapGestureRecognizer) {
            self.remove()
        }
    }
    
    @frozen enum QRCodeError: Error {
        case contentConvertionToDataFailed
        case outputFailed
        case removingWhiteFailed
    }
    
    static func generateWith(content: String, size: CGFloat = UIScreen.main.bounds.width - (HomeLayout.margind * 2.0)) throws -> HomeQRCode {
        guard let data = content.data(using: .isoLatin1, allowLossyConversion: false) else {
            throw QRCodeError.contentConvertionToDataFailed
        }
        let filter = CIFilter(name: "CIQRCodeGenerator", parameters: [:])!
        let invertFilter = CIFilter(name: "CIColorInvert")!
        let colorFilter = CIFilter(name: "CIMaskToAlpha")!
        let ratio: CGFloat
        let scaledOutput: CIImage
        
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel")
        if let output = filter.outputImage {
            ratio = (size / output.extent.width)
            scaledOutput = output.transformed(by: .init(scaleX: ratio, y: ratio), highQualityDownsample: true)
            
            invertFilter.setValue(scaledOutput, forKey: "inputImage")
            if let invertOutput = invertFilter.outputImage {
                colorFilter.setValue(invertOutput, forKey: "inputImage")
                if let colorOutput = colorFilter.outputImage {
                    return HomeQRCode(image: UIImage(ciImage: colorOutput), content: content)
                }
            }
            throw QRCodeError.removingWhiteFailed
        }
        throw QRCodeError.outputFailed
    }
}
