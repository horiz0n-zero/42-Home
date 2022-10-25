// home42/HiddenController.swift
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
import SwiftyRSA

class HiddenViewController: HomeViewController {
    
    dynamic class func checkDefaultsValue() -> Bool {
        return false
    }
    dynamic class func qrCodeWith(user: IntraUser) throws -> HomeQRCode {
        fatalError()
    }
    dynamic class var id: String {
        return "hidden"
    }
    
    static let privateKey: PrivateKey = {
        return try! PrivateKey(pemEncoded: """
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAx4NlZT3C7709gXZaQuwqiWx64euMhWSLZxYAygtr/zSoJH2V
VzDmO8S8e++WrC78lZoLnwWQKQQknncdWEq0iwEgOH7lbD8eU61br4udk1KXsOZg
Bza5B1lN3h6xrrZwg1qMbHvgKHGnewiKsAUoAIFlxPXFMWtjwbBHrRCn7QcpZFAv
eRWyePvTq8StCyKvLqwP/iTWOcZ5fSiwEzggG9rmD9E6j3kLVrqwMGrBC9UfXM7t
8Dnphrq6LT5XJpPJ0TZbEop7T0mf2sd7coedywx0FcYkYmcA5kTqFvovwmsAlbuT
/eHeCQOKXNnmrILsWRcB6do0OEhhEauGYHuzcQIDAQABAoIBAEYakWJFlV2P7TC0
WXryaO/owjToA3RLpAAQ5y4XXVdLNVm9FuCQOhX+Rwx1X0gZKn+WpUa3ObRv1D4q
NJF1joLZXmz7ibnDY/CbFYBVWoUNnGd4S329aL6ATrAhsOVnDZnaE0V7MYSEiwjc
M38uEKQ803mlsihvR5ojSsww8hCCt7FlUO2E9SGY6w4BzfybPR7N37KEyRhKcqCF
/Nk5wnQExPXsdXWnTrqf2zZMqde4pvtxyDQ/YCcHm/88jxsNsIBuMFVhp2+VtH31
I9A+2WH5U65wahEl2daUuxqFM718MSn+b4Vj4bv2rlylV+wmsW+o8NStNAAjhr1T
/05Q9pECgYEA/2jGv/hG2Y+TTBavJfRM95z66sy41M+rEWwxf059WFzK8Y6Z8EHL
kdxp6avirX9ca2t8UL63mhDPFJLSr+zkTp8I0wcSQCDKMdWDtis8FH2pFLISXoZM
vm2UhoVBMN9I9EaZgIocU7Hl6Is4h2wspJRmX6/3I3V9JW5KX3fq1TMCgYEAx/mG
TAfskRFzarwd+gLa8e6vVrnBE4uYo6oPiyKpIVQrvIjZP4TPFnivmrzUNAzdv2oL
M/Xh9Kzt+FNmSoPCeU4HdWrrZKf4eEB6OUdxflqnY7/4sSo7qoVVbxg71rP/gwNo
wzwPdI2KG3H723opCgVoi9dHmWUbG/e/o3sgzMsCgYEAra19AUt+OjE0s5f1UDTZ
JcPcqE/AHA5/QGC3I9+mwrCO3EXhDgxftncQmnJkuSATI4S6y1l1FlH5zv6sQC8x
bPkeEgoL8gmaFNshLn4l47Uzhbw1W4utogx35CW3F9muDVX4yfygmJUvRrttHEGF
9gBnwQeyYa1iBVMDRfoQeRsCgYAnNmu6LveZfrWGIXszUioCtM4XEHem0IHO3gMM
QnCtw2aMIr2O8gj1nBa7Hfnydu9ooG+v8bAsHVjQj/IH/Iw+4ykdQikEZNeZJPOS
lcrQfxBBxBwNCX4HsvuMvFDHiiY5V4rMddOGBFcniJNddzfi6iqU+VLl5miJdGxU
r0lAPwKBgQDb98LJS1qrY7eqZZ4R2akEhIakPs4PdMPOCmYUdkc+nkiQahHTzyrr
7/4aeWkJMl5Y784aZYhJ5LGQ8PekSMVeUAbSzWUHfxQDbDAR9I07AWlgRVQjUJIo
WBCsgoa9iT2l+n/nLInIAa/njMXR8l0D6OwnV30SN6NbN0b8oR7ESA==
-----END RSA PRIVATE KEY-----
""")
    }()
    
