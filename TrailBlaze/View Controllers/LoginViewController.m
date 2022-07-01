//
//  LoginViewController.m
//  TrailBlaze
//
//  Created by Adam Issah on 6/30/22.
//

#import "LoginViewController.h"
#import "SceneDelegate.h"
#import "Parse/Parse.h"
#import "HomeViewController.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation LoginViewController {
    BOOL _emptyField;
}

- (IBAction)didTapLogin:(id)sender {
    if ([_usernameField.text isEqual:@""] || [_passwordField.text isEqual:@""]) {
        _emptyField = YES;
    }
    
    [self loginUser];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (void)loginUser {
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;

    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
        if (error != nil && !_emptyField) {
            NSLog(@"User log in failed: %@", error.localizedDescription);
        } else
            NSLog(@"User logged in successfully");
            SceneDelegate *sceneDelegate = (SceneDelegate *)UIApplication.sharedApplication.connectedScenes.allObjects.firstObject.delegate;
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            HomeViewController *homeViewController = [storyboard instantiateViewControllerWithIdentifier:@"TabViewController"];
            sceneDelegate.window.rootViewController = homeViewController;

            
        }
    ];
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
