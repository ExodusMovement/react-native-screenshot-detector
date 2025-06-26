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
    NSLog(@"[TEST] supportedEvents called");
    return @[@"ScreenshotTaken", @"ScreenRecordingChanged"];
}

- (void)startObserving {
    NSLog(@"[TEST] startObserving called");
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    
    if (screenshotObserver == nil) {
        screenshotObserver = [[NSNotificationCenter defaultCenter] 
            addObserverForName:UIApplicationUserDidTakeScreenshotNotification
            object:nil
            queue:mainQueue
            usingBlock:^(NSNotification *notification) {
                [self screenshotDetected:notification];
            }];
        NSLog(@"[TEST] Screenshot observer registered successfully");
    } else {
        NSLog(@"[TEST] Screenshot observer already exists");
    }
    
    if (screenRecordingObserver == nil) {
        screenRecordingObserver = [[NSNotificationCenter defaultCenter]
            addObserverForName:UIScreenCapturedDidChangeNotification
            object:nil
            queue:mainQueue
            usingBlock:^(NSNotification *notification) {
                [self screenRecordingChanged:notification];
            }];
        NSLog(@"[TEST] Screen recording observer registered successfully");
    } else {
        NSLog(@"[TEST] Screen recording observer already exists");
    }
}

- (void)stopObserving {
    NSLog(@"[TEST] stopObserving called");
    if (screenshotObserver != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:screenshotObserver];
        screenshotObserver = nil;
        NSLog(@"[TEST] Screenshot observer removed successfully");
    }
    
    if (screenRecordingObserver != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:screenRecordingObserver];
        screenRecordingObserver = nil;
        NSLog(@"[TEST] Screen recording observer removed successfully");
    }
}

- (void)screenshotDetected:(NSNotification *)notification {
    NSLog(@"[TEST] 🚨 SCREENSHOT DETECTED! 🚨");
    if (screenshotObserver != nil) {
        NSLog(@"[TEST] Sending ScreenshotTaken event to JavaScript");
        [self sendEventWithName:@"ScreenshotTaken" body:@{}];
        NSLog(@"[TEST] ScreenshotTaken event sent successfully");
    } else {
        NSLog(@"[TEST] ERROR: Screenshot observer is nil, not sending event");
    }
}

- (void)screenRecordingChanged:(NSNotification *)notification {
    BOOL isRecording = [UIScreen mainScreen].isCaptured;
    NSLog(@"[TEST] Screen recording changed: %@", isRecording ? @"STARTED" : @"STOPPED");
    
    if (screenRecordingObserver != nil) {
        NSLog(@"[TEST] Sending ScreenRecordingChanged event to JavaScript");
        [self sendEventWithName:@"ScreenRecordingChanged" body:@{@"isRecording": @(isRecording)}];
        NSLog(@"[TEST] ScreenRecordingChanged event sent successfully");
    } else {
        NSLog(@"[TEST] ERROR: Screen recording observer is nil, not sending event");
    }
}

RCT_EXPORT_METHOD(disableScreenshots) {
    NSLog(@"[TEST] disableScreenshots called");
    dispatch_async(dispatch_get_main_queue(), ^{
        isProtectionEnabled = YES;
        NSLog(@"[TEST] Protection enabled, calling enableTrueScreenshotPrevention");
        [self enableTrueScreenshotPrevention];
        NSLog(@"[TEST] disableScreenshots completed");
    });
}

RCT_EXPORT_METHOD(enableScreenshots) {
    NSLog(@"[TEST] enableScreenshots called");
    dispatch_async(dispatch_get_main_queue(), ^{
        isProtectionEnabled = NO;
        NSLog(@"[TEST] Protection disabled, calling disableTrueScreenshotPrevention");
        [self disableTrueScreenshotPrevention];
        NSLog(@"[TEST] enableScreenshots completed");
    });
}

RCT_EXPORT_METHOD(isScreenRecording:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    BOOL isRecording = [UIScreen mainScreen].isCaptured;
    NSLog(@"[TEST] isScreenRecording called, result: %@", isRecording ? @"YES" : @"NO");
    resolve(@(isRecording));
}

