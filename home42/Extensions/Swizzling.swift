// home42/Swizzling.swift
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
    
    static func introspect() -> [String: Any] {
        var count: UInt32 = 0
        var result: [String: Any] = [:]
        
        let ivars: UnsafeMutablePointer<Ivar>?
        var ivarsResult: [String] = []
        let properties: UnsafeMutablePointer<objc_property_t>?
        var propertiesResult: [String] = []
        let methods: UnsafeMutablePointer<Method>?
        var methodsResult: [String] = []
        
        ivars = class_copyIvarList(Self.self, &count)
        if ivars != nil {
            ivarsResult.reserveCapacity(Int(count))
            for index in 0 ..< Int(count) {
                ivarsResult.append(String(cString: ivar_getName(ivars!.advanced(by: index).pointee)!))
            }
            result["ivars"] = ivarsResult
            free(ivars!)
        }
        properties = class_copyPropertyList(Self.self, &count)
        if properties != nil {
            propertiesResult.reserveCapacity(Int(count))
            for index in 0 ..< Int(count) {
                propertiesResult.append(String(cString: property_getName(properties!.advanced(by: index).pointee)))
            }
            result["properties"] = propertiesResult
            free(properties!)
        }
        methods = class_copyMethodList(Self.self, &count)
        if methods != nil {
            methodsResult.reserveCapacity(Int(count))
            for index in 0 ..< Int(count) {
                methodsResult.append(String(cString: sel_getName(method_getName(methods!.advanced(by: index).pointee))))
            }
            result["methods"] = methodsResult
            free(methods!)
        }
        return result
    }
}
