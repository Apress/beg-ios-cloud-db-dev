//
//  EntryCollectionViewCell.h
//  iCloudTestApp
//
//  Created by Brian Miller on 9/24/13.
//  Copyright (c) 2013 Brian Miller. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CTEntry;

@protocol EntryCollectionViewCellDelegate;

@interface EntryCollectionViewCell : UICollectionViewCell

-(void)configureCellForEntry:(CTEntry *)entry withDelegate:(id<EntryCollectionViewCellDelegate>)delegate;

@end

@protocol EntryCollectionViewCellDelegate <NSObject>
-(void)entryCollectionViewCell:(EntryCollectionViewCell *)cell longPressedForEntry:(CTEntry *)entry;
@end