// Clear and explicit method names
RCT_EXPORT_METHOD(subscribeToScreenshotAndScreenRecording) {
    NSLog(@"[TEST] subscribeToScreenshotAndScreenRecording called - NEW EXPLICIT METHOD!");
    [self startObserving];
    NSLog(@"[TEST] subscribeToScreenshotAndScreenRecording completed");
}

RCT_EXPORT_METHOD(unsubscribeFromScreenshotAndScreenRecording) {
    NSLog(@"[TEST] unsubscribeFromScreenshotAndScreenRecording called");
    [self stopObserving];
    NSLog(@"[TEST] unsubscribeFromScreenshotAndScreenRecording completed");
}

// Screenshot Prevention using Secure Text Field
- (void)enableTrueScreenshotPrevention {
    NSLog(@"[TEST] enableTrueScreenshotPrevention called");
    if (self.secureTextField == nil) {
        NSLog(@"[TEST] Creating new secureTextField");
        self.secureTextField = [[UITextField alloc] init];
        self.secureTextField.userInteractionEnabled = NO;
        self.secureTextField.secureTextEntry = YES;
        
        UIWindow *keyWindow = [self getKeyWindow];
        if (keyWindow != nil) {
            NSLog(@"[TEST] Key window found, setting up secure text field");
            [keyWindow makeKeyAndVisible];
            
            // Make the app window a sublayer of the secure text field
            [keyWindow.layer.superlayer addSublayer:self.secureTextField.layer];
            
            // Add the window layer as a sublayer of the secure text field's first sublayer
            NSArray *sublayers = self.secureTextField.layer.sublayers;
            if (sublayers.count > 0) {
                [sublayers.firstObject addSublayer:keyWindow.layer];
                NSLog(@"[TEST] ✅ Secure text field configured successfully - Screenshot prevention ACTIVE!");
            } else {
                NSLog(@"[TEST] ❌ No sublayers found in secure text field");
            }
        } else {
            NSLog(@"[TEST] ❌ Key window not found!");
        }
    } else {
        NSLog(@"[TEST] Secure text field already exists, enabling secureTextEntry");
        self.secureTextField.secureTextEntry = YES;
        NSLog(@"[TEST] ✅ Secure text field re-enabled - Screenshot prevention ACTIVE!");
    }
}

- (void)disableTrueScreenshotPrevention {
    NSLog(@"[TEST] disableTrueScreenshotPrevention called");
    if (self.secureTextField != nil) {
        NSLog(@"[TEST] Disabling secureTextEntry");
        self.secureTextField.secureTextEntry = NO;
        NSLog(@"[TEST] ✅ Screenshot prevention DISABLED");
    } else {
        NSLog(@"[TEST] Secure text field is nil");
    }
}

- (UIWindow *)getKeyWindow {
    NSLog(@"[TEST] getKeyWindow called");
    UIWindow *keyWindow = nil;
    
    NSSet<UIScene *> *connectedScenes = [UIApplication sharedApplication].connectedScenes;
    NSLog(@"[TEST] Connected scenes count: %lu", (unsigned long)connectedScenes.count);
    
    for (UIScene *scene in connectedScenes) {
        if ([scene isKindOfClass:[UIWindowScene class]]) {
            UIWindowScene *windowScene = (UIWindowScene *)scene;
            NSLog(@"[TEST] Found window scene with %lu windows", (unsigned long)windowScene.windows.count);
            for (UIWindow *window in windowScene.windows) {
                if (window.isKeyWindow) {
                    keyWindow = window;
                    NSLog(@"[TEST] ✅ Found key window using UIScene method");
                    break;
                }
            }
            if (keyWindow) break;
        }
    }
    
    if (keyWindow == nil) {
        NSLog(@"[TEST] ❌ Key window not found using UIScene method!");
    }
    
    return keyWindow;
}

- (void)dealloc {
    NSLog(@"[TEST] dealloc called");
    [self stopObserving];
    [self disableTrueScreenshotPrevention];
}

@end 