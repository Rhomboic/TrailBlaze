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
#import "InterceptRequest.h"
#import "UIImageView+AFNetworking.h"
#import "ParseLiveQuery/ParseLiveQuery-umbrella.h"

@interface MateDetailViewController ()
@property (weak, nonatomic) IBOutlet UIButton *interceptButton;
@property (weak, nonatomic) IBOutlet UIImageView *profilePhoto;


@end

@implementation MateDetailViewController {
    PFLiveQueryClient *liveQueryClient;
    PFLiveQuerySubscription *liveQuerySubscription;
    PFQuery *approvalQuery;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self parseLiveQuerySetUp];
    self.profileName.text = _thisUser.username;
    PFFileObject *image = [_thisUser objectForKey:@"profileImage"];
    [_profilePhoto setImageWithURL:[NSURL URLWithString:[image url]]];
}

- (void) interceptDeclinedAlert {
    UIAlertController * alertvc = [UIAlertController alertControllerWithTitle: @ "Intercept Declined"
                                 message:@"They declines your request to intercept" preferredStyle: UIAlertControllerStyleAlert
                                ];
    UIAlertAction * okAction = [UIAlertAction actionWithTitle: @ "OK"
                            style: UIAlertActionStyleDefault handler: ^ (UIAlertAction * _Nonnull action) {
                              NSLog(@ "OK Tapped");
                            }
                           ];
    
    [alertvc addAction: okAction];
    [self presentViewController: alertvc animated: true completion: nil];
}

- (IBAction)didTapIntercept:(id)sender {
    //start activity indicator animation
    [InterceptRequest uploadRequest:PFUser.currentUser.objectId receiverID:_thisUser.objectId withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            NSLog(@"sent intercept request");
            
        } else {
            NSLog(@"failed to send intercept request");
        }
    }];
     
}

- (void) parseLiveQuerySetUp {
    NSString *path = [[NSBundle mainBundle] pathForResource: @"keys" ofType: @"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];

    NSString *appID = [dict objectForKey: @"appID"];
    NSString *clientKey = [dict objectForKey: @"clientKey"];
    liveQueryClient = [[PFLiveQueryClient alloc] initWithServer:@"https://tblaze.b4a.io" applicationId:appID clientKey:clientKey];
    approvalQuery = [PFQuery queryWithClassName:@"InterceptRequest"];
//    [approvalQuery whereKey:@"approved" equalTo: [NSNumber numberWithBool:YES]];
    [approvalQuery whereKey:@"requester" equalTo: PFUser.currentUser.objectId];
    liveQuerySubscription = [liveQueryClient subscribeToQuery:approvalQuery];
    __weak typeof(self) weakself = self;
    [liveQuerySubscription addUpdateHandler:^(PFQuery<PFObject *> * _Nonnull query, PFObject * _Nonnull object) {
        __strong typeof(self) strongself = weakself;
        ///delete interceptRequest after approval
        [object deleteInBackground];
        if ([object[@"approved"] boolValue] == YES) {
            [Run retreiveRunPolyline:strongself->_thisUser completion:^(MKPolyline * _Nonnull polyline, NSError * _Nullable err) {
               if (polyline) {
                   SceneDelegate *sceneDelegate = (SceneDelegate *)UIApplication.sharedApplication.connectedScenes.allObjects.firstObject.delegate;
                   UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                   UITabBarController *tabBarController = [storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
                   UINavigationController *navController = tabBarController.viewControllers[1];
                   HomeViewController *hvc = navController.childViewControllers[0];
                   hvc.cloudPolyline = polyline;
                   hvc.cloudUser = strongself->_thisUser;
                   [tabBarController setSelectedViewController: navController];
                   sceneDelegate.window.rootViewController = tabBarController;
                   NSLog(@"got run");
                   //stop activity indicator animation
               } else {
                   NSLog(@"did not get run");
               }
           }];
        } else if ([object[@"approved"] boolValue] == NO){
            //stop activity indicator animation
            dispatch_async(dispatch_get_main_queue(), ^{
            [strongself interceptDeclinedAlert];
            });
        }
    
    }];
}
@end
