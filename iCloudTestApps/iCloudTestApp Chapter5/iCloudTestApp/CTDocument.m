//
//  CTDocument.m
//  iCloudTestApp
//
//  Created by Brian Miller on 9/24/13.
//  Copyright (c) 2013 Brian Miller. All rights reserved.
//

#import "UIImage+Resize.h"
#import "CTData.h"
#import "CTMetadata.h"
#import "CTDocument.h"

#define kDataKey @"ctdocument.data"
#define kMetadataKey @"ctdocument.metadata"

@interface CTDocument()
@property (strong, nonatomic) CTData *data;
@property (strong, nonatomic) NSFileWrapper *fileWrapper;
@end

@implementation CTDocument

#pragma mark - Document Writing Methods
- (id)contentsForType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    if(self.metadata == nil || self.data == nil)
        return nil;
    
    NSMutableDictionary *wrappers = [NSMutableDictionary dictionary];
    [self encodeObject:_data toWrappers:wrappers withKey:kDataKey];
    [self encodeObject:_metadata toWrappers:wrappers withKey:kMetadataKey];
    
    NSFileWrapper *fileWrapper = [[NSFileWrapper alloc] initDirectoryWithFileWrappers:wrappers];
    
    return fileWrapper;
}

- (void)encodeObject:(id<NSCoding>)object toWrappers:(NSMutableDictionary *)wrappers withKey:(NSString *)key {
    @autoreleasepool {
        NSMutableData *data = [NSMutableData data];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        [archiver encodeObject:object forKey:@"DATA"];
        [archiver finishEncoding];
        
        NSFileWrapper *wrapper = [[NSFileWrapper alloc] initRegularFileWithContents:data];
        [wrappers setObject:wrapper forKey:key];
    }
}

#pragma mark - Document Reading Methods
-(BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    _fileWrapper = (NSFileWrapper *)contents;
    
    _data = nil;
    _metadata = nil;
    
    return YES;
}

- (id)decodeObjectFromWrapperWithKey:(NSString *)key {
    NSFileWrapper *fileWrapper = [_fileWrapper.fileWrappers objectForKey:key];
    if(!fileWrapper)
        return nil;
    
    NSData *data = [fileWrapper regularFileContents];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    
    return [unarchiver decodeObjectForKey:@"DATA"];
}

#pragma mark - Property Accessors
-(CTData *)data {
    if(_data == nil){
        if(_fileWrapper != nil)
            _data = [self decodeObjectFromWrapperWithKey:kDataKey];
        else
            _data = [[CTData alloc] init];
    }
    
    return _data;
}

-(CTMetadata *)metadata {
    if(_metadata == nil){
        if(_fileWrapper != nil)
            _metadata = [self decodeObjectFromWrapperWithKey:kMetadataKey];
        else
            _metadata = [[CTMetadata alloc] init];
    }
    
    return _metadata;
}

-(NSString *)firstName {
    return [self.data firstName];
}

-(void)setFirstName:(NSString *)firstName {
    if([[self.data firstName] isEqualToString:firstName])
        return;
    
    NSString *oldFirstName = [self.data firstName];
    [self.data setFirstName:firstName];
    
    [self.undoManager setActionName:@"First Name Change"];
    [self.undoManager registerUndoWithTarget:self selector:@selector(setFirstName:) object:oldFirstName];
}

-(NSString *)lastName {
    return [self.data lastName];
}

-(void)setLastName:(NSString *)lastName {
    if([[self.data lastName] isEqualToString:lastName])
        return;
    
    NSString *oldLastName = [self.data lastName];
    [self.data setLastName:lastName];
    
    [self.undoManager setActionName:@"Last Name Change"];
    [self.undoManager registerUndoWithTarget:self selector:@selector(setLastName:) object:oldLastName];
}

-(NSString *)displayName {
    return [self.data displayName];
}

-(void)setDisplayName:(NSString *)displayName {
    if([[self.data displayName] isEqualToString:displayName])
        return;
    
    NSString *oldDisplayName = [self.data displayName];
    [self.data setDisplayName:displayName];
    [self.metadata setDisplayName:displayName];
    
    [self.undoManager setActionName:@"Display Name Change"];
    [self.undoManager registerUndoWithTarget:self selector:@selector(setDisplayName:) object:oldDisplayName];
}

-(NSNumber *)favoriteNumber {
    return [self.data favoriteNumber];
}

-(void)setFavoriteNumber:(NSNumber *)favoriteNumber {
    if([[self.data favoriteNumber] isEqualToNumber:favoriteNumber])
        return;
    
    NSNumber *oldFavoriteNumber = [self.data favoriteNumber];
    [self.data setFavoriteNumber:favoriteNumber];
    
    [self.undoManager setActionName:@"Favorite Number Change"];
    [self.undoManager registerUndoWithTarget:self selector:@selector(setFavoriteNumber:) object:oldFavoriteNumber];
}

-(UIImage *)photo {
    return [self.data photo];
}

-(void)setPhoto:(UIImage *)photo {
    if([[self.data photo] isEqual:photo])
        return;
    
    UIImage *oldPhoto = [self.data photo];
    [self.data setPhoto:photo];
    [self.metadata setThumbnail:[photo resizedImage:CGSizeMake(280, 280) interpolationQuality:kCGInterpolationHigh]];
    
    [self.undoManager setActionName:@"Photo Change"];
    [self.undoManager registerUndoWithTarget:self selector:@selector(setPhoto:) object:oldPhoto];
}

-(NSString *)description {
    return [[self.fileURL lastPathComponent] stringByDeletingPathExtension];
}


@end
