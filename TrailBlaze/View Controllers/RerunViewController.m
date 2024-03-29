//
//  RerunViewController.m
//  TrailBlaze
//
//  Created by Adam Issah on 8/3/22.
//

#import "RerunViewController.h"
#import "Run.h"
#import "RerunCell.h"
#import "SceneDelegate.h"
#import "HomeViewController.h"
#import "DGActivityIndicatorView/DGActivityIndicatorView.h"

@interface RerunViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) DGActivityIndicatorView *activityIndicator;



@end

@implementation RerunViewController {
    NSArray *pastRuns;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureActivityIndicator];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [[PFUser currentUser][@"pastRuns"] fetchIfNeeded];
    pastRuns = [PFUser currentUser][@"pastRuns"];
    
    PFFileObject *image = [PFUser.currentUser objectForKey:@"profileImage"];
    NSLog(@"%@",image.url);
    
    [Run retreiveRunObjects:PFUser.currentUser limit:20 completion:^(NSArray * _Nonnull runObjects, NSError * _Nullable err) {
        [self.activityIndicator stopAnimating];
        [self.activityIndicator setHidden:true];
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

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SceneDelegate *sceneDelegate = (SceneDelegate *)UIApplication.sharedApplication.connectedScenes.allObjects.firstObject.delegate;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UITabBarController *tabBarController = [storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
    UINavigationController *navController = tabBarController.viewControllers[1];
    HomeViewController *hvc = navController.childViewControllers[0];
    hvc.isRerun = true;
    hvc.isReadyToStartRun = true;
    hvc.runObject = pastRuns[indexPath.row];
    [tabBarController setSelectedViewController: navController];
    sceneDelegate.window.rootViewController = tabBarController;
}

- (void) configureActivityIndicator {
    _activityIndicator = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeBallScaleMultiple tintColor:[UIColor yellowColor] size:50.0f];
    _activityIndicator.frame = CGRectMake(self.view.center.x-25, self.view.center.y-25, 50.0f, 50.0f);
    [self.view addSubview:_activityIndicator];
    [_activityIndicator startAnimating];
}

@end
