//
//  RNSecureView.m
//  RNScreenshotDetector
//
//  Created for selective screenshot protection
//

#import "RNSecureView.h"

@implementation RNSecureView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _isSecureEnabled = YES;  // Default to enabled for security
        [self setupSecureTextField];
        [self enableSecureProtection];  // Enable by default
    }
    return self;
}

- (void)setupSecureTextField {
    self.secureTextField = [[UITextField alloc] init];
    self.secureTextField.userInteractionEnabled = NO;
    self.secureTextField.secureTextEntry = YES; // Default enabled for security
    self.secureTextField.backgroundColor = [UIColor clearColor];
    self.secureTextField.frame = self.bounds;
    self.secureTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // Add secureTextField to the view hierarchy
    [self addSubview:self.secureTextField];
    [self sendSubviewToBack:self.secureTextField];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Update secureTextField frame when view resizes
    self.secureTextField.frame = self.bounds;
    
    if (self.isSecureEnabled) {
        [self updateSecureLayerStructure];
    }
}

- (void)enableSecureProtection {
    if (self.isSecureEnabled) return;
    
    self.isSecureEnabled = YES;
    self.secureTextField.secureTextEntry = YES;
    
    [self updateSecureLayerStructure];
}

- (void)disableSecureProtection {
    if (!self.isSecureEnabled) return;
    
    self.isSecureEnabled = NO;
    self.secureTextField.secureTextEntry = NO;
    
    // Reset layer structure
    [self.layer removeFromSuperlayer];
    [self.superview.layer addSublayer:self.layer];
}

- (void)updateSecureLayerStructure {
    if (!self.isSecureEnabled || !self.superview) return;
    
    // Make this view a sublayer of the secure text field
    [self.layer removeFromSuperlayer];
    [self.secureTextField.layer addSublayer:self.layer];
    
    // Ensure secure text field covers the entire view
    self.secureTextField.frame = self.bounds;
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    
    if (self.superview && self.isSecureEnabled) {
        [self updateSecureLayerStructure];
    }
}

- (void)dealloc {
    [self disableSecureProtection];
}

@end 