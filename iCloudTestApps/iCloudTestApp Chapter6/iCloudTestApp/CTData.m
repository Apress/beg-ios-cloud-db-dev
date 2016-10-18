//
//  CTData.m
//  iCloudTestApp
//
//  Created by Brian Miller on 9/24/13.
//  Copyright (c) 2013 Brian Miller. All rights reserved.
//

#import "CTData.h"

#define kVersionKey @"VERSION"
#define kFirstNameKey @"FIRST_NAME"
#define kLastNameKey @"LAST_NAME"
#define kDisplayNameKey @"DISPLAY_NAME"
#define kFavoriteNumberKey @"FAVORITE_NUMBER"
#define kPhotoKey @"PHOTO"

@implementation CTData

- (id)initWithFirstName:(NSString *)firstName lastName:(NSString *)lastName displayName:(NSString *)displayName favoriteNumber:(NSNumber *)favoriteNumber andPhoto:(UIImage *)photo {
    if((self = [super init])){
        _firstName = firstName;
        _lastName = lastName;
        _displayName = displayName;
        _favoriteNumber = favoriteNumber;
        _photo = photo;
    }
    
    return self;
}

- (id)init {
    return [self initWithFirstName:nil lastName:nil displayName:nil favoriteNumber:nil andPhoto:nil];
}

#pragma mark - NSCoding Methods
- (id)initWithCoder:(NSCoder *)aDecoder {
    NSInteger version = [aDecoder decodeIntForKey:kVersionKey];
    
    if(version == 1){
        NSString *firstName = [aDecoder decodeObjectForKey:kFirstNameKey];
        NSString *lastName = [aDecoder decodeObjectForKey:kLastNameKey];
        NSString *displayName = [aDecoder decodeObjectForKey:kDisplayNameKey];
        NSNumber *favoriteNumber = [aDecoder decodeObjectForKey:kFavoriteNumberKey];
        
        NSData *photoData = [aDecoder decodeObjectForKey:kPhotoKey];
        UIImage *photo = [UIImage imageWithData:photoData];
        
        return [self initWithFirstName:firstName lastName:lastName displayName:displayName favoriteNumber:favoriteNumber andPhoto:photo];
    } else {
        return [self init];
    }
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInt:1 forKey:kVersionKey];
    [aCoder encodeObject:_firstName forKey:kFirstNameKey];
    [aCoder encodeObject:_lastName forKey:kLastNameKey];
    [aCoder encodeObject:_displayName forKey:kDisplayNameKey];
    [aCoder encodeObject:_favoriteNumber forKey:kFavoriteNumberKey];
    
    NSData *photoData = UIImagePNGRepresentation(_photo);
    [aCoder encodeObject:photoData forKey:kPhotoKey];
}

@end
