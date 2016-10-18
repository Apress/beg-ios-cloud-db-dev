//
//  SettingsViewController.m
//  iCloudTestApp
//
//  Created by Brian Miller on 9/19/13.
//  Copyright (c) 2013 Brian Miller. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UITextField *txtDisplayName;
@property (weak, nonatomic) IBOutlet UITextField *txtFavoriteNumber;
@property BOOL isChanged;
@end

@implementation SettingsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    _txtDisplayName.text = [[NSUserDefaults standardUserDefaults] stringForKey:CTDisplayName];
    _txtFavoriteNumber.text = [[NSUserDefaults standardUserDefaults] stringForKey:CTFavoriteNumber];
}

-(void)updateDefaultForTextField:(UITextField *)textField {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if([textField isEqual:_txtDisplayName]){
        if(![[userDefaults stringForKey:CTDisplayName] isEqualToString:textField.text]){
            [userDefaults setObject:textField.text forKey:CTDisplayName];
            if([userDefaults synchronize])
                [AppDelegate updateKeyValueStoreKey:CTDisplayName withObject:textField.text];
            
            _isChanged = YES;
        }
    } else {
        if(![[userDefaults stringForKey:CTFavoriteNumber] isEqualToString:textField.text]){
            [userDefaults setObject:[NSNumber numberWithFloat:[textField.text floatValue]] forKey:CTFavoriteNumber];
            if([userDefaults synchronize])
                [AppDelegate updateKeyValueStoreKey:CTFavoriteNumber withObject:textField.text];
            
            _isChanged = YES;
        }
    }
}

-(void)updateAllDefaults {
    [self updateDefaultForTextField:_txtDisplayName];
    [self updateDefaultForTextField:_txtFavoriteNumber];
}

#pragma mark - Button Methods
-(IBAction)btnClosePressed:(id)sender {
    [self updateAllDefaults];
    
    [self dismissViewControllerAnimated:YES completion:^{
        if(_isChanged)
            [AppDelegate syncKVSStore];
    }];
}

#pragma mark - UITextFieldDelegate Methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self updateDefaultForTextField:textField];
    
    if([textField isEqual:_txtDisplayName])
        [_txtFavoriteNumber becomeFirstResponder];
    else
        [_txtFavoriteNumber resignFirstResponder];
    
    return YES;
}

@end
