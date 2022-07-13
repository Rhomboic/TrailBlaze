//
//  MatesViewController.m
//  TrailBlaze
//
//  Created by Adam Issah on 7/6/22.
//

#import "MatesViewController.h"
#import "MateCell.h"
#import "Parse/Parse.h"
#import "User.h"
#import "QueryManager.h"

@interface MatesViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MatesViewController {
    NSArray *mates;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"Mates";
    self.navigationController.navigationBar.prefersLargeTitles = YES;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [[[QueryManager alloc] init] queryMates:10 completion:^(NSArray * _Nonnull mates, NSError * _Nonnull err) {
        if (mates) {
            self->mates = mates;
            [self.tableView reloadData];
        } else {
            NSLog(@"Unable to get mates %@", err.localizedDescription);
        }
    }];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MateCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MateCell" forIndexPath:indexPath];

    User *thisMateObject = [[User alloc] initWithDictionary: self->mates[indexPath.row]];
    NSLog(@" 🥹🥹🥹🥹🥹%@", thisMateObject.friends);
    
    cell.profileName.text = thisMateObject.username;
    if (thisMateObject.isRunning == NO) {
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
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



@end
