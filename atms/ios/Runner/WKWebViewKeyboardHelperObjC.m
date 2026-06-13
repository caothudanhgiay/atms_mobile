#import "WKWebViewKeyboardHelperObjC.h"
#import <WebKit/WebKit.h>
#import <objc/runtime.h>
#import <objc/message.h>

@implementation WKWebViewKeyboardHelperObjC

+ (void)enableKeyboardDisplayWithoutUserAction {
    // WKContentView là private class bên trong WKWebView
    Class WKContentViewClass = NSClassFromString(@"WKContentView");
    if (!WKContentViewClass) {
        NSLog(@"[WKWebViewKeyboardHelper] Không tìm thấy WKContentView");
        return;
    }
    
    // Danh sách các selector theo phiên bản iOS (mới nhất trước)
    // iOS 16.4+ (bao gồm iOS 17, 18)
    SEL sel_16_4 = NSSelectorFromString(@"_elementDidFocus:userIsInteracting:blurPreviousNode:activityStateChanges:userObject:");
    // iOS 13 - 16.3
    SEL sel_13 = NSSelectorFromString(@"_elementDidFocus:userIsInteracting:blurPreviousNode:changingActivityState:userObject:");
    // iOS 12
    SEL sel_12 = NSSelectorFromString(@"_startAssistingNode:userIsInteracting:blurPreviousNode:changingActivityState:userObject:");
    
    Method method = NULL;
    SEL targetSel = NULL;
    
    if ((method = class_getInstanceMethod(WKContentViewClass, sel_16_4))) {
        targetSel = sel_16_4;
    } else if ((method = class_getInstanceMethod(WKContentViewClass, sel_13))) {
        targetSel = sel_13;
    } else if ((method = class_getInstanceMethod(WKContentViewClass, sel_12))) {
        targetSel = sel_12;
    } else {
        NSLog(@"[WKWebViewKeyboardHelper] Không tìm thấy method _elementDidFocus phù hợp");
        return;
    }
    
    // Lấy IMP gốc
    IMP originalImp = method_getImplementation(method);
    
    // Tạo block thay thế — Objective-C dùng `id` (raw pointer)
    // KHÔNG bị ARC retain/release như Swift AnyObject → không crash swift_unknownObjectRetain
    //
    // Signature: void (id self, id focusedElementInfo, BOOL userIsInteracting,
    //                  BOOL blurPreviousNode, id activityStateChanges, id userObject)
    //
    // Lưu ý: imp_implementationWithBlock block KHÔNG có tham số _cmd (SEL),
    // nhưng khi gọi lại originalImp thì cần truyền _cmd.
    SEL capturedSel = targetSel;
    IMP capturedImp = originalImp;
    
    id newBlock = ^(id _self, id arg0, BOOL userIsInteracting, BOOL arg2, id arg3, id arg4) {
        // Gọi lại hàm gốc, luôn truyền userIsInteracting = YES
        // Dùng function pointer cast để gọi IMP trực tiếp
        ((void (*)(id, SEL, id, BOOL, BOOL, id, id))capturedImp)(_self, capturedSel, arg0, YES, arg2, arg3, arg4);
    };
    
    IMP newImp = imp_implementationWithBlock(newBlock);
    method_setImplementation(method, newImp);
    
    NSLog(@"[WKWebViewKeyboardHelper] Đã patch thành công cho selector: %@", NSStringFromSelector(targetSel));
}

@end
