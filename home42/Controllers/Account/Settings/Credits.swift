// home42/Credits.swift
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

final class CreditsViewController: HomeViewController {
    
    private let header: DarkBlurHeaderWithActionsView
    private let scrollView: BasicUIScrollView
    private let container: BasicUIView
    
    required init() {
        var top: NSLayoutYAxisAnchor
        
        self.header = DarkBlurHeaderWithActionsView(icon: .settingsMore, title: ~"settings.extra.credits")
        self.scrollView = BasicUIScrollView()
        self.scrollView.contentInset = .init(top: HomeLayout.safeAera.top + HomeLayout.headerWithActionViewHeigth,
                                             left: 0.0,
                                             bottom: HomeLayout.safeAera.bottom + HomeLayout.margin,
                                             right: 0.0)
        self.container = BasicUIView()
        super.init()
        self.view.backgroundColor = HomeDesign.black
        self.view.addSubview(self.scrollView)
        self.scrollView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.scrollView.addSubview(self.container)
        self.container.topAnchor.constraint(equalTo: self.scrollView.topAnchor).isActive = true
        self.container.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor).isActive = true
        self.container.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor).isActive = true
        self.container.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor).isActive = true
        self.container.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
        self.view.addSubview(self.header)
        self.header.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.header.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.header.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        top = self.container.topAnchor
        
        func setRectangleConstraints(_ view: UIView, topMargin: CGFloat) {
            self.container.addSubview(view)
            view.topAnchor.constraint(equalTo: top, constant: topMargin).isActive = true
            view.leadingAnchor.constraint(equalTo: self.container.leadingAnchor,
                                          constant: HomeLayout.margin).isActive = true
            view.trailingAnchor.constraint(equalTo: self.container.trailingAnchor,
                                           constant: -HomeLayout.margin).isActive = true
            top = view.bottomAnchor
        }
        func setCenteredElement(_ view: UIView, topMargin: CGFloat) {
            self.container.addSubview(view)
            view.topAnchor.constraint(equalTo: top, constant: topMargin).isActive = true
            view.leadingAnchor.constraint(greaterThanOrEqualTo: self.container.leadingAnchor,
                                          constant: HomeLayout.margin).isActive = true
            view.centerXAnchor.constraint(equalTo: self.container.centerXAnchor).isActive = true
            top = view.bottomAnchor
        }
        
        func addTitleSection(text: String, constant: CGFloat) {
            let shadowLabel = BasicUILabel(text: text)
            let label = CoalitionBackgroundWithParallaxLabel(text: text)
            
            label.font = HomeLayout.fontBoldBigTitle
            label.textAlignment = .center
            label.numberOfLines = 0
            shadowLabel.font = label.font
            shadowLabel.textAlignment = label.textAlignment
            shadowLabel.numberOfLines = label.numberOfLines
            shadowLabel.layer.shadowColor = HomeDesign.white.cgColor
            shadowLabel.layer.shadowOpacity = Float(HomeDesign.alphaLayer)
            shadowLabel.layer.shadowRadius = 2.0
            shadowLabel.layer.shadowOffset = .zero
            self.container.addSubview(shadowLabel)
            setRectangleConstraints(label, topMargin: constant)
            shadowLabel.topAnchor.constraint(equalTo: label.topAnchor).isActive = true
            shadowLabel.leadingAnchor.constraint(equalTo: label.leadingAnchor).isActive = true
            shadowLabel.trailingAnchor.constraint(equalTo: label.trailingAnchor).isActive = true
            shadowLabel.bottomAnchor.constraint(equalTo: label.bottomAnchor).isActive = true
        }
        func addSubTitle(text: String, constant: CGFloat) {
            let label = BasicUILabel(text: text)
            
            label.font = HomeLayout.fontSemiBoldTitle
            label.textAlignment = .left
            label.numberOfLines = 0
            label.textColor = HomeDesign.white
            setRectangleConstraints(label, topMargin: constant)
        }
        func addText(text: String, constant: CGFloat) {
            let label = BasicUILabel(text: text)
            
            label.font = HomeLayout.fontRegularMedium
            label.textColor = HomeDesign.lightGray
            label.textAlignment = .left
            label.numberOfLines = 0
            setRectangleConstraints(label, topMargin: constant)
        }
        func addImage(_ asset: UIImage.Assets, constant: CGFloat, w: CGFloat? = nil, h: CGFloat? = nil) {
            let image = asset.image
            let view = BasicUIImageView(image: image)
            
            setCenteredElement(view, topMargin: constant)
            view.widthAnchor.constraint(equalToConstant: w ?? image.size.width).isActive = true
            view.heightAnchor.constraint(equalToConstant: h ?? image.size.height).isActive = true
        }
        let appIconRatio = UIScreen.main.bounds.width / 500.0 * 0.7
        
        addImage(.appIconBig, constant: -HomeLayout.margin, w: 500.0 * appIconRatio, h: 350 * appIconRatio)
        addTitleSection(text: ~"credits.intro-title", constant: HomeLayout.margind)
        addText(text: ~"credits.intro", constant: HomeLayout.margin)
        addText(text: ~"credits.intro-main-contributor", constant: HomeLayout.smargin)
        
        func addMainContributor() {
            let view = BasicUIView()
            let main = HomeApiResources.contributors.first(where: { $0.value.id == 20091 })!.value
            let icon = UserProfilIconView(contributor: main)
            let particules = ParticlesEmitterView(.stars)
            let label = BasicUILabel(text: main.login)
            
            icon.layer.shadowColor = HomeDesign.gold.cgColor
            icon.layer.shadowRadius = HomeLayout.smargin
            icon.layer.shadowOffset = .zero
            icon.layer.shadowOpacity = Float(HomeDesign.alphaMiddle)
            label.font = HomeLayout.fontBoldBigTitle
            label.textColor = HomeDesign.white
            label.layer.shadowColor = icon.layer.shadowColor
            label.layer.shadowRadius = icon.layer.shadowRadius
            label.layer.shadowOffset = icon.layer.shadowOffset
            label.layer.shadowOpacity = icon.layer.shadowOpacity
            view.addSubview(particules)
            view.addSubview(icon)
            icon.isUserInteractionEnabled = true
            icon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(seeMainContributors)))
            icon.setSize(HomeLayout.userProfilIconCreditsHeigth, HomeLayout.userProfilIconCreditsRadius)
            icon.topAnchor.constraint(equalTo: view.topAnchor, constant: HomeLayout.smargin).isActive = true
            icon.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            icon.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -HomeLayout.smargin).isActive = true
            particules.centerXAnchor.constraint(equalTo: icon.centerXAnchor).isActive = true
            particules.centerYAnchor.constraint(equalTo: icon.centerYAnchor).isActive = true
            particules.widthAnchor.constraint(equalTo: icon.widthAnchor, multiplier: 1.3).isActive = true
            particules.heightAnchor.constraint(equalTo: icon.heightAnchor, multiplier: 1.3).isActive = true
            view.addSubview(label)
            label.centerYAnchor.constraint(equalTo: icon.centerYAnchor).isActive = true
            label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: HomeLayout.margin).isActive = true
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            self.container.addSubview(view)
            view.topAnchor.constraint(equalTo: top, constant: HomeLayout.margin).isActive = true
            view.centerXAnchor.constraint(equalTo: self.container.centerXAnchor).isActive = true
            view.leadingAnchor.constraint(greaterThanOrEqualTo: self.container.leadingAnchor,
                                          constant: HomeLayout.smargin).isActive = true
            top = view.bottomAnchor
        }
        
        func addOtherContributorsButton() {
            let view = BasicUIView()
            let label = BasicUILabel(text: String(format: ~"credits.other-contributors",
                                                  HomeApiResources.contributors.count))
            
            view.backgroundColor = HomeDesign.gold
            view.layer.cornerRadius = HomeLayout.scorner
            view.layer.shadowColor = HomeDesign.gold.cgColor
            view.layer.shadowRadius = HomeLayout.smargin
            view.layer.shadowOffset = .zero
            view.layer.shadowOpacity = Float(HomeDesign.alphaMiddle)
            view.isUserInteractionEnabled = true
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(seeOtherContributors)))
            label.font = HomeLayout.fontSemiBoldMedium
            label.textColor = HomeDesign.white
            label.textAlignment = .center
            label.numberOfLines = 0
            self.container.addSubview(view)
            view.topAnchor.constraint(equalTo: top, constant: HomeLayout.margin).isActive = true
            view.centerXAnchor.constraint(equalTo: self.container.centerXAnchor).isActive = true
            view.leadingAnchor.constraint(equalTo: self.container.leadingAnchor,
                                          constant: HomeLayout.margin).isActive = true
            view.addSubview(label)
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: HomeLayout.smargin).isActive = true
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: HomeLayout.smargin).isActive = true
            top = view.bottomAnchor
        }
        
        addTitleSection(text: ~"credits.main-contributor-title", constant: HomeLayout.margins)
        addMainContributor()
        addText(text: ~"credits.main-contributor", constant: HomeLayout.margin)
        addOtherContributorsButton()
        
        addTitleSection(text: ~"credits.faq", constant: HomeLayout.margins)
        for index in 1 ... 10 {
            addSubTitle(text: ~"faqq\(index)", constant: HomeLayout.margins)
            addText(text: ~"faq\(index)", constant: HomeLayout.smargin)
        }
        
        addTitleSection(text: ~"credits.donations-title", constant: HomeLayout.margins)
        addText(text: ~"credits.donations", constant: HomeLayout.margins)
        
        self.container.bottomAnchor.constraint(equalTo: top).isActive = true
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    @objc private func seeMainContributors() {
        let profil = ProfilViewController()
        
        Task.init(priority: .userInitiated) {
            await profil.setupWithUser("afeuerst", id: 20091)
        }
        self.presentWithBlur(profil, completion: nil)
    }
    
    @objc private func seeOtherContributors() {
        self.presentWithBlur(ContributorsListViewController())
    }
}
