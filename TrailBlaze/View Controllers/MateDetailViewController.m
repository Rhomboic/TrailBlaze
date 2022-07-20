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
#import "UIImageView+AFNetworking.h"

@interface MateDetailViewController ()
@property (weak, nonatomic) IBOutlet UIButton *interceptButton;
@property (weak, nonatomic) IBOutlet UIImageView *profilePhoto;


@end

@implementation MateDetailViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.profileName.text = _thisUser.username;
    PFFileObject *image = [_thisUser objectForKey:@"profileImage"];
    [_profilePhoto setImageWithURL:[NSURL URLWithString:[image url]]];
}

- (IBAction)didTapIntercept:(id)sender {
     [Run retreiveRunPolyline:_thisUser completion:^(MKPolyline * _Nonnull polyline, NSError * _Nullable err) {
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
@end
