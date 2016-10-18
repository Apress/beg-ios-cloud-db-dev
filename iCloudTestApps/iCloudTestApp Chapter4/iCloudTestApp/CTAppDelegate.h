//
//  CTAppDelegate.h
//  iCloudTestApp
//
//  Created by Brian Miller on 9/19/13.
//  Copyright (c) 2013 Brian Miller. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CTAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void)updateKeyValueStoreKey:(NSString *)key withObject:(id)object;
- (void)syncKVSStore;

@end
