//
//  EntryCollectionViewCell.m
//  iCloudTestApp
//
//  Created by Brian Miller on 9/24/13.
//  Copyright (c) 2013 Brian Miller. All rights reserved.
//

#import "CTEntry.h"
#import "CTMetadata.h"
#import "EntryCollectionViewCell.h"

@interface EntryCollectionViewCell()
@property (weak) IBOutlet UIImageView *imgPhoto;
@property (weak) IBOutlet UILabel *lblDisplayName;
@property (assign) id<EntryCollectionViewCellDelegate> delegate;
@property (assign) CTEntry *entry;
@end

@implementation EntryCollectionViewCell

-(id)initWithCoder:(NSCoder *)aDecoder {
    if((self = [super initWithCoder:aDecoder])){
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
        [self addGestureRecognizer:longPress];
    }
    
    return self;
}

-(void)longPressed:(UIGestureRecognizer *)gesture {
    if(gesture.state == UIGestureRecognizerStateBegan){
        [_delegate entryCollectionViewCell:self longPressedForEntry:_entry];
    }
}

-(void)configureCellForEntry:(CTEntry *)entry withDelegate:(id<EntryCollectionViewCellDelegate>)delegate {
    if(entry == nil)
        return;
    
    _entry = entry;
    _delegate = delegate;
    
    if([[_entry metadata] thumbnail])
        _imgPhoto.image = [[_entry metadata] thumbnail];
    else
        _imgPhoto.image = [UIImage imageNamed:@"ImgCellNoImage"];
    
    _lblDisplayName.text = [[_entry metadata] displayName];
}

-(void)prepareForReuse {
    _entry = nil;
    _imgPhoto.image = nil;
    _lblDisplayName.text = @"";
}

@end
