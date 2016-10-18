//
//  CloseFriendDetailViewController.h
//  iCloudTestApp
//
//  Created by Brian Miller on 12/7/13.
//  Copyright (c) 2013 Brian Miller. All rights reserved.
//

#import "CloseFriend.h"
#import <UIKit/UIKit.h>

@protocol CloseFriendDetailViewControllerDelegate;

@interface CloseFriendDetailViewController : UIViewController <UITextFieldDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) CloseFriend *closeFriend;
@property (assign) id<CloseFriendDetailViewControllerDelegate> delegate;
@property BOOL shouldStartEditing;

@end

@protocol CloseFriendDetailViewControllerDelegate <NSObject>
-(void)detailViewControllerDidClose:(CloseFriendDetailViewController *)detailViewController;
@end