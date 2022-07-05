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
@property (weak, nonatomic) IBOutlet UIButton *signupButton;
@property UIAlertController *alert;

@end

@implementation LoginViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _usernameField.delegate = self;
    _passwordField.delegate = self;
    
    
    self.alert = [UIAlertController alertControllerWithTitle:@"Empty Fields" message:@"Please fill all fields" preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
    [self.alert addAction:okAction];
}

- (IBAction)didTapLogin:(id)sender {
    if ([_usernameField.text isEqual:@""] || [_passwordField.text isEqual:@""]) {
        [self presentViewController:self.alert animated:YES completion:^{}];
    } else {
        [self loginUser];
    }
}

- (IBAction)didTapSignup:(id)sender {
    [self performSegueWithIdentifier:@"registerViewControllerSegue" sender:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self didTapLogin:_loginButton];
    return YES;
}

- (void)loginUser {
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;

    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
        if (error != nil) {
            NSLog(@"User log in failed: %@", error.localizedDescription);
            [self performSegueWithIdentifier:@"registerViewControllerSegue" sender:nil];
        } else {
            NSLog(@"User logged in successfully");
            SceneDelegate *sceneDelegate = (SceneDelegate *)UIApplication.sharedApplication.connectedScenes.allObjects.firstObject.delegate;
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            HomeViewController *homeViewController = [storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
            sceneDelegate.window.rootViewController = homeViewController;
        }
    }];
}


@end
