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
#import "UIImageView+AFNetworking.h"
#import "Run.h"
#import "MateDetailViewController.h"
@interface MatesViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *findMatesButton;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation MatesViewController {
    NSArray *mates;
    NSMutableArray *filteredMates;
    BOOL isFiltered;
    PFUser *selectedMate;
}
-(void)viewWillAppear:(BOOL)animated {
     [super viewWillAppear:animated];
    [self fetchMates];
   
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"Mates";
    self.navigationController.navigationBar.prefersLargeTitles = YES;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchMates) forControlEvents:(UIControlEventValueChanged)];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
    self.searchBar.delegate = self;
    isFiltered = false;
    
    [self fetchMates];
    
}

- (void) fetchMates {
    [[[QueryManager alloc] init] queryMates:10 completion:^(NSArray * _Nonnull mates, NSError * _Nonnull err) {
        if (mates) {
            self->mates = mates;
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        } else {
            NSLog(@"Unable to get mates %@", err.localizedDescription);
        }
    }];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MateCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MateCell" forIndexPath:indexPath];

    PFUser *thisMateObject;
    if (isFiltered) {
        thisMateObject = filteredMates[indexPath.row];
    } else {
        thisMateObject = mates[indexPath.row];
    }
    
    cell.profileName.text = thisMateObject.username;
    NSLog(@"🐸🐸🐸🐸🐸🐸%@", thisMateObject);
    PFFileObject *image = [thisMateObject objectForKey:@"profileImage"];
    NSLog(@"%@",image.url);
    if (image) {
    [cell.profileImage setImageWithURL:[NSURL URLWithString:[image url]]];
    } else {
        [cell.profileImage setImage: [UIImage systemImageNamed:@"person.crop.circle"]];
    }
    cell.profileImage.layer.cornerRadius = 30;
    cell.profileImage.clipsToBounds = true;
    
    if (thisMateObject[@"isRunning"] == NO) {
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
    if (isFiltered) {
        return filteredMates.count;
    } else {
        return mates.count;
    }
}

- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        isFiltered = false;
    } else {
        isFiltered = true;
        filteredMates = [[NSMutableArray alloc] init];
        
        for (PFObject *user in mates) {
            NSRange nameRange = [user[@"username"] rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if (nameRange.location != NSNotFound) {
                [filteredMates addObject:user];
            }
        }
    }
    [self.tableView reloadData];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (isFiltered) {
        selectedMate = filteredMates[indexPath.row];
    } else {
        selectedMate = mates[indexPath.row];
    }
    [selectedMate fetchIfNeeded];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *ivc = [storyboard instantiateViewControllerWithIdentifier:@"MateDetailViewController"];
    MateDetailViewController *detailView = [[MateDetailViewController alloc] init];
    detailView.profileName.text = selectedMate.username;
    detailView.thisUser = selectedMate;
    [detailView presentViewController:ivc animated:YES completion:nil];
    
    NSLog(@"It's hitting log");
//    if (selectedMate[@"isRunning"]) {
//        [Run retreiveRun:(PFUser *) selectedMate withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
//            if (succeeded) {
//                NSLog(@"run retreived!");
//            } else {
//                NSLog(@"run not retreived");
//            }
//        }];
//    }

}

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    MateDetailViewController *detailView = [segue destinationViewController];
//    detailView.profileName.text = selectedMate.username;
//    detailView.thisUser = selectedMate;
//}
//#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation




@end
