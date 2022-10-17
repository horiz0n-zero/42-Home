// home42/HomeLayout.swift
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

final class HomeLayout: NSObject {
    
    static let dmargin: CGFloat = 3.0
    static let smargin: CGFloat = 6.0
    static let margin: CGFloat  = 12.0
    static let margins: CGFloat = 18.0
    static let margind: CGFloat = 32.0
    
    static let dcorner: CGFloat = 2.0
    static let scorner: CGFloat = 4.0
    static let corner: CGFloat  = 8.0
    static let corners: CGFloat = 12.0
    static let cornerd: CGFloat = 16.0
    
    static let sborder: CGFloat = 1.0
    static let border: CGFloat  = 2.0
    static let borders: CGFloat = 3.0
    
    static var safeAera: UIEdgeInsets = {
        return App.window!.safeAreaInsets
    }()
    static var safeAeraMain: UIEdgeInsets = {
        return .init(top: App.window!.safeAreaInsets.top + HomeLayout.mainSelectionSize + HomeLayout.margin * 2.0 + HomeLayout.smargin,
                     left: App.window!.safeAreaInsets.left,
                     bottom: App.window!.safeAreaInsets.bottom,
                     right: App.window!.safeAreaInsets.right)
    }()
    
    static private let fontSizeLittle: CGFloat   = 10.0
    static private let fontSizeNormal: CGFloat   = 13.0
    static private let fontSizeMedium: CGFloat   = 16.0
    static private let fontSizeTitle: CGFloat    = 19.0
    static private let fontSizeBigTitle: CGFloat = 22.0
    // .thin
    static let fontThinLittle = UIFont.systemFont(ofSize: HomeLayout.fontSizeLittle, weight: .thin)
    static let fontThinNormal = UIFont.systemFont(ofSize: HomeLayout.fontSizeNormal, weight: .thin)
    static let fontThinMedium = UIFont.systemFont(ofSize: HomeLayout.fontSizeMedium, weight: .thin)
    static let fontThinTitle = UIFont.systemFont(ofSize: HomeLayout.fontSizeTitle, weight: .thin)
    static let fontThinBigTitle = UIFont.systemFont(ofSize: HomeLayout.fontSizeBigTitle, weight: .thin)
    // .regular
    static let fontRegularLittle = UIFont.systemFont(ofSize: HomeLayout.fontSizeLittle, weight: .regular)
    static let fontRegularNormal = UIFont.systemFont(ofSize: HomeLayout.fontSizeNormal, weight: .regular)
    static let fontRegularMedium = UIFont.systemFont(ofSize: HomeLayout.fontSizeMedium, weight: .regular)
    static let fontRegularTitle = UIFont.systemFont(ofSize: HomeLayout.fontSizeTitle, weight: .regular)
    static let fontRegularBigTitle = UIFont.systemFont(ofSize: HomeLayout.fontSizeBigTitle, weight: .regular)
    // .semibold
    static let fontSemiBoldLittle = UIFont.systemFont(ofSize: HomeLayout.fontSizeLittle, weight: .semibold)
    static let fontSemiBoldNormal = UIFont.systemFont(ofSize: HomeLayout.fontSizeNormal, weight: .semibold)
    static let fontSemiBoldMedium = UIFont.systemFont(ofSize: HomeLayout.fontSizeMedium, weight: .semibold)
    static let fontSemiBoldTitle = UIFont.systemFont(ofSize: HomeLayout.fontSizeTitle, weight: .semibold)
    static let fontSemiBoldBigTitle = UIFont.systemFont(ofSize: HomeLayout.fontSizeBigTitle, weight: .semibold)
    static let fontMonospacedSemiBoldBigTitle = UIFont.monospacedDigitSystemFont(ofSize: HomeLayout.fontSizeBigTitle, weight: .semibold)
    // .bold
    static let fontBoldLittle = UIFont.systemFont(ofSize: HomeLayout.fontSizeLittle, weight: .bold)
    static let fontBoldNormal = UIFont.systemFont(ofSize: HomeLayout.fontSizeNormal, weight: .bold)
    static let fontBoldMedium = UIFont.systemFont(ofSize: HomeLayout.fontSizeMedium, weight: .bold)
    static let fontBoldTitle = UIFont.systemFont(ofSize: HomeLayout.fontSizeTitle, weight: .bold)
    static let fontBoldBigTitle = UIFont.systemFont(ofSize: HomeLayout.fontSizeBigTitle, weight: .bold)
    // .black
    static let fontBlackLittle = UIFont.systemFont(ofSize: HomeLayout.fontSizeLittle, weight: .black)
    static let fontBlackNormal = UIFont.systemFont(ofSize: HomeLayout.fontSizeNormal, weight: .black)
    static let fontBlackMedium = UIFont.systemFont(ofSize: HomeLayout.fontSizeMedium, weight: .black)
    static let fontMonospacedBlackMedium = UIFont.monospacedDigitSystemFont(ofSize: HomeLayout.fontSizeMedium, weight: .black)
    static let fontBlackTitle = UIFont.systemFont(ofSize: HomeLayout.fontSizeTitle, weight: .black)
    static let fontBlackBigTitle = UIFont.systemFont(ofSize: HomeLayout.fontSizeBigTitle, weight: .black)
}

