//
//  FriendsCollectionViewController.m
//  iCloudTestApp
//
//  Created by Brian Miller on 9/24/13.
//  Copyright (c) 2013 Brian Miller. All rights reserved.
//

#import "CTEntry.h"
#import "CTDocument.h"
#import "CTMetadata.h"
#import "FriendsCollectionViewController.h"

@interface FriendsCollectionViewController ()
@property (strong) NSMutableArray *entries;
@property (strong) CTDocument *selectedDocument;
@property (strong) CTEntry *selectedEntry;
@property BOOL shouldStartEditing;
@property (strong) NSMetadataQuery *query;
@property (strong) NSMutableArray *iCloudURLs;
@property BOOL iCloudIsReady;
@property BOOL awaitingMoveLocalToiCloud;
@property BOOL awaitingCopyiCloudToLocal;
@end

@implementation FriendsCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    _iCloudURLs = [NSMutableArray array];
    _entries = [NSMutableArray array];
    [self reload];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [_query enableUpdates];
}

-(void)viewDidDisappear:(BOOL)animated {
    [_query disableUpdates];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)didBecomeActive:(NSNotification *)notification {
    [self reload];
}

-(void)reload {
    _iCloudIsReady = NO;
    [_iCloudURLs removeAllObjects];
    [_entries removeAllObjects];
    [self.collectionView reloadData];
    
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    
    if([AppDelegate iCloudIsAvailable]){
        if(![self iCloudOn] && ![self promptedForiCloud]){
            [self setPromptedForiCloud:YES];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"iCloud is available" message:@"Would you like to store you documents in the cloud to keep them up-to-date across all of your devices?" delegate:self cancelButtonTitle:@"Not Now" otherButtonTitles:@"Yes", nil];
            [alert setTag:2];
            [alert show];
        }
        
        //move files if newly switched on or off
        if([self iCloudOn] && ![self iCloudWasOn]){
            [self moveLocalToiCloud];
        } else if(![self iCloudOn] && [self iCloudWasOn]){
            [self copyiCloudToLocal];
        }
        
        [self queryiCloud];
        
        [self setiCloudWasOn:[self iCloudOn]];
    } else {
        [self setPromptedForiCloud:NO];
        
        if([self iCloudWasOn]){
            [[[UIAlertView alloc] initWithTitle:@"iCloud Not Available" message:@"You are currently unable to connect to iCloud so updates to your documents will not take place until you are connected to iCloud again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        
        [self setiCloudOn:NO];
        [self setiCloudWasOn:NO];
    }
    
    if(![self iCloudOn])
        [self loadLocal];
}

#pragma mark - UICollectionViewDatasource Methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_entries count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"called for %@",indexPath);
    EntryCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"EntryCollectionViewCell" forIndexPath:indexPath];
    
    CTEntry *entry = _entries[indexPath.row];
    [cell configureCellForEntry:entry withDelegate:self];
    
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout Methods
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CTEntry *entry = _entries[indexPath.row];
    
    _selectedDocument = [[CTDocument alloc] initWithFileURL:[entry fileURL]];
    _shouldStartEditing = NO;
    [_selectedDocument openWithCompletionHandler:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"ToFriendDetails" sender:nil];
        });
    }];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"ToFriendDetails"]){
        [[segue destinationViewController] setDelegate:self];
        [[segue destinationViewController] setDocument:_selectedDocument];
        [[segue destinationViewController] setShouldStartEditing:_shouldStartEditing];
    }
}

#pragma mark - EntryCollectionViewCellDelegate Methods
-(void)entryCollectionViewCell:(EntryCollectionViewCell *)cell longPressedForEntry:(CTEntry *)entry {
    _selectedEntry = entry;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Entry" message:[NSString stringWithFormat:@"Are you sure you want to delete the entry for %@",[[entry metadata] displayName]] delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",nil];
    [alert setTag:1];
    [alert show];
}

#pragma mark - UIAlertViewDelegate Methods
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView.tag == 1){
        if(buttonIndex == alertView.firstOtherButtonIndex)
            [self deleteEntry:_selectedEntry];
        
        _selectedEntry = nil;
    } else if(alertView.tag == 2){
        if(buttonIndex == alertView.firstOtherButtonIndex){
            [self setiCloudOn:YES];
            [self reload];
        }
    } else if(alertView.tag == 3){
        if(buttonIndex == alertView.cancelButtonIndex){
            [self setiCloudOn:YES];
            [self reload];
        } else if(buttonIndex == alertView.firstOtherButtonIndex){
            _awaitingCopyiCloudToLocal = YES;
            if(_iCloudIsReady){
                [self copyiCloudToLocal];
            }
        }
    }
}

