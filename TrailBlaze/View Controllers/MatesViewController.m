//
//  MatesViewController.m
//  TrailBlaze
//
//  Created by Adam Issah on 7/6/22.
//

#import "MatesViewController.h"
#import "MateCell.h"
#import "Parse/Parse.h"
#import "ParseFetch.h"

@interface MatesViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
//@property (weak, nonatomic) NSArray *mates;

@end

@implementation MatesViewController {
    NSArray *mates;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"Mates";
    self.navigationController.navigationBar.prefersLargeTitles = YES;
    
//    [ParseFetch fetchMates:self];
    [self fetchMates];
    
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;

}

- (void) fetchMates{
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    [query orderByDescending:@"createdAt"];
//    [query whereKey:@"objectId" containedIn:[PFUser currentUser][@"friends"]];

        query.limit = 20;
    [query findObjectsInBackgroundWithBlock:^(NSArray *friends, NSError *error) {
        if (friends) {
//            [users fetchIfNeeded];
            self->mates = friends;
            [self.tableView reloadData];
            NSLog(@"%lu", (unsigned long)self->mates.count);
        } else {
            NSLog(@"%@", error.localizedDescription);
            NSLog(@"error");
        }
    }];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MateCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MateCell" forIndexPath:indexPath];
    NSDictionary *thisMate = self->mates[indexPath.row];
//    PFUser *thisMate = self.mates[indexPath.row];
    NSLog(@" 🥹🥹🥹🥹🥹%@", thisMate[@"friends"]);
//    [thisMate[@"username"] fetchIfNeeded];
    
    cell.profileName.text = thisMate[@"username"];
    if (thisMate[@"isRunning"] == NO) {
        cell.runningStatus.text = @"Inactive";
        cell.runningStatus.textColor = UIColor.grayColor;
    } else {
        cell.runningStatus.text = @"Running";
        cell.runningStatus.textColor = UIColor.greenColor;
    }
    
    cell.layer.cornerRadius = 30;
    cell.clipsToBounds = true;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self->mates.count;
//    return 10;
}
@end
