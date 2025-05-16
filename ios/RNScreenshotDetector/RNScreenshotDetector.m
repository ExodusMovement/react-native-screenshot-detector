//
//  RNScreenshotDetector.m
//
//  Created by Graham Carling on 1/11/17.
//  Enhanced for screen recording detection and conditional blur control.
//

#import "RNScreenshotDetector.h"
#import <React/RCTBridge.h>
#import <React/RCTEventEmitter.h>
#import <UIKit/UIKit.h>

@interface RNScreenshotDetector () {
    id observer;
    BOOL blurManuallyEnabled;
    UIVisualEffectView *blurShield;
}
@end

@implementation RNScreenshotDetector

RCT_EXPORT_MODULE();

#pragma mark - Init

- (instancetype)init {
    self = [super init];
    if (self) {
        blurManuallyEnabled = NO;

        [[UIScreen mainScreen] addObserver:self
                                forKeyPath:@"captured"
                                   options:NSKeyValueObservingOptionNew
                                   context:nil];

        dispatch_async(dispatch_get_main_queue(), ^{
            [self setupBlurShield];
            [self updateScreenShield];
        });
    }
    return self;
}

#pragma mark - React Native Events

- (NSArray<NSString *> *)supportedEvents {
    return @[@"ScreenshotTaken"];
}

- (void)startObserving {
    observer = [[NSNotificationCenter defaultCenter]
        addObserverForName:UIApplicationUserDidTakeScreenshotNotification
                    object:nil
                     queue:[NSOperationQueue mainQueue]
                usingBlock:^(NSNotification *notification) {
        [self screenshotDetected:notification];
    }];
}

- (void)stopObserving {
    if (observer != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:observer];
        observer = nil;
    }
}

- (void)screenshotDetected:(NSNotification *)notification {
    if (observer != nil) {
        [self sendEventWithName:@"ScreenshotTaken" body:@{}];
    }
}

#pragma mark - Blur Shield

- (void)setupBlurShield {
    if (blurShield != nil) return;

    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    blurShield = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurShield.frame = [UIScreen mainScreen].bounds;
    blurShield.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    blurShield.hidden = YES;

    UILabel *warningLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    warningLabel.text = @"Screen recording is active.\nSensitive content hidden.";
    warningLabel.textColor = [UIColor whiteColor];
    warningLabel.font = [UIFont boldSystemFontOfSize:18];
    warningLabel.numberOfLines = 0;
    warningLabel.textAlignment = NSTextAlignmentCenter;
    warningLabel.translatesAutoresizingMaskIntoConstraints = NO;

    [blurShield.contentView addSubview:warningLabel];

    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    if (keyWindow) {
        [keyWindow addSubview:blurShield];

        [NSLayoutConstraint activateConstraints:@[
            [warningLabel.centerXAnchor constraintEqualToAnchor:blurShield.contentView.centerXAnchor],
            [warningLabel.centerYAnchor constraintEqualToAnchor:blurShield.contentView.centerYAnchor],
            [warningLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:blurShield.contentView.leadingAnchor constant:20],
            [warningLabel.trailingAnchor constraintLessThanOrEqualToAnchor:blurShield.contentView.trailingAnchor constant:-20]
        ]];
    }
}

- (void)updateScreenShield {
    BOOL isCaptured = [UIScreen mainScreen].isCaptured;
    blurShield.hidden = !(isCaptured && blurManuallyEnabled);
}

#pragma mark - KVO for Screen Capture

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey, id> *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"captured"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateScreenShield];
        });
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - React Native Methods

RCT_EXPORT_METHOD(disableScreenshots) {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([UIScreen mainScreen].isCaptured) {
            blurManuallyEnabled = YES;
            blurShield.hidden = NO;
        }
    });
}

RCT_EXPORT_METHOD(enableScreenshots) {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([UIScreen mainScreen].isCaptured) {
            blurManuallyEnabled = NO;
            blurShield.hidden = YES;
        }
    });
}

#pragma mark - Cleanup

- (void)dealloc {
    if (observer != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:observer];
    }
    [[UIScreen mainScreen] removeObserver:self forKeyPath:@"captured"];
}

@end
