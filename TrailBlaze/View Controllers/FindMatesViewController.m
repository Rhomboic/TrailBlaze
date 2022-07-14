//
//  FindMatesViewController.m
//  TrailBlaze
//
//  Created by Adam Issah on 7/13/22.
//

#import "FindMatesViewController.h"
#import "MateCell.h"
#import "Parse/Parse.h"
#import "User.h"
#import "QueryManager.h"
#import "FriendRequest.h"

@interface FindMatesViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation FindMatesViewController {
    NSArray *users;
    NSMutableArray *filteredUsers;
    BOOL isFiltered;
    
    NSMutableArray *requested;
    
    QueryManager *queryManager1;
    QueryManager *queryManager2;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"Find Mates";
//    self.navigationController.navigationBar.prefersLargeTitles = YES;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.searchBar.delegate = self;
    queryManager1 = [[QueryManager alloc] init];
    queryManager2 = [[QueryManager alloc] init];
    requested = [[NSMutableArray alloc] init];
    isFiltered = false;
    
    [queryManager1 queryUsers:10 completion:^(NSArray * _Nonnull users, NSError * _Nonnull err) {
        if (users) {
            self->users = users;
            [self->queryManager2 queryRequests:10 completion:^(NSArray * _Nonnull myRequests, NSError * _Nonnull err) {
                if (myRequests) {
//                    [PFUser.currentUser fetchIfNeeded];
                    for (NSDictionary *obj in myRequests) {
                        if ([obj[@"requester"] isEqual:PFUser.currentUser.objectId]) {
                            [self->requested addObject:obj[@"receiver"]];
                            NSLog(@"💅🏼💅🏼💅🏼💅🏼💅🏼%@", obj[@"receiver"]);
                        }
                    }
                    [self.tableView reloadData];
                } else {
                    NSLog(@"Unable to get users %@", err.localizedDescription);
                }
            }];
            
        } else {
            NSLog(@"Unable to get users %@", err.localizedDescription);
        }
    }];
    
    
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MateCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MateCell" forIndexPath:indexPath];
    PFObject *thisUserObject;
    if (isFiltered) {
        thisUserObject = self->filteredUsers[indexPath.row];
    } else {
        thisUserObject = self->users[indexPath.row];
    }
    [thisUserObject fetchIfNeeded];
    cell.profileName.text = thisUserObject[@"username"];
    [cell.friendStatusIcon setImage:nil];
    
    for (NSString *st in requested) {
        NSLog(@"🐤🐤🐤🐤🐤🐤🐤🐤%@, %@", thisUserObject.objectId, st);
        if ([st isEqualToString:thisUserObject.objectId]) {
            [cell.friendStatusIcon setImage:[UIImage systemImageNamed:@"person.badge.clock.fill"]];
            goto found;
        }
        
    }
    found:
    if (cell.friendStatusIcon.image == nil) {
        [cell.friendStatusIcon setImage:[UIImage systemImageNamed:@"person.fill.badge.plus"]];
    }
//    if ([requested containsObject:((NSDictionary *)thisUserObject)[@"objectId"]]) {
//        [cell.friendStatusIcon setImage:[UIImage systemImageNamed:@"person.badge.clock.fill"]];
//    } else {
//        [cell.friendStatusIcon setImage:[UIImage systemImageNamed:@"person.fill.badge.plus"]];
//    }
    cell.layer.cornerRadius = 20;
    [cell.layer setBorderColor:[UIColor systemBackgroundColor].CGColor];
    [cell.layer setBorderWidth:5.0f];
    cell.clipsToBounds = true;
    cell.contentView.backgroundColor = UIColor.secondarySystemBackgroundColor;
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (isFiltered) {
        return self->filteredUsers.count;
    } else {
        return self->users.count;
    }
}

- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        isFiltered = false;
    } else {
        isFiltered = true;
        filteredUsers = [[NSMutableArray alloc] init];
        
        for (PFObject *user in users) {
//            User *thisUser = [[User alloc] initWithDictionary:user];
            NSRange nameRange = [user[@"username"] rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if (nameRange.location != NSNotFound) {
                [filteredUsers addObject:user];
            }
        }
    }
    [self.tableView reloadData];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *thisUser;
    if (isFiltered) {
        thisUser = filteredUsers[indexPath.row];
    } else {
        thisUser = users[indexPath.row];
    }
    [FriendRequest uploadRequest:[[PFUser currentUser] objectId] receiverID:[thisUser objectId] withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            NSLog(@"Request Confirmed to be sent");
        } else {
            NSLog(@"Could not send request");
        }
    }];
    MateCell *cell = (MateCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell.friendStatusIcon setImage:[UIImage systemImageNamed:@"person.badge.clock.fill"]];
    
}

@end
