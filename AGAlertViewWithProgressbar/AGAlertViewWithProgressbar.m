//
//  AGAlertViewWithProgressbar.m
//  AGAlertViewWithProgressbar
//
//  Created by Artur Grigor on 19.04.2012.
//  Copyright (c) 2012 Artur Grigor. All rights reserved.
//  
//  For the full copyright and license information, please view the LICENSE
//  file that was distributed with this source code.
//  

#import "AGAlertViewWithProgressbar.h"

@interface AGAlertViewWithProgressbar ()
{
    UIAlertView *alertView;
    UIProgressView *progressView;
    UILabel *progressLabel;
    
    struct {
        unsigned int delegateClickedButtonAtIndex:1;
        unsigned int delegateCancel:1;
        unsigned int delegateWillPresentAlertView:1;
        unsigned int delegateDidPresentAlertView:1;
        unsigned int delegateWillDismissWithButtonIndex:1;
        unsigned int delegateDidDismissWithButtonIndex:1;
        unsigned int delegateShouldEnableFirstOtherButton:1;
    } supportedDelegateMethods;
}

@property (nonatomic, retain) UIAlertView *alertView;
@property (nonatomic, retain) UIProgressView *progressView;
@property (nonatomic, retain) UILabel *progressLabel;

- (void)repositionControls;
- (void)setAutoresizingMask;
- (void)setupAlertView;

@end

@implementation AGAlertViewWithProgressbar

#pragma mark - Properties

@synthesize progress, title, message, delegate, cancelButtonTitle, otherButtonTitles;

- (BOOL)isVisible
{
    return self.alertView.visible;
}

- (void)setProgress:(NSUInteger)theProgress
{
    if (progress != theProgress)
    {
        if (theProgress > 100)
        {
            return;
        }
        
        progress = theProgress;
        
        self.progressView.progress = (float)(progress / 100.f);
        self.progressLabel.text = [NSString stringWithFormat:@"%d%%", progress];
    }
}

- (void)setTitle:(NSString *)theTitle
{
    if (title != theTitle)
    {
        if (title != nil) {
            [title release];
        }
        title = [theTitle retain];
        
        self.alertView.title = title;
    }
}

- (void)setMessage:(NSString *)theMessage
{
    if (message != theMessage)
    {
        if (message != nil) {
            [message release];
        }
        
        message = [theMessage retain];
        
        self.alertView.message = message;
    }
}

- (void)setDelegate:(id<UIAlertViewDelegate>)theDelegate
{
    if (delegate != theDelegate)
    {
        delegate = theDelegate;
        
        supportedDelegateMethods.delegateClickedButtonAtIndex = ([self.delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]);
        supportedDelegateMethods.delegateCancel = ([self.delegate respondsToSelector:@selector(alertViewCancel:)]);
        supportedDelegateMethods.delegateWillPresentAlertView = ([self.delegate respondsToSelector:@selector(willPresentAlertView:)]);
        supportedDelegateMethods.delegateDidPresentAlertView = ([self.delegate respondsToSelector:@selector(didPresentAlertView:)]);
        supportedDelegateMethods.delegateWillDismissWithButtonIndex = ([self.delegate respondsToSelector:@selector(alertView:willDismissWithButtonIndex:)]);
        supportedDelegateMethods.delegateDidDismissWithButtonIndex = ([self.delegate respondsToSelector:@selector(alertView:didDismissWithButtonIndex:)]);
        supportedDelegateMethods.delegateShouldEnableFirstOtherButton = ([self.delegate respondsToSelector:@selector(alertViewShouldEnableFirstOtherButton:)]);
    }
}

- (void)setCancelButtonTitle:(NSString *)theCancelButtonTitle
{
    if (cancelButtonTitle != theCancelButtonTitle)
    {
        if (cancelButtonTitle != nil) {
            [cancelButtonTitle release];
        }
        
        cancelButtonTitle = [theCancelButtonTitle retain];
        
        [self hide];
        self.alertView = nil;
    }
}

- (void)setOtherButtonTitles:(NSArray *)theOtherButtonTitles
{
    if (otherButtonTitles != theOtherButtonTitles)
    {
        if (otherButtonTitles != nil) {
            [otherButtonTitles release];
        }
        
        otherButtonTitles = [theOtherButtonTitles retain];
        
        [self hide];
        self.alertView = nil;
    }
}

@synthesize alertView, progressView, progressLabel;

- (UIAlertView *)alertView
{
    if (alertView == nil)
    {
        alertView = [[UIAlertView alloc] initWithTitle:self.title message:self.message delegate:self cancelButtonTitle:self.cancelButtonTitle otherButtonTitles:nil];
        
        for (NSString *arg in self.otherButtonTitles) {
            [alertView addButtonWithTitle:arg];
        }
        
        [self setupAlertView];
    }
    
    return alertView;
}

#pragma mark - Object Lifecycle

- (void)dealloc
{
    [self hide];
    
    self.alertView = nil;
    self.progressView = nil;
    self.progressLabel = nil;
    
    [super dealloc];
}

