#import "WKWebViewKeyboardHelperObjC.h"
#import <WebKit/WebKit.h>
#import <objc/runtime.h>
#import <objc/message.h>

@implementation WKWebViewKeyboardHelperObjC

+ (void)enableKeyboardDisplayWithoutUserAction {
    Class WKContentViewClass = NSClassFromString(@"WKContentView");
    if (!WKContentViewClass) {
        NSLog(@"[WKWebViewKeyboardHelper] Không tìm thấy WKContentView");
        return;
    }
    
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
    
    IMP originalImp = method_getImplementation(method);
    SEL capturedSel = targetSel;
    
    // FIX: Dùng void* cho TẤT CẢ tham số có thể không phải ObjC object
    // __unsafe_unretained cho id để ARC KHÔNG retain/release
    // void* cho activityStateChanges và userObject vì trên iOS 17/18
    // Apple đã thay đổi kiểu nội bộ — không còn là ObjC object
    id newBlock = ^void (__unsafe_unretained id _self,
                         void *arg0,
                         BOOL userIsInteracting,
                         BOOL arg2,
                         void *arg3,
                         void *arg4) {
        // Cast IMP thành function pointer thuần C — không qua ARC
        typedef void (*OrigFn)(__unsafe_unretained id, SEL, void *, BOOL, BOOL, void *, void *);
        ((OrigFn)originalImp)(_self, capturedSel, arg0, YES, arg2, arg3, arg4);
    };
    
    method_setImplementation(method, imp_implementationWithBlock(newBlock));
    NSLog(@"[WKWebViewKeyboardHelper] Patched: %@", NSStringFromSelector(targetSel));
}

@end
