//
//  AGViewController.m
//  AGAlertViewWithProgressbar Demo
//
//  Created by Artur Grigor on 23.04.2012.
//  Copyright (c) 2012 Artur Grigor. All rights reserved.
//

#import "AGViewController.h"

@interface AGViewController ()
{
    AGAlertViewWithProgressbar *alertViewWithProgressbar;
    NSTimer *timer;
}

@property (retain) AGAlertViewWithProgressbar *alertViewWithProgressbar;
@property (retain) NSTimer *timer;

@end

@implementation AGViewController

#pragma mark - Properties

@synthesize alertViewWithProgressbar, timer;

#pragma mark - Object Lifecycle

- (void)dealloc
{
    self.alertViewWithProgressbar = nil;
    
    [self.timer invalidate];
    self.timer = nil;
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        alertViewWithProgressbar = [[AGAlertViewWithProgressbar alloc] initWithTitle:@"Doing something." message:@"Please wait..." delegate:self cancelButtonTitle:@"Hide" otherButtonTitles:nil];
    }
    
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - Actions

- (IBAction)showAction:(id)sender
{
    [self.timer invalidate];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(incrementProgress:) userInfo:nil repeats:YES];
    [self.timer fire];
    
    [self.alertViewWithProgressbar show];
}

- (IBAction)incrementProgress:(id)sender
{
    self.alertViewWithProgressbar.progress += 1;
}

@end