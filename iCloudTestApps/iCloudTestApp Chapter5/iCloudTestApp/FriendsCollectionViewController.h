//
//  FriendsCollectionViewController.h
//  iCloudTestApp
//
//  Created by Brian Miller on 9/24/13.
//  Copyright (c) 2013 Brian Miller. All rights reserved.
//

#import "FriendDetailViewController.h"
#import "EntryCollectionViewCell.h"
#import <UIKit/UIKit.h>

@interface FriendsCollectionViewController : UICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegate, EntryCollectionViewCellDelegate, UIAlertViewDelegate, FriendDetailViewControllerDelegate>

@end