- (id)initWithTitle:(NSString *)theTitle message:(NSString *)theMessage andDelegate:(id<UIAlertViewDelegate>)theDelegate
{
    return [self initWithTitle:theTitle message:theMessage delegate:theDelegate cancelButtonTitle:nil otherButtonTitles:nil];
}

- (id)initWithTitle:(NSString *)theTitle message:(NSString *)theMessage delegate:(id)theDelegate cancelButtonTitle:(NSString *)titleForTheCancelButton otherButtonTitles:(NSString *)titleForTheFirstButton, ... NS_REQUIRES_NIL_TERMINATION
{
self = [super init];
if (self)
{
    NSMutableArray *otherButtonTitlesArray = [[NSMutableArray alloc] init];
    
    va_list args;
    va_start(args, titleForTheFirstButton);
    for (NSString *arg = titleForTheFirstButton; arg != nil; arg = va_arg(args, NSString*))
    {
        [otherButtonTitlesArray addObject:arg];
    }
    va_end(args);
    
    self.progress = 0;
    self.message = theMessage;
    self.title = theTitle;
    self.delegate = theDelegate;
    self.cancelButtonTitle = titleForTheCancelButton;
    self.otherButtonTitles = otherButtonTitlesArray;
    
    [otherButtonTitlesArray release];
}

return self;
}

#pragma mark - Public Methods

- (void)show
{
    if (! self.visible)
    {
        [self.alertView show];
    }
}

- (void)hide
{
    if (self.visible)
    {
        [self.alertView dismissWithClickedButtonIndex:0 animated:YES];
    }
}

#pragma mark - UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)thisAlertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (supportedDelegateMethods.delegateClickedButtonAtIndex)
        [self.delegate alertView:thisAlertView clickedButtonAtIndex:buttonIndex];
}

- (void)alertViewCancel:(UIAlertView *)thisAlertView
{
    if (supportedDelegateMethods.delegateCancel)
        [self.delegate alertViewCancel:thisAlertView];
}

- (void)willPresentAlertView:(UIAlertView *)thisAlertView
{
    [self repositionControls];
    
    if (supportedDelegateMethods.delegateWillPresentAlertView)
        [self.delegate willPresentAlertView:thisAlertView];
}

- (void)didPresentAlertView:(UIAlertView *)thisAlertView
{
    if (supportedDelegateMethods.delegateDidPresentAlertView)
        [self.delegate didPresentAlertView:thisAlertView];
}

- (void)alertView:(UIAlertView *)thisAlertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (supportedDelegateMethods.delegateWillDismissWithButtonIndex)
        [self.delegate alertView:thisAlertView willDismissWithButtonIndex:buttonIndex];
}

- (void)alertView:(UIAlertView *)thisAlertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    self.alertView = nil;
    
    if (supportedDelegateMethods.delegateDidDismissWithButtonIndex)
        [self.delegate alertView:thisAlertView didDismissWithButtonIndex:buttonIndex];
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)thisAlertView
{
    if (supportedDelegateMethods.delegateShouldEnableFirstOtherButton)
    {
        return [self.delegate alertViewShouldEnableFirstOtherButton:thisAlertView];
    } else {
        return NO;
    }
}

#pragma mark - Private Methods

- (void)repositionControls
{
    UILabel *messageLabel = nil;
    
    NSInteger idx = 0;
    for (UIView *subview in self.alertView.subviews)
    {
        if (([subview isKindOfClass:[UILabel class]]) && subview != self.progressLabel)
        {
            idx++;
            
            if (idx == 2)
            {
                // Second label is the label that's displaying the message
                
                messageLabel = (UILabel *)subview;
                break;
            }
        }
    }
    
    CGFloat y = messageLabel.frame.origin.y + messageLabel.frame.size.height + 20.f;
    
    self.progressView.frame = CGRectMake(30.0f, y + 3.f, 170.0f, 90.0f);
    self.progressLabel.frame = CGRectMake(215.0f, y, 40.f, 14.0f);
    
    if (alertView.numberOfButtons > 0)
    {
        [self setAutoresizingMask];
        
        self.alertView.frame = (CGRect){self.alertView.frame.origin, {self.alertView.frame.size.width, self.alertView.frame.size.height + 40.f}};
    }
}

- (void)setAutoresizingMask
{
    for (UIView *subview in self.alertView.subviews)
    {
        if (([subview isKindOfClass:[UIButton class]]))
        {
            subview.autoresizingMask = subview.autoresizingMask ^ UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        }
    }
}

- (void)setupAlertView
{
    self.alertView.autoresizesSubviews = YES;
    
    progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    self.progressView.progress = (float)(self.progress / 100.f);
    [self.alertView addSubview:self.progressView];
    
    progressLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.progressLabel.backgroundColor = [UIColor clearColor];
    self.progressLabel.textColor = [UIColor whiteColor];
    self.progressLabel.font = [UIFont systemFontOfSize:14.0f];
    self.progressLabel.text = [NSString stringWithFormat:@"%d%%", self.progress];
    self.progressLabel.tag = 1;
    self.progressLabel.textAlignment = UITextAlignmentCenter;
    [self.alertView addSubview:self.progressLabel];
}

@end