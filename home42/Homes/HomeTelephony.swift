//
//  HomeTelephony.swift
//  home42
//
//  Created by Antoine Feuerstein on 18/04/2021.
//

import Foundation
import UIKit

final class HomeTelephony: NSObject {
    
    static func call(_ number: String) {
        let telPrompt = URL(string: "telprompt://\(number)")!
        
        if UIApplication.shared.canOpenURL(telPrompt) {
            UIApplication.shared.open(telPrompt, options: [:], completionHandler: nil)
        }
        else {
            UIApplication.shared.open(URL(string: "tel://\(number)")!, options: [:], completionHandler: nil)
        }
    }
    
    static func message(_ number: String) {
        UIApplication.shared.open(URL(string: "sms://\(number)")!, options: [:], completionHandler: nil)
    }
    
    static func phoneNumber(_ login: String) -> String? {
        return nil
    }
}