#pragma mark - Data Methods
-(void)deleteEntry:(CTEntry *)entry {
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    [fileManager removeItemAtURL:[entry fileURL] error:nil];

    [self removeEntryWithURL:[entry fileURL]];
}

-(void)removeEntryWithURL:(NSURL *)fileURL {
    NSInteger index = [self indexOfEntryWithFileURL:fileURL];
    
    [_entries removeObjectAtIndex:index];
    [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
}

-(void)loadLocal {
    NSArray *localDocuments = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[AppDelegate applicationDocumentsDirectory] includingPropertiesForKeys:nil options:0 error:nil];
    
    [localDocuments enumerateObjectsUsingBlock:^(NSURL *fileURL, NSUInteger idx, BOOL *stop) {
        if([[fileURL pathExtension] isEqualToString:CT_EXTENSION]){
            [self loadDocumentAtFileURL:fileURL];
        }
    }];
    
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
}

-(void)loadDocumentAtFileURL:(NSURL *)fileURL {
    CTDocument *document = [[CTDocument alloc] initWithFileURL:fileURL];
    [document openWithCompletionHandler:^(BOOL success) {
        if(!success){
            NSLog(@"Unable to open document at %@",fileURL);
            return;
        }
        
        CTMetadata *metadata = [document metadata];
        NSURL *fileURL = [document fileURL];
        UIDocumentState state = [document documentState];
        NSFileVersion *version = [NSFileVersion currentVersionOfItemAtURL:fileURL];
        NSLog(@"Loaded file %@",[document fileURL]);
        
        [document closeWithCompletionHandler:^(BOOL success) {
            if(!success){
                NSLog(@"There was an error closing the document at %@",fileURL);
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self addOrUpdateEntryWithURL:fileURL metadata:metadata state:state version:version];
            });
        }];
    }];
}

-(void)addOrUpdateEntryWithURL:(NSURL *)fileURL metadata:(CTMetadata *)metadata state:(UIDocumentState)state version:(NSFileVersion *)version {
    NSInteger index = [self indexOfEntryWithFileURL:fileURL];
    
    if(index == NSNotFound){
        CTEntry *entry = [[CTEntry alloc] initWithFileURL:fileURL metadata:metadata state:state andVersion:version];
        
        [_entries addObject:entry];
        [_entries sortUsingComparator:^NSComparisonResult(CTEntry *entry1, CTEntry *entry2) {
            NSComparisonResult result = [[[entry1 metadata] displayName] compare:[[entry2 metadata] displayName]];
            NSLog(@"results is %d",result);
            return result;
        }];
        
        index = [self indexOfEntryWithFileURL:fileURL];
        [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
    } else {
        CTEntry *entry = [_entries objectAtIndex:index];
        [entry setMetadata:metadata];
        [entry setState:state];
        [entry setVersion:version];
        
        [_entries sortUsingComparator:^NSComparisonResult(CTEntry *entry1, CTEntry *entry2) {
            NSComparisonResult result = [[[entry1 metadata] displayName] compare:[[entry2 metadata] displayName]];
            NSLog(@"results is %d",result);
            return result;
        }];
        
        NSInteger newIndex = [self indexOfEntryWithFileURL:fileURL];
        if(index != newIndex){
            [self.collectionView moveItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] toIndexPath:[NSIndexPath indexPathForRow:newIndex inSection:0]];
        }
        [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:newIndex inSection:0]]];
    }
}

-(NSInteger)indexOfEntryWithFileURL:(NSURL *)fileURL {
    __block NSInteger index = NSNotFound;
    [_entries enumerateObjectsUsingBlock:^(CTEntry *entry, NSUInteger idx, BOOL *stop) {
        if([[entry fileURL] isEqual:fileURL]){
            index = idx;
            *stop = YES;
        }
    }];
    
    return index;
}

-(NSURL *)getDocumentURL:(NSString *)filename {
    return [[AppDelegate applicationDocumentsDirectory] URLByAppendingPathComponent:filename isDirectory:NO];
}

-(NSString *)getDocumentFilename:(NSString *)filename forLocal:(BOOL)isLocal {
    NSInteger docCount = 0;
    NSString *newDocName = nil;
    
    BOOL done = NO;
    BOOL first = YES;
    while(!done){
        if(first){
            first = NO;
            newDocName = [NSString stringWithFormat:@"%@.%@",filename,CT_EXTENSION];
        } else {
            newDocName = [NSString stringWithFormat:@"%@_%d.%@",filename,docCount,CT_EXTENSION];
        }
        
        BOOL nameExists = NO;
        if(isLocal){
            nameExists = [self documentNameExistsInObjects:newDocName];
        } else {
            nameExists = [self documentNameExistsIniCloudURLs:newDocName];
        }
        
        if(!nameExists){
            break;
        } else {
            docCount++;
        }
    }
    
    return newDocName;
}

