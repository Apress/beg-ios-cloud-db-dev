//
//  CTEntry.m
//  iCloudTestApp
//
//  Created by Brian Miller on 9/24/13.
//  Copyright (c) 2013 Brian Miller. All rights reserved.
//

#import "CTEntry.h"

@implementation CTEntry

-(id)initWithFileURL:(NSURL *)fileURL metadata:(CTMetadata *)metadata state:(UIDocumentState)state andVersion:(NSFileVersion *)version {
    if((self = [super init])){
        _fileURL = fileURL;
        _metadata = metadata;
        _state = state;
        _version = version;
    }
    
    return self;
}

@end
