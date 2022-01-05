//
//  Swizzling.swift
//  home42
//
//  Created by Antoine Feuerstein on 18/04/2021.
//

import Foundation

extension NSObject {

    @inlinable @inline(__always) func swizzle(method originalSelector: Selector, with swizzledSelector: Selector) {
        method_exchangeImplementations(class_getInstanceMethod(Self.self, originalSelector)!, class_getInstanceMethod(Self.self, swizzledSelector)!)
    }
    @inlinable @inline(__always) static func swizzle(method originalSelector: Selector, with swizzledSelector: Selector) {
        method_exchangeImplementations(class_getInstanceMethod(Self.self, originalSelector)!, class_getInstanceMethod(Self.self, swizzledSelector)!)
    }
    
    @inlinable @inline(__always) func swizzleImplementation(method originalSelector: Selector, with swizzledSelector: Selector) {
        method_setImplementation(class_getInstanceMethod(Self.self, originalSelector)!, class_getMethodImplementation(Self.self, swizzledSelector)!)
    }
    
    @inlinable @inline(__always) static func swizzleImplementation(method originalSelector: Selector, with swizzledSelector: Selector) {
        method_setImplementation(class_getInstanceMethod(Self.self, originalSelector)!, class_getMethodImplementation(Self.self, swizzledSelector)!)
    }
    
    @inlinable @inline(__always) func retainObject() {
        _ = Unmanaged.passRetained(self)
    }
    @inlinable @inline(__always) func releaseObject() {
        _ = Unmanaged.passUnretained(self).autorelease()
    }
}
