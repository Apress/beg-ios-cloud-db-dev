//
//  CloseFriendDetailViewController.m
//  iCloudTestApp
//
//  Created by Brian Miller on 12/7/13.
//  Copyright (c) 2013 Brian Miller. All rights reserved.
//

#import "UIImage+Resize.h"
#import <QuartzCore/QuartzCore.h>
#import "CloseFriendDetailViewController.h"

@interface CloseFriendDetailViewController ()
@property (weak) IBOutlet UITextField *txtFirstName;
@property (weak) IBOutlet UITextField *txtLastName;
@property (weak) IBOutlet UITextField *txtBirthday;
@property (weak) IBOutlet UIImageView *imgFriend;

@property (strong) NSDateFormatter *dateFormatter;
@end

@implementation CloseFriendDetailViewController {
    UIImagePickerController *_picker;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(btnEditPressed:)];
    [self.navigationItem setRightBarButtonItem:editButton];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(btnBackPressed:)];
    [self.navigationItem setLeftBarButtonItem:backButton];
    [self.navigationItem setHidesBackButton:YES];
    
    [self configureView];
    [self disableAllFields];
    
    
    if(_shouldStartEditing) {
        [self btnEditPressed:nil];
        [_txtFirstName becomeFirstResponder];
    }
}

-(void)disableAllFields {
    [_txtFirstName setEnabled:NO];
    [_txtLastName setEnabled:NO];
    [_txtBirthday setEnabled:NO];
    for(UIGestureRecognizer *gesture in [_imgFriend gestureRecognizers]){
        [_imgFriend removeGestureRecognizer:gesture];
    }
}

-(void)enableAllFields {
    [_txtFirstName setEnabled:YES];
    [_txtLastName setEnabled:YES];
    [_txtBirthday setEnabled:YES];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoTapped:)];
    [_imgFriend addGestureRecognizer:tapGesture];
}

- (void)configureView {
    _txtFirstName.text = [_closeFriend firstName];
    _txtLastName.text = [_closeFriend lastName];
    [_txtBirthday setInputView:[self setupDatePickerWithDate:[_closeFriend birthday]]];
    [_txtBirthday setInputAccessoryView:[self setupKeyboardAccessoryView]];
    _txtBirthday.text = [_dateFormatter stringFromDate:[_closeFriend birthday]];
    
    _imgFriend.layer.borderColor = [UIColor darkGrayColor].CGColor;
    _imgFriend.layer.borderWidth = 2.0f;
 
    if([_closeFriend image] == nil)
        _imgFriend.image = [UIImage imageNamed:@"ImgNoImage"];
    else
        _imgFriend.image = [UIImage imageWithData:[_closeFriend image]];
}

-(void)photoTapped:(UIGestureRecognizer *)gesture {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Change Photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo",@"Choose From Library",nil];
    
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

-(UIDatePicker *)setupDatePickerWithDate:(NSDate *)date {
    if(date == nil)
        date = [NSDate date];
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    [datePicker setDatePickerMode:UIDatePickerModeDate];
    [datePicker setDate:date];
    [datePicker addTarget:self action:@selector(birthdayValueChanged:) forControlEvents:UIControlEventValueChanged];
    [_txtBirthday setInputView:datePicker];
    
    return datePicker;
}

-(UIView *)setupKeyboardAccessoryView {
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44)];
    
    UIBarButtonItem *btnDone = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(btnDatePickerDonePressed:)];
    [toolbar setItems:@[btnDone]];
    
    return toolbar;
}

-(void)birthdayValueChanged:(UIDatePicker *)datePicker {
    _txtBirthday.text = [_dateFormatter stringFromDate:[datePicker date]];
}

#pragma mark - Bar Button Methods
-(void)btnEditPressed:(id)sender {
    [self enableAllFields];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(btnDonePressed:)];
    [self.navigationItem setRightBarButtonItem:doneButton animated:YES];
    
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
}

-(void)btnDonePressed:(id)sender {
    [self disableAllFields];
    
    [_closeFriend setFirstName:_txtFirstName.text];
    [_closeFriend setLastName:_txtLastName.text];
    [_closeFriend setBirthday:[_dateFormatter dateFromString:_txtBirthday.text]];
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(btnEditPressed:)];
    [self.navigationItem setRightBarButtonItem:editButton animated:YES];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(btnBackPressed:)];
    [self.navigationItem setLeftBarButtonItem:backButton animated:YES];
}

-(void)btnBackPressed:(id)sender {
    NSError *error = nil;
    if(![[AppDelegate managedObjectContext] save:&error]){
        NSLog(@"There was an error saving date - %@",error.localizedDescription);
        [[[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"There was an error saving data - %@",error.localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else {
        [_delegate detailViewControllerDidClose:self];
    }
}

-(void)btnDatePickerDonePressed:(id)sender {
    static NSDateFormatter *dateFormatter = nil;
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    }
    
    UIDatePicker *datePicker = (UIDatePicker *)_txtBirthday.inputView;
    _txtBirthday.text = [dateFormatter stringFromDate:datePicker.date];
    [_txtBirthday resignFirstResponder];
}

#pragma mark - UIActionSheetDelegate Methods
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(_picker != nil){
        [_picker dismissViewControllerAnimated:NO completion:nil];
        _picker = nil;
    }
    
    switch (buttonIndex) {
        case 0: {
            _picker = [[UIImagePickerController alloc] init];
            [_picker setDelegate:self];
            [_picker setSourceType:UIImagePickerControllerSourceTypeCamera];
            [_picker setAllowsEditing:YES];
            
            [self presentViewController:_picker animated:YES completion:nil];
        }   break;
        case 1: {
            _picker = [[UIImagePickerController alloc] init];
            [_picker setDelegate:self];
            [_picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            [_picker setAllowsEditing:YES];
            
            [self presentViewController:_picker animated:YES completion:nil];
        }   break;
        default:
            break;
    }
}

#pragma mark - UIImagePickerControllerDelegate Methods
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = (UIImage *)[info objectForKey:UIImagePickerControllerEditedImage];
    
    UIImage *resizedImage = [image resizedImage:CGSizeMake(560, 560) interpolationQuality:kCGInterpolationHigh];
    NSData *imageData = UIImagePNGRepresentation(resizedImage);
    [_closeFriend setImage:imageData];
    [_imgFriend setImage:resizedImage];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate Methods
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if([textField isEqual:_txtFirstName]){
        [_txtLastName becomeFirstResponder];
    } else if([textField isEqual:_txtLastName]){
        [_txtBirthday becomeFirstResponder];
    }
    
    return YES;
}

@end
