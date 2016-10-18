//
//  FriendDetailViewController.h
//  iCloudTestApp
//
//  Created by Brian Miller on 9/24/13.
//  Copyright (c) 2013 Brian Miller. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CTDocument;

@protocol FriendDetailViewControllerDelegate;

@interface FriendDetailViewController : UIViewController <UITextFieldDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) CTDocument *document;
@property (assign) id<FriendDetailViewControllerDelegate> delegate;
@property BOOL shouldStartEditing;

@end

@protocol FriendDetailViewControllerDelegate <NSObject>
-(void)detailViewControllerDidClose:(FriendDetailViewController *)detailViewController;
@end