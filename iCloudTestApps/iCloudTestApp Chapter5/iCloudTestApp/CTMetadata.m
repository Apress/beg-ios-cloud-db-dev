//
//  CTMetadata.m
//  iCloudTestApp
//
//  Created by Brian Miller on 9/24/13.
//  Copyright (c) 2013 Brian Miller. All rights reserved.
//

#import "CTMetadata.h"

#define kVersionKey @"VERSION"
#define kThumbnailKey @"THUMBNAIL"
#define kDisplayNameKey @"DISPLAY_NAME"

@implementation CTMetadata

- (id)initWithThumbnail:(UIImage *)thumbnail andDisplayName:(NSString *)displayName{
    if((self = [super init])){
        _thumbnail = thumbnail;
        _displayName = displayName;
    }
    
    return self;
}

- (id)init {
    return [self initWithThumbnail:nil andDisplayName:nil];
}

#pragma mark - NSCoding Methods
- (id)initWithCoder:(NSCoder *)aDecoder {
    NSInteger version = [aDecoder decodeIntForKey:kVersionKey];
    
    if(version == 1){
        NSData *thumbnailData = [aDecoder decodeObjectForKey:kThumbnailKey];
        UIImage *thumbnail = [UIImage imageWithData:thumbnailData];
        NSString *displayName = [aDecoder decodeObjectForKey:kDisplayNameKey];
        
        return [self initWithThumbnail:thumbnail andDisplayName:displayName];
    } else {
        return [self init];
    }
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInt:1 forKey:kVersionKey];
    NSData *thumbnailData = UIImagePNGRepresentation(_thumbnail);
    [aCoder encodeObject:thumbnailData forKey:kThumbnailKey];
    [aCoder encodeObject:_displayName forKey:kDisplayNameKey];
}
@end
