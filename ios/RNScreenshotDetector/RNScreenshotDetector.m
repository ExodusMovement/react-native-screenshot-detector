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
    BOOL isProtectionEnabled;
}

RCT_EXPORT_MODULE();

- (NSArray<NSString *> *)supportedEvents {
    NSLog(@"[RNScreenshotDetector] supportedEvents called");
    return @[@"ScreenshotTaken", @"ScreenRecordingChanged"];
}

- (void)startObserving {
    NSLog(@"[RNScreenshotDetector] startObserving called");
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    
    if (screenshotObserver == nil) {
        screenshotObserver = [[NSNotificationCenter defaultCenter] 
            addObserverForName:UIApplicationUserDidTakeScreenshotNotification
            object:nil
            queue:mainQueue
            usingBlock:^(NSNotification *notification) {
                [self screenshotDetected:notification];
            }];
        NSLog(@"[RNScreenshotDetector] Screenshot observer registered");
    } else {
        NSLog(@"[RNScreenshotDetector] Screenshot observer already exists");
    }
    
    if (screenRecordingObserver == nil) {
        screenRecordingObserver = [[NSNotificationCenter defaultCenter]
            addObserverForName:UIScreenCapturedDidChangeNotification
            object:nil
            queue:mainQueue
            usingBlock:^(NSNotification *notification) {
                [self screenRecordingChanged:notification];
            }];
        NSLog(@"[RNScreenshotDetector] Screen recording observer registered");
    } else {
        NSLog(@"[RNScreenshotDetector] Screen recording observer already exists");
    }
}

- (void)stopObserving {
    NSLog(@"[RNScreenshotDetector] stopObserving called");
    if (screenshotObserver != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:screenshotObserver];
        screenshotObserver = nil;
        NSLog(@"[RNScreenshotDetector] Screenshot observer removed");
    }
    
    if (screenRecordingObserver != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:screenRecordingObserver];
        screenRecordingObserver = nil;
        NSLog(@"[RNScreenshotDetector] Screen recording observer removed");
    }
}

- (void)screenshotDetected:(NSNotification *)notification {
    NSLog(@"[RNScreenshotDetector] Screenshot detected!");
    if (screenshotObserver != nil) {
        NSLog(@"[RNScreenshotDetector] Sending ScreenshotTaken event");
        [self sendEventWithName:@"ScreenshotTaken" body:@{}];
    } else {
        NSLog(@"[RNScreenshotDetector] Screenshot observer is nil, not sending event");
    }
}

- (void)screenRecordingChanged:(NSNotification *)notification {
    BOOL isRecording = [UIScreen mainScreen].isCaptured;
    NSLog(@"[RNScreenshotDetector] Screen recording changed: %@", isRecording ? @"YES" : @"NO");
    
    if (screenRecordingObserver != nil) {
        NSLog(@"[RNScreenshotDetector] Sending ScreenRecordingChanged event");
        [self sendEventWithName:@"ScreenRecordingChanged" body:@{@"isRecording": @(isRecording)}];
    } else {
        NSLog(@"[RNScreenshotDetector] Screen recording observer is nil, not sending event");
    }
}

RCT_EXPORT_METHOD(disableScreenshots) {
    NSLog(@"[RNScreenshotDetector] disableScreenshots called");
    dispatch_async(dispatch_get_main_queue(), ^{
        isProtectionEnabled = YES;
        NSLog(@"[RNScreenshotDetector] Protection enabled, calling enableTrueScreenshotPrevention");
        [self enableTrueScreenshotPrevention];
    });
}

RCT_EXPORT_METHOD(enableScreenshots) {
    NSLog(@"[RNScreenshotDetector] enableScreenshots called");
    dispatch_async(dispatch_get_main_queue(), ^{
        isProtectionEnabled = NO;
        NSLog(@"[RNScreenshotDetector] Protection disabled, calling disableTrueScreenshotPrevention");
        [self disableTrueScreenshotPrevention];
    });
}

RCT_EXPORT_METHOD(isScreenRecording:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    BOOL isRecording = [UIScreen mainScreen].isCaptured;
    NSLog(@"[RNScreenshotDetector] isScreenRecording called, result: %@", isRecording ? @"YES" : @"NO");
    resolve(@(isRecording));
}

