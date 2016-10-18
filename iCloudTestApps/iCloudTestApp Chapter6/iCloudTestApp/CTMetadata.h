//
//  CTMetadata.h
//  iCloudTestApp
//
//  Created by Brian Miller on 9/24/13.
//  Copyright (c) 2013 Brian Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CTMetadata : NSObject <NSCoding>

@property (strong) UIImage *thumbnail;
@property (strong) NSString *displayName;

@end
