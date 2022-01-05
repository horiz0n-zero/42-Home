//
//  String.swift
//  home42
//
//  Created by Antoine Feuerstein on 11/04/2021.
//

import Foundation

extension String {
    
    var request: URLRequest {
        return URLRequest(url: URL(string: self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)!,
                          cachePolicy: .useProtocolCachePolicy, timeoutInterval: HomeApi.timeOut)
    }
    var url: URL {
        return URL(string: self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)!
    }
}
