//
//  MateDetailViewController.m
//  TrailBlaze
//
//  Created by Adam Issah on 7/18/22.
//

#import "MateDetailViewController.h"
#import "Run.h"
#import "SceneDelegate.h"
#import "HomeViewController.h"

@interface MateDetailViewController ()
@property (weak, nonatomic) IBOutlet UIButton *interceptButton;
@property (weak, nonatomic) IBOutlet UIImageView *profilePhoto;


@end

@implementation MateDetailViewController
- (IBAction)didTapIntercept:(id)sender {
     [Run retreiveRun:self.thisUser completion:^(MKPolyline * _Nonnull polyline, NSError * _Nullable err) {
        if (polyline) {
            SceneDelegate *sceneDelegate = (SceneDelegate *)UIApplication.sharedApplication.connectedScenes.allObjects.firstObject.delegate;
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UITabBarController *tabBarController = [storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
            UINavigationController *navController = tabBarController.viewControllers[1];
            HomeViewController *hvc = navController.childViewControllers[0];
            hvc.cloudPolyline = polyline;
            [tabBarController setSelectedViewController: navController];
            sceneDelegate.window.rootViewController = tabBarController;
            NSLog(@"got run");
            
        } else {
            NSLog(@"did not get run");
        }
    }];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.profileName.text = _thisUser.username;
}
//
//- (void) saveCloudRoute  {
//    [self.delegate sendPolylineToHomeVC:downloadedLine];
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
