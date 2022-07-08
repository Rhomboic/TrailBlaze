//
//  MatesViewController.m
//  TrailBlaze
//
//  Created by Adam Issah on 7/6/22.
//

#import "MatesViewController.h"
#import "MateCell.h"
#import "Parse/Parse.h"

@interface MatesViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MatesViewController {
    NSArray *mates;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fetchMates];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;

}

- (void) fetchMates{
    PFQuery *query = [PFQuery queryWithClassName:@"User"];
    [query orderByDescending:@"createdAt"];
        query.limit = 20;
    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        if (users) {
//            [users fetchIfNeeded];
            self->mates = users;
            for (PFUser *p in self->mates) {
                NSLog(@"%@", p);
            }
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
    NSString *thisMate = self->mates[indexPath.row];
    cell.profileName.text = thisMate;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self->mates.count;
//    return 10;
}
@end
