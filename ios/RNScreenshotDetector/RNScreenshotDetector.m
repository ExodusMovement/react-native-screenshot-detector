//
//  RNScreenshotDetector.m
//
//  Created by Graham Carling on 1/11/17.
//

#import "RNScreenshotDetector.h"
#import <React/RCTBridge.h>
#import <UIKit/UIKit.h>

@implementation RNScreenshotDetector
{
    id screenshotObserver;
    id screenRecordingObserver;
    UIView *securityOverlay;
    BOOL isProtectionEnabled;
}

RCT_EXPORT_MODULE();

- (NSArray<NSString *> *)supportedEvents {
    return @[@"ScreenshotTaken", @"ScreenRecordingChanged"];
}

- (void)startObserving {
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    screenshotObserver = [[NSNotificationCenter defaultCenter] 
        addObserverForName:UIApplicationUserDidTakeScreenshotNotification
        object:nil
        queue:mainQueue
        usingBlock:^(NSNotification *notification) {
            [self screenshotDetected:notification];
        }];
    
    screenRecordingObserver = [[NSNotificationCenter defaultCenter]
        addObserverForName:UIScreenCapturedDidChangeNotification
        object:nil
        queue:mainQueue
        usingBlock:^(NSNotification *notification) {
            [self screenRecordingChanged:notification];
        }];
}

- (void)stopObserving {
    if (screenshotObserver != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:screenshotObserver];
        screenshotObserver = nil;
    }
    
    if (screenRecordingObserver != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:screenRecordingObserver];
        screenRecordingObserver = nil;
    }
}

- (void)screenshotDetected:(NSNotification *)notification {
    if (screenshotObserver != nil) {
        [self sendEventWithName:@"ScreenshotTaken" body:@{}];
    }
}

- (void)screenRecordingChanged:(NSNotification *)notification {
    if (screenRecordingObserver != nil) {
        BOOL isRecording = [UIScreen mainScreen].isCaptured;
        
        [self sendEventWithName:@"ScreenRecordingChanged" body:@{@"isRecording": @(isRecording)}];
    }
}

RCT_EXPORT_METHOD(disableScreenshots) {
    dispatch_async(dispatch_get_main_queue(), ^{
        isProtectionEnabled = YES;
        [self enableTrueScreenshotPrevention];
    });
}

RCT_EXPORT_METHOD(enableScreenshots) {
    dispatch_async(dispatch_get_main_queue(), ^{
        isProtectionEnabled = NO;
        [self disableTrueScreenshotPrevention];
    });
}

RCT_EXPORT_METHOD(isScreenRecording:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    BOOL isRecording = [UIScreen mainScreen].isCaptured;
    resolve(@(isRecording));
}

RCT_EXPORT_METHOD(subscribeToScreenRecording) {
    [self startObserving];
}

RCT_EXPORT_METHOD(unsubscribeFromScreenRecording) {
    [self stopObserving];
}

// Screenshot Prevention using Secure Text Field
- (void)enableTrueScreenshotPrevention {
    if (self.secureTextField == nil) {
        self.secureTextField = [[UITextField alloc] init];
        self.secureTextField.userInteractionEnabled = NO;
        self.secureTextField.secureTextEntry = YES;
        
        UIWindow *keyWindow = [self getKeyWindow];
        if (keyWindow != nil) {
            [keyWindow makeKeyAndVisible];
            
            // Make the app window a sublayer of the secure text field
            [keyWindow.layer.superlayer addSublayer:self.secureTextField.layer];
            
            // Add the window layer as a sublayer of the secure text field's first sublayer
            NSArray *sublayers = self.secureTextField.layer.sublayers;
            if (sublayers.count > 0) {
                [sublayers.firstObject addSublayer:keyWindow.layer];
            }
        }
    } else {
        self.secureTextField.secureTextEntry = YES;
    }
}

- (void)disableTrueScreenshotPrevention {
    if (self.secureTextField != nil) {
        self.secureTextField.secureTextEntry = NO;
    }
}

- (UIWindow *)getKeyWindow {
    UIWindow *keyWindow = nil;
    
    NSSet<UIScene *> *connectedScenes = [UIApplication sharedApplication].connectedScenes;
    for (UIScene *scene in connectedScenes) {
        if ([scene isKindOfClass:[UIWindowScene class]]) {
            UIWindowScene *windowScene = (UIWindowScene *)scene;
            for (UIWindow *window in windowScene.windows) {
                if (window.isKeyWindow) {
                    keyWindow = window;
                    break;
                }
            }
            if (keyWindow) break;
        }
    }
    
    if (keyWindow == nil) {
        keyWindow = [UIApplication sharedApplication].keyWindow;
        if (keyWindow == nil) {
            for (UIWindow *window in [UIApplication sharedApplication].windows) {
                if (window.isKeyWindow) {
                    keyWindow = window;
                    break;
                }
            }
        }
    }
    
    return keyWindow;
}

- (void)dealloc {
    [self stopObserving];
    [self disableTrueScreenshotPrevention];
}

@end 