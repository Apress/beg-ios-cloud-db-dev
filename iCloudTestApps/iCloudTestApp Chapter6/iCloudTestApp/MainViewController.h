//
//  MainViewController.h
//  iCloudTestApp
//
//  Created by Brian Miller on 9/19/13.
//  Copyright (c) 2013 Brian Miller. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface MainViewController : UIViewController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