extension HomeLayout {
    
    static let dynamicAlertHeaderHeigth: CGFloat = 50.0
    static let antenneViewSize: CGFloat = 170.0
    static let dynamicAlertCodeRatio: CGFloat = 1.3
    static let dynamicAlertActionsHeigth: CGFloat = 40.0
    static let dynamicActionsSheetButtonHeigth: CGFloat = 60.0
    
    static let actionButtonSize: CGFloat = 35.0
    static let actionButtonIconSize: CGFloat = 30.0
    static let actionButtonIconRadius = HomeLayout.actionButtonIconSize / 2.0
    static let smallActionButtonSize: CGFloat = 25.0
    static let smallActionButtonIconSize: CGFloat = 15.0
    static let smallActionButtonIconRadius = HomeLayout.smallActionButtonIconSize / 2.0
    static let leftCurvedTitleViewHeigth: CGFloat = 30.0
    static let eventPeopleCurvedTitleViewHeigth: CGFloat = 24.0
    static let coalitionHorizontalFlagHeigth: CGFloat = 65.0
    static let coalitionHorizontalFlagTriangle: CGFloat = 35.0
    static let coalitionHorizontalFlagWidth: CGFloat = HomeLayout.coalitionHorizontalFlagHeigth + 100
    
    static let loginFormElementHeigth: CGFloat = 40.0
    static let mainSelectionSize: CGFloat = 50.0
    static let mainSelectionRadius: CGFloat = HomeLayout.mainSelectionSize / 2.0
    static let mainSelectionIconSize: CGFloat = 40.0
    static let mainSelectionLabelSize: CGFloat = 30.0
    static let mainSelectionLabelRadius: CGFloat = HomeLayout.mainSelectionLabelSize / 2.0
    
    static let profilCellInsets: UIEdgeInsets = .init(top: HomeLayout.smargin, left: HomeLayout.smargin, bottom: HomeLayout.smargin, right: HomeLayout.smargin) // rm
    static let profilCellExpertiseHeigth: CGFloat = 40.0
    static let profilProjectViewCellHeigth: CGFloat = 40.0
    static let profilProjectViewCellExtraMinWidth: CGFloat = 40.0
    static let profilAchievementImageSize: CGFloat = 60.0
    static let profilBackgroundHeigth: CGFloat = { 153.0 + HomeLayout.safeAera.top }()
    
    static let settingsMoreViewHeigth: CGFloat = 80.0

    static let headerWithActionViewHeigth: CGFloat = 52.0
    static let headerWithActionControllerViewHeigth: CGFloat = 64.0
    static let roundedGenericActionsViewHeigth: CGFloat = HomeLayout.actionButtonSize + 5.0
    static let roundedGenericActionsViewRadius: CGFloat = HomeLayout.roundedGenericActionsViewHeigth / 2.0
    
    static let userProfilIconCreditsHeigth: CGFloat = 70.0
    static let userProfilIconCreditsRadius: CGFloat = HomeLayout.userProfilIconCreditsHeigth / 2.0
    static let userProfilIconMainHeigth: CGFloat = 45.0
    static let userProfilIconMainRadius: CGFloat = HomeLayout.userProfilIconMainHeigth / 2.0
    static let userProfilIconProfilHeigth: CGFloat = { UIScreen.main.bounds.width / 4.0 }()
    static let userProfilIconProfilRadius: CGFloat = HomeLayout.userProfilIconProfilHeigth / 2.0
    static let userProfilIconHeigth: CGFloat = 35.0
    static let userProfilIconRadius: CGFloat = HomeLayout.userProfilIconHeigth / 2.0
    static let userProfilIconHistoricHeigth: CGFloat = 54.0
    static let userProfilIconHistoricRadius: CGFloat = HomeLayout.userProfilIconHistoricHeigth / 2.0
    static let userInfoViewHeigth: CGFloat = 60.0
    
    static let clusterSegmentHeigth: CGFloat = 30.0
    static let segmentHeigth: CGFloat = 24.0
    static let buttonHeigth: CGFloat = 35.0
    
    static let terminalHeaderHeight: CGFloat = 43.0
    static let userProfilCorrectionViewCellHeight: CGFloat = 105.0
    static let userProfilCorrectionViewEmptyHeight: CGFloat = 36.0
    static let coalitionHeaderIconSize: CGFloat = 40.0
    static let tagViewHeigth: CGFloat = 26.0
    
    static let eventViewHeigth: CGFloat = 80.0
    static let level21BarHeigth: CGFloat = HomeLayout.userProfilIconProfilHeigth / 4.0
    static let level21BarSemiHeigth: CGFloat = HomeLayout.level21BarHeigth / 2.0
    
    static let imageViewHeightRatio: CGFloat = 0.5625
    static let elearningSubnotionActionHeight: CGFloat = 30.0
    
    static let switchHeigth: CGFloat = HomeLayout.actionButtonIconSize
    static let switchRadius: CGFloat = HomeLayout.switchHeigth / 2.0
    
    static let guidesVersionHeight: CGFloat = 16.0
    static let guidesVersionWidth: CGFloat = 64.0
}
