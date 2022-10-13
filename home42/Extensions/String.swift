// home42/String.swift
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

extension String {
    
    var request: URLRequest {
        return URLRequest(url: URL(string: self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)!,
                          cachePolicy: .useProtocolCachePolicy, timeoutInterval: HomeApi.timeOut)
    }
    var url: URL {
        return URL(string: self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)!
    }
    
    func urlRequest(withParameters parameters: [String: String], isPost: Bool = false) -> URLRequest {
        if isPost {
            // let data = parameters.map({ "\($0.key)=\($0.value)" }).joined(separator: "&")
            var request = URLRequest(url: self.url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: HomeApi.timeOut)
            let body = try! JSONSerialization.data(withJSONObject: parameters, options: .fragmentsAllowed)
            
            request.httpMethod = "POST"
            request.httpBody = body// data.data(using: .utf8)
            return request
        }
        else {
            var components = URLComponents(string: self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)!
            
            components.queryItems = parameters.map({ (key, value) in URLQueryItem(name: key, value: value) })
            return URLRequest(url: components.url!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: HomeApi.timeOut)
        }
    }
    
    var isEmail: Bool {
        let emailRegEx = "(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9]))\\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
    
        return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: self)
    }
    
    func extractMatchesWithRegexPattern(_ pattern: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let results = regex.matches(in: self, range: NSRange(self.startIndex..., in: self))
            
            return results.map { String(self[Range($0.range, in: self)!]) }
        } catch let error {
            #if DEBUG
            print(#function, error.localizedDescription)
            #endif
            return []
        }
    }
    
    func extractRangeMatchesWithRegexPattern(_ pattern: String) -> [NSRange] {
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let results = regex.matches(in: self, range: NSRange(self.startIndex..., in: self))
            
            return results.map(\.range)
        } catch let error {
            #if DEBUG
            print(#function, error.localizedDescription)
            #endif
            return []
        }
    }
    
    func fromBase64URL() -> String? {
        var base64 = self
        
        base64 = base64.replacingOccurrences(of: "-", with: "+")
        base64 = base64.replacingOccurrences(of: "_", with: "/")
        while base64.count % 4 != 0 {
            base64 = base64.appending("=")
        }
        guard let data = Data(base64Encoded: base64) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
        
    func toBase64URL() -> String {
        var result = Data(self.utf8).base64EncodedString()
        
        result = result.replacingOccurrences(of: "+", with: "-")
        result = result.replacingOccurrences(of: "/", with: "_")
        result = result.replacingOccurrences(of: "=", with: "")
        return result
    }
    func base64URLtoBase64() -> String {
        var base64 = self.replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/")
        
        if base64.count % 4 != 0 {
            base64.append(String(repeating: "=", count: 4 - base64.count % 4))
        }
        return base64
    }
}
