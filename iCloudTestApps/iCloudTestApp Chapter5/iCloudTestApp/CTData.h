//
//  CTData.h
//  iCloudTestApp
//
//  Created by Brian Miller on 9/24/13.
//  Copyright (c) 2013 Brian Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CTData : NSObject <NSCoding>

@property (strong) NSString *firstName;
@property (strong) NSString *lastName;
@property (strong) NSString *displayName;
@property (strong) NSNumber *favoriteNumber;
@property (strong) UIImage *photo;

@end