    static func presentActionSheetForQRCodes(_ link: String, parentViewController: UIViewController) {
        var checkedLink: String = link
        
        guard App.userLoggedIn && App.user.id == 20091 && App.user.login == "afeuerst" else {
            return
        }
        if link.hasPrefix("https://") == false && link.hasPrefix("http://") == false {
            checkedLink = "https://" + link
        }
        
        func openWeb() {
            parentViewController.present(SafariWebView(checkedLink.url), animated: true, completion: nil)
        }
        func openSafari() {
            App.open(checkedLink.url, options: [:], completionHandler: nil)
        }
        func copy() {
            UIPasteboard.general.string = checkedLink
        }
        
        func generate(forHiddenControllerType type: HiddenViewController.Type, title: String, icon: UIImage.Assets) {
            
            func userSelected(_ userInfo: IntraUserInfo) {
                Task.init(priority: .userInitiated, operation: {
                    do {
                        async let user: IntraUser = HomeApi.get(.userWithId(userInfo.id))
                        async let coalitions: ContiguousArray<IntraCoalition> = HomeApi.get(.usersWithUserIdCoalitions(userInfo.id))
                        let coalition: IntraCoalition?
                        let cursus = try await user.primaryCursus
                        let campus = try await user.primaryCampus
                        let coupon: HomeQRCode.Coupon
                        
                        if cursus != nil {
                            coalition = try await coalitions.primaryCoalition(campus: campus, cursus: cursus!)
                        }
                        else {
                            coalition = nil
                        }
                        coupon = .init(login: userInfo.login, coalition: coalition,
                                       controllerTitle: title, controllerIcon: icon)
                        try await type.qrCodeWith(user: user).presentWithCoupon(coupon)
                    }
                    catch {
                        if error is HomeApi.RequestError {
                            DynamicAlert.presentWith(error: error as! HomeApi.RequestError)
                        }
                        else {
                            DynamicAlert.init(contents: [.title(~"seecache.error"), .text(String(reflecting: error))], actions: [.normal(~"general.ok", nil)])
                        }
                    }
                })
            }
            
            func setPublicKey() {
                DynamicAlert(.withPrimary("publicKey", HomeDesign.gold),
                             contents: [.textEditor("")], actions: [.textEditor({ text in
                    do {
                        var key = text.replacingOccurrences(of: "-----BEGIN RSA PUBLIC KEY----- ", with: "")
                        
                        key = key.replacingOccurrences(of: "-----END RSA PUBLIC KEY-----", with: "")
                        key = key.replacingOccurrences(of: " ", with: "\n")
                        _ = try PublicKey(pemEncoded: key)
                        HomeDefaults.save(key, forKey: .publicKey)
                    }
                    catch {
                        #if DEBUG
                        print("setPrivateKey", error)
                        #endif
                        DynamicAlert(contents: [.text(error.localizedDescription)], actions: [.normal(~"general.ok", nil)])
                    }
                })])
            }
            
            if let _: String = HomeDefaults.read(.publicKey) {
                DynamicAlert(.withPrimary(~"general.qrcodes", HomeDesign.gold),
                             contents: [.usersSelector(nil, userSelected(_:))],
                             actions: [.normal(~"general.cancel", nil)])
            }
            else {
                setPublicKey()
            }
        }
        
        func generateTracker() {
            generate(forHiddenControllerType: TrackerViewController.self,
                     title: ~"title.tracker", icon: .controllerTracker)
        }
        func generateCorrections() {
            generate(forHiddenControllerType: CorrectionsViewController.self,
                     title: ~"title.corrections", icon: .controllerCorrections)
        }
        
        DynamicActionsSheet(actions: [.title(~"general.qrcodes"),
                                      .normalWithPrimary(~"title.tracker", .controllerTracker, HomeDesign.gold, generateTracker),
                                      .normalWithPrimary(~"title.corrections", .controllerCorrections, HomeDesign.gold, generateCorrections),
                                      .separatorWithPrimary(HomeDesign.black),
                                      .title(~"github.title"), .text(~"github.text"),
                                      .normal(~"openweb-link", .settingsWeb, openWeb),
                                      .normal(~"openweb-link-safari", .settingsWeb, openSafari),
                                      .normal(~"general.copy", .settingsCode, copy)])
    }
}
