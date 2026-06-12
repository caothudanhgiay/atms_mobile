//
//  WKWebViewKeyboardHelper.swift
//  Runner
//
//  Cho phép WKWebView hiện keyboard khi gọi element.focus() programmatically,
//  không cần user gesture. Giải quyết vấn đề iOS chặn keyboard khi focus
//  được gọi từ JavaScript channel (Flutter → JS → focus).
//

import Foundation
import WebKit

class WKWebViewKeyboardHelper: NSObject {
    
    /// Gọi hàm này một lần trong AppDelegate.didFinishLaunchingWithOptions
    /// để patch WKWebView cho phép keyboard hiện không cần user gesture.
    @objc static func enableKeyboardDisplayWithoutUserAction() {
        // WKContentView là private class bên trong WKWebView
        guard let WKContentViewClass: AnyClass = NSClassFromString("WKContentView") else {
            print("[WKWebViewKeyboardHelper] Không tìm thấy WKContentView")
            return
        }
        
        // Tìm selector _elementDidFocus: (signature thay đổi theo iOS version)
        // iOS 16.4+
        let sel_16_4 = NSSelectorFromString("_elementDidFocus:userIsInteracting:blurPreviousNode:activityStateChanges:userObject:")
        // iOS 13 - 16.3
        let sel_13 = NSSelectorFromString("_elementDidFocus:userIsInteracting:blurPreviousNode:changingActivityState:userObject:")
        // iOS 12
        let sel_12 = NSSelectorFromString("_startAssistingNode:userIsInteracting:blurPreviousNode:changingActivityState:userObject:")
        
        if let method = class_getInstanceMethod(WKContentViewClass, sel_16_4) {
            swizzle(cls: WKContentViewClass, original: sel_16_4, originalMethod: method)
        } else if let method = class_getInstanceMethod(WKContentViewClass, sel_13) {
            swizzle(cls: WKContentViewClass, original: sel_13, originalMethod: method)
        } else if let method = class_getInstanceMethod(WKContentViewClass, sel_12) {
            swizzle(cls: WKContentViewClass, original: sel_12, originalMethod: method)
        } else {
            print("[WKWebViewKeyboardHelper] Không tìm thấy method _elementDidFocus phù hợp")
        }
    }
    
    private static func swizzle(cls: AnyClass, original: Selector, originalMethod: Method) {
        let originalImp = method_getImplementation(originalMethod)
        let originalEncoding = method_getTypeEncoding(originalMethod)
        
        // Tạo hàm thay thế: thay đổi tham số userIsInteracting thành true
        // Signature: void (id, SEL, id, BOOL, BOOL, BOOL/int, id)
        //                                  ^ userIsInteracting
        let newImp: IMP = imp_implementationWithBlock(
            { (self: AnyObject, arg0: AnyObject, userIsInteracting: Bool, arg2: Bool, arg3: UInt32, arg4: AnyObject?) -> Void in
                // Gọi lại hàm gốc nhưng luôn truyền userIsInteracting = true
                typealias FuncType = @convention(c) (AnyObject, Selector, AnyObject, Bool, Bool, UInt32, AnyObject?) -> Void
                let originalFunc = unsafeBitCast(originalImp, to: FuncType.self)
                originalFunc(self, original, arg0, true, arg2, arg3, arg4)
            } as @convention(block) (AnyObject, AnyObject, Bool, Bool, UInt32, AnyObject?) -> Void
        )
        
        method_setImplementation(originalMethod, newImp)
    }
}
