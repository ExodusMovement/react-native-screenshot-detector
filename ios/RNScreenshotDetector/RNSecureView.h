//
//  RNSecureView.h
//  RNScreenshotDetector
//
//  Created for selective screenshot protection
//

#import <UIKit/UIKit.h>

@interface RNSecureView : UIView

@property (nonatomic, strong) UITextField *secureTextField;
@property (nonatomic, assign) BOOL isSecureEnabled;

- (void)enableSecureProtection;
- (void)disableSecureProtection;

@end 