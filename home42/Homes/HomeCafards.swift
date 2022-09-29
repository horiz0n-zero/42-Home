// home42/HomeCafards.swift
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
import MessageUI

final class HomeCafards: NSObject, MFMailComposeViewControllerDelegate {
    
    static private var bugReport: HomeCafards? = nil
    
    static func generateReport(apiJSONText: String? = nil, apiJSONError: HomeApi.RequestError? = nil, completion: (() -> ())? = nil) {
        guard HomeCafards.bugReport == nil else {
            return
        }
        
        DynamicAlert(.noneWithPrimary(HomeDesign.redError),
                     contents: [.imageWithPrimary(.settingsCafard, 50.0, HomeDesign.redError),
                                .title(~"cafards.generate-title"),
                                .separator(HomeDesign.redError),
                                .text(~"cafards.generate")],
                     actions: [.normal(~"general.cancel", nil), .highligth(~"general.generate", {
            self.bugReport = HomeCafards(apiJSONText: apiJSONText, apiJSONError: apiJSONError)
            completion?()
        })])
    }
    
    private let picture: UIImage
    private var hierarchy: String
    private let defaultsDump: String
    private let header: String
    private var appDump: String
    private let apiJSONText: String?
    private let apiJSONError: HomeApi.RequestError?
    
    init(apiJSONText: String?, apiJSONError: HomeApi.RequestError?) {
        var root: UIViewController = App.mainController
        var systemInfo = utsname()
        let modelCode: String?
        
        func readViewControllerHierarchy(viewController: UIViewController) -> String {
            var result: String = String(describing: type(of: viewController)) + "\n"
            var indentation: Int = 1
            
            func readViews(_ view: UIView) {
                result += String(repeating: "  > ", count: indentation) + String(describing: type(of: view)) + "\n"
                if view.subviews.count > 0 {
                    indentation += 1
                    for subview in view.subviews {
                        readViews(subview)
                    }
                    indentation -= 1
                }
            }
            
            for subview in viewController.view.subviews {
                readViews(subview)
            }
            return result
        }
        
        self.picture = App.mainController.topPresentedViewController().view.renderImage()
        self.hierarchy = readViewControllerHierarchy(viewController: root)
        
        while root.presentedViewController != nil {
            self.hierarchy += String(describing: type(of: root)) + ".presentedViewController:\n"
            root = root.presentedViewController!
            self.hierarchy += readViewControllerHierarchy(viewController: root)
        }
        
        uname(&systemInfo)
        modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in String.init(validatingUTF8: ptr)
            }
        }
        self.defaultsDump = HomeDefaults.jsonRepresentation()
        self.header = """
generated_at: \(Date().toString(.comprehensive))
login: \(App.user.login)
id: \(App.user.id)
displayname: \(App.user.displayname)
primary_campus: \(App.user.campus(forUserCampusId: App.userCampus.campus_id).name)
primary_campus_id: \(App.userCampus.campus_id)
primary_cursus: \(App.userCursus == nil ? "nil" : App.userCursus.cursus.name)
primary_cursus_id: \(App.userCursus == nil ? "nil" : "\(App.userCursus.cursus.id)")
device_name: \(UIDevice.current.name)
device_system_name: \(UIDevice.current.systemName)
device_system_version: \(UIDevice.current.systemVersion)
device_model: \(modelCode ?? UIDevice.current.model)
device_uuid: \(UIDevice.current.identifierForVendor?.uuidString ?? "none")
"""
        self.appDump = "none"
        dump(App, to: &self.appDump)
        self.apiJSONText = apiJSONText
        self.apiJSONError = apiJSONError
        super.init()
        if MFMailComposeViewController.canSendMail() {
            self.sendEmail()
        }
        else {
            DynamicAlert(.fullPrimary(~"general.warning", HomeDesign.redError), contents: [.text(~"cafards.email-unavailable")], actions: [.normal(~"general.ok", nil)])
        }
    }
    
    private func sendEmail() {
        let email = MFMailComposeViewController()
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?.?.?"
        
        email.mailComposeDelegate = self
        email.setToRecipients(["afeuerst@student.42.fr"])
        #if DEBUG
        email.setSubject("42Home \(version) Beta Bug Report - \(App.user.login) - \(Date().toString(.comprehensive))")
        #else
        email.setSubject("42Home \(version) Bug Report - \(App.user.login) - \(Date().toString(.comprehensive))")
        #endif
        email.setMessageBody(self.header, isHTML: false)
        email.addAttachmentData(self.picture.pngData()!, mimeType: "image/png", fileName: "capture.png")
        email.addAttachmentData(self.hierarchy.data(using: .utf8)!, mimeType: "plain/text", fileName: "hierarchy.txt")
        email.addAttachmentData(self.defaultsDump.data(using: .utf8)!, mimeType: "plain/text", fileName: "defaults.txt")
        email.addAttachmentData(self.appDump.data(using: .utf8)!, mimeType: "plain/text", fileName: "app.txt")
        if let jsonText = self.apiJSONText, let error = self.apiJSONError {
            email.addAttachmentData(jsonText.data(using: .utf8)!, mimeType: "plain/text", fileName: "apiResult.json")
            email.addAttachmentData(error.description.data(using: .utf8)!, mimeType: "plain/text", fileName: "apiReason.json")
        }
        App.mainController.topPresentedViewController().present(email, animated: true, completion: nil)
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        HomeCafards.bugReport = nil
    }
}
