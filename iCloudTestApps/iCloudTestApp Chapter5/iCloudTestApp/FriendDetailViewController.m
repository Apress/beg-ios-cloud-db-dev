//
//  FriendDetailViewController.m
//  iCloudTestApp
//
//  Created by Brian Miller on 9/24/13.
//  Copyright (c) 2013 Brian Miller. All rights reserved.
//

#import "CTDocument.h"
#import "UIImage+Resize.h"
#import <QuartzCore/QuartzCore.h>
#import "FriendDetailViewController.h"

@interface FriendDetailViewController ()
@property (weak) IBOutlet UITextField *txtFirstName;
@property (weak) IBOutlet UITextField *txtLastName;
@property (weak) IBOutlet UITextField *txtDisplayName;
@property (weak) IBOutlet UITextField *txtFavoriteNumber;
@property (weak) IBOutlet UIImageView *imgFriend;
@end

@implementation FriendDetailViewController {
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
    [_txtDisplayName setEnabled:NO];
    [_txtFavoriteNumber setEnabled:NO];
    for(UIGestureRecognizer *gesture in [_imgFriend gestureRecognizers]){
        [_imgFriend removeGestureRecognizer:gesture];
    }
}

-(void)enableAllFields {
    [_txtFirstName setEnabled:YES];
    [_txtLastName setEnabled:YES];
    [_txtDisplayName setEnabled:YES];
    [_txtFavoriteNumber setEnabled:YES];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoTapped:)];
    [_imgFriend addGestureRecognizer:tapGesture];
}

- (void)configureView {
    _txtFirstName.text = [_document firstName];
    _txtLastName.text = [_document lastName];
    _txtDisplayName.text = [_document displayName];
    _txtFavoriteNumber.text = [[_document favoriteNumber] stringValue];
    
    _imgFriend.layer.borderColor = [UIColor darkGrayColor].CGColor;
    _imgFriend.layer.borderWidth = 2.0f;
    
    if([_document photo])
        _imgFriend.image = [_document photo];
    else
        _imgFriend.image = [UIImage imageNamed:@"ImgNoImage"];
}

-(void)photoTapped:(UIGestureRecognizer *)gesture {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Change Photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo",@"Choose From Library",nil];
    
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
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
    
    [_document setFirstName:_txtFirstName.text];
    [_document setLastName:_txtLastName.text];
    [_document setDisplayName:_txtDisplayName.text];
    [_document setFavoriteNumber:[NSNumber numberWithFloat:[_txtFavoriteNumber.text floatValue]]];
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(btnEditPressed:)];
    [self.navigationItem setRightBarButtonItem:editButton animated:YES];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(btnBackPressed:)];
    [self.navigationItem setLeftBarButtonItem:backButton animated:YES];
}

-(void)btnBackPressed:(id)sender {
    [_document saveToURL:[_document fileURL] forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
        [_document closeWithCompletionHandler:^(BOOL success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(!success){
                    NSLog(@"Failed to close - %@",[_document fileURL]);
                }
                
                [_delegate detailViewControllerDidClose:self];
            });
        }];
    }];
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
    [_document setPhoto:resizedImage];
    [_imgFriend setImage:resizedImage];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate Methods
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if([textField isEqual:_txtFirstName]){
        [_txtLastName becomeFirstResponder];
    } else if([textField isEqual:_txtLastName]){
        if([_txtDisplayName.text isEqualToString:@""])
            _txtDisplayName.text = [NSString stringWithFormat:@"%@ %@",_txtFirstName.text,_txtLastName.text];
        [_txtDisplayName becomeFirstResponder];
    } else if([textField isEqual:_txtDisplayName]){
        [_txtFavoriteNumber becomeFirstResponder];
    } else if([textField isEqual:_txtFavoriteNumber]){
        [_txtFavoriteNumber resignFirstResponder];
    }
    
    return YES;
}

@end
