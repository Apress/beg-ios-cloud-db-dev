//
//  CTDocument.h
//  iCloudTestApp
//
//  Created by Brian Miller on 9/24/13.
//  Copyright (c) 2013 Brian Miller. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CTData;
@class CTMetadata;

#define CT_EXTENSION @"ict"

@interface CTDocument : UIDocument

@property (strong, nonatomic) CTMetadata *metadata;

-(NSString *)firstName;
-(void)setFirstName:(NSString *)firstName;
-(NSString *)lastName;
-(void)setLastName:(NSString *)lastName;
-(NSString *)displayName;
-(void)setDisplayName:(NSString *)displayName;
-(NSNumber *)favoriteNumber;
-(void)setFavoriteNumber:(NSNumber *)favoriteNumber;
-(UIImage *)photo;
-(void)setPhoto:(UIImage *)photo;
-(NSString *)description;

@end
