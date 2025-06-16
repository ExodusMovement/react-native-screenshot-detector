//
//  RNSecureViewManager.m
//  RNScreenshotDetector
//
//  React Native ViewManager for SecureView
//

#import "RNSecureViewManager.h"
#import "RNSecureView.h"
#import <React/RCTUIManager.h>

@implementation RNSecureViewManager

RCT_EXPORT_MODULE(RNSecureView)

- (UIView *)view {
    return [[RNSecureView alloc] init];
}

RCT_EXPORT_VIEW_PROPERTY(enabled, BOOL)

RCT_CUSTOM_VIEW_PROPERTY(enabled, BOOL, RNSecureView) {
    BOOL isEnabled = json ? [RCTConvert BOOL:json] : defaultView.isSecureEnabled;
    
    if (isEnabled) {
        [view enableSecureProtection];
    } else {
        [view disableSecureProtection];
    }
}

RCT_EXPORT_METHOD(enableProtection:(nonnull NSNumber *)reactTag) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
        RNSecureView *view = (RNSecureView *)viewRegistry[reactTag];
        if ([view isKindOfClass:[RNSecureView class]]) {
            [view enableSecureProtection];
        }
    }];
}

RCT_EXPORT_METHOD(disableProtection:(nonnull NSNumber *)reactTag) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
        RNSecureView *view = (RNSecureView *)viewRegistry[reactTag];
        if ([view isKindOfClass:[RNSecureView class]]) {
            [view disableSecureProtection];
        }
    }];
}

@end 