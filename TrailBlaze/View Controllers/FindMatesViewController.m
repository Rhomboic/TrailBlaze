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
#import "UIImageView+AFNetworking.h"

@interface FindMatesViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) UIRefreshControl *refreshControl;


@end

@implementation FindMatesViewController {
    NSArray *users;
    NSMutableArray *filteredUsers;
    BOOL isFiltered;
    
    NSMutableArray *requested;
    NSMutableArray *received;

    
    QueryManager *userQueryManager;
    QueryManager *friendRequestQueryManager;
    QueryManager *friendReceivesQueryManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"Find Mates";
    self.navigationController.navigationBar.prefersLargeTitles = NO;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchUsers) forControlEvents:(UIControlEventValueChanged)];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    self.searchBar.delegate = self;
    
    userQueryManager = [[QueryManager alloc] init];
    friendRequestQueryManager = [[QueryManager alloc] init];
    friendReceivesQueryManager = [[QueryManager alloc] init];
    
    requested = [[NSMutableArray alloc] init];
    received = [[NSMutableArray alloc] init];
    
    isFiltered = false;
    
    [self fetchUsers];

    
}

- (void) fetchUsers {
    [userQueryManager queryUsers:10 completion:^(NSArray * _Nonnull users, NSError * _Nonnull err) {
        if (users) {
            
            self->users = users;
            
            [self->friendRequestQueryManager queryRequests:10 completion:^(NSArray * _Nonnull myRequests, NSError * _Nonnull err) {
                if (myRequests) {
                    
                    for (NSDictionary *obj in myRequests) {
                        [self->requested addObject:obj[@"receiver"]];
                    }
                    
                    [self->friendReceivesQueryManager queryReceives:10 completion:^(NSArray * _Nonnull myReceives, NSError * _Nonnull err) {
                        if (myReceives) {
                            
                            for (NSDictionary *obj in myReceives) {
                                [self->received addObject:obj[@"requester"]];
                            }
                            
                            for (NSString *personID in self->requested) {
                                if ([self->received containsObject:personID]) {
                                    [[PFUser currentUser] addObject:personID forKey:@"friends"];
                                    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                        if (succeeded) {
                                            NSLog(@"friend added successfully!");
                                        } else {
                                            NSLog(@"%@", error.localizedDescription);
                                        }
                                    }];
                                }
                            }
                            [self.tableView reloadData];
                            [self.refreshControl endRefreshing];
                        } else {
                            NSLog(@"Unable to get users %@", err.localizedDescription);
                        }
                    }];
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
    PFFileObject *image = [thisUserObject objectForKey:@"profileImage"];
    
    NSLog(@"%@",image.url);
    if (image) {
    [cell.profileImage setImageWithURL:[NSURL URLWithString:[image url]]];
    } else {
        [cell.profileImage setImage: [UIImage systemImageNamed:@"person.crop.circle"]];
    }
    cell.profileImage.layer.cornerRadius = 30;
    cell.profileImage.clipsToBounds = true;
    
    [cell.friendStatusIcon setImage:nil];
    [cell.friendStatusIcon setTintColor:UIColor.systemBlueColor];
    
    
    for (NSString *st in received) {
        NSLog(@"🐤🐤🐤🐤🐤🐤🐤🐤%@, %@", thisUserObject.objectId, st);
        if ([st isEqualToString:thisUserObject.objectId]) {
            [cell.friendStatusIcon setImage:[UIImage systemImageNamed:@"person.fill.questionmark"]];
            [cell.friendStatusIcon setTintColor:UIColor.darkGrayColor];
        }
        
    }
    for (NSString *st in requested) {
        if ([st isEqualToString:thisUserObject.objectId]) {
            [cell.friendStatusIcon setImage:[UIImage systemImageNamed:@"person.badge.clock.fill"]];
            [cell.friendStatusIcon setTintColor:UIColor.darkGrayColor];
        }
        
    }
    
    [[PFUser currentUser] fetchIfNeeded];
    for (NSString *st in [PFUser currentUser][@"friends"]) {
        if ([st isEqual:thisUserObject.objectId]) {
            [cell.friendStatusIcon setImage:[UIImage systemImageNamed:@"person.fill.checkmark"]];
            [cell.friendStatusIcon setTintColor:UIColor.systemGreenColor];
        }
        
    }
    
    if (cell.friendStatusIcon.image == nil) {
        [cell.friendStatusIcon setImage:[UIImage systemImageNamed:@"person.fill.badge.plus"]];
    }
    
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
    [cell.friendStatusIcon setTintColor:UIColor.darkGrayColor];
    
}

@end
