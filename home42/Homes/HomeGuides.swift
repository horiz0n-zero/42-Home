//
//  HomeGuides.swift
//  home42
//
//  Created by Antoine Feuerstein on 09/07/2021.
//

import Foundation
import UIKit

final class HomeGuides: NSObject {
    
    @frozen enum HowToFile: String {
        case addCluster = "res/guides/add_cluster.pdf"
    }
    
    static func alertActionLink(_ howToFile: HomeGuides.HowToFile) -> DynamicAlert.Action {
        
        let block: () -> () = {
            let path = HomeResources.applicationDirectory.appendingPathComponent(howToFile.rawValue)
            let safari = SafariWebView(path)
            
            App.mainController.present(safari, animated: true, completion: nil)
        }
        
        return .highligth(~"GUIDE", block)
    }
    
}
