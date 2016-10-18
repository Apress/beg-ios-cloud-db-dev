//
//  CloseFriend.h
//  iCloudTestApp
//
//  Created by Brian Miller on 12/7/13.
//  Copyright (c) 2013 Brian Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CloseFriend : NSManagedObject

@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSDate * birthday;
@property (nonatomic, retain) NSData * image;

@end
