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
    UIWindow *originalKeyWindow;      
    CALayer *originalSuperlayer;      
}

RCT_EXPORT_MODULE();

- (NSArray<NSString *> *)supportedEvents {
    return @[@"ScreenshotTaken", @"ScreenRecordingChanged"];
}

- (void)startObserving {
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    
    if (screenshotObserver == nil) {
        screenshotObserver = [[NSNotificationCenter defaultCenter] 
            addObserverForName:UIApplicationUserDidTakeScreenshotNotification
            object:nil
            queue:mainQueue
            usingBlock:^(NSNotification *notification) {
                [self screenshotDetected:notification];
            }];
    }
    
    if (screenRecordingObserver == nil) {
        screenRecordingObserver = [[NSNotificationCenter defaultCenter]
            addObserverForName:UIScreenCapturedDidChangeNotification
            object:nil
            queue:mainQueue
            usingBlock:^(NSNotification *notification) {
                [self screenRecordingChanged:notification];
            }];
    }
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
    BOOL isRecording = [UIScreen mainScreen].isCaptured;
    
    if (screenRecordingObserver != nil) {
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

RCT_EXPORT_METHOD(subscribeToScreenshotAndScreenRecording) {
    [self startObserving];
}

RCT_EXPORT_METHOD(unsubscribeFromScreenshotAndScreenRecording) {
    [self stopObserving];
}

// Screenshot Prevention using Secure Text Field
- (void)enableTrueScreenshotPrevention {
    @try {
        if (self.secureTextField == nil) {
            self.secureTextField = [[UITextField alloc] init];
            self.secureTextField.userInteractionEnabled = NO;
            self.secureTextField.secureTextEntry = YES;
        }
        
        UIWindow *keyWindow = [self getKeyWindow];
        if (keyWindow != nil) {
            originalKeyWindow = keyWindow;
            originalSuperlayer = keyWindow.layer.superlayer;
            
            [keyWindow makeKeyAndVisible];
            
            if (originalSuperlayer != nil) {
                [originalSuperlayer addSublayer:self.secureTextField.layer];
                
                [keyWindow.layer removeFromSuperlayer];
                
                NSArray *sublayers = self.secureTextField.layer.sublayers;
                if (sublayers.count > 0) {
                    [sublayers.firstObject addSublayer:keyWindow.layer];
                } else {
                    [self.secureTextField.layer addSublayer:keyWindow.layer];
                }
            }   
        } 
    } @catch (NSException *exception) {
        NSLog(@"[RNScreenshotDetector] Error in enableTrueScreenshotPrevention: %@", exception);
    }
}

- (void)disableTrueScreenshotPrevention {
    @try {
        if (self.secureTextField != nil) {
            self.secureTextField.secureTextEntry = NO;
            
            if (originalKeyWindow != nil && originalSuperlayer != nil) {
                [originalKeyWindow.layer removeFromSuperlayer];
                [originalSuperlayer addSublayer:originalKeyWindow.layer];
                
                [self.secureTextField.layer removeFromSuperlayer];
            }
            
            originalKeyWindow = nil;
            originalSuperlayer = nil;
            
            [self.secureTextField removeFromSuperview];
            self.secureTextField = nil;
        }
    } @catch (NSException *exception) {
        NSLog(@"[RNScreenshotDetector] Error in disableTrueScreenshotPrevention: %@", exception);
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
    
    return keyWindow;
}

- (void)dealloc {
    [self stopObserving];
    [self disableTrueScreenshotPrevention];
}

@end 