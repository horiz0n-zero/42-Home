// home42/LeftCurvedTitleView.swift
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

final class LeftCurvedTitleView: BasicUILabel {
    
    private var textWidth: CGFloat = 0.0
    private var primaryColor: UIColor
    private let addTopCorner: Bool
    
    init(text: String, primaryColor: UIColor, addTopCorner: Bool = true) {
        self.primaryColor = primaryColor
        self.addTopCorner = addTopCorner
        super.init(text: text)
        self.font = HomeLayout.fontSemiBoldMedium
        self.textColor = HomeDesign.white
        self.adjustsFontSizeToFitWidth = true
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview != nil else { return }
        
        self.heightAnchor.constraint(equalToConstant: HomeLayout.leftCurvedTitleViewHeigth).isActive = true
    }
    
    func update(with text: String, primaryColor: UIColor, animate: Bool = false) {
        self.text = text
        self.primaryColor = primaryColor
        if animate {
            HomeAnimations.transitionShort(withView: self, {
                self.text = text
                self.setNeedsDisplay()
            })
        }
        else {
            self.setNeedsDisplay()
        }
    }
    
    private static let radius: CGFloat = HomeLayout.scorner
    fileprivate static let dradius = radius * 2.0
    static let minHeight = HomeLayout.leftCurvedTitleViewHeigth * 0.3
    private static let minusWidth = HomeLayout.leftCurvedTitleViewHeigth * 0.6
    static let middleHeigth: CGFloat = HomeLayout.leftCurvedTitleViewHeigth -
                                                ((HomeLayout.leftCurvedTitleViewHeigth - LeftCurvedTitleView.minHeight) / 2.0)
    override func drawText(in rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        let textRect = rect.insetBy(dx: HomeLayout.margin, dy: 0.0)
        let startPoint: CGPoint
        let middlePoint: CGPoint
        let endPoint: CGPoint
        
        self.textWidth = self.textRect(forBounds: rect, limitedToNumberOfLines: 1).width + HomeLayout.margin
        self.primaryColor.setFill()
        if self.addTopCorner {
            context.move(to: .init(x: 0.0, y: LeftCurvedTitleView.dradius))
            context.addQuadCurve(to: .init(x: LeftCurvedTitleView.dradius, y: 0.0), control: .zero)
            context.addLine(to: .init(x: rect.size.width - LeftCurvedTitleView.dradius, y: 0.0))
            context.addQuadCurve(to: .init(x: rect.size.width, y: LeftCurvedTitleView.dradius), control: .init(x: rect.size.width, y: 0.0))
        }
        else {
            context.move(to: .zero)
            context.addLine(to: .init(x: rect.size.width, y: 0.0))
        }
        if self.textWidth >= rect.size.width - LeftCurvedTitleView.minusWidth {
            context.addLine(to: .init(x: rect.size.width, y: rect.size.height))
        }
        else {
            startPoint = .init(x: self.textWidth + LeftCurvedTitleView.minusWidth, y: LeftCurvedTitleView.minHeight)
            middlePoint = .init(x: startPoint.x - LeftCurvedTitleView.minusWidth / 2.0, y: LeftCurvedTitleView.middleHeigth)
            endPoint = .init(x: self.textWidth, y: rect.size.height)
            context.addLine(to: .init(x: rect.size.width, y: LeftCurvedTitleView.minHeight))
            context.addLine(to: startPoint)
            context.addQuadCurve(to: middlePoint, control: .init(x: middlePoint.x, y: startPoint.y))
            context.addQuadCurve(to: endPoint, control: .init(x: middlePoint.x, y: endPoint.y))
        }
        context.addLine(to: .init(x: 0.0, y: rect.size.height))
        context.addLine(to: .zero)
        context.fillPath()
        super.drawText(in: textRect)
    }
}

final class EventPeopleCurvedView: BasicUILabel {
    
    private var primaryColor: UIColor
    private var secondaryColor: UIColor
    
