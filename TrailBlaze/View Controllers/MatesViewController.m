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
@property (weak, nonatomic) IBOutlet UIBarButtonItem *findMatesButton;

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
    
    cell.layer.cornerRadius = 20;
    [cell.layer setBorderColor:[UIColor systemBackgroundColor].CGColor];
    [cell.layer setBorderWidth:5.0f];
    cell.clipsToBounds = true;
    cell.contentView.backgroundColor = UIColor.secondarySystemBackgroundColor;
   
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self->mates.count;
}


//#pragma mark - Navigation
//
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    NSIndexPath *indexPath = [self.movieCollView indexPathForCell:cell];
//
//    DetailsViewController *detailView = [segue destinationViewController];
//
//}




@end
