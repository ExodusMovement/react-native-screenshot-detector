//
//  RNScreenshotDetector.h
//
//  Created by Graham Carling on 1/11/17.
//

#import <React/RCTEventEmitter.h>
#import <React/RCTBridgeModule.h>

@interface RNScreenshotDetector : RCTEventEmitter <RCTBridgeModule>

@property (nonatomic, strong) UITextField *secureTextField;

- (void)screenshotDetected:(NSNotification*)notification;
- (void)screenRecordingChanged:(NSNotification*)notification;

@end