RCT_EXPORT_METHOD(subscribeToScreenRecording) {
    NSLog(@"[RNScreenshotDetector] subscribeToScreenRecording called (NOTE: activates both screenshot and screen recording observers)");
    [self startObserving];
}

RCT_EXPORT_METHOD(unsubscribeFromScreenRecording) {
    NSLog(@"[RNScreenshotDetector] unsubscribeFromScreenRecording called");
    [self stopObserving];
}

RCT_EXPORT_METHOD(subscribeToScreenshotAndScreenRecording) {
    NSLog(@"[RNScreenshotDetector] subscribeToScreenshotAndScreenRecording called (clearer method name)");
    [self startObserving];
}

RCT_EXPORT_METHOD(unsubscribeFromScreenshotAndScreenRecording) {
    NSLog(@"[RNScreenshotDetector] unsubscribeFromScreenshotAndScreenRecording called (clearer method name)");
    [self stopObserving];
}

// Screenshot Prevention using Secure Text Field
- (void)enableTrueScreenshotPrevention {
    NSLog(@"[RNScreenshotDetector] enableTrueScreenshotPrevention called");
    if (self.secureTextField == nil) {
        NSLog(@"[RNScreenshotDetector] Creating new secureTextField");
        self.secureTextField = [[UITextField alloc] init];
        self.secureTextField.userInteractionEnabled = NO;
        self.secureTextField.secureTextEntry = YES;
        
        UIWindow *keyWindow = [self getKeyWindow];
        if (keyWindow != nil) {
            NSLog(@"[RNScreenshotDetector] Key window found, setting up secure text field");
            [keyWindow makeKeyAndVisible];
            
            // Make the app window a sublayer of the secure text field
            [keyWindow.layer.superlayer addSublayer:self.secureTextField.layer];
            
            // Add the window layer as a sublayer of the secure text field's first sublayer
            NSArray *sublayers = self.secureTextField.layer.sublayers;
            if (sublayers.count > 0) {
                [sublayers.firstObject addSublayer:keyWindow.layer];
                NSLog(@"[RNScreenshotDetector] Secure text field layers configured");
            } else {
                NSLog(@"[RNScreenshotDetector] No sublayers found in secure text field");
            }
        } else {
            NSLog(@"[RNScreenshotDetector] Key window not found!");
        }
    } else {
        NSLog(@"[RNScreenshotDetector] Secure text field already exists, enabling secureTextEntry");
        self.secureTextField.secureTextEntry = YES;
    }
}

- (void)disableTrueScreenshotPrevention {
    NSLog(@"[RNScreenshotDetector] disableTrueScreenshotPrevention called");
    if (self.secureTextField != nil) {
        NSLog(@"[RNScreenshotDetector] Disabling secureTextEntry");
        self.secureTextField.secureTextEntry = NO;
    } else {
        NSLog(@"[RNScreenshotDetector] Secure text field is nil");
    }
}

- (UIWindow *)getKeyWindow {
    NSLog(@"[RNScreenshotDetector] getKeyWindow called");
    UIWindow *keyWindow = nil;
    
    NSSet<UIScene *> *connectedScenes = [UIApplication sharedApplication].connectedScenes;
    NSLog(@"[RNScreenshotDetector] Connected scenes count: %lu", (unsigned long)connectedScenes.count);
    
    for (UIScene *scene in connectedScenes) {
        if ([scene isKindOfClass:[UIWindowScene class]]) {
            UIWindowScene *windowScene = (UIWindowScene *)scene;
            NSLog(@"[RNScreenshotDetector] Found window scene with %lu windows", (unsigned long)windowScene.windows.count);
            for (UIWindow *window in windowScene.windows) {
                if (window.isKeyWindow) {
                    keyWindow = window;
                    NSLog(@"[RNScreenshotDetector] Found key window using UIScene method");
                    break;
                }
            }
            if (keyWindow) break;
        }
    }
    
    if (keyWindow == nil) {
        NSLog(@"[RNScreenshotDetector] ERROR: Key window not found using UIScene method (iOS 16.0+)!");
    }
    
    return keyWindow;
}

- (void)dealloc {
    NSLog(@"[RNScreenshotDetector] dealloc called");
    [self stopObserving];
    [self disableTrueScreenshotPrevention];
}

@end 