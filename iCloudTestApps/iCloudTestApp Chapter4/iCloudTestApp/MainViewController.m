//
//  MainViewController.m
//  iCloudTestApp
//
//  Created by Brian Miller on 9/19/13.
//  Copyright (c) 2013 Brian Miller. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lblWelcome;
@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateUI];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    //removes self from responding to any notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateUI {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _lblWelcome.text = [NSString stringWithFormat:@"Welcome %@\nYour favorite number is %@",[userDefaults stringForKey:CTDisplayName],[userDefaults stringForKey:CTFavoriteNumber]];
}

@end
