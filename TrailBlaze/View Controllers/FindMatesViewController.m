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

@interface FindMatesViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation FindMatesViewController {
    NSArray *users;
    NSMutableArray *filteredUsers;
    BOOL isFiltered;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"Find Mates";
//    self.navigationController.navigationBar.prefersLargeTitles = YES;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.searchBar.delegate = self;
    isFiltered = false;
    
    [[[QueryManager alloc] init] queryUsers:10 completion:^(NSArray * _Nonnull users, NSError * _Nonnull err) {
        if (users) {
            self->users = users;
            [self.tableView reloadData];
        } else {
            NSLog(@"Unable to get users %@", err.localizedDescription);
        }
    }];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MateCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MateCell" forIndexPath:indexPath];
    User *thisUserObject;
    if (isFiltered) {
        thisUserObject = [[User alloc] initWithDictionary: self->filteredUsers[indexPath.row]];
    } else {
        thisUserObject = [[User alloc] initWithDictionary: self->users[indexPath.row]];
    }
    
    cell.profileName.text = thisUserObject.username;
    
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

@end