    init(text: String, primaryColor: UIColor, secondaryColor: UIColor) {
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        super.init(text: text)
        self.font = HomeLayout.fontBoldMedium
        self.textColor = HomeDesign.white
        self.textAlignment = .right
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview != nil else { return }
        
        self.heightAnchor.constraint(equalToConstant: HomeLayout.eventPeopleCurvedTitleViewHeigth).isActive = true
    }
    
    func update(with text: String, primaryColor: UIColor, secondaryColor: UIColor) {
        self.text = text
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.setNeedsDisplay()
    }
    
    private static let radius: CGFloat = HomeLayout.scorner
    private static let dradius = radius * 2.0
    private static let minHeight = HomeLayout.eventPeopleCurvedTitleViewHeigth * 0.3
    private static let minusWidth = HomeLayout.eventPeopleCurvedTitleViewHeigth * 0.6
    private static let middleHeigth: CGFloat = HomeLayout.eventPeopleCurvedTitleViewHeigth - ((HomeLayout.eventPeopleCurvedTitleViewHeigth - EventPeopleCurvedView.minHeight) / 2.0)
    override func drawText(in rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        let offset = HomeLayout.margins + HomeLayout.smargin
        let textWidth = self.textRect(forBounds: rect, limitedToNumberOfLines: 1).width + offset + HomeLayout.smargin
        let textRect = rect.insetBy(dx: offset, dy: HomeLayout.smargin)
        let peopleImage = UIImage.Assets.actionPeople.image
        let curve = HomeLayout.smargin
        
        self.primaryColor.setFill()
        context.move(to: .init(x: 0.0, y: rect.size.height))
        context.addLine(to: .init(x: rect.size.width, y: rect.size.height))
        context.addLine(to: .init(x: rect.size.width, y: 0.0))
        
        context.addLine(to: .init(x: rect.size.width - textWidth + curve, y: 0.0))
        context.addQuadCurve(to: .init(x: rect.size.width - textWidth, y: curve), control: .init(x: rect.size.width - textWidth, y: 0.0))
        
        context.addLine(to: .init(x: rect.size.width - textWidth, y: rect.size.height - EventPeopleCurvedView.minHeight - curve))
        context.addQuadCurve(to: .init(x: rect.size.width - textWidth - curve, y: rect.size.height - EventPeopleCurvedView.minHeight),
                             control: .init(x: rect.size.width - textWidth, y: rect.size.height - EventPeopleCurvedView.minHeight))
        
        context.addLine(to: .init(x: 0.0, y: rect.size.height - EventPeopleCurvedView.minHeight))
        context.addLine(to: .init(x: 0.0, y: rect.size.height))
        context.fillPath()
        self.secondaryColor.setFill()
        peopleImage.draw(in: .init(origin: .init(x: rect.width - rect.height, y: 0.0),
                                   size: .init(width: rect.size.height, height: rect.size.height)))
        super.drawText(in: textRect)
        /*if self.textWidth >= rect.size.width - EventPeopleCurvedView.minusWidth {
            context.addLine(to: .init(x: rect.size.width, y: rect.size.height))
        }
        else {
            startPoint = .init(x: self.textWidth + EventPeopleCurvedView.minusWidth, y: EventPeopleCurvedView.minHeight)
            middlePoint = .init(x: startPoint.x - EventPeopleCurvedView.minusWidth / 2.0, y: EventPeopleCurvedView.middleHeigth)
            endPoint = .init(x: self.textWidth, y: rect.size.height)
            context.addLine(to: .init(x: rect.size.width, y: EventPeopleCurvedView.minHeight))
            context.addLine(to: startPoint)
            context.addQuadCurve(to: middlePoint, control: .init(x: middlePoint.x, y: startPoint.y))
            context.addQuadCurve(to: endPoint, control: .init(x: middlePoint.x, y: endPoint.y))
        }
        context.addLine(to: .init(x: 0.0, y: rect.size.height))
        context.addLine(to: .zero)
        context.fillPath()
        super.drawText(in: textRect)*/
    }
    
}
