//
//  RerunViewController.m
//  TrailBlaze
//
//  Created by Adam Issah on 8/3/22.
//

#import "RerunViewController.h"
#import "Run.h"
#import "RerunCell.h"

@interface RerunViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation RerunViewController {
    NSArray *pastRuns;
}
- (void) viewWillAppear:(BOOL)animated {
    [Run retreiveRunObjects:PFUser.currentUser limit:10 completion:^(NSArray * _Nonnull runObjects, NSError * _Nullable err) {
        if (runObjects) {
            self->pastRuns = runObjects;
            [self->_tableView reloadData];
        } else {
            NSLog(@"No past runs");
        }
    }];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    [[PFUser currentUser][@"pastRuns"] fetchIfNeeded];
    pastRuns = [PFUser currentUser][@"pastRuns"];
    
    PFFileObject *image = [PFUser.currentUser objectForKey:@"profileImage"];
    NSLog(@"%@",image.url);
    
    [Run retreiveRunObjects:PFUser.currentUser limit:20 completion:^(NSArray * _Nonnull runObjects, NSError * _Nullable err) {
        if (runObjects) {
            self->pastRuns = runObjects;
            [self->_tableView reloadData];
        } else {
            NSLog(@"No past runs");
        }
    }];
    
    
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    RerunCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RerunCell" forIndexPath:indexPath];
    if (pastRuns) {
        @try {
        cell.startLocationAddress.text = pastRuns[indexPath.row][@"startLocationAddress"];
        cell.endLocationAddress.text = pastRuns[indexPath.row][@"endLocationAddress"];
        cell.averagePace.text = pastRuns[indexPath.row][@"overallAveragePace"];
        }
        @catch (NSException * e) {
            
        }
        
        cell.layer.cornerRadius = 20;
        [cell.layer setBorderColor:[UIColor systemBackgroundColor].CGColor];
        [cell.layer setBorderWidth:5.0f];
        cell.clipsToBounds = true;
        cell.contentView.backgroundColor = UIColor.secondarySystemBackgroundColor;
    }
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return pastRuns.count;
}
@end
