#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Cho phép WKWebView hiện keyboard khi gọi element.focus() programmatically,
/// không cần user gesture. Viết bằng Objective-C để tránh Swift ARC crash
/// (swift_unknownObjectRetain) trên iOS 17/18.
@interface WKWebViewKeyboardHelperObjC : NSObject

+ (void)enableKeyboardDisplayWithoutUserAction;

@end

NS_ASSUME_NONNULL_END
