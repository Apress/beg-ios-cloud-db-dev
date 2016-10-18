//
//  CloseFriendsTableViewController.m
//  iCloudTestApp
//
//  Created by Brian Miller on 12/7/13.
//  Copyright (c) 2013 Brian Miller. All rights reserved.
//

#import "CloseFriendsTableViewController.h"
#import "CloseFriend.h"

@interface CloseFriendsTableViewController ()
@property (strong) NSArray *closeFriends;
@property (strong) CloseFriend *selectedFriend;
@property BOOL shouldStartEditing;
@end

@implementation CloseFriendsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self loadCloseFriends];
}

-(void)loadCloseFriends {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CloseFriend" inManagedObjectContext:[AppDelegate managedObjectContext]];
    [request setEntity:entity];
    
    [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES]]];
    
    NSError *error = nil;
    NSArray *results = [[AppDelegate managedObjectContext] executeFetchRequest:request error:&error];
    if(error == nil){
        _closeFriends = results;
    } else {
        NSLog(@"There was an error getting data - %@",error.localizedDescription);
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_closeFriends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CloseFriendCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [self configureCloseFriendCell:cell withFriend:_closeFriends[indexPath.row]];
    
    return cell;
}

-(void)configureCloseFriendCell:(UITableViewCell *)cell withFriend:(CloseFriend *)closeFriend {
    static NSDateFormatter *dateFormat = nil;
    if (nil == dateFormat) {
        dateFormat = [[NSDateFormatter alloc] init]; // NOT NSDateFormatter *dateFormat = ...
        [dateFormat setDateStyle:NSDateFormatterShortStyle];
    }
    
    NSMutableString *name = [NSMutableString stringWithString:@""];
    NSString *birthday = @"";
    
    if(![[closeFriend firstName] isEqualToString:@""])
        [name appendString:[NSString stringWithFormat:@"%@ ",[closeFriend firstName]]];
    if(![[closeFriend lastName] isEqualToString:@""])
        [name appendString:[closeFriend lastName]];
    
    if([name isEqualToString:@""])
        [name appendString:@"Undefined"];
    
    cell.textLabel.text = name;
    
    if([closeFriend birthday] != nil)
        birthday = [dateFormat stringFromDate:[closeFriend birthday]];
    
    cell.detailTextLabel.text = birthday;
    
    if([closeFriend image] != nil)
        cell.imageView.image = [UIImage imageWithData:[closeFriend image]];
    else
        cell.imageView.image = nil;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self removeCloseFriend:_closeFriends[indexPath.row]];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

-(void)removeCloseFriend:(CloseFriend *)closeFriend {
    NSMutableArray *closeFriends = _closeFriends.mutableCopy;
    [closeFriends removeObject:closeFriend];
    
    _closeFriends = closeFriends;
    
    [[AppDelegate managedObjectContext] deleteObject:closeFriend];
    NSError *error = nil;
    if(![[AppDelegate managedObjectContext] save:&error]){
        NSLog(@"There was an error deleting data - %@",error.localizedDescription);
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _selectedFriend = _closeFriends[indexPath.row];
    _shouldStartEditing = NO;
    [self performSegueWithIdentifier:@"ToCloseFriendDetails" sender:nil];
}

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

#pragma mark - Button Methods
-(IBAction)btnAddPressed:(id)sender {
    
    CloseFriend *closeFriend = [NSEntityDescription insertNewObjectForEntityForName:@"CloseFriend" inManagedObjectContext:[AppDelegate managedObjectContext]];
    _selectedFriend = closeFriend;
    _shouldStartEditing = YES;
    
    [self loadCloseFriends];
    [self performSegueWithIdentifier:@"ToCloseFriendDetails" sender:nil];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"ToCloseFriendDetails"]){
        [[segue destinationViewController] setDelegate:self];
        [[segue destinationViewController] setCloseFriend:_selectedFriend];
        [[segue destinationViewController] setShouldStartEditing:_shouldStartEditing];
    }
}

#pragma mark - CloseFriendDetailViewControllerDelegate Methods
-(void)detailViewControllerDidClose:(CloseFriendDetailViewController *)detailViewController {
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    [self.tableView reloadData];
}

@end
