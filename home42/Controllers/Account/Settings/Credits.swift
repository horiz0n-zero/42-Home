//
//  Credits.swift
//  home42
//
//  Created by Antoine Feuerstein on 02/05/2021.
//

import Foundation
import UIKit

final class CreditsViewController: HomeViewController {
    
    private let header: DarkBlurHeaderWithActionsView
    private let scrollView: BasicUIScrollView
    private let container: BasicUIView
    
    required init() {
        var top: NSLayoutYAxisAnchor
        
        self.header = DarkBlurHeaderWithActionsView(title: ~"SETTINGS_EXTRA_CREDITS")
        self.scrollView = BasicUIScrollView()
        self.scrollView.contentInset = .init(top: App.safeAera.top + HomeLayout.headerWithActionViewHeigth, left: 0.0,
                                             bottom: App.safeAera.bottom + HomeLayout.margin, right: 0.0)
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
            view.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: HomeLayout.margin).isActive = true
            view.trailingAnchor.constraint(equalTo: self.container.trailingAnchor, constant: -HomeLayout.margin).isActive = true
            top = view.bottomAnchor
        }
        func setCenteredElement(_ view: UIView, topMargin: CGFloat) {
            self.container.addSubview(view)
            view.topAnchor.constraint(equalTo: top, constant: topMargin).isActive = true
            view.leadingAnchor.constraint(greaterThanOrEqualTo: self.container.leadingAnchor, constant: HomeLayout.margin).isActive = true
            view.centerXAnchor.constraint(equalTo: self.container.centerXAnchor).isActive = true
            top = view.bottomAnchor
        }
        
        func addTitleSection(text: String, constant: CGFloat) {
            let label = BasicUILabel(text: text)
            
            label.font = HomeLayout.fontSemiBoldBigTitle
            label.textColor = HomeDesign.lightGray
            label.textAlignment = .center
            label.numberOfLines = 0
            setRectangleConstraints(label, topMargin: constant)
        }
        func addSubTitle(text: String, constant: CGFloat) {
            let label = BasicUILabel(text: text)
            
            label.font = HomeLayout.fontSemiBoldTitle
            label.textColor = HomeDesign.lightGray
            label.textAlignment = .left
            label.numberOfLines = 0
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
        func addImage(_ asset: UIImage.Assets, constant: CGFloat) {
            let image = asset.image
            let view = BasicUIImageView(image: image)
            
            setCenteredElement(view, topMargin: constant)
            view.widthAnchor.constraint(equalToConstant: image.size.width).isActive = true
            view.heightAnchor.constraint(equalToConstant: image.size.height).isActive = true
        }
        
        addImage(.settingsAppIcon, constant: HomeLayout.smargin)
        addTitleSection(text: "42 Home", constant: 0.0)
        addText(text: ~"CREDITS_INTRO_1", constant: HomeLayout.margin)
        addText(text: ~"CREDITS_INTRO_2", constant: HomeLayout.smargin)
        addTitleSection(text: ~"CREDITS_FAQ", constant: HomeLayout.margin)
        addSubTitle(text: ~"FAQQ1", constant: HomeLayout.smargin)
        addText(text: ~"FAQ1", constant: HomeLayout.smargin)
        addSubTitle(text: ~"FAQQ2", constant: HomeLayout.smargin)
        addText(text: ~"FAQ2", constant: HomeLayout.smargin)
        addSubTitle(text: ~"FAQQ3", constant: HomeLayout.smargin)
        addText(text: ~"FAQ3", constant: HomeLayout.smargin)
        self.container.bottomAnchor.constraint(equalTo: top).isActive = true
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