-(BOOL)documentNameExistsInObjects:(NSString *)documentName {
    __block BOOL nameExists = NO;
    [_entries enumerateObjectsUsingBlock:^(CTEntry *entry, NSUInteger idx, BOOL *stop) {
        if([[[entry fileURL] lastPathComponent] isEqualToString:documentName]){
            nameExists = YES;
            *stop = YES;
        }
    }];
    
    return nameExists;
}

-(BOOL)documentNameExistsIniCloudURLs:(NSString *)documentName {
    __block BOOL nameExists = NO;
    [_iCloudURLs enumerateObjectsUsingBlock:^(NSURL *fileURL, NSUInteger idx, BOOL *stop) {
        if([[fileURL lastPathComponent] isEqualToString:documentName]){
            nameExists = YES;
            *stop = YES;
        }
    }];
    
    return nameExists;
}

#pragma mark - Button Methods
-(IBAction)btnAddPressed:(id)sender {
    NSURL *fileURL = [self getDocumentURL:[self getDocumentFilename:@"Friend" forLocal:YES]];
    
    CTDocument *document = [[CTDocument alloc] initWithFileURL:fileURL];
    _shouldStartEditing = YES;
    [document saveToURL:[document fileURL] forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
        if(!success)
            NSLog(@"There was an error saving the document - %@",fileURL);
        
        NSLog(@"File created at %@", fileURL);
        
        CTMetadata *metadata = [document metadata];
        NSURL *fileURL = [document fileURL];
        UIDocumentState state = [document documentState];
        NSFileVersion *version = [NSFileVersion currentVersionOfItemAtURL:fileURL];
        
        _selectedDocument = document;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addOrUpdateEntryWithURL:fileURL metadata:metadata state:state version:version];
            [self performSegueWithIdentifier:@"ToFriendDetails" sender:nil];
        });
    }];
}

#pragma mark - FriendDetailViewControllerDelegate Methods
-(void)detailViewControllerDidClose:(FriendDetailViewController *)detailViewController {
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    NSFileVersion *version = [NSFileVersion currentVersionOfItemAtURL:[detailViewController.document fileURL]];
    [self addOrUpdateEntryWithURL:[detailViewController.document fileURL] metadata:[detailViewController.document metadata] state:[detailViewController.document documentState] version:version];
}

#pragma mark - Helpers
-(BOOL)iCloudOn {
    return [[NSUserDefaults standardUserDefaults] boolForKey:CTiCloudOn];
}

-(void)setiCloudOn:(BOOL)on {
    [[NSUserDefaults standardUserDefaults] setBool:on forKey:CTiCloudOn];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(BOOL)iCloudWasOn {
    return [[NSUserDefaults standardUserDefaults] boolForKey:CTiCloudWasOn];
}

-(void)setiCloudWasOn:(BOOL)on {
    [[NSUserDefaults standardUserDefaults] setBool:on forKey:CTiCloudWasOn];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(BOOL)promptedForiCloud {
    return [[NSUserDefaults standardUserDefaults] boolForKey:CTPromptedForiCloud];
}

-(void)setPromptedForiCloud:(BOOL)prompted {
    [[NSUserDefaults standardUserDefaults] setBool:prompted forKey:CTPromptedForiCloud];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - iCloud Methods
-(NSMetadataQuery *)documentQuery {
    NSMetadataQuery *query = [[NSMetadataQuery alloc] init];
    if(query){
        [query setSearchScopes:@[NSMetadataQueryUbiquitousDocumentsScope]];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K LIKE %@",NSMetadataItemFSNameKey,[NSString stringWithFormat:@"*.%@",CT_EXTENSION]];
        [query setPredicate:predicate];
    }
    
    return query;
}

-(void)queryiCloud {
    [self stopiCloudQuery];
    _query = [self documentQuery];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processiCloudFiles:) name:NSMetadataQueryDidFinishGatheringNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processiCloudFiles:) name:NSMetadataQueryDidUpdateNotification object:nil];
    [_query startQuery];
}

-(void)stopiCloudQuery {
    if(_query){
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSMetadataQueryDidFinishGatheringNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSMetadataQueryDidUpdateNotification object:nil];
        [_query stopQuery];
        _query = nil;
    }
}

