//
//  CTAppDelegate.m
//  iCloudTestApp
//
//  Created by Brian Miller on 9/19/13.
//  Copyright (c) 2013 Brian Miller. All rights reserved.
//

#import "CTAppDelegate.h"

#import "MainViewController.h"

@implementation CTAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if(![self hasDefaults])
        [self createDefaults];
    
    
//    [self initializeiCloudAccessWithCompletionHandler:^(BOOL isAvailable) {
//        _iCloudIsAvailable = isAvailable;
//    }];
    
    //register for Key-Value Store Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storeDidChange:) name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification object:[NSUbiquitousKeyValueStore defaultStore]];
    
    [self syncKVSStore];
    
    // Override point for customization after application launch.
//    MainViewController *controller = (MainViewController *)self.window.rootViewController;
//    controller.managedObjectContext = self.managedObjectContext;
    return YES;
}

-(void)initializeiCloudAccessWithCompletionHandler:(void(^)(BOOL isAvailable)) completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _iCloudURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
        if(_iCloudURL != nil){
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"iCloud is available - %@",_iCloudURL);
                completion(TRUE);
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"iCloud is not available");
                completion(FALSE);
            });
        }
    });
}

- (BOOL)hasDefaults {
    BOOL hasDefaults = YES;

    if([[NSUserDefaults standardUserDefaults] stringForKey:CTDisplayName] == nil)
        hasDefaults = NO;
    else if([[NSUserDefaults standardUserDefaults] stringForKey:CTFavoriteNumber] == nil)
        hasDefaults = NO;
    
    return hasDefaults;
}

- (void)createDefaults {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = @{CTDisplayName:@"John Doe",CTFavoriteNumber:@1};
    [userDefaults registerDefaults:appDefaults];
}

- (void)updateKeyValueStoreKey:(NSString *)key withObject:(id)object {
    NSUbiquitousKeyValueStore *kvStore = [NSUbiquitousKeyValueStore defaultStore];
    [kvStore setObject:object forKey:key];
}

- (void)syncKVSStore {
    [[NSUbiquitousKeyValueStore defaultStore] synchronize];
}

- (void)storeDidChange:(NSNotification *)notification {
    // Get the list of keys that did change
    NSDictionary *userInfo = [notification userInfo];
    NSNumber *reasongForChange = [userInfo objectForKey:NSUbiquitousKeyValueStoreChangeReasonKey];
    NSInteger reason = -1;
    
    //If a reason could not be determined we shouldn't update anything
    if(!reasongForChange)
        return;
    
    //Update only for changes from the server
    reason = [reasongForChange integerValue];
    if(reason == NSUbiquitousKeyValueStoreServerChange || reason == NSUbiquitousKeyValueStoreInitialSyncChange){
        NSArray *changedKeys = [userInfo objectForKey:NSUbiquitousKeyValueStoreChangedKeysKey];
        NSUbiquitousKeyValueStore *kvStore = [NSUbiquitousKeyValueStore defaultStore];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        [changedKeys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
            id value = [kvStore objectForKey:key];
            [userDefaults setObject:value forKey:key];
        }];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:UIShouldRefresh object:nil];
    }
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self initializeiCloudAccessWithCompletionHandler:^(BOOL isAvailable) {
        _iCloudIsAvailable = isAvailable;
    }];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"iCloudTestApp" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"iCloudTestApp.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
