//
//  CTEntry.h
//  iCloudTestApp
//
//  Created by Brian Miller on 9/24/13.
//  Copyright (c) 2013 Brian Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CTMetadata;

@interface CTEntry : NSObject

@property (strong) NSURL *fileURL;
@property (strong) CTMetadata *metadata;
@property (assign) UIDocumentState state;
@property (strong) NSFileVersion *version;

-(id)initWithFileURL:(NSURL *)fileURL metadata:(CTMetadata *)metadata state:(UIDocumentState)state andVersion:(NSFileVersion *)version;

@end