-(void)processiCloudFiles:(NSNotification *)notification {
    [_query disableUpdates];
    
    [_iCloudURLs removeAllObjects];
    
    [[_query results] enumerateObjectsUsingBlock:^(NSMetadataItem *item, NSUInteger idx, BOOL *stop) {
        NSURL *fileURL = [item valueForAttribute:NSMetadataItemURLKey];
        NSNumber *aBool = nil;
        
        [fileURL getResourceValue:&aBool forKey:NSURLIsHiddenKey error:nil];
        if(aBool && ![aBool boolValue]){
            [_iCloudURLs addObject:fileURL];
        }
    }];
    
    NSLog(@"Found %i files in iCloud",[_iCloudURLs count]);
    _iCloudIsReady = YES;
    
    if([self iCloudOn]){
        for(NSInteger i = [_entries count] - 1; i >= 0; i--){
            CTEntry *entry = _entries[i];
            if(![_iCloudURLs containsObject:[entry fileURL]]){
                [self removeEntryWithURL:[entry fileURL]];
            }
        }
        
        [_iCloudURLs enumerateObjectsUsingBlock:^(NSURL *fileURL, NSUInteger idx, BOOL *stop) {
            [self loadDocumentAtFileURL:fileURL];
        }];
        
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    }
    
    [_query enableUpdates];
    
    if(_awaitingMoveLocalToiCloud) {
        _awaitingMoveLocalToiCloud = NO;
        [self moveLocalToiCloud];
    } else if(_awaitingCopyiCloudToLocal){
        [self copyiCloudToLocal];
    }
}

-(void)moveLocalToiCloud {
    if(_iCloudIsReady && !_awaitingMoveLocalToiCloud){
        NSArray *localDocuments = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[AppDelegate applicationDocumentsDirectory] includingPropertiesForKeys:nil options:0 error:nil];
        [localDocuments enumerateObjectsUsingBlock:^(NSURL *fileURL, NSUInteger idx, BOOL *stop) {
            if([[fileURL pathExtension] isEqualToString:CT_EXTENSION]){
                NSString *fileName = [[fileURL lastPathComponent] stringByDeletingPathExtension];
                NSURL *destinationURL = [self getDocumentURL:[self getDocumentFilename:fileName forLocal:NO]];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSError *error = nil;
                    BOOL success = [[NSFileManager defaultManager] setUbiquitous:[self iCloudOn] itemAtURL:fileURL destinationURL:destinationURL error:&error];
                    if(success){
                        NSLog(@"Moved %@ to %@",fileURL,destinationURL);
                        [self loadDocumentAtFileURL:destinationURL];
                    } else {
                        NSLog(@"Error Moving %@ to %@ - %@",fileURL,destinationURL,error.localizedDescription);
                    }
                });
            }
        }];
    } else {
        _awaitingMoveLocalToiCloud = YES;
    }
}

-(void)copyiCloudToLocal {
    if(_iCloudIsReady && _awaitingCopyiCloudToLocal){
        _awaitingCopyiCloudToLocal = NO;
        
        [_iCloudURLs enumerateObjectsUsingBlock:^(NSURL *fileURL, NSUInteger idx, BOOL *stop) {
            NSString *fileName = [[fileURL lastPathComponent] stringByDeletingPathExtension];
            NSURL *destinationURL = [self getDocumentURL:[self getDocumentFilename:fileName forLocal:YES]];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
                [fileCoordinator coordinateReadingItemAtURL:fileURL options:NSFileCoordinatorReadingWithoutChanges error:nil byAccessor:^(NSURL *newURL) {
                    NSFileManager *fileManager = [[NSFileManager alloc] init];
                    NSError *error = nil;
                    
                    BOOL success = [fileManager copyItemAtURL:fileURL toURL:destinationURL error:&error];
                    if(success){
                        NSLog(@"Copied %@ to %@",fileURL,destinationURL);
                        [self loadDocumentAtFileURL:destinationURL];
                    } else {
                        NSLog(@"Error Copying %@ to %@ - %@",fileURL,destinationURL,error.localizedDescription);
                    }
                }];
            });
        }];
    } else {
        if(!_awaitingCopyiCloudToLocal){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Turning iCloud Off" message:@"What would you like to do with the documents currently on iCloud?" delegate:self cancelButtonTitle:@"Keep Using iCloud" otherButtonTitles:@"Keep a local copy",@"Keep only on iCloud", nil];
            [alert setTag:3];
            [alert show];
        }
    }
}

@end
