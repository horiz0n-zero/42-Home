// home42/Attributes.swift
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
import Accessibility

@propertyWrapper struct LazyDefaultsLinkIntraObjects<G: IntraObject> {
    
    private let link: HomeDefaults.Key
    private var container: ContiguousArray<G>! = nil
    
    var wrappedValue: ContiguousArray<G>! {
        mutating get {
            if self.container == nil {
                self.container = HomeDefaults.read(self.link)
            }
            return self.container
        }
        set {
            HomeDefaults.save(newValue, forKey: self.link)
            self.container = newValue
        }
    }
    
    init(_ link: HomeDefaults.Key) {
        self.link = link
    }
}

@propertyWrapper struct LazyLocalJSONDictionaryMapped<K: Hashable, G: IntraObject> {
    
    private let url: URL // lazy task.get() ?
    private var container: [K: G]! = nil
    private let keypath: KeyPath<G, K>
    
    var wrappedValue: [K: G]! {
        mutating get {
            if self.container == nil {
                let file = try! Data(contentsOf: self.url)
                let elements = try! JSONDecoder.decoder.decode([G].self, from: file)
                
                self.container = [:]
                self.container.reserveCapacity(elements.count)
                for element in elements {
                    self.container[element[keyPath: self.keypath]] = element
                }
            }
            return self.container
        }
        set {
            
        }
    }
    
    init(_ location: String, _ keypath: KeyPath<G, K>) {
        self.url = HomeResources.applicationDirectory.appendingPathComponent(location)
        self.keypath = keypath
    }
}
